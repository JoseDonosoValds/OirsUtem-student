import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_services.dart'; // Importar ApiService
import '../utils/user_data.dart'; // Importar UserModel
import '../utils/navbar.dart'; // Importar el Navbar
import '../utils/classes/get/info_categories.dart'; // Importar la clase para manejar las categorías
import '../utils/appbar.dart'; // Importar el AppBar personalizado

class CrearSolicitudScreen extends StatefulWidget {
  const CrearSolicitudScreen({Key? key}) : super(key: key);

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

  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();

  static const String url = 'https://api.sebastian.cl/oirs-utem';

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    final userModel = Provider.of<UserModel>(context, listen: false);
    final idToken = userModel.idToken;

    final data = await ApiService.get("$url/v1/info/categories", idToken!);

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

  Future<void> _fetchTypes(String categoryToken) async {
    final userModel = Provider.of<UserModel>(context, listen: false);
    final idToken = userModel.idToken;

    setState(() {
      isLoadingTypes = true;
    });

    final data =
        await ApiService.get("$url/v1/info/types", idToken!);

    if (data != null) {
      setState(() {
        types = List<String>.from(data);
        selectedType = null;
        isLoadingTypes = false;
      });
    } else {
      setState(() {
        isLoadingTypes = false;
      });
    }
  }

  Future<void> _sendRequest() async {
  final userModel = Provider.of<UserModel>(context, listen: false);
  final idToken = userModel.idToken;

  if (selectedCategory == null || selectedType == null) {
    _showDialog(
      'Error',
      'Por favor selecciona una categoría y un tipo de solicitud.',
    );
    return;
  }

  final body = {
    "type": selectedType,
    "subject": _subjectController.text,
    "message": _bodyController.text,
  };

  final postUrl = "$url/v1/icso/${selectedCategory!.token}/ticket";

  final response = await ApiService.post(postUrl, idToken!, body);

  if (response != null) {
    _showDialog('Éxito', 'Solicitud enviada exitosamente.');
    _resetFields(); // Vaciar los campos después de enviar
  } else {
    _showDialog('Error', 'No se pudo enviar la solicitud. Inténtalo de nuevo.');
  }
}

void _resetFields() {
  setState(() {
    // Vaciar los campos de texto
    _subjectController.clear();
    _bodyController.clear();
    // Reiniciar las selecciones
    selectedCategory = null;
    selectedType = null;
    types = [];
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Crear Solicitud'), // AppBar personalizado
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
                DropdownButton<CategoryTicketTypes>(
                  isExpanded: true,
                  value: selectedCategory,
                  hint: const Text('Selecciona una categoría'),
                  items: categories.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category.name),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedCategory = value;
                      types = [];
                      selectedType = null;
                    });
                    if (value != null) {
                      _fetchTypes(value.token);
                    }
                  },
                ),
                const SizedBox(height: 16.0),
                if (isLoadingTypes)
                  const Center(child: CircularProgressIndicator())
                else if (types.isNotEmpty)
                  DropdownButton<String>(
                    isExpanded: true,
                    value: selectedType,
                    hint: const Text('Selecciona un tipo de solicitud'),
                    items: types.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text(type),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedType = value;
                      });
                    },
                  ),
                const SizedBox(height: 16.0),
                TextField(
                  controller: _subjectController,
                  decoration: const InputDecoration(
                    labelText: 'Asunto',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16.0),
                TextField(
                  controller: _bodyController,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    labelText: 'Mensaje',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16.0),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _sendRequest,
                    child: const Text('Enviar Solicitud'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const Navbar(currentIndex: 1), // Integrar el Navbar
    );
  }
}
