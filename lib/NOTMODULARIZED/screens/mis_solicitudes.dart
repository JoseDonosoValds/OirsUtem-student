import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:logger/logger.dart';
import '../services/api_services.dart'; // Importar ApiService
import '../utils/user_data.dart'; // Importar UserModel
import '../utils/navbar.dart'; // Importar el Navbar
import 'crear_solicitud.dart'; // Importar la pantalla CrearSolicitudScreen
import '../utils/classes/get/info_categories.dart'; // Importar la clase CategoryTicketTypes
import '../utils/classes/get/ticket_token_tickets.dart'; // Importar la clase OwnTickets
import '../utils/appbar.dart'; // Importar el AppBar personalizado

class MisSolicitudesScreen extends StatefulWidget {
  const MisSolicitudesScreen({super.key});

  @override
  _MisSolicitudesScreenState createState() => _MisSolicitudesScreenState();
}

class _MisSolicitudesScreenState extends State<MisSolicitudesScreen> {
  List<CategoryTicketTypes> categories = [];
  List<OwnTickets> allSolicitudes = [];
  List<OwnTickets> filteredSolicitudes = [];
  String selectedFilter = 'Todas';
  bool isLoading = true;
  final ScrollController _scrollController = ScrollController();
  static const String baseUrl = 'https://api.sebastian.cl/oirs-utem';

  static final Logger _logger = Logger();

  String? selectedFile; // Para manejar el archivo seleccionado

