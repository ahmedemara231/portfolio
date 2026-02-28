import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const PortfolioApp());
}

class PortfolioApp extends StatelessWidget {
  const PortfolioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Developer Portfolio',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'sans-serif',
        splashFactory: NoSplash.splashFactory, // avoids ink_sparkle shader on web
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF030213),
          onPrimary: Color(0xFFFFFFFF),
          surface: Color(0xFFFFFFFF),
          onSurface: Color(0xFF030213),
        ),
        scaffoldBackgroundColor: Colors.white,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            textStyle: const TextStyle(
                fontWeight: FontWeight.w500, fontSize: 15),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            textStyle: const TextStyle(
                fontWeight: FontWeight.w500, fontSize: 15),
          ),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
