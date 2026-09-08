import 'package:flutter/material.dart';

class NavigationService {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static Future<T?> push<T>(Widget page) async {
    return await navigatorKey.currentState?.push(
      MaterialPageRoute(builder: (context) => page),
    );
  }

  static void pop<T>([T? result]) {
    navigatorKey.currentState?.pop(result);
  }

  static Future<T?> pushReplacement<T>(Widget page) async {
    return await navigatorKey.currentState?.pushReplacement(
      MaterialPageRoute(builder: (context) => page),
    );
  }

  static Future<T?> pushAndRemoveUntil<T>(Widget page, bool Function(Route<dynamic>) predicate) async {
    return await navigatorKey.currentState?.pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => page),
      predicate,
    );
  }
}