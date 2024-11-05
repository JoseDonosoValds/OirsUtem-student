import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_services.dart'; // Importar el ApiService
import '../utils/user_data.dart'; // Importar el UserModel
import '../utils/navbar.dart'; // Importar el Navbar
import '../utils/classes/get/info_categories.dart'; // Importar la clase para manejar las categorías
// import '../utils/classes/get/types.dart'; // Importar la función para manejar los tipos de solicitud

class CrearSolicitudScreen extends StatefulWidget {
  const CrearSolicitudScreen({super.key});

  @override
  _CrearSolicitudScreenState createState() => _CrearSolicitudScreenState();
}

class _CrearSolicitudScreenState extends State<CrearSolicitudScreen> {
  List<CategoryTicketTypes> categories = [];
  List<String> types =
      []; // Lista para manejar los tipos de solicitud como cadenas de texto
  CategoryTicketTypes? selectedCategory;
  String? selectedType; // Variable para el tipo de solicitud seleccionado
  bool isLoading = true;
  bool isCategorySelected = false;
  bool isTypeSelected =
      false; // Nueva bandera para verificar si se seleccionó un tipo
  bool isSubjectEntered = false;
  static const String url =
      'https://api.sebastian.cl/oirs-utem'; // URL base de tu API

  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchCategories();
    _fetchTypes(); // Llamada para obtener los tipos de solicitudes
  }

  Future<void> _fetchCategories() async {
    final userModel = Provider.of<UserModel>(context, listen: false);
    final idToken = userModel.idToken; // Obtiene el idToken desde Provider

    final data = await ApiService.get(
        "$url/v1/info/categories", idToken!); // URL de tu API

    if (data != null) {
      setState(() {
        categories = List<CategoryTicketTypes>.from(
          data.map((item) => CategoryTicketTypes.fromJson(item)),
        );
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Nueva función para obtener los tipos de solicitudes
  Future<void> _fetchTypes() async {
    final userModel = Provider.of<UserModel>(context, listen: false);
    final idToken = userModel.idToken; // Obtiene el idToken desde Provider

    final data =
        await ApiService.get("$url/v1/info/types", idToken!); // URL de tu API

    if (data != null) {
      setState(() {
        types = List<String>.from(
            data); // Maneja los tipos de solicitud como una lista de Strings
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Función para enviar la solicitud (POST)
  Future<void> _sendRequest() async {
    final userModel = Provider.of<UserModel>(context, listen: false);
    final idToken = userModel.idToken; // Obtiene el idToken desde Provider

    if (selectedCategory == null || selectedType == null) {
      _showErrorDialog(
          'Por favor selecciona una categoría y un tipo de solicitud.');
      return;
    }

    // Construir la URL dinámica
    final postUrl = "$url/v1/icso/${selectedCategory!.token}/ticket";

    // Crear el body del POST en formato JSON
    final body = {
      "type": selectedType,
      "subject": _subjectController.text,
      "message": _bodyController.text,
    };

    // Hacer el POST
    final response = await ApiService.post(postUrl, idToken!, body);

    if (response != null) {
      _showSuccessDialog('Solicitud enviada exitosamente. :$response');
    } else {
      _showErrorDialog(
          'Error al enviar la solicitud. Por favor, intenta de nuevo.');
    }
  }

  // Mostrar diálogo de éxito
  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Éxito'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cerrar el diálogo
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // Mostrar diálogo de error
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cerrar el diálogo
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
      appBar: AppBar(
        title: const Text('Crear Solicitud'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Categoría:',
                    style: TextStyle(fontSize: 18),
                  ),
                  DropdownButton<CategoryTicketTypes>(
                    hint: const Text('Selecciona una categoría'),
                    isExpanded: true,
                    value: selectedCategory,
                    items: categories.map((category) {
                      return DropdownMenuItem<CategoryTicketTypes>(
                        value: category,
                        child: Text(category.name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedCategory = value;
                        isCategorySelected = true;
                      });
                    },
                  ),
                  const SizedBox(height: 20),

                  // Nueva sección para el tipo de solicitud
                  const Text(
                    'Tipo de Solicitud:',
                    style: TextStyle(fontSize: 18),
                  ),
                  DropdownButton<String>(
                    hint: const Text('Selecciona el tipo de solicitud'),
                    isExpanded: true,
                    value: selectedType,
                    items: types.map((type) {
                      return DropdownMenuItem<String>(
                        value: type,
                        child: Text(
                            type), // Mostrar el nombre del tipo de solicitud
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedType = value;
                        isTypeSelected = true;
                      });
                    },
                  ),
                  const SizedBox(height: 20),

                  const Text(
                    'Asunto:',
                    style: TextStyle(fontSize: 18),
                  ),
                  TextField(
                    controller: _subjectController,
                    enabled: isCategorySelected && isTypeSelected,
                    onChanged: (value) {
                      setState(() {
                        isSubjectEntered = value.isNotEmpty;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Ingresa el asunto',
                      border: OutlineInputBorder(),
                      enabled: isCategorySelected && isTypeSelected,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Cuerpo:',
                    style: TextStyle(fontSize: 18),
                  ),
                  TextField(
                    controller: _bodyController,
                    enabled: isCategorySelected &&
                        isTypeSelected &&
                        isSubjectEntered,
                    decoration: InputDecoration(
                      hintText: 'Escribe el cuerpo de la solicitud',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 5,
                  ),
                  const SizedBox(height: 20),
                  // Botón para enviar la solicitud
                  Center(
                    child: ElevatedButton(
                      onPressed: _sendRequest, // Enviar la solicitud
                      child: const Text('Enviar Solicitud'),
                    ),
                  ),
                ],
              ),
      ),
      bottomNavigationBar: const Navbar(currentIndex: 0),
    );
  }
}
