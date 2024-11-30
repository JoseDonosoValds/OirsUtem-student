import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logger/logger.dart';
import '/features/data/data_sources/api_oirs/oirsInfoService.dart';
import '/features/data/data_sources/api_oirs/oirsIcsoService.dart';
import 'widgets/widgets.dart'; // Importamos el widget de solicitud
import '/features/domain/entities/category_entity.dart';
import '/features/data/data_sources/local/sharedPreferences.dart'; // Importar ApiService
// import '/core/core.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  static final Logger _logger = Logger(); // Instancia de Logger, luego usarlo

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<CategoryTicketTypes> categories = []; // Lista de categorías
  bool isLoadingCategories = true;
  String displayName = ''; // Variable para almacenar el displayName

  CategoryTicketTypes? selectedCategory;
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchCategories(); // Cargar categorías desde el API
    _loadDisplayName(); // Cargar el displayName desde SharedPreferences
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  Future<void> _fetchCategories() async {
    final infoService = InfoService();
    final data = await infoService.getCategories(); // Obtener las categorías

    if (data.isNotEmpty) {
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

  // Función para cargar el displayName desde SharedPreferences
  Future<void> _loadDisplayName() async {
    String? name = await StorageService.getValue('displayName');
    setState(() {
      displayName = name; // Si no hay displayName, usamos un valor por defecto
    });
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

  Future<void> _sendRequest(
      String type, String? catToken, String subject, String message) async {
    final service = IcsoService();

    if (catToken == null || subject.isEmpty || message.isEmpty) {
      _showDialog('Error', 'Por favor llena todos los campos antes de enviar.');
      return;
    }

    final headers = {
      'categoryToken': catToken,
    };

    final body = {
      "type": type,
      "subject": subject,
      "message": message,
    };

    try {
      // Aquí usamos la función createTicket del servicio IcsoService
      final response = await service.createTicket(headers, body);

      if (response['success']) {
        _showDialog('Éxito', 'Solicitud enviada exitosamente.');
      } else {
        _showDialog(
            'Error', 'No se pudo enviar la solicitud. Inténtalo de nuevo.');
      }
    } catch (e) {
      _showDialog('Error', 'Ocurrió un error al enviar la solicitud.');
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
        return Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 16),
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
                      type,
                      selectedCategory?.token,
                      _subjectController.text,
                      _bodyController.text,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF04347c),
                  ),
                  child: const Text('Enviar Solicitud'),
                ),
              ],
            ),
          ),
        );
      },
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
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: isLoadingCategories
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                children: [
                  // Mostrar el displayName después de cargarlo
                  Text(
                    'Hola! $displayName',
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
                          child: SolicitudOptionWidget(
                            title: 'Reclamo',
                            icon: Icons.warning_amber_rounded,
                            color: Colors.orange.shade300,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Flexible(
                        flex: 1,
                        child: GestureDetector(
                          onTap: () => _showQuickRequestPopup('SUGGESTION'),
                          child: SolicitudOptionWidget(
                            title: 'Sugerencia',
                            icon: Icons.lightbulb,
                            color: Colors.green.shade300,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Flexible(
                        flex: 1,
                        child: GestureDetector(
                          onTap: () => _showQuickRequestPopup('INFORMATION'),
                          child: SolicitudOptionWidget(
                            title: 'Información',
                            icon: Icons.info_outline,
                            color: Colors.blue.shade300,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }
}
