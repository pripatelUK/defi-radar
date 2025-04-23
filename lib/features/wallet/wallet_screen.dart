import 'package:flutter/material.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My wallet'),
      ),
      body: const Center(
        child: Text('My wallet', style: TextStyle(fontSize: 24)),
      ),
    );
  }
}
