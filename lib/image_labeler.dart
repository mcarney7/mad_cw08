import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';

class ImageLabelingScreen extends StatefulWidget {
  const ImageLabelingScreen({Key? key}) : super(key: key);

  @override
  State<ImageLabelingScreen> createState() => _ImageLabelingScreenState();
}

class _ImageLabelingScreenState extends State<ImageLabelingScreen> {
  Uint8List? _imageBytes;
  List<ImageLabel> _labels = [];
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _imageBytes = bytes;
      });
      _labelImage(pickedFile.path);
    }
  }

  Future<void> _labelImage(String imagePath) async {
    final inputImage = InputImage.fromFilePath(imagePath);
    final ImageLabeler labeler = ImageLabeler(options: ImageLabelerOptions());
    final List<ImageLabel> labels = await labeler.processImage(inputImage);

    setState(() {
      _labels = labels;
    });

    labeler.close();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Image Labeling')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () => _pickImage(ImageSource.camera),
              child: const Text('Capture Image'),
            ),
            ElevatedButton(
              onPressed: () => _pickImage(ImageSource.gallery),
              child: const Text('Select from Gallery'),
            ),
            if (_imageBytes != null) ...[
              const SizedBox(height: 16),
              Image.memory(_imageBytes!), // Use Image.memory for compatibility
              const SizedBox(height: 16),
              const Text('Detected Labels:', style: TextStyle(fontSize: 18)),
              Expanded(
                child: ListView.builder(
                  itemCount: _labels.length,
                  itemBuilder: (context, index) {
                    final label = _labels[index];
                    return ListTile(
                      title: Text(label.label),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
