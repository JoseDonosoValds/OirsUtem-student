import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import '../services/google_services.dart';
import '../utils/user_data.dart';
import '../utils/navbar.dart';
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

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Estudiante',
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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Saludo personalizado
              Text(
                'Hola! ${userModel.displayName ?? '_NOMBRE'}',
                style: GoogleFonts.poppins(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),

              // Crear Solicitud Section
              Text(
                'Crear Solicitud',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildSolicitudOption(
                    context,
                    'Reclamo',
                    Icons.warning_amber_rounded,
                    Colors.orange.shade300,
                  ),
                  _buildSolicitudOption(
                    context,
                    'Sugerencia',
                    Icons.lightbulb,
                    Colors.green.shade300,
                  ),
                  _buildSolicitudOption(
                    context,
                    'Información',
                    Icons.info_outline,
                    Colors.blue.shade300,
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const Navbar(currentIndex: 0),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Acción del botón flotante
        },
        child: const Icon(Icons.add),
        backgroundColor: Colors.blueAccent,
      ),
    );
  }

  // Widget para construir la opción de crear solicitud
  Widget _buildSolicitudOption(BuildContext context, String title, IconData icon, Color color) {
    return GestureDetector(
      onTap: () {
        // Acción para navegar o crear solicitud
      },
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.white),
            const SizedBox(height: 10),
            Text(
              title,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
