import 'package:flutter/material.dart';
import '/core/core.dart';
import '/features/presentation/pages/login/widgets/login_button.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness ==
        Brightness.dark; // Verifica si es modo oscuro

    return Scaffold(
      appBar: const TopNavigation(title: "Iniciar Sesión", isMainScreen: true),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Text(
              'Oirs UTEM',
              style: StyleText.headline,
            ),
            LoginButton(),
          ],
        ),
      ),
    );
  }
}
