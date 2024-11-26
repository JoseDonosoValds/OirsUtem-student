import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import '../services/google_services.dart'; // Importar GoogleServices
import '../services/api_services.dart'; // Importar ApiService
import '../utils/user_data.dart';
import '../utils/navbar.dart';
import '../utils/appbar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  static final Logger _logger = Logger();

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> categories = []; // Categorías obtenidas del API
  bool isLoadingCategories = true;

  @override
  void initState() {
    super.initState();
    _fetchCategories(); // Cargar categorías desde el API
  }

  Future<void> _fetchCategories() async {
    final userModel = Provider.of<UserModel>(context, listen: false);
    final idToken = userModel.idToken;

    final data = await ApiService.get(
        "https://api.sebastian.cl/oirs-utem/v1/info/categories", idToken!);

    if (data != null) {
      setState(() {
        categories = data;
        isLoadingCategories = false;
      });
    } else {
      setState(() {
        isLoadingCategories = false;
      });
    }
  }

  Future<void> _sendQuickRequest(String type, String categoryToken) async {
    final userModel = Provider.of<UserModel>(context, listen: false);
    final idToken = userModel.idToken;

    final body = {
      "type": type,
      "subject": "Solicitud Rápida: $type",
      "message": "Esta es una solicitud rápida del tipo $type.",
    };

    final postUrl =
        "https://api.sebastian.cl/oirs-utem/v1/icso/$categoryToken/ticket";

    final response = await ApiService.post(postUrl, idToken!, body);

    if (response != null) {
      _showDialog('Éxito', 'Solicitud rápida enviada correctamente.');
    } else {
      _showDialog('Error', 'No se pudo enviar la solicitud. Intenta de nuevo.');
    }
  }

  void _showQuickRequestPopup(String type) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        final filteredCategories = categories
            .where((category) =>
                category['name'].toLowerCase() == type.toLowerCase())
            .toList();

        if (filteredCategories.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'No hay categorías disponibles para el tipo: $type',
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey),
            ),
          );
        }

        final categoryToken = filteredCategories.first['token'];

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
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
                'Enviar Solicitud Rápida',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF04347c),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Tipo de Solicitud: $type',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Esta acción enviará automáticamente una solicitud rápida del tipo "$type".',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _sendQuickRequest(type, categoryToken);
                  },
                  child: const Text('Enviar Solicitud'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF04347c),
                  ),
                ),
              ),
            ],
          ),
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
      appBar: const CustomAppBar(title: 'Inicio'),
      body: Padding(
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
                          onTap: () => _showQuickRequestPopup('Reclamo'),
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
                          onTap: () => _showQuickRequestPopup('Sugerencia'),
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
                          onTap: () => _showQuickRequestPopup('Información'),
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
                  FloatingActionButton(
                    onPressed: () async {
                      final confirmed = await _showLogoutConfirmationDialog(context);
                      if (confirmed) {
                        await GoogleServices.signOut(userModel);
                        
                      }
                    },
                    tooltip: 'Cerrar Sesión',
                    backgroundColor: Colors.redAccent,
                    child: const Icon(Icons.logout, color: Colors.white),
                  ),
                ],
              ),
      ),
      bottomNavigationBar: Navbar(currentIndex: 0),
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
