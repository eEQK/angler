import 'package:data_class/data_class.dart';
import 'package:ios/auth/auth_service.dart';
import 'package:ios/lesson/lesson_service.dart';
import 'package:ios/user/user_service.dart';
import 'package:localstore/localstore.dart';

// ignore: unnecessary_late
late final di = () {
  final db = Localstore.instance;
  final users = db.collection('users');
  final lessons = db.collection('lessons');
  final attempts = db.collection('attempts');

  final UserService userService = LocalUserService(users);
  final AuthService authService = LocalAuthService(userService: userService);
  final LessonService lessonService = LocalLessonService(lessons, attempts);

  return DI(
    userService: userService,
    authService: authService,
    lessonService: lessonService,
  );
}();

@Data()
class DI {
  final AuthService authService;
  final UserService userService;
  final LessonService lessonService;
}
