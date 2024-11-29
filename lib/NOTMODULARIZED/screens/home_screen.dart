import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import '../utils/classes/get/info_categories.dart';
import '../../features/data/data_sources/Google/google_services.dart'; // Importar GoogleServices
import '../services/api_services.dart'; // Importar ApiService
import '../../features/data/models/user_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  static final Logger _logger = Logger();

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> categories = []; // Categorías obtenidas del API
  bool isLoadingCategories = true;
  final Logger _logger = Logger();

  // Variables para manejar el estado del formulario
  CategoryTicketTypes? selectedCategory;
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchCategories(); // Cargar categorías desde el API
  }

  @override
  void dispose() {
    // Limpiar controladores cuando el widget se elimine
    _subjectController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  Future<void> _fetchCategories() async {
    final userModel = Provider.of<UserModel>(context, listen: false);
    final idToken = userModel.idToken;

    final data = await ApiService.get("https://api.sebastian.cl/oirs-utem/v1/info/categories", idToken!);

    if (data != null) {
      setState(() {
        categories = List<CategoryTicketTypes>.from(
          data.map((item) => CategoryTicketTypes.fromJson(item)),
        );
        isLoadingCategories = false;
      });
    } else {
      setState(() {
        isLoadingCategories = false;
      });
    }
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

  void _showQuickRequestPopup(String type) {
    _logger.i('Filtered type: $type');
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
                  'Crear Solicitud Rápida',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF04347c),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<CategoryTicketTypes>(
                  value: selectedCategory,
                  hint: const Text('Seleccionar Categoría'),
                  items: categories.map((category) {
                    return DropdownMenuItem<CategoryTicketTypes>(
                      value: category,
                      child: Text(category.name),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedCategory = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _subjectController,
                  decoration: const InputDecoration(
                    labelText: 'Asunto',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _bodyController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Cuerpo del Mensaje',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _sendRequest(
                      type: type,
                      categoryToken: selectedCategory?.token,
                      subject: _subjectController.text,
                      message: _bodyController.text,
                    );
                  },
                  child: const Text('Enviar Solicitud'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF04347c),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _sendRequest({
    required String type,
    required String? categoryToken,
    required String subject,
    required String message,
  }) async {
    final userModel = Provider.of<UserModel>(context, listen: false);
    final idToken = userModel.idToken;

    if (categoryToken == null || subject.isEmpty || message.isEmpty) {
      _showDialog(
        'Error',
        'Por favor llena todos los campos antes de enviar.',
      );
      return;
    }

    final body = {
      "type": type,
      "subject": subject,
      "message": message,
    };

    final postUrl =
        "https://api.sebastian.cl/oirs-utem/v1/icso/$categoryToken/ticket";

    final response = await ApiService.post(postUrl, idToken!, body);

    if (response != null) {
      _showDialog('Éxito', 'Solicitud enviada exitosamente.');
    } else {
      _showDialog(
          'Error', 'No se pudo enviar la solicitud. Inténtalo de nuevo.');
    }
  }

  Future<bool> _showLogoutConfirmationDialog(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Cerrar Sesión'),
            content: const Text('¿Estás seguro de que quieres cerrar sesión?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Cerrar Sesión'),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    final userModel = Provider.of<UserModel>(context);

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
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: isLoadingCategories
                ? const Center(child: CircularProgressIndicator())
                : ListView(
                    children: [
                      Text(
                        'Hola! ${userModel.displayName ?? '_NOMBRE'}',
                        style: GoogleFonts.poppins(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Crear Solicitud',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            flex: 1,
                            child: GestureDetector(
                              onTap: () => _showQuickRequestPopup('CLAIM'),
                              child: _buildSolicitudOption(
                                context,
                                'Reclamo',
                                Icons.warning_amber_rounded,
                                Colors.orange.shade300,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Flexible(
                            flex: 1,
                            child: GestureDetector(
                              onTap: () => _showQuickRequestPopup('SUGGESTION'),
                              child: _buildSolicitudOption(
                                context,
                                'Sugerencia',
                                Icons.lightbulb,
                                Colors.green.shade300,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Flexible(
                            flex: 1,
                            child: GestureDetector(
                              onTap: () => _showQuickRequestPopup('INFORMATION'),
                              child: _buildSolicitudOption(
                                context,
                                'Información',
                                Icons.info_outline,
                                Colors.blue.shade300,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton(
              onPressed: () async {
                final confirmed = await _showLogoutConfirmationDialog(context);
                if (confirmed) {
                  await GoogleServices.signOut();
                }
              },
              tooltip: 'Cerrar Sesión',
              backgroundColor: Colors.redAccent,
              child: const Icon(Icons.logout, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSolicitudOption(
      BuildContext context, String title, IconData icon, Color color) {
    return Container(
      width: double.infinity,
      height: 120,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 40, color: Colors.black.withOpacity(0.6)),
            const Spacer(),
            Center(
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: Colors.black.withOpacity(0.6),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
