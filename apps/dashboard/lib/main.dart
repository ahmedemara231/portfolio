import 'package:flutter/material.dart';
import 'package:core/core.dart';
import 'widgets/dashboard_shell.dart';
import 'theme/dashboard_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  WidgetsBinding.instance.ensureSemantics();
  try {
    await initializeContentBackend();
    runApp(const DashboardApp());
  } catch (_) {
    runApp(
      MaterialApp(
        theme: DashboardTheme.light,
        home: const Scaffold(
          body: Center(
            child: StateMessage(
              title: 'Could not open the dashboard',
              message:
                  'Reload to try again. Local preview requires browser storage.',
            ),
          ),
        ),
      ),
    );
  }
}

class DashboardApp extends StatelessWidget {
  const DashboardApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Portfolio Studio — Ahmed Emara',
    debugShowCheckedModeBanner: false,
    theme: DashboardTheme.light,
    home: const DashboardShell(),
  );
}
