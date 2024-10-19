import 'package:json/json.dart';

class LessonType {
  const LessonType._(this.value);

  final String value;

  static final LessonType quiz = LessonType._('quiz');
  static final LessonType exam = LessonType._('exam');

  Map<String, dynamic> toJson() => {'value': value};
  factory LessonType.fromJson(dynamic json) {
    switch (json['value']) {
      case 'quiz':
        return LessonType.quiz;
      case 'exam':
        return LessonType.exam;
      default:
        throw Exception('Unknown type: $json');
    }
  }
}

class Level {
  const Level._(this.value);

  final String value;

  static final Level b1 = Level._('B1');
  static final Level b2 = Level._('B2');

  Map<String, dynamic> toJson() => {'value': value};
  factory Level.fromJson(dynamic json) {
    switch (json['value']) {
      case 'B1':
        return Level.b1;
      case 'B2':
        return Level.b2;
      default:
        throw Exception('Unknown level: $json');
    }
  }
}

@JsonCodable()
class Lesson {
  const Lesson({
    required this.id,
    required this.name,
    required this.description,
    required this.label,
    required this.imageUrl,
    required this.type,
    required this.isCompleted,
    required this.isLocked,
    required this.questions,
    required this.level,
  });

  final String id;
  final String name;

  final String description;
  final String label;
  final String imageUrl;

  final LessonType type;
  final bool isCompleted;
  final bool isLocked;

  final Level level;

  final List<Question> questions;
}

@JsonCodable()
class Question {
  const Question({
    required this.id,
    required this.content,
    required this.answers,
    required this.correctAnswerIndex,
    required this.comment,
    required this.level,
  });

  final String id;
  final String content;
  final List<String> answers;
  final int correctAnswerIndex;
  final String comment;
  final Level level;
}

@JsonCodable()
class Attempt {
  const Attempt({
    required this.id,
    required this.lessonId,
    required this.userId,
    required this.answers,
  });

  final String id;
  final String lessonId;
  final String userId;
  final List<int> answers;
}
