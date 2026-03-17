import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:core/core.dart';
import 'theme/dashboard_theme.dart';
import 'widgets/dashboard_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const DashboardApp());
}

class DashboardApp extends StatelessWidget {
  const DashboardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Portfolio Dashboard',
      debugShowCheckedModeBanner: false,
      theme: DashboardTheme.light,
      home: const DashboardShell(),
    );
  }
}
