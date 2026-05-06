import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

/// Wraps Firebase Storage for image uploads.
/// Replace uploadImage() body with an HTTP multipart call for FastAPI migration.
class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final _uuid = const Uuid();

  /// Uploads a local image file and returns the public download URL.
  /// [userId]    — used to organise files by user in storage
  /// [imageFile] — the local File selected by image_picker
  Future<StorageResult> uploadImage({
    required String userId,
    required File imageFile,
  }) async {
    try {
      // Create a unique filename: posts/userId/uuid.jpg
      final fileName = '${_uuid.v4()}.jpg';
      final ref = _storage.ref().child('posts/$userId/$fileName');

      // Upload with metadata
      final uploadTask = ref.putFile(
        imageFile,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      // Wait for completion
      final snapshot = await uploadTask;

      // Get public URL
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return StorageResult.success(downloadUrl);
    } on FirebaseException catch (e) {
      return StorageResult.failure(
        e.message ?? 'Upload failed. Please try again.',
      );
    } catch (e) {
      return StorageResult.failure('An unexpected error occurred during upload.');
    }
  }

  /// Delete an image from storage by its URL
  Future<void> deleteImage(String imageUrl) async {
    try {
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
    } catch (_) {
      // Silently fail — the post may already be deleted
    }
  }
}

// ── Result wrapper ────────────────────────────────────────────────────────────
class StorageResult {
  final bool isSuccess;
  final String? downloadUrl;
  final String? errorMessage;

  const StorageResult._({
    required this.isSuccess,
    this.downloadUrl,
    this.errorMessage,
  });

  factory StorageResult.success(String url) =>
      StorageResult._(isSuccess: true, downloadUrl: url);

  factory StorageResult.failure(String message) =>
      StorageResult._(isSuccess: false, errorMessage: message);
}