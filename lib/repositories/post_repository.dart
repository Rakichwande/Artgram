import '../models/post_model.dart';
import '../models/comment_model.dart';
import '../services/firestore_service.dart';
import '../services/storage_service.dart';
import 'dart:io';

class PostRepository {
  final FirestoreService _firestore;
  final StorageService   _storage;

  PostRepository({
    FirestoreService? firestore,
    StorageService?   storage,
  })  : _firestore = firestore ?? FirestoreService(),
        _storage   = storage   ?? StorageService();

  // ── Feed ──────────────────────────────────────────────────────────────────
  Stream<List<PostModel>> getPostsStream()             => _firestore.getPostsStream();
  Stream<List<PostModel>> getPostsByTagStream(String t) => _firestore.getPostsByTagStream(t);
  Future<List<PostModel>> getPostsByUser(String uid)   => _firestore.getPostsByUser(uid);

  // ── Create post ───────────────────────────────────────────────────────────
  Future<UploadResult> createPost({
    required File         imageFile,
    required String       caption,
    required String       userId,
    required String       username,
    required String       avatarInitials,
    required List<String> tags,
  }) async {
    final storageResult = await _storage.uploadImage(
      userId: userId, imageFile: imageFile,
    );
    if (!storageResult.isSuccess) {
      return UploadResult.failure(storageResult.errorMessage ?? 'Upload failed.');
    }

    final post = PostModel(
      id:             '',
      userId:         userId,
      username:       username,
      avatarInitials: avatarInitials,
      imageUrl:       storageResult.downloadUrl!,
      caption:        caption,
      likes:          0,
      comments:       0,
      timestamp:      DateTime.now(),
      tags:           tags,
      likedBy:        [],
    );

    try {
      await _firestore.createPost(post);
      return UploadResult.success();
    } catch (e) {
      return UploadResult.failure('Failed to save post. Please try again.');
    }
  }

  // ── Likes ─────────────────────────────────────────────────────────────────
  Future<void> toggleLike({
    required String postId,
    required String userId,
    required bool   isCurrentlyLiked,
  }) =>
      _firestore.toggleLike(
        postId: postId, userId: userId, isCurrentlyLiked: isCurrentlyLiked,
      );

  // ── Comments ──────────────────────────────────────────────────────────────
  Stream<List<CommentModel>> getCommentsStream(String postId) =>
      _firestore.getCommentsStream(postId);

  Future<void> addComment(CommentModel comment) =>
      _firestore.addComment(comment);

  Future<void> deleteComment({required String commentId, required String postId}) =>
      _firestore.deleteComment(commentId: commentId, postId: postId);
}

class UploadResult {
  final bool isSuccess;
  final String? errorMessage;
  const UploadResult._({required this.isSuccess, this.errorMessage});
  factory UploadResult.success()               => const UploadResult._(isSuccess: true);
  factory UploadResult.failure(String message) => UploadResult._(isSuccess: false, errorMessage: message);
}
