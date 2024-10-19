import 'package:flutter/material.dart';
import 'package:ios/lesson/lesson.dart';
import 'package:ios/widgets/spacing.dart';

class PreviousAttemptsSection extends StatelessWidget {
  const PreviousAttemptsSection({super.key, required this.attempts});

  final List<Attempt> attempts;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Divider(),
        Text(
          'Previous attempts',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        kVertical12,
        for (final attempt in attempts)
          ListTile(
            leading: CircleAvatar(
              child: Text('${attempt.score * 100 ~/ 1}%'),
            ),
            title: Text(
              MaterialLocalizations.of(context).formatFullDate(
                DateTime.fromMillisecondsSinceEpoch(attempt.timestamp),
              ),
            ),
          ),
      ],
    );
  }
}
