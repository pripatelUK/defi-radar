import 'package:flutter/material.dart';

class AppScreen extends StatefulWidget {
  const AppScreen({super.key});

  @override
  AppScreenState createState() => AppScreenState();
}

class AppScreenState extends State<AppScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text("Welcome to Privy")),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Privy Starter Repo"),
            ],
          ),
        ),
      ),
    );
  }
}
