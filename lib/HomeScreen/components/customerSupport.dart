import 'dart:math';
import 'package:flutter/material.dart';
import '../../constants.dart';

class SupportPage extends StatefulWidget {
  const SupportPage({Key? key}) : super(key: key);

  @override
  State<SupportPage> createState() => _SupportPageState();
}

class _SupportPageState extends State<SupportPage> {
  final List<Map<String, String>> _faq = [
    {
      "question": "How do I create an account?",
      "answer": "To create an account, click on the 'Sign Up' button and fill in the required details."
    },
    {
      "question": "How can I reset my password?",
      "answer": "To reset your password, click on 'Forgot Password' at the login screen and follow the instructions."
    },
    {
      "question": "How do I earn points?",
      "answer": "You can earn points by inviting friends, making purchases, and participating in promotions."
    },
    {
      "question": "How can I contact customer support?",
      "answer": "You can contact customer support by emailing support@dollartab.com or by calling our hotline at 1-800-123-4567."
    },
    {
      "question": "What is the referral program?",
      "answer": "Our referral program allows you to earn points by referring new users to the Dollar Tab app."
    },
    {
      "question": "Can I use the app internationally?",
      "answer": "Yes, the Dollar Tab app can be used internationally. However, some features might be restricted based on your location."
    },
    {
      "question": "Is my personal data safe?",
      "answer": "Yes, we prioritize your privacy and data security. Please refer to our Privacy Policy for more details."
    },
    {
      "question": "How can I update my profile information?",
      "answer": "You can update your profile information by going to the 'Profile' section in the app and making the necessary changes."
    },
    {
      "question": "How do I delete my account?",
      "answer": "To delete your account, please contact our customer support team, and they will assist you with the process."
    },
  ];

  int? _selectedQuestionIndex;

  void _toggleAnswer(int index) {
    setState(() {
      if (_selectedQuestionIndex == index) {
        _selectedQuestionIndex = null;
      } else {
        _selectedQuestionIndex = index;
      }
    });
  }

  void _getRandomFaq() {
    final random = Random();
    setState(() {
      _selectedQuestionIndex = random.nextInt(_faq.length);
    });
  }

  @override
  void initState() {
    super.initState();
    _getRandomFaq();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryColor,
      appBar: AppBar(
        title: Text('Frequently Asked Questions', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: AppColors.primaryColor,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              const SizedBox(height: 20),
              _faq.isEmpty
                  ? Center(
                child: Text(
                  'No questions available.',
                  style: TextStyle(color: Colors.white),
                ),
              )
                  : ListView.builder(
                shrinkWrap: true,
                itemCount: _faq.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () => _toggleAnswer(index),
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _faq[index]['question']!,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            if (_selectedQuestionIndex == index)
                              const SizedBox(height: 10),
                            if (_selectedQuestionIndex == index)
                              Text(
                                _faq[index]['answer']!,
                                style: const TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _selectedQuestionIndex = null;
                  });
                  _getRandomFaq();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text(
                  'Get Another Question',
                  style: TextStyle(fontSize: 16,color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
