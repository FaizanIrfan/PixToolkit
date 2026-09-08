class AppConstants {
  // App Info
  static const String appName = 'PixToolkit';
  static const String appTagline = 'Smart Image Toolkit';
  static const String version = '1.0.0';
  
  // Storage Paths
  static const String processedImagesDir = 'PixToolkit/Processed';
  
  // Default Values
  static const int defaultCompressionQuality = 85;
  static const int maxImageWidth = 4096;
  static const int maxImageHeight = 4096;
  static const int maxFileSizeMB = 50;
  
  // Feature Presets
  static const Map<String, double> cropPresets = {
    'Square (1:1)': 1.0,
    'Landscape (4:3)': 4 / 3,
    'Widescreen (16:9)': 16 / 9,
    'Portrait (9:16)': 9 / 16,
    'Custom': 0,
  };
  
  static const List<String> formatOptions = ['JPG', 'PNG', 'WEBP'];
  
  static const Map<String, List<int>> commonSizes = {
    'Instagram Post': [1080, 1080],
    'Facebook Cover': [820, 312],
    'Twitter Header': [1500, 500],
    'LinkedIn Post': [1200, 627],
    'HD (1920x1080)': [1920, 1080],
    'Full HD (3840x2160)': [3840, 2160],
  };
  
  // Animation Durations
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration snackbarDuration = Duration(seconds: 3);
}