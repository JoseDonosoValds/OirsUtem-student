import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/api_services.dart';
import '../utils/user_data.dart';
import '../utils/navbar.dart';
import '../utils/classes/get/info_categories.dart';
import '../utils/classes/get/ticket_token_tickets.dart'; // Importar la clase OwnTickets

class MisSolicitudesScreen extends StatefulWidget {
  const MisSolicitudesScreen({super.key});

  @override
  _MisSolicitudesScreenState createState() => _MisSolicitudesScreenState();
}

class _MisSolicitudesScreenState extends State<MisSolicitudesScreen> {
  List<CategoryTicketTypes> categories = [];
  List<OwnTickets> allSolicitudes =
      []; // Lista completa para todas las solicitudes
  List<OwnTickets> filteredSolicitudes =
      []; // Lista filtrada que se muestra al usuario
  String selectedFilter = 'Todas';
  bool isLoading = true;
  final ScrollController _scrollController = ScrollController();
  static const String baseUrl =
      'https://api.sebastian.cl/oirs-utem'; // URL base de la API

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

  // Obtener categorías y todas las solicitudes desde el API
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

    // Obtener todas las solicitudes inicialmente
    List<OwnTickets> allTickets = [];

    for (var category in categories) {
      final solicitudesUrl =
          "$baseUrl/v1/icso/${category.token}/tickets?type=%20&status=%20";

      // Obtener solicitudes por categoría
      final solicitudesData = await ApiService.get(solicitudesUrl, idToken);
      if (solicitudesData != null) {
        final tickets = List<OwnTickets>.from(
          solicitudesData.map((item) => OwnTickets.fromJson(item)),
        );
        allTickets.addAll(tickets);
      }
    }

    setState(() {
      allSolicitudes = allTickets; // Guardar todas las solicitudes
      filteredSolicitudes =
          allSolicitudes; // Inicialmente mostrar todas las solicitudes
      isLoading = false;
    });
  }

  // Cambiar el filtro de solicitudes de manera local
  void _changeFilter(String filter) {
    setState(() {
      selectedFilter = filter;
      if (filter == 'Todas') {
        filteredSolicitudes = allSolicitudes; // Mostrar todas las solicitudes
      } else {
        // Filtrar las solicitudes de acuerdo con la categoría seleccionada
        filteredSolicitudes = allSolicitudes
            .where((solicitud) => solicitud.category.name == filter)
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Mis Solicitudes',
          style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Filtros
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
            const SizedBox(height: 20),

            // Lista de Solicitudes
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      controller: _scrollController,
                      itemCount: filteredSolicitudes.length,
                      itemBuilder: (context, index) {
                        final solicitud = filteredSolicitudes[index];
                        return _buildSolicitudCard(solicitud);
                      },
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const Navbar(currentIndex: 1),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Acción para crear una nueva solicitud
        },
        child: const Icon(Icons.add),
        backgroundColor: Colors.blueAccent,
      ),
    );
  }

  // Widget para construir los botones de filtro
  Widget _buildFilterButton(String label, Color color) {
    return GestureDetector(
      onTap: () {
        _changeFilter(label);
        // Mantener la posición del Scroll
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(_scrollController.position.minScrollExtent);
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: selectedFilter == label ? Colors.blueAccent : color,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            color: selectedFilter == label ? Colors.white : Colors.black,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // Widget para construir las tarjetas de solicitudes
  Widget _buildSolicitudCard(OwnTickets solicitud) {
    String tipo = solicitud.type.toLowerCase();
    String asunto = solicitud.subject;
    String estado = solicitud.status;
    String descripcion = solicitud.message;
    String categoria = solicitud.category.name;

    // Definir colores para cada tipo de solicitud
    Color tipoColor;
    switch (tipo) {
      case 'information':
        tipoColor = const Color(0xFF316f8e); // Azul oscuro
        break;
      case 'suggestion':
        tipoColor = const Color(0xFF4d7032); // Verde oscuro
        break;
      case 'claim':
        tipoColor = const Color(0xFF9b6a2c); // Marrón
        break;
      default:
        tipoColor = Colors.grey; // Color predeterminado
    }

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Stack(
        children: [
          ListTile(
            leading: Icon(
              Icons.description,
              color: tipoColor,
              size: 30,
            ),
            title: Text(
              categoria,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: tipoColor,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  asunto,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                  ),
                ),
                if (descripcion.isNotEmpty)
                  Text(
                    descripcion,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                const SizedBox(height: 5),
                Text(
                  estado,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: estado == 'Error'
                        ? Colors.red
                        : estado == 'Cerrado'
                            ? Colors.grey
                            : Colors.blueAccent,
                  ),
                ),
              ],
            ),
            trailing: const Icon(Icons.more_vert),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              decoration: BoxDecoration(
                color: tipoColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                estado,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
