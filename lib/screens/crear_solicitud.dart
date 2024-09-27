import 'package:flutter/material.dart';

class CrearSolicitudScreen extends StatelessWidget {
  const CrearSolicitudScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Solicitud'),
        backgroundColor: Colors.blueAccent,
      ),
      body: const Center(
        child: Text(
          'Pantalla para crear una nueva solicitud.',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
