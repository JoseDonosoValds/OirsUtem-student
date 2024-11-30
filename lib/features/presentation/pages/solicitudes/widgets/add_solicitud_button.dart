import 'package:flutter/material.dart';
import '/core/core.dart'; // Para el tema y estilos
import '/features/presentation/pages/views.dart';

class AddSolicitudButton extends StatelessWidget {
  const AddSolicitudButton({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FloatingActionButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const CrearSolicitudScreen(),
          ),
        );
      },
      backgroundColor: theme.colorScheme.primary,
      child: Icon(
        Icons.add,
        color: theme.colorScheme.onPrimary,
      ),
    );
  }
}
