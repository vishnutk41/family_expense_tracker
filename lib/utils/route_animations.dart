import 'package:flutter/material.dart';

class CustomPageTransitionsBuilder extends PageTransitionsBuilder {
  @override
  Widget buildTransitions<T extends Object?>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    const begin = Offset(1.0, 0.0);
    const end = Offset.zero;
    const curve = Curves.ease;

    var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
    var slideAnimation = animation.drive(tween);

    return SlideTransition(
      position: slideAnimation,
      child: child,
    );
  }
}

class RouteAnimations {
  static Route createSlideRoute(Widget nextPage) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => nextPage,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0); // Start from the right
        const end = Offset.zero;
        const curve = Curves.ease;

        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var slideAnimation = animation.drive(tween);

        return SlideTransition(
          position: slideAnimation,
          child: child,
        );
      },
    );
  }

  static Route createFadeRoute(Widget nextPage) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => nextPage,
      transitionDuration: const Duration(seconds: 1), // Extended duration for a slower effect
      reverseTransitionDuration: const Duration(seconds: 1), // Also slow when popping the route
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeInOut, // A smooth curve for more gradual transition
          reverseCurve: Curves.easeInOut,
        );
        return FadeTransition(
          opacity: curvedAnimation, // Use the curvedAnimation for opacity
          child: child,
        );
      },
    );
  }
} 