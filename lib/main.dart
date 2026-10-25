import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'cubit/settings_cubit.dart';
import 'pages/home_page.dart';

void main() {
  runApp(
    BlocProvider(create: (context) => SettingsCubit(), child: const TodoApp()),
  );
}

class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    const seedColor = Color(0xFF5B5FEF);

    return BlocBuilder<SettingsCubit, bool>(
      builder: (context, isDarkTheme) => MaterialApp(
        title: 'Мои задачи',
        debugShowCheckedModeBanner: false,
        theme: _buildTheme(seedColor, Brightness.light),
        darkTheme: _buildTheme(seedColor, Brightness.dark),
        themeMode: isDarkTheme ? ThemeMode.dark : ThemeMode.light,
        home: const HomePage(),
      ),
    );
  }

  ThemeData _buildTheme(Color seedColor, Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: ColorScheme.fromSeed(
        seedColor: seedColor,
        brightness: brightness,
      ),
      scaffoldBackgroundColor: isDark
          ? const Color(0xFF121212)
          : const Color(0xFFF7F7FB),
      appBarTheme: AppBarTheme(
        backgroundColor: isDark
            ? const Color(0xFF121212)
            : const Color(0xFFF7F7FB),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: false,
        fillColor: Colors.white30,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: isDark ? const Color(0xFF45454F) : const Color(0xFFE6E6EF),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: isDark ? const Color(0xFF45454F) : const Color(0xFFE6E6EF),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: seedColor, width: 1.5),
        ),
      ),
    );
  }
}
