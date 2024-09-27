import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:logger/logger.dart';
import '../utils/user_data.dart'; // Import the UserModel

class GoogleServices {
  static final Logger _logger = Logger();
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Sign in with Google and Firebase
  static Future<bool> signInWithGoogle(UserModel userModel) async {
    try {
      // Trigger the Google Sign-In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        _logger.w('Google sign-in canceled by user.');
        // Ensure the user is signed out
        await _signOutOnFailure(userModel);
        return false; // User canceled the sign-in
      }

      // Ensure that the email belongs to the @utem.cl domain
      if (!googleUser.email.endsWith('@utem.cl')) {
        _logger.w('El correo no pertenece al dominio @utem.cl');
        // Ensure the user is signed out
        await _signOutOnFailure(userModel);
        return false; // Email is not from @utem.cl domain
      }

      // Obtain the Google Sign-In authentication
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential for Firebase authentication
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      final User? firebaseUser = userCredential.user;

      if (firebaseUser != null) {
        _logger.i('Successfully signed in with Firebase: ${firebaseUser.email}');
        // Update the UserModel with the user's information
        userModel.updateUser(
          firebaseUser.displayName,
          firebaseUser.email,
          firebaseUser.photoURL,
          googleAuth.idToken,
          googleAuth.accessToken,
        );
        return true;
      } else {
        _logger.e('Firebase user is null after signing in.');
        // Ensure the user is signed out
        await _signOutOnFailure(userModel);
        return false;
      }
    } catch (error) {
      _logger.e('Error signing in with Google and Firebase: $error');
      // Ensure the user is signed out
      await _signOutOnFailure(userModel);
      return false;
    }
  }

  // Helper function to handle sign out on failure
  static Future<void> _signOutOnFailure(UserModel userModel) async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
      userModel.updateUser('', '', '', '', '');
      _logger.i('Successfully signed out after failed login attempt.');
    } catch (error) {
      _logger.e('Error during sign out after login failure: $error');
    }
  }

  // Sign out from Google and Firebase
  static Future<void> signOutGoogle(UserModel userModel) async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
      userModel.updateUser('', '', '', '', '');
      _logger.i('Successfully signed out from Google and Firebase.');
    } catch (error) {
      _logger.e('Error signing out: $error');
    }
  }
}
