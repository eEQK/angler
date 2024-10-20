import 'dart:async';
import 'dart:convert';

import 'package:image_picker/image_picker.dart';
import 'package:ios/lesson/lesson.dart';
import 'package:ios/user/user.dart';
import 'package:localstore/localstore.dart';

abstract class UserService {
  Future<User?> getUser(String login);
  Future<void> saveUser(User user);
  Future<void> updateLevel(String login, Level level);
  Future<void> updateImage(String login, XFile image);
}

class LocalUserService implements UserService {
  const LocalUserService(this._users);

  final CollectionRef _users;

  @override
  Future<User?> getUser(String login) async {
    final data = await _users.doc(login).get();
    return data != null ? User.fromJson(data) : null;
  }

  @override
  Future<void> updateLevel(String login, Level level) async {
    final user = await _users.doc(login).get();
    if (user == null) {
      throw 'user not found';
    }

    await _users.doc(login).set(
      {'level': level.toJson()},
      SetOptions(merge: true),
    );
  }

  @override
  Future<void> saveUser(User user) async {
    _users.doc(user.login).set(user.toJson(), SetOptions(merge: true));
  }

  @override
  Future<void> updateImage(String login, XFile image) async {
    final user = await _users.doc(login).get();

    final bytes = await image.readAsBytes();
    final base64 = base64Encode(bytes);

    final updatedUser = user!..['image'] = base64;
    await _users.doc(login).set(updatedUser);
  }
}
