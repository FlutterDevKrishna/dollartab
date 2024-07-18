import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../constants.dart';

class FeedbackSection extends StatefulWidget {
  const FeedbackSection({Key? key}) : super(key: key);

  @override
  _FeedbackSectionState createState() => _FeedbackSectionState();
}

class _FeedbackSectionState extends State<FeedbackSection> {
  late bool _isSending;
  late File _imageFile;
  late TextEditingController _titleController;
  late TextEditingController _textController;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _isSending = false;
    _imageFile = File(''); // Initialize with an empty file
    _titleController = TextEditingController();
    _textController = TextEditingController();
  }

  Future<void> _getImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _sendFeedback() async {
    setState(() {
      _isSending = true;
    });

    try {
      final Reference ref = FirebaseStorage.instance.ref().child('feedback_images/${DateTime.now().toString()}');
      await ref.putFile(_imageFile);
      final String imageUrl = await ref.getDownloadURL();

      final feedbackData = {
        'title': _titleController.text,
        'text': _textController.text,
        'imageUrl': imageUrl,
        'timestamp': DateTime.now(),
      };

      await FirebaseFirestore.instance.collection('feedback').add(feedbackData);

      // Reset state
      setState(() {
        _isSending = false;
        _imageFile = File(''); // Reset image file
        _titleController.clear(); // Clear title text field
        _textController.clear(); // Clear text field
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Feedback sent!'),
          backgroundColor: AppColors.primaryColor,
        ),
      );
    } catch (error) {
      print('Error uploading image: $error');
      setState(() {
        _isSending = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to send feedback'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        leading: BackButton(color: Colors.white),
        title: Text('Your Feedback', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: AppColors.primaryColor,
      ),
      body: SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 6.0,
                offset: Offset(0, 2),
              ),
            ],
          ),
          margin: EdgeInsets.all(20),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Share Your Feedback',
                  style: TextStyle(
                    color: AppColors.yellow900,
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24.0),
                TextField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: 'Write your Title',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),
                TextField(
                  controller: _textController,
                  decoration: InputDecoration(
                    labelText: 'Write your Text',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  maxLines: 4,
                ),
                const SizedBox(height: 24.0),
                GestureDetector(
                  onTap: _getImage,
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        foregroundColor: Colors.white,
                        backgroundImage: _imageFile.path.isNotEmpty
                            ? FileImage(_imageFile)
                            : AssetImage('assets/images/uploadimg.png') as ImageProvider,
                      ),
                      SizedBox(height: 8.0),
                      Text(
                        'Upload Image',
                        style: TextStyle(fontSize: 16.0, color: Colors.white),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24.0),
                _isSending
                    ? CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.primaryColor,
                  ),
                )
                    : ElevatedButton(
                  onPressed: _sendFeedback,
                  child: Text(
                    'Send Feedback',
                    style: TextStyle(fontSize: 18.0, color: AppColors.primaryTextColor),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24.0),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _textController.dispose();
    super.dispose();
  }
}
