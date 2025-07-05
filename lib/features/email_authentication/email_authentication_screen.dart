import 'package:flutter/material.dart';
import 'package:flutter_starter/core/privy_manager.dart';
import 'package:flutter_starter/core/app_colors.dart';
import 'package:flutter_starter/router/app_router.dart';
import 'package:go_router/go_router.dart';

class EmailAuthenticationScreen extends StatefulWidget {
  const EmailAuthenticationScreen({super.key});

  @override
  EmailAuthenticationScreenState createState() =>
      EmailAuthenticationScreenState();
}

class EmailAuthenticationScreenState extends State<EmailAuthenticationScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController codeController = TextEditingController();
  bool codeSent = false;
  String? errorMessage;
  bool isLoading = false;

  /// Shows a message using a Snackbar
  void showMessage(String message, {bool isError = false}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.buttonRadius),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Sends OTP to the provided email
  /// 
  /// NOTE: To use email authentication, you must enable it in the Privy Dashboard:
  /// https://dashboard.privy.io/apps?page=login-methods
  Future<void> sendCode() async {
    // Get and validate the email input
    String email = emailController.text.trim();
    if (email.isEmpty) {
      showMessage("Please enter your email", isError: true);
      return;
    }

    // Update UI to show loading state and clear any previous errors
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      // Call Privy SDK to send verification code
      // This makes an API request to Privy's authentication service
      final result = await privyManager.privy.email.sendCode(email);

      // Handle the result using Privy's Result type which has onSuccess and onFailure handlers
      result.fold(
        // Success handler - code was sent successfully
        onSuccess: (_) {
          setState(() {
            codeSent =
                true; // This will trigger UI to show the code input field
            errorMessage = null;
            isLoading = false;
          });
          showMessage("Code sent successfully to $email");
        },
        // Failure handler - something went wrong on Privy's end
        onFailure: (error) {
          setState(() {
            errorMessage = error.message; // Store error message from Privy
            codeSent = false; // Ensure code input remains hidden
            isLoading = false;
          });
          showMessage("Error sending code: ${error.message}", isError: true);
        },
      );
    } catch (e) {
      // Handle unexpected exceptions (network issues, etc.)
      setState(() {
        isLoading = false;
        errorMessage = e.toString();
      });
      showMessage("Unexpected error: $e", isError: true);
    }
  }

  /// Logs in using code and email, then navigates to the authenticated screen on success
  Future<void> login() async {
    // Validate the verification code input
    String code = codeController.text.trim();
    if (code.isEmpty) {
      showMessage("Please enter the verification code", isError: true);
      return;
    }

    // Update UI to show loading state and clear previous errors
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      // Call Privy SDK to verify the code and complete authentication
      // This performs verification against Privy's authentication service
      final result = await privyManager.privy.email.loginWithCode(
        code: code, // The verification code entered by user
        email:
            emailController.text.trim(), // The email address to verify against
      );

      // Handle the authentication result
      result.fold(
        // Success handler - user was authenticated
        onSuccess: (user) {
          // user is a PrivyUser object containing the authenticated user's information
          setState(() {
            isLoading = false;
          });
          showMessage("Authentication successful!");

          // Navigate to authenticated screen
          if (mounted) {
            context.go(AppRouter.authenticatedPath);
          }
        },
        // Failure handler - authentication failed
        onFailure: (error) {
          // Common failures: invalid code, expired code, too many attempts
          setState(() {
            errorMessage = error.message;
            isLoading = false;
          });
          showMessage("Login error: ${error.message}", isError: true);
        },
      );
    } catch (e) {
      // Handle unexpected exceptions (network issues, etc.)
      setState(() {
        isLoading = false;
        errorMessage = e.toString();
      });
      showMessage("Unexpected error: $e", isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Email Authentication'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.mainSpacing),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.largeSpacing),
                  child: Column(
                    children: [
                      // Privy Logo
                      ClipRRect(
                        borderRadius: BorderRadius.circular(AppRadius.cardRadius),
                        child: Image.asset(
                          'lib/assets/privy_logo.png',
                          height: 100,
                          width: 150,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.mainSpacing),
                      
                      Text(
                        'Login with Email',
                        style: Theme.of(context).textTheme.headlineLarge,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.tightSpacing),
                      
                      Text(
                        'Enter your email to receive a verification code',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.mainSpacing),

              // Email Input Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.mainSpacing),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.email_outlined,
                            color: AppColors.primary,
                            size: 20,
                          ),
                          const SizedBox(width: AppSpacing.tightSpacing),
                          Text(
                            'Email Address',
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.mainSpacing),

                      TextField(
                        controller: emailController,
                        decoration: InputDecoration(
                          labelText: "Enter your email address",
                          hintText: "example@email.com",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppRadius.buttonRadius),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppRadius.buttonRadius),
                            borderSide: BorderSide(color: AppColors.primary),
                          ),
                          prefixIcon: Icon(
                            Icons.email,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        autocorrect: false,
                        enabled: !isLoading,
                      ),
                      const SizedBox(height: AppSpacing.mainSpacing),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: isLoading ? null : sendCode,
                          icon: isLoading && !codeSent
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.send),
                          label: Text(
                            isLoading && !codeSent
                                ? "Sending..."
                                : "Send Verification Code",
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Verification Code Card (shown after code is sent)
              if (codeSent) ...[
                const SizedBox(height: AppSpacing.mainSpacing),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.mainSpacing),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.verified_user,
                              color: AppColors.primary,
                              size: 20,
                            ),
                            const SizedBox(width: AppSpacing.tightSpacing),
                            Text(
                              'Verification Code',
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.tightSpacing),
                        
                        Text(
                          'Enter the verification code sent to ${emailController.text.trim()}',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.mainSpacing),

                        TextField(
                          controller: codeController,
                          decoration: InputDecoration(
                            labelText: "Verification Code",
                            hintText: "Enter 6-digit code",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(AppRadius.buttonRadius),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(AppRadius.buttonRadius),
                              borderSide: BorderSide(color: AppColors.primary),
                            ),
                            prefixIcon: Icon(
                              Icons.lock,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          enabled: !isLoading,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 18,
                            letterSpacing: 2,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.mainSpacing),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: isLoading ? null : login,
                            icon: isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(Icons.login),
                            label: Text(
                              isLoading ? "Verifying..." : "Verify & Login",
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: AppSpacing.secondarySpacing),
                        
                        Center(
                          child: TextButton(
                            onPressed: isLoading ? null : () {
                              setState(() {
                                codeSent = false;
                                codeController.clear();
                                errorMessage = null;
                              });
                            },
                            child: const Text('Use different email'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              // Error Message Card
              if (errorMessage != null) ...[
                const SizedBox(height: AppSpacing.mainSpacing),
                Card(
                  color: AppColors.error.withOpacity(0.1),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.mainSpacing),
                    child: Row(
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: AppColors.error,
                          size: 20,
                        ),
                        const SizedBox(width: AppSpacing.secondarySpacing),
                        Expanded(
                          child: Text(
                            errorMessage!,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.error,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              const SizedBox(height: AppSpacing.extraLargeSpacing),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    codeController.dispose();
    super.dispose();
  }
}
