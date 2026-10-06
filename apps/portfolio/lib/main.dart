import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:core/core.dart';
import 'screens/home_screen.dart';
import 'screens/projects_screen.dart';
import 'services/public_content.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();
  WidgetsBinding.instance.ensureSemantics();
  try {
    await initializeContentBackend();
    runApp(const PortfolioApp());
  } catch (_) {
    runApp(
      MaterialApp(
        theme: Design.theme,
        home: const Scaffold(
          body: Center(
            child: StateMessage(
              title: 'Unable to open the portfolio',
              message:
                  'Please reload the page. Browser storage must be available for local previews.',
            ),
          ),
        ),
      ),
    );
  }
}

class PortfolioApp extends StatefulWidget {
  const PortfolioApp({super.key});
  @override
  State<PortfolioApp> createState() => _PortfolioAppState();
}

class _PortfolioAppState extends State<PortfolioApp> {
  late final content = PublicContent();
  @override
  void dispose() {
    content.dispose();
    super.dispose();
  }

  Route<dynamic> route(RouteSettings settings) {
    // Hosting may redirect generated HTML directories to a trailing slash.
    final path = Uri.parse(
      settings.name ?? '/',
    ).path.replaceFirst(RegExp(r'/+$'), '');
    final Widget page;
    if (path == '/' || path.isEmpty) {
      page = HomeScreen(content: content);
    } else if (path == '/projects') {
      page = ProjectsScreen(content: content);
    } else if (path.startsWith('/projects/') && path.split('/').length == 3) {
      page = ProjectScreen(
        slug: Uri.decodeComponent(path.split('/').last),
        content: content,
      );
    } else {
      page = const NotFoundScreen();
    }
    return MaterialPageRoute(settings: settings, builder: (_) => page);
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Ahmed Emara — Flutter Developer',
    debugShowCheckedModeBanner: false,
    theme: Design.theme,
    onGenerateRoute: route,
    onGenerateInitialRoutes: (name) => [route(RouteSettings(name: name))],
  );
}
