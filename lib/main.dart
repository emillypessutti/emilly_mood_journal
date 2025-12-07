import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'di/injection_container.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/privacy_policy_screen.dart';
import 'screens/profile_setup_screen.dart';
import 'screens/home_screen.dart';
import 'screens/auth_screen.dart';
import 'theme/app_theme.dart';
import 'services/supabase_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializa SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  
  // Inicializa Supabase (se configurado)
  try {
    await SupabaseService.initialize();
  } catch (e) {
    debugPrint('⚠️ Supabase não configurado: $e');
    // App continua funcionando apenas com cache local
  }
  
  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const MoodJournalApp(),
    ),
  );
}

class MoodJournalApp extends StatelessWidget {
  const MoodJournalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MoodJournal - Diário de Bem-estar',
      theme: AppTheme.lightTheme,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('pt', 'BR'),
        Locale('en', 'US'),
      ],
      home: const SplashScreen(),
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/auth': (context) => const AuthScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
        '/privacy': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          final enforce = args is Map && args['enforce'] == true;
          return PrivacyPolicyScreen(enforceAcceptance: enforce);
        },
        '/profile-setup': (context) => const ProfileSetupScreen(),
        '/home': (context) => const HomeScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
