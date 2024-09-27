import 'package:google_sign_in/google_sign_in.dart';
import 'package:logger/logger.dart';

import '../utils/user_data.dart'; // Importa el UserModel

class GoogleServices {
  static final Logger _logger = Logger();
  static final GoogleSignIn _googleSignIn = GoogleSignIn(); // Instancia de GoogleSignIn para el flujo nativo

  // Iniciar sesión con Google y actualizar el UserModel
  static Future<bool> signInWithGoogle(UserModel userModel) async {
    try {
      // Inicia el flujo de autenticación de Google en Android con el pop-up nativo
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        _logger.w('Inicio de sesión con Google cancelado por el usuario.');
        await _handleSignOut(userModel);
        return false; // El usuario canceló el inicio de sesión
      }

      // Obtén las credenciales de autenticación de Google
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Actualiza el UserModel con la información obtenida de Google
      _updateUserModel(userModel, googleUser, googleAuth.idToken, googleAuth.accessToken);
      _logger.i('Inicio de sesión exitoso con Google: ${googleUser.email}');
      return true;
    } catch (error) {
      _logger.e('Error durante el inicio de sesión con Google: $error');
      await _handleSignOut(userModel);
      return false;
    }
  }

  // Actualiza el modelo de usuario con la información obtenida de Google
  static void _updateUserModel(UserModel userModel, GoogleSignInAccount googleUser, String? idToken, String? accessToken) {
    userModel.updateUser(
      googleUser.displayName,
      googleUser.email,
      googleUser.photoUrl,
      idToken,        // idToken de Google obtenido
      accessToken,    // accessToken de Google obtenido
    );
  }

  // Cierra sesión de GoogleSignIn y limpia el UserModel
  static Future<void> signOutGoogle(UserModel userModel) async {
    await _handleSignOut(userModel);
    _logger.i('Cierre de sesión exitoso de Google.');
  }

  // Lógica para cerrar sesión y limpiar el estado del usuario
  static Future<void> _handleSignOut(UserModel userModel) async {
    try {
      await _googleSignIn.signOut();  // Cierra sesión de Google
      userModel.updateUser('', '', '', '', '');
    } catch (error) {
      _logger.w('Error durante el cierre de sesión: $error');
    }
  }
}
