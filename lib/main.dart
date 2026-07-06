import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/network/supabase_config.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  bool isConfigured =
      SupabaseConfig.url != 'https://your-project-id.supabase.co' &&
      SupabaseConfig.anonKey != 'your-supabase-anon-key' &&
      SupabaseConfig.url.isNotEmpty &&
      SupabaseConfig.anonKey.isNotEmpty;

  if (isConfigured) {
    try {
      await Supabase.initialize(
        url: SupabaseConfig.url,
        publishableKey: SupabaseConfig.anonKey,
      );
    } catch (e) {
      isConfigured = false;
    }
  }

  runApp(
    ProviderScope(
      child: MyApp(isConfigured: isConfigured),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool isConfigured;

  const MyApp({
    super.key,
    required this.isConfigured,
  });

  @override
  Widget build(BuildContext context) {
    if (!isConfigured) {
      return MaterialApp(
        title: 'UG MOVIE',
        theme: AppTheme.darkTheme,
        themeMode: ThemeMode.dark,
        debugShowCheckedModeBanner: false,
        home: const ConfigurationWarningScreen(),
      );
    }

    return MaterialApp.router(
      title: 'UG MOVIE',
      theme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      routerConfig: routerProvider,
      debugShowCheckedModeBanner: false,
    );
  }
}

class ConfigurationWarningScreen extends StatelessWidget {
  const ConfigurationWarningScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: Color(0xFFE50914),
                size: 80,
              ),
              const SizedBox(height: 24),
              Text(
                'Configuration Required',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 28),
              ),
              const SizedBox(height: 16),
              Text(
                'Please configure your Supabase Project URL and Anon Key in:',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 15),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1B1E30),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF2C2F48)),
                ),
                child: const Text(
                  'lib/core/network/supabase_config.dart',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'monospace',
                    color: Color(0xFFFF2E3B),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Steps to setup:\n'
                '1. Create a free project on supabase.com\n'
                '2. Paste the SQL script from schema.sql in the SQL Editor\n'
                '3. Get your project API keys (URL and Anon key)\n'
                '4. Update the values in supabase_config.dart\n'
                '5. Restart the Flutter app!',
                style: TextStyle(color: Colors.white70, height: 1.6),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
