import 'dart:async';
import 'dart:convert';

import 'package:ios/main.dart';
import 'package:ios/user/user.dart';

abstract class UserService {
  Future<User?> getUser(String login);
  Future<void> saveUser(User user);
  Future<void> updateUserLevel(String login, Level level);
}

class LocalUserService implements UserService {
  static const _usersKey = 'users';

  final _users = {
    for (final e in (prefs.getStringList(_usersKey) ?? [])
        .map((e) => User.fromJson(jsonDecode(e))))
      e.login: e,
  };

  Map<String, User> get users => _users;
  set users(Map<String, User> value) {
    _users.clear();
    _users.addAll(value);

    unawaited(
      prefs.setStringList(
        _usersKey,
        users.values.map((e) => jsonEncode(e.toJson())).toList(),
      ),
    );
  }

  @override
  Future<User?> getUser(String login) async {
    return users[login];
  }

  @override
  Future<void> updateUserLevel(String login, Level level) async {
    final user = users[login]!;
    users[login] = user.copyWith(level: level);
    await prefs.setStringList(
      _usersKey,
      users.values.map((e) => jsonEncode(e.toJson())).toList(),
    );
  }

  @override
  Future<void> saveUser(User user) async {
    users[user.login] = user;
    await prefs.setStringList(
      _usersKey,
      users.values.map((e) => jsonEncode(e.toJson())).toList(),
    );
  }
}
