import 'package:flutter/material.dart';

class QuizScreen extends StatelessWidget {
  final String roomId;
  const QuizScreen({super.key, required this.roomId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Quiz Game: $roomId')),
      body: Center(child: Text('Quiz Screen for room: $roomId (Placeholder)')),
    );
  }
}
