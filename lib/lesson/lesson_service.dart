import 'dart:developer';
import 'dart:math';

import 'package:flutter/services.dart';
import 'package:ios/lesson/lesson.dart';
import 'package:ios/main.dart';
import 'package:localstore/localstore.dart';

const _images = [
  'https://images.unsplash.com/photo-1532033375034-a29004ea9769?q=50&w=1000&auto=format&fit=crop',
  'https://images.unsplash.com/photo-1721332149346-00e39ce5c24f?q=50&w=1000&auto=format&fit=crop',
  'https://images.unsplash.com/photo-1729281260962-96168dcaff4f?q=50&w=1000&auto=format&fit=crop',
  'https://images.unsplash.com/photo-1729148074715-78de89a6bed2?q=50&w=1000&auto=format&fit=crop',
  'https://images.unsplash.com/photo-1728934189385-ac692470acf6?q=50&w=1000&auto=format&fit=crop',
];

abstract class LessonService {
  Future<List<Lesson>> getLessons(Level level);
  Future<Lesson> getLesson(String id);
  Future<List<Attempt>> getAttempts(String user, String lessonId);
  Future<Attempt> getAttempt(String id);
  Future<String> submit(String user, String lessonId, List<int> answers);
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
    return all!.values
        .map((e) => Lesson.fromJson(e))
        .where((e) => e.level == level)
        .toList();
  }

  @override
  Future<String> submit(String user, String lessonId, List<int> answers) async {
    final lesson = await getLesson(lessonId);

    var correct = 0;
    for (var i = 0; i < lesson.questions.length; i++) {
      if (lesson.questions[i].correctAnswerIndex == answers[i]) {
        correct++;
      }
    }

    final id = uuid.v7();
    _attempts.doc(id).set(
          Attempt(
            id: id,
            lessonId: lessonId,
            userId: user,
            answers: answers,
            timestamp: DateTime.now().millisecondsSinceEpoch,
            score: correct / lesson.questions.length,
          ).toJson(),
        );

    final percentage = correct / lesson.questions.length;
    // threshold for completion is so low just for testing purposes
    const threshold = 0.2;
    if (percentage >= threshold) {
      await _lessons.doc(lessonId).set(lesson.toJson()..['isCompleted'] = true);
      _checkIfExamUnlocked(lesson);
    }

    return id;
  }

  void _checkIfExamUnlocked(Lesson lesson) async {
    const quizzesPerExam = _targetQuizzes / _targetExams;

    final ordinal = lesson.ordinal;
    final lowerBound = ordinal ~/ quizzesPerExam * quizzesPerExam;
    final upperBound = lowerBound + quizzesPerExam;

    final lessons = await getLessons(lesson.level);
    final quizzes = lessons
        .where((e) => e.type == LessonType.quiz)
        .where((e) => e.ordinal >= lowerBound && e.ordinal < upperBound)
        .toList();

    final completed = quizzes.every((e) => e.isCompleted);
    if (completed) {
      final exams = lessons.where((e) => e.type == LessonType.exam).toList();
      final unlockedOrdinal = lowerBound ~/ quizzesPerExam;
      final unlockedExam =
          exams.firstWhere((e) => e.ordinal == unlockedOrdinal);

      final exam = await _lessons.doc(unlockedExam.id).get();

      await _lessons
          .doc(unlockedExam.id)
          .set(exam!..['isLocked'] = false);
    }
  }

  @override
  Future<List<Attempt>> getAttempts(String user, String lessonId) {
    return _attempts
        .get()
        .then(
          (value) => value!.values.map((e) => Attempt.fromJson(e)).toList(),
        )
        .then(
          (value) => value
              .where((e) => e.userId == user && e.lessonId == lessonId)
              .toList(),
        );
  }

  @override
  Future<Attempt> getAttempt(String id) {
    return _attempts.doc(id).get().then((value) => Attempt.fromJson(value!));
  }

  static Future<void> maybeInitializeFromCsv() async {
    final coll = Localstore.instance.collection('lessons');
    // await coll.delete();
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
          correctAnswerIndex: int.parse(answer) - 1,
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
      _targetQuizzes,
      (index) {
        final start = index * chunks;
        final end = start + chunks;

        return Lesson(
          id: uuid.v7(),
          name: 'Chapter ${index + 1}',
          description:
              'This chapter will give you some introduction into the terms used in business (change me)',
          label: 'Business headstart (change me)',
          imageUrl: _images[Random().nextInt(_images.length)],
          type: LessonType.quiz,
          isCompleted: false,
          isLocked: false,
          questions: questions.sublist(start, end),
          level: level,
          ordinal: index,
        );
      },
    );
  }

  static List<Lesson> _calculateExams(List<Lesson> lessons) {
    final chunks = lessons.length ~/ _targetExams;

    return List.generate(
      _targetExams,
      (index) {
        final start = index * chunks;
        final end = start + chunks;

        return Lesson(
          id: uuid.v7(),
          name: 'Exam ${index + 1}',
          description:
              'This exam will test your knowledge on the terms used in business (change me)',
          label: 'Business exam (change me)',
          imageUrl: _images[Random().nextInt(_images.length)],
          type: LessonType.exam,
          isCompleted: false,
          isLocked: true,
          questions:
              lessons.sublist(start, end).expand((e) => e.questions).toList(),
          level: lessons.first.level,
          ordinal: index,
        );
      },
    );
  }
}
