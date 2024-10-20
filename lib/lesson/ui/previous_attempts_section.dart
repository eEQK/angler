import 'package:flutter/material.dart';
import 'package:ios/lesson/lesson.dart';
import 'package:ios/widgets/spacing.dart';

class PreviousAttemptsSection extends StatelessWidget {
  const PreviousAttemptsSection({super.key, required this.attempts});

  final List<Attempt> attempts;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Divider(),
          Text(
            'Previous attempts',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          kVertical12,
          for (final attempt in attempts)
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                ),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  child: Text('${attempt.score * 100 ~/ 1}%'),
                ),
                title: Text(
                  MaterialLocalizations.of(context).formatFullDate(
                    DateTime.fromMillisecondsSinceEpoch(attempt.timestamp),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
