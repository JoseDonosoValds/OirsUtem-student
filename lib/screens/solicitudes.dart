import 'package:flutter/material.dart';
import 'crear_solicitud.dart';
import 'mis_solicitudes.dart';
import '../utils/navbar.dart'; // Import the Navbar for consistency

class SolicitudesScreen extends StatelessWidget {
  const SolicitudesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Solicitudes'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CrearSolicitudScreen()),
                );
              },
              child: const Text('Crear Solicitud'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MisSolicitudesScreen()),
                );
              },
              child: const Text('Estado de mis Solicitudes'),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const Navbar(currentIndex: 1),
    );
  }
}
