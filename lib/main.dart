import 'package:flutter/material.dart';
import 'package:flutter_starter/router/app_router.dart';

void main() {
  runApp(const MyPrivyStarterApp());
}

class MyPrivyStarterApp extends StatelessWidget {
  const MyPrivyStarterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: "Privy Starter Repo",
      debugShowCheckedModeBanner: false,
      routerConfig: AppRouter().router,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
    );
  }
}
