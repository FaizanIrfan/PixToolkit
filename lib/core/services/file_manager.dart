import 'dart:io';
import 'dart:typed_data';
import 'dart:math';

import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';

class FileManager {
  static final Uuid _uuid = Uuid();

  /// Get application documents directory
  static Future<Directory> get appDocumentsDir async {
    return await getApplicationDocumentsDirectory();
  }

  /// Get temporary directory
  static Future<Directory> get tempDir async {
    return await getTemporaryDirectory();
  }

  /// Save image bytes to file
  static Future<File> saveImage({
    required Uint8List imageBytes,
    required String fileName,
    String? subDirectory,
  }) async {
    final dir = await appDocumentsDir;
    Directory targetDir = dir;

    if (subDirectory != null) {
      targetDir = Directory(path.join(dir.path, subDirectory));
      if (!await targetDir.exists()) {
        await targetDir.create(recursive: true);
      }
    }

    final file = File(path.join(targetDir.path, fileName));
    await file.writeAsBytes(imageBytes);
    return file;
  }

  /// Generate unique filename with timestamp
  static String generateUniqueFilename({
    required String originalName,
    String format = 'jpg',
  }) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final uuid = _uuid.v4().substring(0, 8);
    final ext = format.toLowerCase();
    
    final nameWithoutExt = path.basenameWithoutExtension(originalName);
    return '${nameWithoutExt}_${timestamp}_$uuid.$ext';
  }

  /// Get file size in readable format
  static String getFileSize(File file) {
    final bytes = file.lengthSync();
    if (bytes <= 0) return '0 B';
    
    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
    final i = (log(bytes) / log(1024)).floor();
    
    return '${(bytes / pow(1024, i)).toStringAsFixed(i > 0 ? 2 : 0)} ${suffixes[i]}';
  }

  /// Get file size in bytes
  static int getFileSizeBytes(File file) {
    return file.lengthSync();
  }

  /// Check if file exists
  static Future<bool> fileExists(String filePath) async {
    final file = File(filePath);
    return await file.exists();
  }

  /// Delete file
  static Future<void> deleteFile(String filePath) async {
    final file = File(filePath);
    if (await file.exists()) {
      await file.delete();
    }
  }

  /// Clean up temporary files
  static Future<void> cleanupTempFiles() async {
    try {
      final tempDir = await getTemporaryDirectory();
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    } catch (e) {
      // Ignore cleanup errors
    }
  }

  /// Get all files in directory
  static Future<List<File>> getFilesInDirectory({
    required String directoryPath,
    List<String> extensions = const ['jpg', 'jpeg', 'png', 'webp', 'gif'],
  }) async {
    final dir = Directory(directoryPath);
    if (!await dir.exists()) return [];

    final files = await dir.list().where((entity) {
      return entity is File &&
          extensions.any((ext) =>
              entity.path.toLowerCase().endsWith('.$ext'));
    }).toList();

    return files.cast<File>();
  }

  /// Copy file to another location
  static Future<File> copyFile({
    required File source,
    required String destinationPath,
  }) async {
    return await source.copy(destinationPath);
  }

  /// Read file as bytes
  static Future<Uint8List> readFileAsBytes(File file) async {
    return await file.readAsBytes();
  }

  /// Get file extension
  static String getFileExtension(String filePath) {
    return path.extension(filePath).toLowerCase().replaceFirst('.', '');
  }

  /// Get file name without extension
  static String getFileNameWithoutExtension(String filePath) {
    return path.basenameWithoutExtension(filePath);
  }
}