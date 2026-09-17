import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

// Services
import 'services/audio_service.dart';

// Screens
import 'screens/signup_screen.dart';
import 'screens/profile_setup_screen.dart' as profile;
import 'screens/home_screen.dart' as home;
import 'screens/settings_screen.dart';
import 'screens/workout_screen.dart';
import 'screens/music_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final isSignedUp = prefs.getBool('isSignedUp') ?? false;
  final isProfileComplete = prefs.getBool('isProfileComplete') ?? false;
  final isDarkMode = prefs.getBool('darkMode') ?? false;

  runApp(
    ChangeNotifierProvider(
      create: (_) => AudioService(), // ✅ Removed .init()
      child: MyApp(
        isSignedUp: isSignedUp,
        isProfileComplete: isProfileComplete,
        isDarkMode: isDarkMode,
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool isSignedUp;
  final bool isProfileComplete;
  final bool isDarkMode;

  const MyApp({
    super.key,
    required this.isSignedUp,
    required this.isProfileComplete,
    required this.isDarkMode,
  });

  Future<Widget> _getInitialScreen() async {
    if (!isSignedUp) {
      return const SignUpScreen();
    } else if (!isProfileComplete) {
      return const profile.ProfileSetupScreen();
    } else {
      return const home.HomeScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Fitness App',
      theme: isDarkMode ? ThemeData.dark() : ThemeData.light(),
      home: FutureBuilder<Widget>(
        future: _getInitialScreen(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          } else if (snapshot.hasError) {
            return Scaffold(
              body: Center(child: Text('Error: ${snapshot.error}')),
            );
          } else {
            return snapshot.data!;
          }
        },
      ),
      routes: {
        '/settings': (context) => const SettingsScreen(),
        '/workout': (context) => const WorkoutScreen(),
        '/music': (context) => const MusicScreen(),
      },
    );
  }
}
