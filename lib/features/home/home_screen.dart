import 'dart:async';
import 'package:flutter/material.dart';
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
  PrivyUser? _user;
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
        
        // Load user data if authenticated
        _loadUserData();
        
        // Set up the auth listener
        _setupAuthListener();
      }
    } catch (e) {
      debugPrint("Error initializing Privy: $e");
    }
  }

  Future<void> _loadUserData() async {
    try {
      // Access the user property directly from Privy
      final user = privyManager.privy.user;
      if (mounted) {
        setState(() {
          _user = user;
        });
      }
    } catch (e) {
      debugPrint('Error loading user data: $e');
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
        _loadUserData();
      } else if (state is Unauthenticated && mounted) {
        setState(() {
          _user = null;
        });
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
        title: const Text("Home"),
        actions: [
          if (_user != null)
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: _logout,
              tooltip: 'Logout',
            ),
        ],
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
              
              // Main content based on authentication state
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
        padding: const EdgeInsets.all(AppSpacing.tightSpacing),
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
              _user != null ? "Safe Salary" : "Welcome to Safe Salary",
              style: Theme.of(context).textTheme.headlineLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.tightSpacing),
            
            // Subtitle
            Text(
              _user != null 
                ? "Manage your teams salary"
                : "Get started with secure salary management",
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
    if (_user == null) {
      return _buildAuthenticationContent(context);
    } else {
      return _buildUserDashboard(context);
    }
  }

  Widget _buildAuthenticationContent(BuildContext context) {
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
                
                // Text(
                //   "Secure Authentication",
                //   style: Theme.of(context).textTheme.headlineMedium,
                //   textAlign: TextAlign.center,
                // ),
                // const SizedBox(height: AppSpacing.tightSpacing),
                
                // Text(
                //   "Get started with secure, decentralized authentication using Privy's cutting-edge technology.",
                //   style: Theme.of(context).textTheme.bodyMedium,
                //   textAlign: TextAlign.center,
                // ),
                // const SizedBox(height: AppSpacing.largeSpacing),
                
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
        
        // const SizedBox(height: AppSpacing.mainSpacing),
        
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
                  Icons.business,
                  "Company Management",
                  "Team collaboration and project management",
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUserDashboard(BuildContext context) {
    return Column(
      children: [
        // User Profile Card
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.largeSpacing),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.secondarySpacing),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppRadius.cardRadius),
                  ),
                  child: Icon(
                    Icons.verified_user,
                    color: AppColors.primary,
                    size: 32,
                  ),
                ),
                const SizedBox(width: AppSpacing.mainSpacing),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome back!',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: AppSpacing.tightSpacing),
                      Text(
                        'User ID: ${_user?.id.substring(0, 8)}...',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: AppSpacing.mainSpacing),

        // Quick Actions
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.mainSpacing),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Quick Actions",
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: AppSpacing.mainSpacing),
                
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => context.go(AppRouter.authenticatedPath),
                        icon: const Icon(Icons.person),
                        label: const Text('View Profile'),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.secondarySpacing),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _showWalletInfo(context),
                        icon: const Icon(Icons.wallet),
                        label: const Text('Wallet Info'),
                      ),
                    ),
                  ],
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

  void _showWalletInfo(BuildContext context) {
    final ethWallets = _user?.embeddedEthereumWallets ?? [];
    final solWallets = _user?.embeddedSolanaWallets ?? [];
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Wallet Information'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Ethereum Wallets: ${ethWallets.length}'),
            Text('Solana Wallets: ${solWallets.length}'),
            const SizedBox(height: AppSpacing.mainSpacing),
            Text(
              'Visit the Wallets tab to manage your wallets and view DeFi positions.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _logout() async {
    try {
      await privyManager.privy.logout();
      setState(() {
        _user = null;
      });
    } catch (e) {
      debugPrint('Error logging out: $e');
    }
  }
}
