import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/theme_provider.dart';
import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';
import 'localization/localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:easy_localization/easy_localization.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/chatbot_screen.dart';
import 'screens/community_screen.dart';
import 'screens/extras_menu_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/log_progress_screen.dart';
import 'screens/settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Initialize Firebase
  await LocalizationHelper.init(); // Initialize localization

  runApp(
    EasyLocalization(
      supportedLocales: LocalizationHelper.getSupportedLocales(),
      path: 'lib/localization', // Path to translations
      fallbackLocale: LocalizationHelper.getFallbackLocale(),
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(
              create: (_) => ThemeProvider()), // Theme state management
        ],
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider =
        Provider.of<ThemeProvider>(context); // Access theme state

    return MaterialApp(
      debugShowCheckedModeBanner: false, // Disable debug banner
      title: LocalizationHelper.translate(context, 'app_title'), // App title
      theme: AppTheme.lightTheme, // Define light theme
      darkTheme: AppTheme.darkTheme, // Define dark theme
      themeMode: themeProvider.themeMode, // Dynamically switch theme
      locale: context.locale, // Current locale
      supportedLocales:
          LocalizationHelper.getSupportedLocales(), // Supported locales
      localizationsDelegates:
          context.localizationDelegates, // Localization delegates
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/home_screen': (context) => const HomeScreen(),
        '/chatbot': (context) => const ChatbotScreen(),
        '/community': (context) => const CommunityScreen(),
        '/extras': (context) => const ExtrasMenuScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/notifications': (context) => const NotificationsScreen(),
        '/log_progress': (context) => const LogProgressScreen(),
        '/settings': (context) => const SettingsScreen(),

      },
    );
  }
}
