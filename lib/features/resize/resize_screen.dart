import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pixtoolkit/core/services/image_processor.dart';
import 'package:pixtoolkit/core/services/picker_service.dart';
import 'package:pixtoolkit/core/services/file_manager.dart';

class ResizeScreen extends StatefulWidget {
  const ResizeScreen({super.key});

  @override
  State<ResizeScreen> createState() => _ResizeScreenState();
}

class _ResizeScreenState extends State<ResizeScreen> {
  Uint8List? _originalBytes;
  Uint8List? _resizedBytes;
  int _width = 1080;
  int _height = 1080;
  final bool _maintainAspectRatio = true;
  double _aspectRatio = 1.0;
  bool _isLoading = false;

  Future<void> _pickImage() async {
    setState(() => _isLoading = true);
    try {
      final bytes = await PickerService.pickImageFromGallery();
      if (bytes != null) {
        final info = ImageProcessor.getImageInfo(bytes);
        final w = (info['width'] as int) > 0 ? info['width'] as int : 1080;
        final h = (info['height'] as int) > 0 ? info['height'] as int : 1080;
        setState(() {
          _originalBytes = bytes;
          _resizedBytes = bytes;
          _width = w;
          _height = h;
          _aspectRatio = w / h;
        });
        await _resizeImage();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _resizeImage() async {
    if (_originalBytes == null) return;
    setState(() => _isLoading = true);
    try {
      final resized = await ImageProcessor.resizeImage(
        imageBytes: _originalBytes!,
        width: _width,
        height: _height,
        maintainAspectRatio: _maintainAspectRatio,
      );
      if (mounted) setState(() => _resizedBytes = resized);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveAndShare() async {
    if (_resizedBytes == null) return;
    try {
      final file = await FileManager.saveImage(
        imageBytes: _resizedBytes!,
        fileName: FileManager.generateUniqueFilename(originalName: 'resized.jpg'),
        subDirectory: 'PixToolkit_Resized',
      );
      await Share.shareXFiles([XFile(file.path)], text: 'Resized with PixToolkit');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }