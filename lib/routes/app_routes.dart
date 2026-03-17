import 'package:flutter/material.dart';
import '../screens/auth/login_screen.dart';
import '../screens/citizen/dashboard_screen.dart';
import '../screens/citizen/report_issue_screen.dart';
class AppRoutes {
  static Map<String, WidgetBuilder> routes = {
    '/': (context) => const LoginScreen(),
    '/dashboard': (context) => const DashboardScreen(),
    '/report': (context) => const ReportIssueScreen(),
  };
}