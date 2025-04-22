import 'package:flutter/material.dart';
import 'package:flutter_starter/app.dart';

void main() {
  runApp(const MyPrivyStarterApp());
}

class MyPrivyStarterApp extends StatelessWidget {
  const MyPrivyStarterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: "Privy Starter Repo",
      debugShowCheckedModeBanner: false,
      home: AppScreen(), // Ensure this is wrapped inside MaterialApp
    );
  }
}
