import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:ios/auth/ui/auth_screen.dart';
import 'package:ios/di.dart';
import 'package:ios/home/home_screen.dart';
import 'package:ios/home/language_level_screen.dart';
import 'package:ios/lesson/lesson_service.dart';
import 'package:ios/lesson/ui/lesson_screen.dart';
import 'package:ios/lesson/ui/questions_screen.dart';
import 'package:ios/lesson/ui/result_screen.dart';
import 'package:ios/user/ui/user_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

late final SharedPreferencesWithCache prefs;
final uuid = const Uuid();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await LocalLessonService.maybeInitializeFromCsv();
  prefs = await SharedPreferencesWithCache.create(
    cacheOptions: SharedPreferencesWithCacheOptions(),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (_) => const _LoadingScreen(),
        HomeScreen.route: (_) => const HomeScreen(),
        AuthScreen.route: (_) => const AuthScreen(),
        LanguageLevelScreen.route: (_) => const LanguageLevelScreen(),
        LessonScreen.route: (_) => const LessonScreen(),
        QuestionsScreen.route: (_) => const QuestionsScreen(),
        ResultScreen.route: (_) => const ResultScreen(),
        UserScreen.route: (_) => const UserScreen(),
      },
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
    );
  }
}

class _LoadingScreen extends HookWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    useEffect(
      () {
        di.authService.isAuthenticated().then((isAuthenticated) {
          final route = isAuthenticated ? HomeScreen.route : AuthScreen.route;

          if (context.mounted) {
            Navigator.of(context).pushReplacementNamed(route);
          }
        });

        return null;
      },
      const [],
    );

    return Scaffold(
      body: Center(
        child: CircularProgressIndicator.adaptive(),
      ),
    );
  }
}
