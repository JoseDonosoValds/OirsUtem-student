import 'package:google_sign_in/google_sign_in.dart';
import 'package:logger/logger.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Importa Firebase Auth para la autenticación
import '../utils/user_data.dart' show UserModel; // Solo importar UserModel de user_data

class GoogleServices {
  static final Logger _logger = Logger();
  static final GoogleSignIn _googleSignIn = GoogleSignIn(); // Instancia de GoogleSignIn para el flujo nativo

  // Iniciar sesión con Google y actualizar el UserModel
  static Future<bool> signInWithGoogle(UserModel userModel) async {
    try {
      // Inicia el flujo de autenticación de Google
      final GoogleSignInAccount? account = await _googleSignIn.signIn();

      if (account == null) {
        // Si el usuario cancela el proceso, lo informamos y retornamos false
        _logger.i('El usuario canceló el inicio de sesión');
        return false;
      }

      // Obtener autenticación de Google
      final GoogleSignInAuthentication googleAuth = await account.authentication;

      // Autenticar en Firebase usando las credenciales de Google
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Inicia sesión en Firebase
      UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);

      // Actualizar UserModel con la información del usuario de Firebase
      userModel.updateUser(
        userCredential.user?.displayName,
        userCredential.user?.email,
        userCredential.user?.photoURL,
        googleAuth.idToken,
        googleAuth.accessToken);

      _logger.i('Inicio de sesión exitoso en Firebase: ${userCredential.user?.displayName}');
      return true;
    } catch (error) {
      // Manejamos el error y lo registramos
      _logger.e('Error durante la autenticación de Google o Firebase: $error');
      return false;
    }
  }

  // Cerrar sesión de Google y Firebase
  static Future<void> signOut(UserModel userModel) async {
    try {
      // Cerrar sesión en Google
      await _googleSignIn.signOut();
      // Cerrar sesión en Firebase
      // Limpiar el UserModel
      userModel.updateUser(null, null, null, null, null);
      _logger.i('Cierre de sesión exitoso');
    } catch (error) {
      _logger.e('Error al cerrar sesión: $error');
    }
  }
}
