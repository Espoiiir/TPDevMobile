import 'package:flutter/material.dart';

import 'screens/app_shell.dart';

void main() {
  runApp(const RaiderIoApp());
}

class RaiderIoApp extends StatelessWidget {
  const RaiderIoApp({super.key});

  @override
  Widget build(BuildContext context) {
    const gold = Color(0xFFFFC857);
    const blue = Color(0xFF2E6F95);
    const ink = Color(0xFF111827);

    return MaterialApp(
      title: 'Raider.IO Companion',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: gold,
          primary: gold,
          secondary: blue,
          surface: const Color(0xFFFAF7EF),
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFFAF7EF),
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          backgroundColor: ink,
          foregroundColor: Colors.white,
          elevation: 0,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 21,
            fontWeight: FontWeight.w800,
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 2,
          color: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          clipBehavior: Clip.antiAlias,
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: blue,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        navigationBarTheme: NavigationBarThemeData(
          indicatorColor: gold.withValues(alpha: 0.38),
          labelTextStyle: WidgetStateProperty.all(
            const TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
      ),
      home: const AppShell(),
    );
  }
}
