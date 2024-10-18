import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:ios/auth/ui/auth_screen.dart';
import 'package:ios/di.dart';
import 'package:ios/home/language_level_screen.dart';
import 'package:ios/user/ui/user_screen.dart';

class HomeScreen extends HookWidget {
  const HomeScreen({super.key});

  static const route = '/home';

  @override
  Widget build(BuildContext context) {
    useEffect(() {
      ensureUserInitialized(context);
      return null;
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Squibbble'),
        actions: [
          IconButton.filledTonal(
            onPressed: () => Navigator.of(context).pushNamed(UserScreen.route),
            icon: Icon(Icons.person),
          ),
        ],
      ),
      body: const SizedBox.shrink(),
    );
  }

  void ensureUserInitialized(BuildContext context) async {
    final user = await di.authService.currentUser();
    if (user == null && context.mounted) {
      Navigator.of(context).pushReplacementNamed(AuthScreen.route);
    } else if (!user!.isInitialized() && context.mounted) {
      Navigator.of(context).pushReplacementNamed(LanguageLevelScreen.route);
    }
  }
}
