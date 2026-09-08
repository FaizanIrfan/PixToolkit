import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pixtoolkit/core/services/image_processor.dart';
import 'package:pixtoolkit/core/services/picker_service.dart';
import 'package:pixtoolkit/core/services/file_manager.dart';
import 'package:pixtoolkit/shared/theme/app_theme.dart';

class CompressScreen extends StatefulWidget {
  const CompressScreen({super.key});

  @override
  State<CompressScreen> createState() => _CompressScreenState();
}

class _CompressScreenState extends State<CompressScreen> {
  Uint8List? _originalImageBytes;
  Uint8List? _compressedImageBytes;
  int _quality = 80;
  bool _isLoading = false;
  Map<String, dynamic>? _originalInfo;
  Map<String, dynamic>? _compressedInfo;

  Future<void> _pickImage() async {
    setState(() => _isLoading = true);
    try {
      final bytes = await PickerService.pickImageFromGallery();
      if (bytes != null) {
        setState(() {
          _originalImageBytes = bytes;
          _compressedImageBytes = bytes;
          _originalInfo = ImageProcessor.getImageInfo(bytes);
          _compressedInfo = _originalInfo;
          _quality = 80;
        });
        await _compressImage();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _compressImage() async {
    if (_originalImageBytes == null) return;
    
    setState(() => _isLoading = true);
    try {
      final compressed = await ImageProcessor.compressImage(
        imageBytes: _originalImageBytes!,
        quality: _quality,
      );
      if (mounted) {
        setState(() {
          _compressedImageBytes = compressed;
          _compressedInfo = ImageProcessor.getImageInfo(compressed);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error compressing image: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _saveAndShare() async {
    if (_compressedImageBytes == null) return;
    
    try {
      final file = await FileManager.saveImage(
        imageBytes: _compressedImageBytes!,
        fileName: FileManager.generateUniqueFilename(originalName: 'compressed.jpg'),
        subDirectory: 'PixToolkit_Compressed',
      );
      
      await Share.shareXFiles([XFile(file.path)], text: 'Compressed with PixToolkit');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving/sharing: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Compress Image'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _originalImageBytes == null
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.image_outlined,
                      size: 80,
                      color: AppTheme.primaryColor.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 16),
                    Text('No image selected', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _pickImage,
                      icon: const Icon(Icons.add_photo_alternate),
                      label: const Text('Select Image'),
                    ),
                  ],
                ),
              )
            : Column(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              const Text('Original', style: TextStyle(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.memory(_originalImageBytes!, fit: BoxFit.cover),
                                ),
                              ),
                              const SizedBox(height: 8),
                              if (_originalInfo != null)
                                Text('${_originalInfo!['sizeKB']} KB', style: const TextStyle(fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            children: [
                              const Text('Compressed', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.successColor)),
                              const SizedBox(height: 8),
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: _isLoading
                                      ? const Center(child: CircularProgressIndicator())
                                      : Image.memory(_compressedImageBytes!, fit: BoxFit.cover),
                                ),
                              ),
                              const SizedBox(height: 8),
                              if (_compressedInfo != null)
                                Text('${_compressedInfo!['sizeKB']} KB', style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.successColor)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Quality', style: TextStyle(fontWeight: FontWeight.bold)),
                              Text('$_quality%', style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
                            ],
                          ),
                          Slider(
                            value: _quality.toDouble(),
                            min: 10,
                            max: 100,
                            divisions: 18,
                            label: '$_quality%',
                            onChanged: (value) {
                              setState(() => _quality = value.toInt());
                            },
                            onChangeEnd: (value) {
                              _compressImage();
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _pickImage,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Change Image'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _saveAndShare,
                          icon: const Icon(Icons.share),
                          label: const Text('Save & Share'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }
}