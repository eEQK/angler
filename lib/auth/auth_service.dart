import 'package:ios/main.dart';
import 'package:ios/user/user.dart';
import 'package:ios/user/user_service.dart';

abstract class AuthService {
  Future<bool> isAuthenticated();
  Future<User?> currentUser();

  Future<User?> login(String login, String password);
  Future<User?> createAccount(String login, String password);
}

class LocalAuthService implements AuthService {
  static const _loginKey = 'login';

  LocalAuthService({required this.userService});

  final UserService userService;

  @override
  Future<bool> isAuthenticated() async {
    final login = prefs.getString(_loginKey);
    return login != null;
  }

  @override
  Future<User?> createAccount(String login, String password) async {
    final alreadyExists = await userService.getUser(login) != null;
    if (alreadyExists) {
      return null;
    }

    await prefs.setString(_loginKey, login);
    final user = User(login: login, password: password);
    userService.saveUser(user);

    return user;
  }

  @override
  Future<User?> login(String login, String password) async {
    final user = await userService.getUser(login);
    if (user == null || user.password != password) {
      return null;
    }

    await prefs.setString(_loginKey, login);
    return user;
  }

  @override
  Future<User?> currentUser() async {
    final login = prefs.getString(_loginKey);
    if (login == null) {
      return null;
    }

    return userService.getUser(login);
  }
}
