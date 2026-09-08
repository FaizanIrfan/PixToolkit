import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';

class PickerService {
  static final ImagePicker _picker = ImagePicker();

  /// Pick an image from gallery
  static Future<Uint8List?> pickImageFromGallery() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 100,
    );
    if (image != null) {
      return await image.readAsBytes();
    }
    return null;
  }

  /// Pick an image from camera
  static Future<Uint8List?> pickImageFromCamera() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 100,
    );
    if (image != null) {
      return await image.readAsBytes();
    }
    return null;
  }
}