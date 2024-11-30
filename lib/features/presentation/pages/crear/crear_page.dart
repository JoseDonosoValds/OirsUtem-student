import 'package:flutter/material.dart';
import 'widgets/category_dropdown.dart';
import 'widgets/type_dropdown.dart';
import 'package:logger/logger.dart'; // Importar Logger
import 'widgets/request_form.dart';
import '/features/data/data_sources/api_oirs/oirsInfoService.dart'; // Importar ApiService
import '/features/data/data_sources/api_oirs/oirsIcsoService.dart';
import '/core/core.dart'; // Importar tu tema y estilos
// import '/features/presentation/pages/views.dart';

// import '../services/api_services.dart'; // Asegúrate de que tu servicio esté en su lugar
// import 'mis_solicitudes.dart'; // Pantalla de Mis Solicitudes
import '/features/domain/entities/category_entity.dart'; // Asegúrate de importar tus modelos

class CrearSolicitudScreen extends StatefulWidget {
  const CrearSolicitudScreen({super.key});

  @override
  _CrearSolicitudScreenState createState() => _CrearSolicitudScreenState();
}

class _CrearSolicitudScreenState extends State<CrearSolicitudScreen> {
  List<CategoryTicketTypes> categories = [];
  List<String> types = [];
  CategoryTicketTypes? selectedCategory;
  String? selectedType;
  bool isLoadingCategories = true;
  bool isLoadingTypes = false;

  final Logger _logger = Logger();
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();

  // Instancia del InfoService
  final InfoService _infoService = InfoService();

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  // Obtener categorías
  Future<void> _fetchCategories() async {
    try {
      final data = await _infoService.getCategories();
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
    } catch (error) {
      _showDialog('Error', 'No se pudieron cargar las categorías.');
      setState(() {
        isLoadingCategories = false;
      });
    }
  }

  // Obtener tipos según la categoría seleccionada
  Future<void> _fetchTypes(String categoryToken) async {
    setState(() {
      isLoadingTypes = true;
    });
    try {
      final data = await _infoService.getTypes();
      setState(() {
        types = List<String>.from(data);
        selectedType = null;
        isLoadingTypes = false;
      });
    } catch (error) {
      _showDialog('Error', 'No se pudieron cargar los tipos de solicitud.');
      setState(() {
        isLoadingTypes = false;
      });
    }
  }

  Future<void> _sendRequest(
      String type, String catToken, String subject, String message) async {
    final service = IcsoService();

    final headers = {
      'categoryToken': catToken,
    };

    final body = {
      "type": type,
      "subject": subject,
      "message": message,
    };

    // Mostrar un indicador de carga mientras se envía la solicitud
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    try {
      // Enviar la solicitud al servicio
      final response = await service.createTicket(headers, body);

      // Cerrar el indicador de carga
      Navigator.of(context, rootNavigator: true).pop();

      if (response['success']) {
        _showDialog('Éxito', 'Solicitud enviada exitosamente.');
        _resetFields();
        // Redirigir después de un pequeño retraso
        Future.delayed(const Duration(seconds: 1), () {
          Navigator.of(context).pop();
          Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (context) => const BottomNavBar(),
          ));
        });
      } else {
        _showDialog(
            'Error', response['message'] ?? 'Ocurrió un error inesperado.');
      }
    } catch (error, stackTrace) {
      _logger.e('Error al enviar la solicitud $error, $stackTrace');
      Navigator.of(context, rootNavigator: true).pop();
      _showDialog(
          'Error', 'No se pudo enviar la solicitud. Inténtalo más tarde.');
    }
  }

  void _resetFields() {
    setState(() {
      _subjectController.clear();
      _bodyController.clear();
      selectedCategory = null;
      selectedType = null;
      types = [];
    });
  }

  Future<void> _showDialog(String title, String message) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * 0.05,
              vertical: MediaQuery.of(context).size.height * 0.02,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CategoryDropdown(
                  categories: categories,
                  selectedCategory: selectedCategory,
                  onCategoryChanged: (category) {
                    setState(() {
                      selectedCategory = category;
                      types = [];
                      selectedType = null;
                    });
                    if (category != null) {
                      _fetchTypes(category.token);
                    }
                  },
                ),
                if (selectedCategory != null)
                  Text(selectedCategory!.description,
                      style:
                          const TextStyle(fontSize: 12.0, color: Colors.grey)),
                const SizedBox(height: 16.0),
                TypeDropdown(
                  isLoading: isLoadingTypes,
                  types: types,
                  selectedType: selectedType,
                  onTypeChanged: (type) {
                    setState(() {
                      selectedType = type;
                    });
                  },
                ),
                RequestForm(
                  subjectController: _subjectController,
                  bodyController: _bodyController,
                ),
                const SizedBox(height: 16.0),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (selectedCategory == null) {
                        _showDialog(
                            'Error', 'Por favor selecciona una categoría.');
                        return;
                      }

                      if (selectedType == null) {
                        _showDialog('Error',
                            'Por favor selecciona un tipo de solicitud.');
                        return;
                      }

                      if (_subjectController.text.isEmpty) {
                        _showDialog(
                            'Error', 'El campo "Asunto" no puede estar vacío.');
                        return;
                      }

                      if (_bodyController.text.isEmpty) {
                        _showDialog('Error',
                            'El campo "Mensaje" no puede estar vacío.');
                        return;
                      }

                      _sendRequest(
                        selectedType!,
                        selectedCategory!.token,
                        _subjectController.text,
                        _bodyController.text,
                      );
                    },
                    child: const Text('Enviar Solicitud'),
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
