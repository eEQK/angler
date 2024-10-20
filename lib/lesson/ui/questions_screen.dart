import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:ios/di.dart';
import 'package:ios/lesson/lesson.dart';
import 'package:ios/lesson/ui/result_screen.dart';
import 'package:ios/utils/hooks.dart';
import 'package:ios/widgets/spacing.dart';

class QuestionsScreen extends HookWidget {
  const QuestionsScreen({super.key});

  static const route = '/questions';

  @override
  Widget build(BuildContext context) {
    final id = ModalRoute.of(context)!.settings.arguments as String;

    final lesson = useMemoFuture(() => di.lessonService.getLesson(id));
    if (lesson.connectionState == ConnectionState.waiting) {
      return Center(child: CircularProgressIndicator());
    }

    final answers = useState<List<int>>(
      List.filled(lesson.requireData.questions.length, -1),
    );
    final progress = useMemoized(
      () =>
          answers.value.where((e) => e != -1).length /
          lesson.requireData.questions.length *
          100 ~/
          1,
      [answers.value],
    );

    final viewIndex = useState(0);
    final question = useMemoized(
      () => lesson.requireData.questions[viewIndex.value],
      [viewIndex.value],
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          lesson.requireData.type == LessonType.quiz ? 'Quiz' : 'Exam',
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          kVertical12,
          _ProgressSummary(
            progress: progress,
            lesson: lesson,
          ),
          kVertical64,
          Text(
            question.content,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          kVertical32,
          for (var i = 0; i < question.answers.length; i++)
            RadioListTile<int>(
              value: i,
              groupValue: answers.value[viewIndex.value],
              onChanged: (value) {
                answers.value[viewIndex.value] = value!;
                answers.value = List.of(answers.value);
              },
              title: Text(question.answers[i]),
            ),
          OverflowBar(
            alignment: MainAxisAlignment.end,
            spacing: 16,
            children: [
              if (viewIndex.value > 0)
                TextButton(
                  child: const Text('Back'),
                  onPressed: () => viewIndex.value--,
                ),
              if (viewIndex.value == lesson.requireData.questions.length - 1)
                FilledButton(
                  onPressed: () async {
                    final user = await di.authService.currentUser();
                    final id = await di.lessonService.submit(
                      user!.login,
                      lesson.requireData.id,
                      answers.value,
                    );

                    if (context.mounted) {
                      Navigator.of(context).pushNamed(
                        ResultScreen.route,
                        arguments: id,
                      );
                    }
                  },
                  child: const Text('Finish'),
                ),
              if (viewIndex.value < lesson.requireData.questions.length - 1)
                FilledButton.tonal(
                  onPressed: answers.value[viewIndex.value] == -1
                      ? null
                      : () => viewIndex.value++,
                  child: const Text('Continue'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProgressSummary extends StatelessWidget {
  const _ProgressSummary({
    required this.progress,
    required this.lesson,
  });

  final int progress;
  final AsyncSnapshot<Lesson> lesson;

  @override
  Widget build(BuildContext context) {
    final total = lesson.requireData.questions.length;

    return Material(
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      color: Theme.of(context).colorScheme.surfaceContainer,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: ListTile(
          leading: CircleAvatar(child: Text('$progress%')),
          title: Text(
            lesson.requireData.name,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          trailing: Text(
            '${(total * progress ~/ 100).toInt()} / $total',
          ),
        ),
      ),
    );
  }
}
