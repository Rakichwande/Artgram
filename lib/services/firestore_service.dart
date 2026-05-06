import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/post_model.dart';

/// Wraps all Firestore database operations.
/// Swap these method bodies for HTTP calls when migrating to FastAPI.
class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── Collection reference ───────────────────────────────────────────────
  CollectionReference<Map<String, dynamic>> get _posts =>
      _db.collection('posts');

  // ── Real-time feed stream ──────────────────────────────────────────────
  /// Returns a live stream of posts ordered by newest first.
  Stream<List<PostModel>> getPostsStream() {
    return _posts
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => PostModel.fromFirestore(doc)).toList());
  }

  // ── Create a new post ──────────────────────────────────────────────────
  Future<void> createPost(PostModel post) async {
    await _posts.add(post.toMap());
  }

  // ── Toggle like on a post ──────────────────────────────────────────────
  Future<void> toggleLike({
    required String postId,
    required String userId,
    required bool isCurrentlyLiked,
  }) async {
    final ref = _posts.doc(postId);
    await _db.runTransaction((transaction) async {
      final snapshot = await transaction.get(ref);
      if (!snapshot.exists) return;
      final currentLikes = (snapshot.data()?['likes'] ?? 0) as int;
      final newLikes = isCurrentlyLiked
          ? (currentLikes - 1).clamp(0, 9999999)
          : currentLikes + 1;
      transaction.update(ref, {'likes': newLikes});
    });
  }

  // ── Delete a post ──────────────────────────────────────────────────────
  Future<void> deletePost(String postId) async {
    await _posts.doc(postId).delete();
  }

  // ── Get posts by a specific user ───────────────────────────────────────
  Future<List<PostModel>> getPostsByUser(String userId) async {
    final snapshot = await _posts
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .get();
    return snapshot.docs.map((doc) => PostModel.fromFirestore(doc)).toList();
  }
}