import 'dart:async';

import 'package:ios/user/user.dart';
import 'package:localstore/localstore.dart';

abstract class UserService {
  Future<User?> getUser(String login);
  Future<void> saveUser(User user);
  Future<void> updateUserLevel(String login, Level level);
}

class LocalUserService implements UserService {
  const LocalUserService(CollectionRef users) : _users = users;

  final CollectionRef _users;

  @override
  Future<User?> getUser(String login) async {
    final data = await _users.doc(login).get();
    return data != null ? User.fromJson(data) : null;
  }

  @override
  Future<void> updateUserLevel(String login, Level level) async {
    final user = await _users.doc(login).get();
    if (user == null) {
      throw 'user not found';
    }

    await _users.doc(login).set({'level': level.value});
  }

  @override
  Future<void> saveUser(User user) async {
    _users.doc(user.login).set(user.toJson());
  }
}
