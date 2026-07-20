import 'dart:typed_data';
import 'package:cloudinary_public/cloudinary_public.dart';

class CloudinaryService {
  final CloudinaryPublic _cloudinary;

  // Cloudinary credentials
  static const String _cloudName = 'l8oqc2v3';
  static const String _uploadPreset = 'quiz_app_upload'; // You need to create this in Cloudinary dashboard

  CloudinaryService()
      : _cloudinary = CloudinaryPublic(
          _cloudName,
          _uploadPreset,
          cache: true,
        );

  /// Upload image bytes to Cloudinary
  /// Returns the secure URL of the uploaded image
  Future<String> uploadImage({
    required Uint8List imageBytes,
    required String folder,
    String? publicId,
  }) async {
    try {
      final response = await _cloudinary.uploadFile(
        CloudinaryFile.fromBytesData(
          imageBytes,
          identifier: publicId ?? 'quiz_cover_${DateTime.now().millisecondsSinceEpoch}.jpg',
          folder: folder,
          resourceType: CloudinaryResourceType.Image,
        ),
      );
      return response.secureUrl;
    } catch (e) {
      throw Exception('Failed to upload image to Cloudinary: $e');
    }
  }

  /// Upload image from file path (for mobile only)
  Future<String> uploadImageFromFile({
    required String filePath,
    required String folder,
    String? publicId,
  }) async {
    try {
      final response = await _cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          filePath,
          identifier: publicId ?? 'quiz_cover_${DateTime.now().millisecondsSinceEpoch}.jpg',
          folder: folder,
          resourceType: CloudinaryResourceType.Image,
        ),
      );
      return response.secureUrl;
    } catch (e) {
      throw Exception('Failed to upload image to Cloudinary: $e');
    }
  }

  /// Get optimized image URL with transformations
  String getOptimizedUrl(String originalUrl, {int? width, int? height}) {
    return CloudinaryImage(originalUrl)
        .transform()
        .width(width ?? 800)
        .height(height ?? 600)
        .quality('auto')
        .toString();
  }
}
