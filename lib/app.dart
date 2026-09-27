import 'package:flutter/material.dart';

import 'features/crime_check/presentation/crime_check_page.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Safer Streets',
      debugShowCheckedModeBanner: false,
      theme: _theme(Brightness.light),
      darkTheme: _theme(Brightness.dark),
      home: const CrimeCheckPage(),
    );
  }

  ThemeData _theme(Brightness brightness) {
    Color pick(int light, int dark) =>
        Color(brightness == Brightness.light ? light : dark);
    final scheme =
        ColorScheme.fromSeed(
          seedColor: const Color(0xFF1D4F86),
          brightness: brightness,
        ).copyWith(
          primary: pick(0xFF1D4F86, 0xFFA9C9F0),
          onPrimary: pick(0xFFFFFFFF, 0xFF0B1D33),
          // More crime. Amber and blue stay distinct with red-green colour
          // blindness, and amber reads as "note this" without red's alarm.
          tertiary: pick(0xFF974500, 0xFFF3B072),
          surface: pick(0xFFFFFFFF, 0xFF131518),
          onSurface: pick(0xFF16181B, 0xFFE8EAED),
          onSurfaceVariant: pick(0xFF4B5058, 0xFFB4B9C0),
          surfaceContainerLow: pick(0xFFEEF3F8, 0xFF18202B),
          surfaceContainerHighest: pick(0xFFE6E9ED, 0xFF262A30),
          outline: pick(0xFFB9C1CB, 0xFF4A525D),
          outlineVariant: pick(0xFFD9DCE0, 0xFF343840),
        );
    TextStyle heading(double size) => TextStyle(
      fontSize: size,
      fontWeight: FontWeight.w800,
      letterSpacing: size * -0.025,
      height: 1.1,
    );
    final radius = BorderRadius.circular(8);
    // Button text styles replace the theme's, so they name the font too.
    const font = 'Inter';

    return ThemeData(
      colorScheme: scheme,
      fontFamily: font,
      textTheme: TextTheme(
        displayLarge: heading(80),
        displayMedium: heading(56),
        displaySmall: heading(40),
        headlineMedium: heading(30),
        titleLarge: heading(20),
        bodyLarge: const TextStyle(fontSize: 18, height: 1.5),
        bodyMedium: const TextStyle(fontSize: 16, height: 1.5),
        bodySmall: const TextStyle(fontSize: 14, height: 1.45),
        labelMedium: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          letterSpacing: 1,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: scheme.onSurface,
          foregroundColor: scheme.surface,
          minimumSize: const Size(0, 56),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: radius),
          textStyle: const TextStyle(
            fontFamily: font,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: Size.zero,
          padding: const EdgeInsets.all(4),
          textStyle: const TextStyle(
            fontFamily: font,
            decoration: TextDecoration.underline,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surface,
        border: OutlineInputBorder(borderRadius: radius),
        enabledBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(color: scheme.onSurface, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(color: scheme.primary, width: 2),
        ),
      ),
    );
  }
}
