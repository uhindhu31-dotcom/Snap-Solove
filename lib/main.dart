import 'package:flutter/material.dart';
import 'routes/app_routes.dart';

void main() {
  runApp(const SnapSolveApp());
}

class SnapSolveApp extends StatelessWidget {
  const SnapSolveApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: AppRoutes.routes, // ✅ THIS IS IMPORTANT
    );
  }
}