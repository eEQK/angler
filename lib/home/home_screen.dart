import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:ios/auth/ui/auth_screen.dart';
import 'package:ios/di.dart';
import 'package:ios/home/language_level_screen.dart';
import 'package:ios/lesson/lesson.dart';
import 'package:ios/lesson/ui/lesson_screen.dart';
import 'package:ios/user/ui/user_screen.dart';
import 'package:ios/user/user.dart';
import 'package:ios/utils/hooks.dart';
import 'package:ios/widgets/spacing.dart';

class HomeScreen extends HookWidget {
  const HomeScreen({super.key});

  static const route = '/home';

  @override
  Widget build(BuildContext context) {
    final user = useMemoFuture(() => di.authService.currentUser());
    useEffect(
      () {
        ensureUserInitialized(context, user);
        return null;
      },
      [user],
    );

    if (user.connectionState == ConnectionState.waiting) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final lessonsRefreshTrigger = useState(0);
    final lessons = useMemoFuture(
      () => di.lessonService.getLessons(user.requireData!.level!),
      [lessonsRefreshTrigger.value],
    );
    if (lessons.connectionState == ConnectionState.waiting) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final upcoming = lessons.requireData
        .where((e) => e.type == LessonType.quiz && !e.isCompleted)
        .toList();
    final completed = lessons.requireData
        .where((e) => e.type == LessonType.quiz && e.isCompleted)
        .toList();
    final exams =
        lessons.requireData.where((e) => e.type == LessonType.exam).toList();

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
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [
          _Section(
            label: '🤓  Upcoming lessons',
            child: _HorizontalLessons(
              lessons: upcoming,
              onTap: (lesson) => Navigator.of(context)
                  .pushNamed(LessonScreen.route, arguments: lesson.id)
                  .then((_) => lessonsRefreshTrigger.value++),
            ),
          ),
          _Section(
            label: '✍️  Exams',
            child: _HorizontalLessons(
              lessons: exams,
              onTap: (lesson) => Navigator.of(context)
                  .pushNamed(LessonScreen.route, arguments: lesson.id)
                  .then((_) => lessonsRefreshTrigger.value++),
            ),
          ),
          if (completed.isNotEmpty)
            _Section(
              label: '😎  Finished lessons',
              child: _HorizontalLessons(
                lessons: completed,
                onTap: (lesson) => Navigator.of(context)
                    .pushNamed(LessonScreen.route, arguments: lesson.id)
                    .then((_) => lessonsRefreshTrigger.value++),
              ),
            ),
        ],
      ),
    );
  }

  void ensureUserInitialized(
    BuildContext context,
    AsyncSnapshot<User?> user,
  ) async {
    if (user.connectionState == ConnectionState.waiting) {
      return;
    } else if (user.data == null) {
      Navigator.of(context).pushReplacementNamed(AuthScreen.route);
    } else if (!user.requireData!.isInitialized()) {
      Navigator.of(context).pushReplacementNamed(LanguageLevelScreen.route);
    }
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(label, style: Theme.of(context).textTheme.titleLarge),
        ),
        kVertical8,
        child,
      ],
    );
  }
}

class _HorizontalLessons extends StatelessWidget {
  const _HorizontalLessons({required this.lessons, required this.onTap});

  final List<Lesson> lessons;
  final ValueChanged<Lesson> onTap;

  @override
  Widget build(BuildContext context) {
    const padding = 8.0;
    final textHeight = MediaQuery.textScalerOf(context)
        .scale(Theme.of(context).textTheme.titleMedium!.fontSize!);

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: 96 + padding * 2 + 4 + textHeight),
      child: CarouselView(
        itemExtent: 96 + padding * 2,
        shrinkExtent: 96 + padding * 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: EdgeInsets.symmetric(horizontal: padding),
        onTap: (e) => onTap(lessons[e]),
        children: [
          for (final lesson in lessons) _LessonCard(lesson),
        ],
      ),
    );
  }
}

class _LessonCard extends StatelessWidget {
  const _LessonCard(this.lesson);

  final Lesson lesson;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 96,
          height: 96,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              ColorFiltered(
                colorFilter: ColorFilter.mode(
                  lesson.isLocked
                      ? Theme.of(context).colorScheme.surfaceContainer
                      : Colors.transparent,
                  BlendMode.saturation,
                ),
                child: Image.network(lesson.imageUrl, fit: BoxFit.cover),
              ),
              if (lesson.isCompleted)
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check_circle,
                      color: Colors.green,
                    ),
                  ),
                ),
              if (lesson.isLocked)
                Positioned.fill(
                  child: Container(
                    color: Theme.of(context)
                        .colorScheme
                        .surfaceContainer
                        .withAlpha(130),
                    child: Center(
                      child: Icon(
                        Icons.lock,
                        size: 32,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        kVertical4,
        Text(
          lesson.name,
          style: Theme.of(context).textTheme.titleMedium,
          maxLines: 1,
        ),
      ],
    );
  }
}
