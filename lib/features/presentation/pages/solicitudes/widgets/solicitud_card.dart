import 'package:flutter/material.dart';
import '/core/core.dart'; // Importar AppTheme y StyleText
import '/features/domain/entities/ticket_entity.dart';

// Función privada para mostrar los detalles de la solicitud
void _showSolicitudDetailPopup(
    BuildContext context, Ticket solicitud, Color tipoColor) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (BuildContext context) {
      final theme = Theme.of(context);

      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Detalle de la Solicitud',
                style: StyleText.headlineSmall.copyWith(
                  color: theme.colorScheme.primary, // Color del encabezado
                ),
              ),
              const SizedBox(height: 16),
              _buildDetailRow('Tipo:', solicitud.type, theme),
              _buildDetailRow('Asunto:', solicitud.subject, theme),
              _buildDetailRow('Mensaje:', solicitud.message, theme),
              _buildDetailRow(
                  'Respuesta:', solicitud.response ?? 'Sin respuesta', theme),
            ],
          ),
        ),
      );
    },
  );
}

// Widget para construir cada fila de detalles
Widget _buildDetailRow(String label, String content, ThemeData theme) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4.0),
    child: RichText(
      text: TextSpan(
        text: '$label ',
        style: StyleText.bodyBold.copyWith(
          color: theme.colorScheme.onSurface, // Color de la etiqueta
        ),
        children: [
          TextSpan(
            text: content,
            style: StyleText.body.copyWith(
              color: theme.colorScheme.onSurface, // Color del contenido
            ),
          ),
        ],
      ),
    ),
  );
}

class SolicitudCard extends StatelessWidget {
  final Ticket solicitud;

  const SolicitudCard({required this.solicitud, super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    // Determinar el color del borde según el tipo de solicitud
    String tipo = solicitud.type.toLowerCase();
    Color tipoColor;
    switch (tipo) {
      case 'information':
        tipoColor = AppTheme.getInformationColor(isDarkMode);
        break;
      case 'suggestion':
        tipoColor = AppTheme.getSuggestionColor(isDarkMode);
        break;
      case 'claim':
        tipoColor = AppTheme.getClaimColor(isDarkMode);
        break;
      default:
        tipoColor = const Color.fromARGB(255, 255, 1, 1);
    }

    // Colores dinámicos para la tarjeta
    final cardColor = theme.cardColor;
    final textColor = theme.colorScheme.onSurface;

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
            color: cardColor, // Fondo dinámico de la tarjeta
            borderRadius: BorderRadius.circular(8),
            border: Border(
              left: BorderSide(color: tipoColor, width: 4), // Borde del tipo
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        solicitud.category.name, // Categoría de la solicitud
                        style: StyleText.label.copyWith(
                          color: tipoColor, // Color del texto según el tipo
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis, // Evitar overflow
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8.0, vertical: 4.0),
                      decoration: BoxDecoration(
                        color: tipoColor, // Fondo del estado
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        solicitud.status, // Estado de la solicitud
                        style: StyleText.bodyBold.copyWith(
                          color: Colors.white, // Texto blanco para el estado
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  solicitud.subject, // Asunto de la solicitud
                  style: StyleText.descriptionBold.copyWith(
                    color: textColor, // Color dinámico del texto
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (solicitud.message.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      solicitud.message, // Mensaje de la solicitud
                      style: StyleText.description.copyWith(
                        color: textColor.withOpacity(0.7), // Texto con opacidad
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
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
