import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../screens/login_screen.dart';
import '../screens/main_navigation.dart';
import '../sign_up.dart';

class AppConfig extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Always show the signup screen first
    return SignUpScreen();
  }
} 