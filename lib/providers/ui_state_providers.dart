import 'package:flutter_riverpod/flutter_riverpod.dart';

// UI loading state providers to avoid setState usage in screens
final loginLoadingProvider = StateProvider<bool>((ref) => false);
final signUpLoadingProvider = StateProvider<bool>((ref) => false);
final familyLoadingProvider = StateProvider<bool>((ref) => false);

// UI state providers
final selectedCategoryProvider = StateProvider<String?>((ref) => null);
final navigationIndexProvider = StateProvider<int>((ref) => 1);