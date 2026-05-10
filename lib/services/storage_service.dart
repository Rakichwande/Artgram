import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/api_config.dart';

/// Uploads images to FastAPI server instead of Firebase Storage.
/// 
/// Phase 1B: POST multipart image → FastAPI → returns URL
/// Phase 2:  This file stays the same (already using FastAPI)
class StorageService {

  Future<StorageResult> uploadImage({
    required String userId,
    required File   imageFile,
  }) async {
    try {
      // Build multipart request
      final request = http.MultipartRequest(
        'POST',
        Uri.parse(ApiConfig.uploadEndpoint),
      );

      // Attach image file
      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          imageFile.path,
        ),
      );

      // Add user ID as header for future auth use
      request.headers['X-User-Id'] = userId;

      // Send request
      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 30),
      );
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201) {
        final data       = jsonDecode(response.body) as Map<String, dynamic>;
        final imagePath  = data['image_url'] as String;

        // Build full URL from the relative path FastAPI returns
        final fullUrl = '${ApiConfig.baseUrl}$imagePath';

        return StorageResult.success(fullUrl);
      } else {
        final data    = jsonDecode(response.body) as Map<String, dynamic>;
        final detail  = data['detail'] ?? 'Upload failed (${response.statusCode})';
        return StorageResult.failure(detail.toString());
      }
    } on SocketException {
      return StorageResult.failure(
        'Cannot reach server. Make sure FastAPI is running and your IP in api_config.dart is correct.',
      );
    } catch (e) {
      return StorageResult.failure('Upload error: ${e.toString()}');
    }
  }
}

class StorageResult {
  final bool    isSuccess;
  final String? downloadUrl;
  final String? errorMessage;

  const StorageResult._({required this.isSuccess, this.downloadUrl, this.errorMessage});

  factory StorageResult.success(String url) =>
      StorageResult._(isSuccess: true, downloadUrl: url);

  factory StorageResult.failure(String msg) =>
      StorageResult._(isSuccess: false, errorMessage: msg);
}
