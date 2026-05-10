import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/post_model.dart';
import '../models/comment_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _posts    => _db.collection('posts');
  CollectionReference<Map<String, dynamic>> get _comments => _db.collection('comments');

  // ── Posts ──────────────────────────────────────────────────────────────────
  Stream<List<PostModel>> getPostsStream() {
    return _posts
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => PostModel.fromFirestore(d)).toList());
  }

  Stream<List<PostModel>> getPostsByTagStream(String tag) {
    if (tag == 'All') return getPostsStream();
    return _posts
        .where('tags', arrayContains: tag)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => PostModel.fromFirestore(d)).toList());
  }

  Future<void> createPost(PostModel post) async => _posts.add(post.toMap());

  Future<List<PostModel>> getPostsByUser(String userId) async {
    final snap = await _posts
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .get();
    return snap.docs.map((d) => PostModel.fromFirestore(d)).toList();
  }

  // ── Likes ──────────────────────────────────────────────────────────────────
  Future<void> toggleLike({
    required String postId,
    required String userId,
    required bool isCurrentlyLiked,
  }) async {
    final ref = _posts.doc(postId);
    await _db.runTransaction((tx) async {
      final snap = await tx.get(ref);
      if (!snap.exists) return;
      final data    = snap.data()!;
      final likedBy = List<String>.from(data['likedBy'] ?? []);
      final cur     = (data['likes'] ?? 0) as int;
      if (isCurrentlyLiked) {
        likedBy.remove(userId);
        tx.update(ref, {'likedBy': likedBy, 'likes': (cur - 1).clamp(0, 9999999)});
      } else {
        if (!likedBy.contains(userId)) {
          likedBy.add(userId);
          tx.update(ref, {'likedBy': likedBy, 'likes': cur + 1});
        }
      }
    });
  }

  // ── Comments — NO orderBy to avoid needing a composite index ──────────────
  // Sorting is done in Dart after fetching — instant response, no index needed
  Stream<List<CommentModel>> getCommentsStream(String postId) {
    return _comments
        .where('postId', isEqualTo: postId)
        .snapshots()
        .map((s) {
          final list = s.docs.map((d) => CommentModel.fromFirestore(d)).toList();
          // Sort by timestamp ascending in Dart — no Firestore index required
          list.sort((a, b) => a.timestamp.compareTo(b.timestamp));
          return list;
        });
  }

  Future<void> addComment(CommentModel comment) async {
    // Simple add — no transaction needed, faster response
    final commentRef = await _comments.add(comment.toMap());
    // Update comment count separately
    await _posts.doc(comment.postId).update({
      'comments': FieldValue.increment(1),
    });
  }

  Future<void> deleteComment({
    required String commentId,
    required String postId,
  }) async {
    await _comments.doc(commentId).delete();
    await _posts.doc(postId).update({
      'comments': FieldValue.increment(-1),
    });
  }
}
