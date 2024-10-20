import 'package:collection/collection.dart';
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

    final attemptsRefreshTrigger = useState(0);
    final previousAttempts = useMemoFuture(
      () async {
        final user = await di.authService.currentUser();
        return di.lessonService.getAttempts(user!.login, quiz.requireData.id);
      },
      [attemptsRefreshTrigger.value],
    );

    return Scaffold(
      appBar: AppBar(title: Text(quiz.requireData.name)),
      body: ListView(
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
                      : () async {
                          await Navigator.of(context).pushNamed(
                            QuestionsScreen.route,
                            arguments: quiz.requireData.id,
                          );
                          attemptsRefreshTrigger.value++;
                        },
                  child: const Text('Begin'),
                ),
              ],
            ),
          ),
          TextButton(
            child: Text('(dev only) add random attempt'),
            onPressed: () async {
              final user = await di.authService.currentUser();
              await di.lessonService.submit(
                user!.login,
                quiz.requireData.id,
                [
                  for (var i = 0; i < quiz.requireData.questions.length; i++)
                    i % 4,
                ].shuffled(),
              );
              attemptsRefreshTrigger.value++;
            },
          ),
          if (previousAttempts.connectionState == ConnectionState.waiting)
            Center(child: CircularProgressIndicator()),
          if (previousAttempts.data != null &&
              previousAttempts.requireData.isNotEmpty)
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
