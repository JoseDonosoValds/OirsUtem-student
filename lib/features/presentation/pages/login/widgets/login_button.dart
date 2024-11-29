import 'package:appcm202402/core/widgets/navigation/bottom_navigation.dart';
import 'package:flutter/material.dart';
import '/features/data/data_sources/Google/google_services.dart'; // Asegúrate de que la ruta es correcta
import '/features/presentation/pages/views.dart';

class LoginButton extends StatelessWidget {
  const LoginButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        bool isLoggedIn = await GoogleServices.signInWithGoogle();
        if (isLoggedIn) {
          // Si el inicio de sesión es exitoso, navega a la siguiente pantalla
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const BottomNavBar()),
          );
        } else {
          // Si hubo un error en el inicio de sesión, muestra un mensaje
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error al iniciar sesión con Google')),
          );
        }
      },
      child: const Text('Iniciar sesión con Google'),
    );
  }
}
