import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Google Fonts for custom font
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'home_screen.dart';
import '../services/google_services.dart';
import 'package:sign_in_button/sign_in_button.dart'; // Using the SignInButton package
import '../utils/user_data.dart'; // Import UserModel

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});
  static final Logger _logger = Logger();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [Color(0xFF2193b0), Color(0xFF6DD5FA)], // Updated colors
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(),
                // Custom Logo Text with Google Fonts
                Text(
                  'OIRS',
                  style: GoogleFonts.pacifico( // Using a stylish font from Google Fonts
                    textStyle: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Bienvenido',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w400,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                // Google Sign-in Button using SignInButton package
                SignInButton(
                  Buttons.google,
                  text: "Sign in with Google",
                  onPressed: () async {
                    try {
                      final userModel = Provider.of<UserModel>(context, listen: false);
                      bool success = await GoogleServices.signInWithGoogle(userModel);
                      if (success) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const HomeScreen()),
                        );
                      } else {
                        _showLoginFailedDialog(context);
                      }
                    } catch (e) {
                      _logger.e('Login failed: $e');
                      _showLoginFailedDialog(context);
                    }
                  },
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showLoginFailedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Falló al conectar'),
          content: const Text('Falló el logueo, ha sido reportado el error'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
