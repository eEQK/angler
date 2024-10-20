import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:ios/di.dart';
import 'package:ios/lesson/lesson.dart';
import 'package:ios/utils/hooks.dart';
import 'package:ios/widgets/spacing.dart';

class ResultScreen extends HookWidget {
  const ResultScreen({super.key});

  static const route = '/result';

  @override
  Widget build(BuildContext context) {
    final attemptId = ModalRoute.of(context)!.settings.arguments as String;
    final attempt = useMemoFuture(() => di.lessonService.getAttempt(attemptId));
    if (attempt.connectionState == ConnectionState.waiting) {
      return Center(child: CircularProgressIndicator());
    }

    final lesson = useMemoFuture(
      () => di.lessonService.getLesson(attempt.requireData.lessonId),
    );
    if (lesson.connectionState == ConnectionState.waiting) {
      return Center(child: CircularProgressIndicator());
    }

    final percentage = attempt.requireData.score * 100 ~/ 1;
    final total = attempt.requireData.answers.length;
    final correct = total * attempt.requireData.score ~/ 1;

    return Scaffold(
      appBar: AppBar(
        title: Text('Result'),
        leading: CloseButton(),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          kVertical64,
          Text(
            'Congratulations!',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          kVertical16,
          Text(
            'You got $percentage% ($correct/$total) of the questions correct.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          kVertical64,
          Column(
            children: [
              for (int i = 0; i < total; i++)
                _AnswerTile(
                  lesson.requireData.questions[i],
                  attempt.requireData.answers[i],
                ),
            ],
          ),
          kVertical16,
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Close'),
            ),
          ),
          kVertical64,
        ],
      ),
    );
  }
}

class _AnswerTile extends StatelessWidget {
  const _AnswerTile(this.question, this.answer);

  final Question question;
  final int answer;

  @override
  Widget build(BuildContext context) {
    final isCorrect = question.correctAnswerIndex == answer;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: isCorrect ? Colors.green : Colors.red,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                child: Icon(isCorrect ? Icons.check : Icons.close),
              ),
              kHorizontal12,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      question.content,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    kVertical4,
                    Text(
                      'Your answer: ${question.answers[answer]}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    if (!isCorrect) ...[
                      kVertical24,
                      Text(
                        'Correct answer: ${question.answers[question.correctAnswerIndex]}',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      kVertical4,
                      Text(
                        question.comment,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
