import 'dart:typed_data';
import 'dart:math';
import 'package:image/image.dart' as img;

class ImageProcessor {
  static Future<Uint8List> compressImage({
    required Uint8List imageBytes,
    required int quality,
    String format = 'jpg',
  }) async {
    final image = img.decodeImage(imageBytes);
    if (image == null) return imageBytes;
    
    final formatLower = format.toLowerCase();
    if (formatLower == 'jpg' || formatLower == 'jpeg') {
      return Uint8List.fromList(img.encodeJpg(image, quality: quality));
    } else if (formatLower == 'png') {
      return Uint8List.fromList(img.encodePng(image, level: (100 - quality) ~/ 10));
    } else if (formatLower == 'webp') {
      // Fallback to PNG/JPG or use standard encode if available, avoiding undefined function error
      return Uint8List.fromList(img.encodeJpg(image, quality: quality));
    }
    return imageBytes;
  }

  static Future<Uint8List> resizeImage({
    required Uint8List imageBytes,
    required int width,
    required int height,
    bool maintainAspectRatio = false,
  }) async {
    final image = img.decodeImage(imageBytes);
    if (image == null) return imageBytes;
    
    img.Image resized;
    if (maintainAspectRatio) {
      final ratio = image.width / image.height;
      int newWidth, newHeight;
      if (width / height > ratio) {
        newHeight = height;
        newWidth = (height * ratio).toInt();
      } else {
        newWidth = width;
        newHeight = (width / ratio).toInt();
      }
      resized = img.copyResize(image, width: newWidth, height: newHeight);
    } else {
      resized = img.copyResize(image, width: width, height: height);
    }
    return Uint8List.fromList(img.encodeJpg(resized));
  }

  static Future<Uint8List> cropImage({
    required Uint8List imageBytes,
    required int x,
    required int y,
    required int width,
    required int height,
  }) async {
    final image = img.decodeImage(imageBytes);
    if (image == null) return imageBytes;
    
    final cropped = img.copyCrop(image, x: x, y: y, width: width, height: height);
    return Uint8List.fromList(img.encodeJpg(cropped));
  }

  static Future<Uint8List> convertImageFormat({
    required Uint8List imageBytes,
    required String targetFormat,
    int quality = 85,
  }) async {
    final image = img.decodeImage(imageBytes);
    if (image == null) return imageBytes;
    
    final format = targetFormat.toLowerCase();
    if (format == 'jpg' || format == 'jpeg') return Uint8List.fromList(img.encodeJpg(image, quality: quality));
    if (format == 'png') return Uint8List.fromList(img.encodePng(image));
    if (format == 'webp') return Uint8List.fromList(img.encodeJpg(image, quality: quality));
    return imageBytes;
  }

  static Future<Uint8List> reduceToTargetSize({
    required Uint8List imageBytes,
    required int targetKB,
    String format = 'jpg',
    int minQuality = 30,
    int minDimension = 300,
  }) async {
    final image = img.decodeImage(imageBytes);
    if (image == null) return imageBytes;
    
    var currentBytes = imageBytes;
    var currentImage = image;
    var currentQuality = 85;
    var currentWidth = image.width;
    var currentHeight = image.height;
    
    while (currentBytes.lengthInBytes > targetKB * 1024 && currentQuality > minQuality) {
      currentQuality -= 5;
      currentBytes = await compressImage(imageBytes: Uint8List.fromList(img.encodeJpg(currentImage)), quality: currentQuality, format: format);
      if (currentBytes.lengthInBytes <= targetKB * 1024) return currentBytes;
    }
    
    var scaleFactor = 0.9;
    while (currentBytes.lengthInBytes > targetKB * 1024 && currentWidth > minDimension && currentHeight > minDimension) {
      currentWidth = (currentWidth * scaleFactor).toInt();
      currentHeight = (currentHeight * scaleFactor).toInt();
      final resized = img.copyResize(currentImage, width: currentWidth, height: currentHeight);
      currentBytes = await compressImage(imageBytes: Uint8List.fromList(img.encodeJpg(resized)), quality: max(minQuality, currentQuality), format: format);
      currentImage = resized;
      scaleFactor = max(0.5, scaleFactor - 0.1);
      if (currentBytes.lengthInBytes <= targetKB * 1024) return currentBytes;
    }
    return currentBytes;
  }

  static Map<String, dynamic> getImageInfo(Uint8List imageBytes) {
    final image = img.decodeImage(imageBytes);
    if (image == null) return {'width': 0, 'height': 0, 'sizeKB': '0.00', 'format': 'unknown'};
    return {
      'width': image.width,
      'height': image.height,
      'sizeKB': (imageBytes.lengthInBytes / 1024).toStringAsFixed(2),
      'format': detectFormat(imageBytes)
    };
  }

  static String detectFormat(Uint8List bytes) {
    if (bytes.length < 12) return 'unknown';
    if (bytes[0] == 0xFF && bytes[1] == 0xD8 && bytes[2] == 0xFF) return 'jpg';
    if (bytes[0] == 0x89 && bytes[1] == 0x50 && bytes[2] == 0x4E && bytes[3] == 0x47) return 'png';
    if (bytes[0] == 0x52 && bytes[1] == 0x49 && bytes[2] == 0x46 && bytes[3] == 0x46 && bytes[8] == 0x57 && bytes[9] == 0x45 && bytes[10] == 0x42 && bytes[11] == 0x50) return 'webp';
    return 'unknown';
  }
}