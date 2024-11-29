import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'widgets/category_dropdown.dart';
import 'widgets/type_dropdown.dart';
import 'widgets/request_form.dart';
import '/features/data/data_sources/api_oirs/oirsInfoService.dart';
import '/features/data/data_sources/api_oirs/oirsIcsoService.dart';
import '/features/domain/entities/category_entity.dart';

class CrearSolicitudScreen extends StatefulWidget {
  const CrearSolicitudScreen({Key? key}) : super(key: key);

  @override
  _CrearSolicitudScreenState createState() => _CrearSolicitudScreenState();
}

class _CrearSolicitudScreenState extends State<CrearSolicitudScreen> {
  final Logger _logger = Logger();

  List<CategoryTicketTypes> categories = [];
  List<String> types = [];
  CategoryTicketTypes? selectedCategory;
  String? selectedType;
  bool isLoadingCategories = true;
  bool isLoadingTypes = false;

  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();

  final InfoService _infoService = InfoService();

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

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
      _logger.e('Error al cargar las categorías: $error');
      _showDialog('Error', 'No se pudieron cargar las categorías.');
      setState(() {
        isLoadingCategories = false;
      });
    }
  }

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
      _logger.e('Error al cargar los tipos de solicitud: $error');
      _showDialog('Error', 'No se pudieron cargar los tipos de solicitud.');
      setState(() {
        isLoadingTypes = false;
      });
    }
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
      final response = await service.createTicket(headers, body);

      if (response != null && response['status'] == 'success') {
        _showDialog('Éxito', 'Solicitud enviada exitosamente.');
      } else {
        _showDialog(
            'Error', 'No se pudo enviar la solicitud. Inténtalo de nuevo.');
      }
    } catch (error) {
      _logger.e('Error al enviar la solicitud: $error');
      _showDialog('Error', 'Ocurrió un error al enviar la solicitud.');
    }
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
    return SafeArea(
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
                Text(
                  selectedCategory!.description,
                  style: const TextStyle(fontSize: 12.0, color: Colors.grey),
                ),
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
    );
  }
}
