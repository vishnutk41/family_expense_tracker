import 'app_router.dart';
import 'router.dart';

void navigateFromData(Map<String, dynamic> data) {
  final String? route = data['route'] ?? data['screen'];
  switch (route) {
    case 'members':
      appRouter.push(const MembersExpensesRoute());
      break;
    case 'profile':
      appRouter.push(const ProfileRoute());
      break;
    case 'home':
      appRouter.push(const HomeRoute());
      break;
    default:
      appRouter.push(const HomeRoute());
  }
}

