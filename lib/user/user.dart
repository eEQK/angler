import 'package:ios/lesson/lesson.dart';
import 'package:json/json.dart';

@JsonCodable()
class User {
  const User({
    required this.login,
    required this.password,
    this.level,
  });

  final String login;
  final String password;

  final Level? level;

  bool isInitialized() => level != null;

  User copyWith({
    String? login,
    String? password,
    Level? level,
  }) =>
      User(
        login: login ?? this.login,
        password: password ?? this.password,
        level: level ?? this.level,
      );
}
