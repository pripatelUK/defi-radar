import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../router/app_router.dart';

class EmailAuthenticationScreen extends StatelessWidget {
  const EmailAuthenticationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Email Authentication'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Email Authentication', style: TextStyle(fontSize: 24)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                context.go(AppRouter.authenticatedPath);
              },
              child: const Text('Go to Authenticated Screen'),
            ),
          ],
        ),
      ),
    );
  }
}
