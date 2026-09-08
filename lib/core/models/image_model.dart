class ProcessedImage {
  final String id;
  final String name;
  final String originalPath;
  final List<int> bytes;
  final int fileSize; // in bytes
  final DateTime processedAt;
  final String format;
  final Map<String, dynamic>? metadata;

  ProcessedImage({
    required this.id,
    required this.name,
    required this.originalPath,
    required this.bytes,
    required this.fileSize,
    required this.processedAt,
    required this.format,
    this.metadata,
  });

  String get fileSizeFormatted {
    if (fileSize < 1024) return '$fileSize B';
    if (fileSize < 1024 * 1024) return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  double get compressionRatio {
    // To be calculated based on original size
    return 1.0;
  }
}

class ProcessingOptions {
  final int? quality;
  final int? targetWidth;
  final int? targetHeight;
  final String? targetFormat;
  final int? targetSizeKB;
  final Map<String, dynamic>? cropOptions;

  ProcessingOptions({
    this.quality,
    this.targetWidth,
    this.targetHeight,
    this.targetFormat,
    this.targetSizeKB,
    this.cropOptions,
  });
}