import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // For using Google Fonts
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import '../services/google_services.dart';
import '../utils/user_data.dart';
import '../utils/navbar.dart'; // Import the Navbar widget
import 'login_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static final Logger _logger = Logger();

  @override
  Widget build(BuildContext context) {
    final userModel = Provider.of<UserModel>(context);

    // Log userModel data
    HomeScreen._logger.i(
        'UserModel: ${userModel.displayName}, ${userModel.email}, ${userModel.idToken}, ${userModel.accessToken}');

    if (userModel.email == null) {
      return const Scaffold(
        body: Center(
          child: Text('No user is currently signed in.'),
        ),
      );
    }

    // Function to censor email
    String censorEmail(String email) {
      if (email.isEmpty || !email.contains('@')) {
        return email;
      }
      final parts = email.split('@');
      final localPart = parts[0];
      final domainPart = parts[1];
      final censoredLocalPart = localPart[0] + '*' * (localPart.length - 1);
      return '$censoredLocalPart@$domainPart';
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Inicio',
          style: GoogleFonts.pacifico(fontSize: 28, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [Color(0xFF2193b0), Color(0xFF6DD5FA)],
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              try {
                await GoogleServices.signOutGoogle(userModel);
                // Navigate to LoginScreen
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              } catch (e) {
                HomeScreen._logger.e('Logout failed: $e');
              }
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Profile Picture
            CircleAvatar(
              backgroundImage: userModel.photoUrl != null && userModel.photoUrl!.isNotEmpty
                  ? NetworkImage(userModel.photoUrl!)
                  : const AssetImage('assets/default_profile.png') as ImageProvider,
              radius: 50,
            ),
            const SizedBox(height: 20),
            // User Info Card
            Card(
              elevation: 5,
              margin: const EdgeInsets.symmetric(horizontal: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Display name
                    Text(
                      userModel.displayName ?? 'No name',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Email (censored)
                    Text(
                      censorEmail(userModel.email ?? ''),
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const Navbar(currentIndex: 0),
    );
  }
}
