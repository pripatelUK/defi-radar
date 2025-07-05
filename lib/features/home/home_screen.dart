import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_starter/core/navigation_manager.dart';
import 'package:flutter_starter/core/privy_manager.dart';
import 'package:flutter_starter/core/app_colors.dart';
import 'package:flutter_starter/router/app_router.dart';
import 'package:go_router/go_router.dart';
import 'package:privy_flutter/privy_flutter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  bool _isPrivyReady = false;
  StreamSubscription<AuthState>? _authSubscription;

  @override
  void initState() {
    super.initState();
    _initializePrivyAndAwaitReady();
  }

  Future<void> _initializePrivyAndAwaitReady() async {
    try {
      // Initialize Privy first
      privyManager.initializePrivy();
      // Then wait for it to be ready
      await privyManager.privy.awaitReady();

      // Update state to indicate Privy is ready
      if (mounted) {
        setState(() {
          _isPrivyReady = true;
        });
        // Set up the auth listener directly in the HomeScreen
        _setupAuthListener();
      }
    } catch (e) {
      debugPrint("Error initializing Privy: $e");
    }
  }

  /// Set up listener for auth state changes
  void _setupAuthListener() {
    // Cancel any existing subscription
    _authSubscription?.cancel();
    
    // Subscribe to auth state changes
    _authSubscription = privyManager.privy.authStateStream.listen((state) {
      debugPrint('Auth state changed: $state');
      
      if (state is Authenticated && mounted) {
        debugPrint('User authenticated: ${state.user.id}');
        // Navigate to authenticated screen
        navigationManager.navigateToAuthenticatedScreen(context);
      }
    });
  }

  @override
  void dispose() {
    // Clean up subscription when widget is disposed
    _authSubscription?.cancel();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Welcome to Privy"),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.mainSpacing),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Welcome section
              _buildWelcomeSection(context),
              
              const SizedBox(height: AppSpacing.largeSpacing),
              
              // Main content based on Privy ready state
              _isPrivyReady ? _buildMainContent(context) : _buildLoadingContent(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.largeSpacing),
        child: Column(
          children: [
            // Privy Logo
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.cardRadius),
              child: Image.asset(
                'lib/assets/privy_logo.png',
                height: 120,
                width: 180,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: AppSpacing.mainSpacing),
            
            // Welcome title
            Text(
              "Privy Starter Repo",
              style: Theme.of(context).textTheme.headlineLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.tightSpacing),
            
            // Subtitle
            Text(
              "Your gateway to decentralized authentication",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent(BuildContext context) {
    return Column(
      children: [
        // Authentication section
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.largeSpacing),
            child: Column(
              children: [
                Icon(
                  Icons.security,
                  size: 48,
                  color: AppColors.primary,
                ),
                const SizedBox(height: AppSpacing.mainSpacing),
                
                Text(
                  "Secure Authentication",
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.tightSpacing),
                
                Text(
                  "Get started with secure, decentralized authentication using Privy's cutting-edge technology.",
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.largeSpacing),
                
                // Login button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      context.go(AppRouter.emailAuthPath);
                    },
                    icon: const Icon(Icons.email),
                    label: const Text('Login With Email'),
                  ),
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: AppSpacing.mainSpacing),
        
        // Features section
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.largeSpacing),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Features",
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: AppSpacing.mainSpacing),
                
                _buildFeatureItem(
                  context,
                  Icons.wallet,
                  "Multi-Chain Wallets",
                  "Support for Ethereum and Solana wallets",
                ),
                const SizedBox(height: AppSpacing.secondarySpacing),
                
                _buildFeatureItem(
                  context,
                  Icons.shield,
                  "Secure Authentication",
                  "Email-based authentication with encryption",
                ),
                const SizedBox(height: AppSpacing.secondarySpacing),
                
                _buildFeatureItem(
                  context,
                  Icons.speed,
                  "Fast & Reliable",
                  "Quick setup and seamless user experience",
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureItem(
    BuildContext context,
    IconData icon,
    String title,
    String description,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.tightSpacing),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppRadius.buttonRadius),
          ),
          child: Icon(
            icon,
            size: 20,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: AppSpacing.secondarySpacing),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingContent(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.extraLargeSpacing),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: AppColors.primary,
            ),
            const SizedBox(height: AppSpacing.mainSpacing),
            Text(
              "Initializing Privy...",
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: AppSpacing.tightSpacing),
            Text(
              "Setting up secure authentication",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
