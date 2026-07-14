import 'package:flutter/material.dart';

class RewardScreen extends StatelessWidget {
  final String roomId;
  const RewardScreen({super.key, required this.roomId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Reward Claim: $roomId')),
      body: Center(child: Text('Reward Screen for room: $roomId (Placeholder)')),
    );
  }
}
