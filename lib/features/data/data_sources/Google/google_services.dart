import 'package:google_sign_in/google_sign_in.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Importa Firebase Auth para la autenticación

class GoogleServices {
  static final Logger _logger = Logger();
  static final GoogleSignIn _googleSignIn =
      GoogleSignIn(); // Instancia de GoogleSignIn para el flujo nativo

  // Guardar la información del usuario en SharedPreferences
  static Future<void> _saveUserToPreferences(UserCredential userCredential,
      String? idToken, String? accessToken) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        'displayName', userCredential.user?.displayName ?? '');
    await prefs.setString('email', userCredential.user?.email ?? '');
    await prefs.setString('photoUrl', userCredential.user?.photoURL ?? '');
    await prefs.setString('idToken', idToken ?? '');
    await prefs.setString('accessToken', accessToken ?? '');
  }

  static Future<String> getData(final String key) async {
    String data = '';
    await SharedPreferences.getInstance().then((sp) {
      data = sp.getString(key) ?? '';
    });
    return data;
  }

  // Iniciar sesión con Google y actualizar SharedPreferences
  static Future<bool> signInWithGoogle() async {
    try {
      // Inicia el flujo de autenticación de Google
      final GoogleSignInAccount? account = await _googleSignIn.signIn();

      if (account == null) {
        // Si el usuario cancela el proceso, lo informamos y retornamos false
        _logger.i('El usuario canceló el inicio de sesión');
        return false;
      }

      // Obtener autenticación de Google
      final GoogleSignInAuthentication googleAuth =
          await account.authentication;

      // Autenticar en Firebase usando las credenciales de Google
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Inicia sesión en Firebase
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      // Guardar la información del usuario en SharedPreferences
      await _saveUserToPreferences(
          userCredential, googleAuth.idToken, googleAuth.accessToken);

      _logger.i(
          'Inicio de sesión exitoso en Firebase: ${userCredential.user?.displayName}');
      return true;
    } catch (error) {
      // Manejamos el error y lo registramos
      _logger.e('Error durante la autenticación de Google o Firebase: $error');
      return false;
    }
  }

  // Cerrar sesión de Google y Firebase
  static Future<void> signOut() async {
    try {
      // Cerrar sesión en Google
      await _googleSignIn.signOut();
      // Cerrar sesión en Firebase
      await FirebaseAuth.instance.signOut();

      // Limpiar la información almacenada en SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('displayName');
      await prefs.remove('email');
      await prefs.remove('photoUrl');
      await prefs.remove('idToken');
      await prefs.remove('accessToken');

      _logger.i('Cierre de sesión exitoso');
    } catch (error) {
      _logger.e('Error al cerrar sesión: $error');
    }
  }
}
