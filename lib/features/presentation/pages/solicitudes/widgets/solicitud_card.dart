import 'package:flutter/material.dart';
import '/core/core.dart'; // Importar AppTheme y StyleText
import '/features/domain/entities/ticket_entity.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:convert';
import 'package:logger/logger.dart';
import '/features/data/data_sources/api_oirs/oirsIcsoService.dart';
//import '/features/data/data_sources/api_oirs/oirsInfoService.dart';
import '/features/data/data_sources/api_oirs/oirsAttatchmentService.dart';

final _logger = Logger();

class SolicitudCard extends StatefulWidget {
  final Ticket solicitud;

  final Function(Ticket) onDelete; // Callback para eliminar el ticket

  const SolicitudCard(
      {required this.solicitud, required this.onDelete, super.key});

  @override
  _SolicitudCardState createState() => _SolicitudCardState();
}

class _SolicitudCardState extends State<SolicitudCard> {
  String? selectedFile;
  String? base64Data;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    // Determinar el color del borde según el tipo de solicitud
    final tipoColor =
        _getTipoColor(widget.solicitud.type.toLowerCase(), isDarkMode);

    // Colores dinámicos para la tarjeta
    final cardColor = theme.cardColor;
    final textColor = theme.colorScheme.onSurface;

    return GestureDetector(
      onTap: () => _showExpandableModal(context), // Llama al modal expandible
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 2,
        margin: const EdgeInsets.symmetric(vertical: 6.0),
        child: Container(
          decoration: BoxDecoration(
            color: cardColor,
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
                _buildHeader(context, tipoColor),
                const SizedBox(height: 4),
                _buildSubject(textColor),
                if (widget.solicitud.message.isNotEmpty)
                  _buildMessage(textColor),
                const SizedBox(height: 8),
                if (selectedFile != null) _buildSelectedFile(),
                _buildResponse(widget.solicitud.response),
                _buildActions(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Obtener color según el tipo
  Color _getTipoColor(String tipo, bool isDarkMode) {
    switch (tipo) {
      case 'information':
        return AppTheme.getInformationColor(isDarkMode);
      case 'suggestion':
        return AppTheme.getSuggestionColor(isDarkMode);
      case 'claim':
        return AppTheme.getClaimColor(isDarkMode);
      default:
        return const Color.fromARGB(255, 255, 1, 1);
    }
  }

  // Mostrar nombre del archivo seleccionado
  Widget _buildSelectedFile() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          const Icon(Icons.insert_drive_file, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              selectedFile!,
              style: StyleText.body.copyWith(color: Colors.grey),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // Construir encabezado
  Widget _buildHeader(BuildContext context, Color tipoColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            widget.solicitud.category.name,
            style: StyleText.label.copyWith(color: tipoColor),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          decoration: BoxDecoration(
            color: tipoColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            widget.solicitud.status,
            style: StyleText.bodyBold.copyWith(color: Colors.white),
          ),
        ),
      ],
    );
  }

  // Construir asunto
  Widget _buildSubject(Color textColor) {
    return Text(
      widget.solicitud.subject,
      style: StyleText.descriptionBold.copyWith(color: textColor),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  // Construir mensaje
  Widget _buildMessage(Color textColor) {
    return Padding(
      padding: const EdgeInsets.only(top: 4.0),
      child: Text(
        widget.solicitud.message,
        style:
            StyleText.description.copyWith(color: textColor.withOpacity(0.7)),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  // Mostrar la respuesta si está disponible
  Widget _buildResponse(String? response) {
    if (response == null || response.isEmpty) {
      return const SizedBox.shrink(); // No mostrar nada si no hay respuesta
    }

    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Respuesta:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          Text(
            response,
            style: StyleText.body.copyWith(color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }

  // Construir acciones
  Widget _buildActions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ElevatedButton.icon(
          onPressed: () => _showEditSolicitudModal(context),
          icon: const Icon(Icons.edit),
          label: const Text('Editar'),
        ),
        ElevatedButton.icon(
          onPressed: selectedFile == null
              ? () => _pickFile(context)
              : () => _confirmSendAttachment(context),
          icon: Icon(selectedFile == null ? Icons.attach_file : Icons.send),
          label: Text(selectedFile == null ? 'Adjuntar' : 'Enviar'),
        ),
      ],
    );
  }

  // Seleccionar archivo
  Future<void> _pickFile(BuildContext context) async {
    try {
      final result = await FilePicker.platform.pickFiles(withData: true);
      if (result != null) {
        final file = result.files.single;

        setState(() {
          selectedFile = file.name;
          base64Data = base64Encode(file.bytes!);
        });

        _logger.d('Archivo seleccionado: $selectedFile');
      } else {
        _logger.i('No se seleccionó ningún archivo');
      }
    } catch (error) {
      _logger.e("Error al seleccionar archivo: $error");
      _showDialog('Error', 'Hubo un error al seleccionar el archivo.');
    }
  }

  // Mostrar la hoja modal expandible desde abajo
  void _showExpandableModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.5, // Altura inicial (50% de la pantalla)
          minChildSize: 0.3, // Altura mínima
          maxChildSize: 0.9, // Altura máxima
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Indicador de que se puede arrastrar
                  Container(
                    width: 40,
                    height: 5,
                    margin: const EdgeInsets.only(top: 10, bottom: 10),
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      children: [
                        Text(
                          widget.solicitud.category.name,
                          style: StyleText.headlineSmall.copyWith(
                              color: Theme.of(context).colorScheme.primary),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Asunto: ${widget.solicitud.subject}",
                          style: StyleText.descriptionBold.copyWith(
                              color: Theme.of(context).colorScheme.onSurface),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.solicitud.message,
                          style: StyleText.body.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.7)),
                        ),
                        if (widget.solicitud.response != null)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 16),
                              Text(
                                "Respuesta:",
                                style: StyleText.descriptionBold.copyWith(
                                    color:
                                        Theme.of(context).colorScheme.primary),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                widget.solicitud.response!,
                                style: StyleText.body.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface),
                              ),
                            ],
                          ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // Confirmación para enviar archivo
  void _confirmSendAttachment(BuildContext context) {
    if (selectedFile == null || base64Data == null) {
      _showDialog('Error', 'No hay archivo seleccionado para enviar.');
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirmar Envío'),
          content: Text('¿Seguro que deseas enviar "$selectedFile"?'),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  selectedFile = null;
                  base64Data = null;
                });
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                _sendAttachment();
              },
              child: const Text('Enviar'),
            ),
          ],
        );
      },
    );
  }

  void _showDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // Enviar archivo adjunto
  Future<void> _sendAttachment() async {
    if (base64Data == null || selectedFile == null) {
      _showDialog('Error', 'No hay archivo seleccionado para enviar.');
      return;
    }

    try {
      final fileData = {
        "name": selectedFile!,
        "mime": _getMimeType(selectedFile!.split('.').last),
        "data": base64Data!,
      };

      final attService = attachmentsService();
      final res = await attService.createAttachment(
        {'categoryToken': widget.solicitud.token},
        fileData,
      );

      if (res['success']) {
        _logger.d("Archivo enviado exitosamente.");
        _showDialog('Éxito', 'El archivo fue enviado exitosamente.');
      } else {
        _logger.e("Error al enviar archivo: ${res['message']}");
        _showDialog('Error', 'Hubo un error al enviar el archivo.');
      }

      setState(() {
        selectedFile = null;
        base64Data = null;
      });
    } catch (error) {
      _logger.e("Error al enviar archivo: $error");
      setState(() {
        selectedFile = null;
        base64Data = null;
      });
      _showDialog('Error', 'Hubo un error al enviar el archivo.');
    }
  }

  // Obtener tipo MIME
  String _getMimeType(String extension) {
    final mimeTypes = {
      "pdf": "application/pdf",
      "doc": "application/msword",
      "docx":
          "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
      "jpg": "image/jpeg",
      "jpeg": "image/jpeg",
      "png": "image/png",
    };
    return mimeTypes[extension.toLowerCase()] ?? "application/octet-stream";
  }

  // Modal para editar la solicitud
  void _showEditSolicitudModal(BuildContext context) {
    final subjectController =
        TextEditingController(text: widget.solicitud.subject);
    final messageController =
        TextEditingController(text: widget.solicitud.message);

    final String currentType = widget.solicitud.type.toUpperCase();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: SingleChildScrollView(
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: subjectController,
                        decoration: const InputDecoration(labelText: 'Asunto'),
                      ),
                      TextField(
                        controller: messageController,
                        decoration: const InputDecoration(labelText: 'Mensaje'),
                        maxLines: 4,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Text(
                            'Tipo: ',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            currentType,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () async {
                          // Cierra el modal de edición
                          Navigator.pop(context);

                          // Realiza la solicitud para editar
                          await _sendEditRequest(
                            subjectController.text,
                            messageController.text,
                            currentType,
                          );
                        },
                        child: const Text('Guardar Cambios'),
                      ),
                    ],
                  ),
                ),
                // Botón en la esquina superior derecha
                Positioned(
                  top: 8,
                  right: 8,
                  child: IconButton(
                    onPressed: () => _confirmDeleteTicket(context),
                    icon: const Icon(Icons.delete, color: Colors.red),
                    tooltip: 'Eliminar Ticket',
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _confirmDeleteTicket(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Eliminar Ticket'),
          content: const Text(
            '¿Estás seguro de que deseas eliminar este ticket? Esta acción no se puede deshacer.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                _deleteTicket();
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
              ),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );
    ;
  }

  Future<void> _deleteTicket() async {
    final icsoService = IcsoService();

    // Cerramos el modal antes de proceder con la eliminación
    Navigator.pop(context);

    try {
      final response = await icsoService.deleteTicket({
        'ticketToken': widget.solicitud.token,
      });

      if (response['success']) {
        _logger.d("Ticket eliminado exitosamente.");
        _showDialog('Éxito', 'El ticket fue eliminado exitosamente.');

        // Llamamos al callback para eliminar el ticket de la lista en el widget padre
        widget.onDelete(widget.solicitud);
      } else {
        _logger.e("Error al eliminar el ticket.");
        _showDialog('Error', 'No se pudo eliminar el ticket.');
      }
    } catch (e) {
      _logger.e("Error al eliminar el ticket: $e");
      _showDialog('Error', 'Hubo un error al eliminar el ticket.');
    }
  }

  // Enviar edición
  Future<void> _sendEditRequest(
      String subject, String message, String type) async {
    final icsoService = IcsoService();
    try {
      final response = await icsoService.updateTicket(
        {"ticketToken": widget.solicitud.token},
        {
          "subject": subject,
          "message": message,
          "type": type,
        },
      );
      if (response['success']) {
        _logger.d("Solicitud actualizada exitosamente.");
        _showDialog('Éxito', 'La solicitud fue actualizada exitosamente.');

        // Aquí usamos setState para actualizar la UI con los nuevos valores
        setState(() {
          widget.solicitud.subject = subject;
          widget.solicitud.message = message;
          widget.solicitud.type = type;
        });
      } else {
        _logger.e("Error al actualizar solicitud: ${response['message']}");
        _showDialog('Error', 'Hubo un error al actualizar la solicitud.');
      }
    } catch (e) {
      _logger.e("Error al actualizar solicitud: $e");
      _showDialog('Error', 'Hubo un error al actualizar la solicitud.');
    }
  }
}
