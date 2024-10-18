import 'package:data_class/data_class.dart';
import 'package:ios/auth/auth_service.dart';
import 'package:ios/user/user_service.dart';

final di = () {
  final UserService userService = LocalUserService();
  final AuthService authService = LocalAuthService(userService: userService);

  return DI(
    userService: userService,
    authService: authService,
  );
}();

@Data()
class DI {
  final AuthService authService;
  final UserService userService;
}
