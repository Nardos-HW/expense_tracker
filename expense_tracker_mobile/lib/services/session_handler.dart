import 'package:flutter/material.dart';
import '../app_navigator.dart';
import '../screens/login_screen.dart';
import 'auth_service.dart';

class SessionHandler {
  static final AuthService _authService = AuthService();

  /// Clears local token and navigates back to LoginScreen with a friendly message.
  static Future<void> handleUnauthorized() async {
    await _authService.removeToken();
    navigatorKey.currentState?.pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => const LoginScreen(
          message: 'Your session has ended. Please log in again.',
        ),
      ),
      (route) => false,
    );
  }

  /// Displays a SnackBar when an action is forbidden for this device platform.
  static void showForbidden([String message = 'This device is not allowed to do that.']) {
    scaffoldMessengerKey.currentState?.removeCurrentSnackBar();
    scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
