import 'package:flutter/material.dart';
import 'package:outfitaura/services/api_service.dart';

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  _FeedbackPageState createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  final _messageController = TextEditingController();
  int _rating = 0;
  bool _isSubmitting = false;

  void _submitFeedback() async {
    if (_rating < 1 || _rating > 5 || _messageController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a rating (1–5) and enter a message'),
          backgroundColor: Color(0xFFE15757),
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await ApiService.submitFeedback(_rating, _messageController.text.trim());
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Feedback submitted successfully'),
          backgroundColor: Color(0xFF4ACDEB),
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: const Color(0xFFE15757),
        ),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset('assets/logo.png', height: 40),
            const SizedBox(width: 8),
            const Text(
              'Submit Feedback',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF007180),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        color: const Color(0xFFDDEAE0),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your Feedback',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF007180),
              ),
            ),
            const SizedBox(height: 20),
            Card(
              elevation: 6,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              color: const Color(0xFF82BECC),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Rating',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: List.generate(5, (index) {
                        return IconButton(
                          icon: Icon(
                            index < _rating ? Icons.star : Icons.star_border,
                            color: Colors.yellow,
                            size: 30,
                          ),
                          onPressed: () {
                            setState(() {
                              _rating = index + 1;
                            });
                          },
                        );
                      }),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _messageController,
                      decoration: const InputDecoration(
                        labelText: 'Message',
                        labelStyle: TextStyle(color: Colors.white),
                        filled: true,
                        fillColor: Color(0xFFDDEAE0),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                      ),
                      maxLines: 4,
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4ACDEB),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        ),
                        onPressed: _isSubmitting ? null : _submitFeedback,
                        child: _isSubmitting
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text('Submit', style: TextStyle(fontSize: 16)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}