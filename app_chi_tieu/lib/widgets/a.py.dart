import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: OCRScreen(),
  ));
}
class OCRScreen extends StatefulWidget {
  @override
  _OCRScreenState createState() => _OCRScreenState();
}
class _OCRScreenState extends State<OCRScreen> {
  String recognizedText = '';

  Future<void> _pickImageAndRecognizeText() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    final inputImage = InputImage.fromFilePath(pickedFile.path);

    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    final RecognizedText result = await textRecognizer.processImage(inputImage);

    String text = result.text;

    setState(() {
      recognizedText = text;
    });

    textRecognizer.close();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('OCR Hóa đơn')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _pickImageAndRecognizeText,
              child: Text('Chụp ảnh hóa đơn'),
            ),
            SizedBox(height: 20),
            Text(
              'Văn bản nhận dạng:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: SelectableText(recognizedText),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
