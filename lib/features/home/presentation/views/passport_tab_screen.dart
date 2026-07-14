import 'package:flutter/material.dart';

class PassportTabScreen extends StatelessWidget {
  const PassportTabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🛂 Passport'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.contact_mail_outlined, size: 80, color: Color(0xFF004948)),
              const SizedBox(height: 16),
              Text(
                'Travel Passport',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: const Color(0xFF004948),
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              const Text(
                'View your profile stats, achievements, and traveler level.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black54),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
