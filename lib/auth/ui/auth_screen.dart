import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:ios/di.dart';
import 'package:ios/home/home_screen.dart';
import 'package:ios/home/language_level_screen.dart';
import 'package:ios/widgets/spacing.dart';

enum _AuthMode { login, register }

class AuthScreen extends HookWidget {
  const AuthScreen({super.key});

  static const route = '/auth';

  @override
  Widget build(BuildContext context) {
    final mode = useState(_AuthMode.login);
    final displayError = useState(false);

    final login = useTextEditingController();
    final password = useTextEditingController();

    final textStyles = Theme.of(context).textTheme;

    return Scaffold(
      body: Form(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('🇬🇧', style: textStyles.displayLarge),
              kVertical24,
              Text('Squibbble', style: textStyles.headlineLarge),
              kVertical8,
              Text(
                'Your English learning companion',
                style: textStyles.titleLarge,
                textAlign: TextAlign.center,
              ),
              kVertical64,
              _TextField(
                controller: login,
                label: 'Login',
              ),
              kVertical8,
              _TextField(
                controller: password,
                label: 'Password',
              ),
              if (displayError.value)
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    switch (mode.value) {
                      _AuthMode.login => 'Invalid login or password',
                      _AuthMode.register => 'Account already exists',
                    },
                    style: textStyles.bodyMedium!.copyWith(color: Colors.red),
                  ),
                ),
              kVertical12,
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton(
                  onPressed: () async {
                    displayError.value = false;

                    final user = await switch (mode.value) {
                      _AuthMode.login =>
                        di.authService.login(login.text, password.text),
                      _AuthMode.register =>
                        di.authService.createAccount(login.text, password.text),
                    };

                    displayError.value = user == null;

                    if (user != null && context.mounted) {
                      Navigator.of(context).pushReplacementNamed(
                        user.level != null
                            ? HomeScreen.route
                            : LanguageLevelScreen.route,
                      );
                    }
                  },
                  child: Text(
                    mode.value == _AuthMode.login ? 'Log in' : 'Create account',
                  ),
                ),
              ),
              kVertical24,
              if (mode.value == _AuthMode.login)
                TextButton(
                  onPressed: () {
                    displayError.value = false;
                    mode.value = _AuthMode.register;
                  },
                  child: Text('I already have an account'),
                )
              else
                TextButton(
                  onPressed: () {
                    displayError.value = false;
                    mode.value = _AuthMode.login;
                  },
                  child: Text('I want to log in instead'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TextField extends StatelessWidget {
  const _TextField({required this.controller, required this.label});

  final TextEditingController controller;
  final String label;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        labelText: label,
      ),
    );
  }
}
