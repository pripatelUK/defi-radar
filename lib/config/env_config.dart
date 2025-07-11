import 'package:flutter_dotenv/flutter_dotenv.dart';

/// A utility class to access environment variables throughout the app
class EnvConfig {
  /// The Privy App ID from environment variables
  static String get privyAppId => dotenv.env['PRIVY_APP_ID'] ?? '';
  
  /// The Privy Client ID from environment variables
  static String get privyClientId => dotenv.env['PRIVY_CLIENT_ID'] ?? '';
  
  /// The Privy App Secret from environment variables (for API authentication)
  static String get privyAppSecret => dotenv.env['PRIVY_APP_SECRET'] ?? '';
  
  /// The Debank Access Token from environment variables
  static String get debankAccessToken => dotenv.env['DEBANK'] ?? '';
}
