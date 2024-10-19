import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:ios/di.dart';
import 'package:ios/home/home_screen.dart';
import 'package:ios/lesson/lesson.dart';
import 'package:ios/user/user.dart';
import 'package:ios/utils/hooks.dart';
import 'package:ios/widgets/spacing.dart';

class LanguageLevelScreen extends HookWidget {
  const LanguageLevelScreen({super.key});

  static const route = '/language-level';

  @override
  Widget build(BuildContext context) {
    final userSnapshot = useMemoFuture(() => di.authService.currentUser());

    if (!userSnapshot.hasData) {
      return Center(child: CircularProgressIndicator());
    }

    final user = userSnapshot.data!;

    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '👋  Hello, ${user.login}!',
            style: Theme.of(context).textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          kVertical64,
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Text(
              'Which level would you like to choose?',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
          ),
          kVertical24,
          _LevelTile(
            label: 'B1',
            title: 'I want the basics',
            onTap: () => _onLevelSelected(context, Level.b1, user),
          ),
          _LevelTile(
            label: 'B2',
            title: 'I want a challenge',
            onTap: () => _onLevelSelected(context, Level.b2, user),
          ),
        ],
      ),
    );
  }

  void _onLevelSelected(BuildContext context, Level level, User user) {
    di.userService.updateUserLevel(user.login, level);
    Navigator.of(context).pushReplacementNamed(HomeScreen.route);
  }
}

class _LevelTile extends StatelessWidget {
  const _LevelTile({
    required this.onTap,
    required this.label,
    required this.title,
  });

  final VoidCallback onTap;
  final String label;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(child: Text(label)),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
          ),
        ),
        tileColor: Theme.of(context).colorScheme.surfaceContainer,
        title: Text(title, style: Theme.of(context).textTheme.titleMedium),
        trailing: const Icon(Icons.arrow_forward_ios),
        minTileHeight: 76,
      ),
    );
  }
}
