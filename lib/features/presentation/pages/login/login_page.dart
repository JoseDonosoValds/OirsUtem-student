import 'package:flutter/material.dart';
import '/core/core.dart';
import '/features/presentation/pages/login/widgets/login_button.dart'; // 
// 

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: TopNavigation(title: "Iniciar Sesión", isMainScreen: true),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Si tienes un formulario, puedes incluirlo aquí
            // LoginForm(),
            LoginButton(), // El botón de login de Google
          ],
        ),
      ),
    );
  }
}