  @override
  void initState() {
    super.initState();
    _fetchCategoriesAndSolicitudes();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _updateTicket(
      String ticketToken, String type, String subject, String message) async {
    final userModel = Provider.of<UserModel>(context, listen: false);
    final idToken = userModel.idToken;

    final url = "$baseUrl/v1/icso/$ticketToken/ticket";

    final body = {
      "type": type,
      "subject": subject,
      "message": message,
    };

    try {
      final response = await ApiService.put(url, idToken!, body);

      if (response != null) {
        // Mostrar mensaje de éxito
        _showDialog('Éxito', 'Solicitud actualizada correctamente.');

        // Cerrar todos los diálogos
        Navigator.of(context).popUntil((route) => route.isFirst);

        // Recargar la lista de tickets
        await _fetchCategoriesAndSolicitudes();
      } else {
        _showDialog('Error', 'No se pudo actualizar la solicitud.');
      }
    } catch (e) {
      _showDialog('Error', 'Ocurrió un error al actualizar la solicitud: $e');
    }
  }

  Future<void> _fetchCategoriesAndSolicitudes() async {
    final userModel = Provider.of<UserModel>(context, listen: false);
    final idToken = userModel.idToken;

    // Obtener categorías
    final categoryData =
        await ApiService.get("$baseUrl/v1/info/categories", idToken!);
    if (categoryData != null) {
      categories = List<CategoryTicketTypes>.from(
        categoryData.map((item) => CategoryTicketTypes.fromJson(item)),
      );
    }

    // Obtener todas las solicitudes
    List<OwnTickets> allTickets = [];
    for (var category in categories) {
      final solicitudesUrl =
          "$baseUrl/v1/icso/${category.token}/tickets?type=%20&status=%20";
      final solicitudesData = await ApiService.get(solicitudesUrl, idToken);
      if (solicitudesData != null) {
        final tickets = List<OwnTickets>.from(
          solicitudesData.map((item) => OwnTickets.fromJson(item)),
        );
        allTickets.addAll(tickets);
      }
    }

    setState(() {
      allSolicitudes = allTickets;
      filteredSolicitudes = allSolicitudes;
      isLoading = false;
    });
  }

  Future<void> _sendAttachment(
      String ticketToken, String name, String mime, String data) async {
    final userModel = Provider.of<UserModel>(context, listen: false);
    final idToken = userModel.idToken;

    final url =
        "https://api.sebastian.cl/oirs-utem/v1/attachments/$ticketToken/upload";

    final body = {
      "name": name,
      "mime": mime,
      "data": data,
    };

    try {
      final response = await ApiService.post(url, idToken!, body);

      if (response != null) {
        // Mostrar un mensaje de éxito si el campo success es true
        _showDialog('Éxito', 'Archivo enviado correctamente.');
      } else {
        // Mostrar un mensaje de error con detalle si está disponible
        _showDialog(
          'Error',
          response != null && response['detail'] != null
              ? response['detail']
              : 'No se pudo enviar el archivo. Intenta de nuevo.',
        );
      }
    } catch (e) {
      _showDialog('Error', 'Ocurrió un error al enviar el archivo: $e');
    }
  }

  void _changeFilter(String filter) {
    setState(() {
      selectedFilter = filter;
      if (filter == 'Todas') {
        filteredSolicitudes = allSolicitudes;
      } else {
        filteredSolicitudes = allSolicitudes
            .where((solicitud) => solicitud.category.name == filter)
            .toList();
      }
    });
  }

  void _showDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          message,
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.grey.shade700,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _pickFile() async {
    String? base64Data;
    final result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() {
        selectedFile = result.files.single.name;
        base64Data = result.files.single.bytes != null
            ? base64Encode(result.files.single.bytes!)
            : null;
        _logger.d('Selected file: $selectedFile, base64: $base64Data');
      });
    }
  }

  Widget _buildDetailRow(String title, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$title ',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey.shade700,
            ),
          ),
        ),
      ],
    );
  }

  void _showSolicitudDetailPopup(OwnTickets solicitud, Color tipoColor) {
    String? fileName;
    String? mimeType;
    String? base64Data;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 5,
                        margin: const EdgeInsets.only(bottom: 16.0),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade400,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    Text(
                      'Detalle de la Solicitud',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF04347c),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildDetailRow('Token:', solicitud.token),
                    const SizedBox(height: 8),
                    _buildDetailRow('Tipo:', solicitud.type),
                    const SizedBox(height: 8),
                    _buildDetailRow('Asunto:', solicitud.subject),
                    const SizedBox(height: 8),
                    _buildDetailRow('Estado:', solicitud.status),
                    const SizedBox(height: 8),
                    _buildDetailRow('Categoría:', solicitud.category.name),
                    const SizedBox(height: 16),
                    Text(
                      'Mensaje:',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      solicitud.message,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                      ),
                    ),

                    // solo debe verse si hay una respuesta
                    Text(
                      'Respuesta:',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      solicitud.response ?? 'Sin respuesta',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    //
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _showEditForm(solicitud),
                        icon: const Icon(Icons.edit),
                        label: const Text('Editar Solicitud'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF04347c),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Adjuntar archivo:',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              final result =
                                  await FilePicker.platform.pickFiles(
                                allowedExtensions: [
                                  'pdf',
                                  'jpg',
                                  'jpeg',
                                  'png'
                                ],
                                type: FileType.custom,
                                withData: true,
                              );

                              if (result != null) {
                                final file = result.files.single;
                                setState(() {
                                  fileName = file.name;
                                  mimeType = file.extension == 'pdf'
                                      ? 'application/pdf'
                                      : 'image/${file.extension}';
                                  base64Data = file.bytes != null
                                      ? base64Encode(file.bytes!)
                                      : null;
                                  _logger.d(
                                      'Selected file: $fileName, base64: $base64Data, mime: $mimeType');
                                });
                              }
                            },
                            icon: const Icon(Icons.attach_file),
                            label: const Text('Seleccionar Archivo'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF04347c),
                            ),
                          ),
                        ),
                        if (fileName != null)
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              setState(() {
                                fileName = null;
                                mimeType = null;
                                base64Data = null;
                              });
                            },
                          ),
                      ],
                    ),
                    if (fileName != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Archivo seleccionado: $fileName',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.grey.shade700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () async {
                                  Navigator.pop(context);
                                  await _sendAttachment(solicitud.token,
                                      fileName!, mimeType!, base64Data!);
                                },
                                icon: const Icon(Icons.send),
                                label: const Text('Enviar Archivo'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showEditForm(OwnTickets solicitud) {
    String? updatedType = solicitud.type;
    final TextEditingController subjectController =
        TextEditingController(text: solicitud.subject);
    final TextEditingController messageController =
        TextEditingController(text: solicitud.message);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Editar Solicitud',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF04347c),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: updatedType,
                  decoration: const InputDecoration(
                    labelText: 'Tipo',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    'CLAIM',
                    'SUGGESTION',
                    'INFORMATION',
                  ].map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(type),
                    );
                  }).toList(),
                  onChanged: (value) {
                    updatedType = value;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: subjectController,
                  decoration: const InputDecoration(
                    labelText: 'Asunto',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: messageController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Mensaje',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      await _updateTicket(
                        solicitud.token,
                        updatedType!,
                        subjectController.text,
                        messageController.text,
                      );
                      Navigator.pop(context);
                    },
                    child: const Text('Actualizar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF04347c),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFilterButton(String label, Color color) {
    return GestureDetector(
      onTap: () {
        _changeFilter(label);
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(_scrollController.position.minScrollExtent);
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4.0),
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
        decoration: BoxDecoration(
          color: selectedFilter == label
              ? const Color.fromARGB(128, 7, 84, 98)
              : color,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            color: const Color(0xFF04347c),
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildCompactSolicitudCard(OwnTickets solicitud) {
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
      onTap: () {
        _showSolicitudDetailPopup(solicitud, tipoColor);
      },
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Mis Solicitudes'),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterButton('Todas', Colors.blueAccent),
                    ...categories.map((category) {
                      return _buildFilterButton(
                          category.name, Colors.grey.shade300);
                    }).toList(),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                        controller: _scrollController,
                        itemCount: filteredSolicitudes.length,
                        itemBuilder: (context, index) {
                          final solicitud = filteredSolicitudes[index];
                          return _buildCompactSolicitudCard(solicitud);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const Navbar(currentIndex: 1),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const CrearSolicitudScreen()),
          );
        },
        child: const Icon(Icons.add, color: Color(0xFF04347c)),
        backgroundColor: const Color.fromARGB(128, 7, 84, 98),
      ),
    );
  }
}
