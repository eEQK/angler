import 'package:json/json.dart';

class Level {
  const Level._(this.value);

  final String value;

  static final Level b1 = Level._('B1');
  static final Level b2 = Level._('B2');

  Map<String, dynamic> toJson() => {'value': value};
  factory Level.fromJson(Map<String, Object?> json) {
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
