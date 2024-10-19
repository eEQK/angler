import 'package:flutter/services.dart';
import 'package:ios/lesson/lesson.dart';
import 'package:ios/main.dart';
import 'package:localstore/localstore.dart';

abstract class LessonService {
  Future<List<Lesson>> getLessons(Level level);
  Future<Lesson> getLesson(String id);
  Future<List<Attempt>> getAttempts(String user, String lessonId);
  Future<void> submit(String user, String lessonId, List<int> answers);
}

const _lessonsCsv = 'assets/grammar.csv';
const _headerRows = 1;
final _separator = String.fromCharCode(0x1f);
const _targetQuizzes = 20;
const _targetExams = 2;

class LocalLessonService implements LessonService {
  LocalLessonService(this._lessons, this._attempts);

  final CollectionRef _lessons;
  final CollectionRef _attempts;

  @override
  Future<Lesson> getLesson(String id) {
    return _lessons.doc(id).get().then((value) => Lesson.fromJson(value!));
  }

  @override
  Future<List<Lesson>> getLessons(Level level) async {
    // localstore doesn't seem to support querying, so get all and filter client-side
    final all = await _lessons.get();
    return all!.values.map((e) => Lesson.fromJson(e)).toList();
  }

  @override
  Future<void> submit(String user, String lessonId, List<int> answers) async {
    final id = uuid.v7();
    _attempts.doc(id).set(
          Attempt(
            id: id,
            lessonId: lessonId,
            userId: user,
            answers: answers,
          ).toJson(),
        );
  }

  @override
  Future<List<Attempt>> getAttempts(String user, String lessonId) {
    return _attempts
        .where('userId', isEqualTo: user)
        .where('lessonId', isEqualTo: lessonId)
        .get()
        .then(
          (value) => value!.values.map((e) => Attempt.fromJson(e)).toList(),
        );
  }

  static Future<void> maybeInitializeFromCsv() async {
    final coll = Localstore.instance.collection('lessons');
    final items = await coll.get();
    if (items != null && items.isNotEmpty) {
      return;
    }

    final questions = await _loadQuestions();

    final b1Quizzes = _calculateQuizzes(
      questions.where((e) => e.level == Level.b1).toList(),
      Level.b1,
    );
    final b1Exams = _calculateExams(b1Quizzes);
    final b2Quizzes = _calculateQuizzes(
      questions.where((e) => e.level == Level.b2).toList(),
      Level.b2,
    );
    final b2Exams = _calculateExams(b2Quizzes);

    for (final lesson
        in [b1Quizzes, b1Exams, b2Quizzes, b2Exams].expand((e) => e)) {
      await coll.doc(lesson.id).set(lesson.toJson());
    }
  }

  static Future<List<Question>> _loadQuestions() async {
    final csv = await rootBundle.loadString(_lessonsCsv, cache: false);
    final entries = csv.split('\n').skip(_headerRows).toList();

    final result = <Question>[];

    for (final entry in entries) {
      if (entry.isEmpty) {
        continue;
      }

      final [task, answer, a, b, c, d, comment, topic, level] =
          entry.split(_separator);

      result.add(
        Question(
          id: uuid.v7(),
          content: task,
          answers: [a, b, c, d],
          correctAnswerIndex: int.parse(answer),
          comment: comment,
          level: level == '1' ? Level.b1 : Level.b2,
        ),
      );
    }

    return result;
  }

  static List<Lesson> _calculateQuizzes(List<Question> questions, Level level) {
    final chunks = questions.length ~/ _targetQuizzes;

    return List.generate(
      chunks,
      (index) {
        final start = index * _targetQuizzes;
        final end = start + _targetQuizzes;

        return Lesson(
          id: uuid.v7(),
          name: 'Chapter ${index + 1}',
          description:
              'This chapter will give you some introduction into the terms used in business (change me)',
          label: 'Business headstart (change me)',
          imageUrl: 'assets/wallet.jpg',
          type: LessonType.quiz,
          isCompleted: false,
          isLocked: false,
          questions: questions.sublist(start, end),
          level: level,
        );
      },
    );
  }

  static List<Lesson> _calculateExams(List<Lesson> lessons) {
    final chunks = lessons.length ~/ _targetExams;
    return List.generate(
      chunks,
      (index) {
        final start = index * _targetExams;
        final end = start + _targetExams;

        return Lesson(
          id: uuid.v7(),
          name: 'Exam ${index + 1}',
          description:
              'This exam will test your knowledge on the terms used in business (change me)',
          label: 'Business exam (change me)',
          imageUrl: 'assets/wallet.jpg',
          type: LessonType.exam,
          isCompleted: false,
          isLocked: true,
          questions:
              lessons.sublist(start, end).expand((e) => e.questions).toList(),
          level: lessons.first.level,
        );
      },
    );
  }
}
