import 'package:flutter/material.dart';
import 'package:core/core.dart';
import 'widgets/dashboard_shell.dart';
import 'widgets/auth_gate.dart';
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
    home: FirestoreService.useFirebase
        ? const AuthGate(child: _DashboardNavigator())
        : const DashboardShell(),
  );
}

/// Every private route and dialog lives below the session guard. The outer
/// app keeps its root focus scope and sign-in Overlay throughout auth changes.
class _DashboardNavigator extends StatelessWidget {
  const _DashboardNavigator();
  @override
  Widget build(BuildContext context) => HeroControllerScope.none(
    child: Navigator(
      onGenerateRoute: (settings) => MaterialPageRoute<void>(
        settings: settings,
        builder: (_) => const DashboardShell(),
      ),
    ),
  );
}
