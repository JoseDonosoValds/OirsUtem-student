import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

class ApiService {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0, // No imprimir los métodos
      errorMethodCount: 5, // Cantidad de líneas en errores
      lineLength: 1024, // Aumentar el límite de longitud de línea
      colors: true, // Imprimir en color
      printEmojis: true, // Incluir emojis en el log
      printTime: false, // No mostrar la hora
    ),
  );

  // Método GET para obtener datos de la API, autenticado con idToken
  static Future<dynamic> get(String url, String idToken) async {

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $idToken',  // Autenticación con idToken
          'Content-Type': 'application/json',  // Header para aceptar JSON
          'accept': 'application/json',        // Header para recibir JSON
        },
      );
      if (response.statusCode == 200) {
        final decodedResponse = utf8.decode(response.bodyBytes);
        return jsonDecode(decodedResponse); 
      } else {
        _logger.e('Error en la petición GET: ${response.statusCode}, ${response.body}');
        return null;
      }
    } catch (e) {
      _logger.e('Excepción en la petición GET: $e');
      return null;
    }
  }

  // Método POST para crear datos en la API
  static Future<dynamic> post(String url, String idToken, Map<String, dynamic> body) async {
    final jsonBody = jsonEncode(body); // Convertimos el body a JSON string para registrar

    _logger.i('Enviando payload en POST a $url con body: $jsonBody'); // Registramos el payload

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $idToken',
          'Content-Type': 'application/json',
          'accept': 'application/json',
        },
        body: jsonBody,
      );

      if (response.statusCode == 201) {
        _logger.i('Respuesta exitosa en POST: ${response.statusCode}, ${response.body}');
        final decodedResponse = utf8.decode(response.bodyBytes);
        return jsonDecode(decodedResponse); 
      } else {
        _logger.e('Error en la petición POST: ${response.statusCode}, ${response.body}');
        return null;
      }
    } catch (e) {
      _logger.e('Excepción en la petición POST: $e');
      return null;
    }
  }

  // Método PUT para actualizar datos en la API
  static Future<dynamic> put(String url, String idToken, Map<String, dynamic> body) async {
    final jsonBody = jsonEncode(body); // Convertimos el body a JSON string para registrar

    _logger.i('Enviando payload en PUT a $url con body: $jsonBody'); // Registramos el payload

    try {
      final response = await http.put(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $idToken',
          'Content-Type': 'application/json',
          'accept': 'application/json',
        },
        body: jsonBody,
      );

      if (response.statusCode == 200) {
        final decodedResponse = utf8.decode(response.bodyBytes);
        return jsonDecode(decodedResponse); 
      } else {
        _logger.e('Error en la petición PUT: ${response.statusCode}, ${response.body}');
        return null;
      }
    } catch (e) {
      _logger.e('Excepción en la petición PUT: $e');
      return null;
    }
  }

  // Método DELETE para eliminar datos de la API
  static Future<bool> delete(String url, String idToken, {Map<String, dynamic>? body}) async {
    String? jsonBody;
    if (body != null) {
      jsonBody = jsonEncode(body);
      _logger.i('Enviando payload en DELETE a $url con body: $jsonBody'); // Registramos el payload en DELETE (si existe)
    }

    _logger.i('Enviando DELETE a $url'); // Registramos solo la URL y el idToken

    try {
      final response = await http.delete(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $idToken',
          'Content-Type': 'application/json',
          'accept': 'application/json',
        },
        body: jsonBody,
      );

      if (response.statusCode == 200) {
        return true; // Eliminación exitosa
      } else {
        _logger.e('Error en la petición DELETE: ${response.statusCode}, ${response.body}');
        return false;
      }
    } catch (e) {
      _logger.e('Excepción en la petición DELETE: $e');
      return false;
    }
  }
}
