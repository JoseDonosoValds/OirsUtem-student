import 'package:flutter/material.dart';

class EstadoSolicitudScreen extends StatelessWidget {
  const EstadoSolicitudScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Estado de mis Solicitudes'),
        backgroundColor: Colors.blueAccent,
      ),
      body: const Center(
        child: Text(
          'Pantalla para ver el estado de las solicitudes.',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
