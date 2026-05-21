// main.dart
import 'package:algebra_chatbot/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/chat_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/history_provider.dart';
import 'providers/formula_provider.dart';
import '../core/theme/app_theme.dart';
import 'providers/navigation_provider.dart';
import 'providers/solver_provider.dart';
import 'providers/admin_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => FormulaProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => HistoryProvider()),
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
        ChangeNotifierProvider(create: (_) => SolverProvider()),
        ChangeNotifierProvider(create: (_) => AdminProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light, // Gọi từ file AppTheme
      darkTheme: AppTheme.dark, // Gọi từ file AppTheme
      themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: const SplashScreen(),
    );
  }
}