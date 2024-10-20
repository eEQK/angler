import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:ios/di.dart';
import 'package:ios/lesson/ui/lesson_card.dart';
import 'package:ios/lesson/ui/previous_attempts_section.dart';
import 'package:ios/lesson/ui/questions_screen.dart';
import 'package:ios/utils/hooks.dart';
import 'package:ios/widgets/spacing.dart';

class LessonScreen extends HookWidget {
  const LessonScreen({super.key});

  static const route = '/lesson';

  @override
  Widget build(BuildContext context) {
    final id = ModalRoute.of(context)!.settings.arguments as String;

    final quiz = useMemoFuture(() => di.lessonService.getLesson(id));
    if (quiz.connectionState == ConnectionState.waiting) {
      return Center(child: CircularProgressIndicator());
    }

    final previousAttempts = useMemoFuture(
      () async {
        final user = await di.authService.currentUser();
        return di.lessonService.getAttempts(quiz.requireData.id, user!.login);
      },
    );

    return Scaffold(
      appBar: AppBar(title: Text(quiz.requireData.name)),
      body: Column(
        children: [
          LessonCard(lesson: quiz.requireData),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (quiz.requireData.isLocked)
                  Expanded(child: _LockedInfo())
                else
                  const SizedBox.shrink(),
                FilledButton(
                  onPressed: quiz.requireData.isLocked
                      ? null
                      : () => Navigator.of(context).pushNamed(
                            QuestionsScreen.route,
                            arguments: quiz.requireData.id,
                          ),
                  child: const Text('Begin'),
                ),
              ],
            ),
          ),
          if (previousAttempts.connectionState == ConnectionState.waiting)
            Center(child: CircularProgressIndicator()),
          if (previousAttempts.data != null)
            PreviousAttemptsSection(attempts: previousAttempts.requireData),
        ],
      ),
    );
  }
}

class _LockedInfo extends StatelessWidget {
  const _LockedInfo();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.lock_outline, color: Theme.of(context).colorScheme.primary),
        kHorizontal12,
        Flexible(
          child: Text(
            'This unit will be unlocked once you progress some more',
            style: TextStyle(color: Theme.of(context).colorScheme.primary),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ),
      ],
    );
  }
}
