import 'package:flutter/material.dart';

class ShopTabScreen extends StatelessWidget {
  const ShopTabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🎁 Cửa Hàng'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.storefront_outlined, size: 80, color: Color(0xFFFB8C00)),
              const SizedBox(height: 16),
              Text(
                'Cửa Hàng Quiz',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: const Color(0xFFFB8C00),
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Đổi xu của bạn lấy các avatar đặc biệt và vật phẩm tăng sức mạnh.',
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
