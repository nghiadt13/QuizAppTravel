import 'package:flutter/material.dart';

class LiveMonitoringScreen extends StatelessWidget {
  final String roomId;
  const LiveMonitoringScreen({super.key, required this.roomId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Live Monitoring: $roomId')),
      body: Center(child: Text('Live Monitoring Screen for room: $roomId (Placeholder)')),
    );
  }
}
