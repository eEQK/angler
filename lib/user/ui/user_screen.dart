import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:ios/auth/ui/auth_screen.dart';
import 'package:ios/di.dart';
import 'package:ios/user/user.dart';
import 'package:ios/utils/hooks.dart';
import 'package:ios/widgets/spacing.dart';

class UserScreen extends HookWidget {
  const UserScreen({super.key});

  static const route = '/user';

  @override
  Widget build(BuildContext context) {
    final user = useMemoFuture(() => di.authService.currentUser());

    if (user.connectionState == ConnectionState.waiting) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('User profile')),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          kVertical32,
          Center(
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 64,
                  child: Icon(Icons.person_outline, size: 72),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: IconButton.filled(
                    icon: Icon(Icons.edit),
                    onPressed: () {},
                  ),
                ),
              ],
            ),
          ),
          kVertical32,
          TextButton(
            onPressed: () async {
              await di.authService.logout();
              if (context.mounted) {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  AuthScreen.route,
                  (route) => false,
                );
              }
            },
            child: Text('Sign out'),
          ),
          kVertical32,
          _ChangePassword(user.requireData!),
        ],
      ),
    );
  }
}

class _ChangePassword extends HookWidget {
  const _ChangePassword(this.user);

  final User user;

  @override
  Widget build(BuildContext context) {
    final oldPasswordController = useTextEditingController();
    final newPasswordController = useTextEditingController();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(),
        Text('Change password'),
        kVertical16,
        TextField(
          controller: oldPasswordController,
          obscureText: true,
          decoration: InputDecoration(
            labelText: 'Current password',
            border: OutlineInputBorder(),
          ),
        ),
        kVertical8,
        TextField(
          controller: newPasswordController,
          obscureText: true,
          decoration: InputDecoration(
            labelText: 'New password',
            border: OutlineInputBorder(),
          ),
        ),
        kVertical12,
        Align(
          alignment: Alignment.centerRight,
          child: FilledButton(
            onPressed: () async {
              try {
                await di.authService.changePassword(
                  oldPasswordController.text,
                  newPasswordController.text,
                );
                oldPasswordController.clear();
                newPasswordController.clear();
                if (context.mounted) {
                  FocusScope.of(context).unfocus();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Password changed')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to change password: $e'),
                    ),
                  );
                }
              }
            },
            child: Text('Confirm'),
          ),
        ),
      ],
    );
  }
}
