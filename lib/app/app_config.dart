import 'package:flutter/material.dart';
import 'package:auto_route/annotations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../screens/login_screen.dart';
import '../screens/main_navigation.dart';
import '../sign_up.dart';

@RoutePage(name: 'AppConfigRoute')
class AppConfig extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authViewModelProvider);
    return authState.when(
      data: (user) => user != null ? MainNavigation() : LoginScreen(),
      loading: () => Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (_,__) => Scaffold(body: Center(child: Text('Error'))),
    );
  }
} 
