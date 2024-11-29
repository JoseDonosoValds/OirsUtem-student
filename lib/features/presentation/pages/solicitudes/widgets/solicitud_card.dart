// widgets/solicitud_card.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '/features/domain/entities/ticket_entity.dart';
//import 'solicitud_detail_popup.dart';

// Función privada
void _showSolicitudDetailPopup(
    BuildContext context, Ticket solicitud, Color tipoColor) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (BuildContext context) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Detalle de la solicitud
              Text(
                'Detalle de la Solicitud',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF04347c),
                ),
              ),
              const SizedBox(height: 16),
              Text('Token: ${solicitud.token}'),
              Text('Tipo: ${solicitud.type}'),
              Text('Asunto: ${solicitud.subject}'),
              Text('Estado: ${solicitud.status}'),
              Text('Mensaje: ${solicitud.message}'),
              // Puedes agregar más detalles aquí si lo deseas
            ],
          ),
        ),
      );
    },
  );
}

class SolicitudCard extends StatelessWidget {
  final Ticket solicitud;

  const SolicitudCard({required this.solicitud, super.key});

  @override
  Widget build(BuildContext context) {
    String tipo = solicitud.type.toLowerCase();
    String asunto = solicitud.subject;
    String estado = solicitud.status;
    String descripcion = solicitud.message;
    String categoria = solicitud.category.name;

    Color tipoColor;
    switch (tipo) {
      case 'information':
        tipoColor = const Color(0xFF316f8e);
        break;
      case 'suggestion':
        tipoColor = const Color(0xFF4d7032);
        break;
      case 'claim':
        tipoColor = const Color(0xFF9b6a2c);
        break;
      default:
        tipoColor = Colors.grey;
    }

    return GestureDetector(
      onTap: () => _showSolicitudDetailPopup(context, solicitud, tipoColor),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 2,
        margin: const EdgeInsets.symmetric(vertical: 6.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border(
              left: BorderSide(color: tipoColor, width: 4),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      categoria,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: tipoColor,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8.0, vertical: 4.0),
                      decoration: BoxDecoration(
                        color: tipoColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        estado,
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  asunto,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                  ),
                ),
                if (descripcion.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      descripcion,
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        color: Colors.grey,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
