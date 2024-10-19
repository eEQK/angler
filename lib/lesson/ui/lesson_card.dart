import 'package:flutter/material.dart';
import 'package:ios/lesson/lesson.dart';
import 'package:ios/widgets/spacing.dart';

class LessonCard extends StatelessWidget {
  const LessonCard({
    super.key,
    required this.lesson,
  });

  final Lesson lesson;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Theme.of(context).colorScheme.surfaceContainer,
      ),
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Image.asset(lesson.imageUrl, fit: BoxFit.cover),
          ),
          kVertical16,
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              lesson.label,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          kVertical16,
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              lesson.description,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          kVertical24,
        ],
      ),
    );
  }
}
