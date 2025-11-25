import 'package:auto_route/auto_route.dart';
import '../app/app_config.dart';
import '../screens/login_screen.dart';
import '../sign_up.dart';
import '../home_page.dart';
import '../screens/members_expenses_screen.dart';
import '../screens/profile_page.dart';
import '../screens/notifications_screen.dart';
import '../screens/main_navigation.dart';

part 'app_router.gr.dart';

@AutoRouterConfig(replaceInRouteName: 'Screen|Page,Route')
class AppRouter extends RootStackRouter {
  @override
  RouteType get defaultRouteType => const RouteType.material();

  @override
  List<AutoRoute> get routes => [
        AutoRoute(path: '/', page: AppConfigRoute.page, initial: true),
        AutoRoute(path: '/login', page: LoginRoute.page),
        AutoRoute(path: '/signup', page: SignUpRoute.page),
        AutoRoute(path: '/home', page: HomeRoute.page),
        AutoRoute(path: '/members', page: MembersExpensesRoute.page),
        AutoRoute(path: '/profile', page: ProfileRoute.page),
        AutoRoute(path: '/notifications', page: NotificationsRoute.page),
        AutoRoute(path: '/main', page: MainNavigationRoute.page),
      ];
}
