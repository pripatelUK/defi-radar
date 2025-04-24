import 'package:flutter/material.dart';
import 'package:flutter_starter/core/privy_manager.dart';
import 'package:flutter_starter/router/app_router.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  bool _isPrivyReady = false;

  @override
  void initState() {
    super.initState();
    _initializePrivyAndAwaitReady();
  }

  Future<void> _initializePrivyAndAwaitReady() async {
    // Initialize Privy
    PrivyManager().initializePrivy();

    // Wait for Privy to be ready
    await PrivyManager.privy.awaitReady();

    // Update state to indicate Privy is ready
    if (mounted) {
      setState(() {
        _isPrivyReady = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Welcome to Privy"),
      ),
      body: Center(
        child:
            _isPrivyReady
                // Main content when Privy is ready
                ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Privy Logo from assets
                    Image.asset(
                      'lib/assets/privy_logo.png',
                      height: 180,
                      width: 250,
                    ),
                    const SizedBox(height: 24),
                    // Larger Title using theme's headlineLarge
                    Text(
                      "Privy Starter Repo",
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: () {
                        context.go(AppRouter.emailAuthPath);
                      },
                      child: const Text('Login With Email'),
                    ),
                  ],
                )
                // Loading indicator when Privy is not ready
                : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Using theme's primary color for loading indicator
                    CircularProgressIndicator(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 20),
                    // Using theme's text style
                    Text(
                      "Initializing Privy...",
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
      ),
    );
  }
}
