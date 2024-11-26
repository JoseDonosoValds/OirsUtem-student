import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import '../utils/classes/get/error_status.dart'; // Importar ErrorStatus

class ApiService {
  static final Logger _logger = Logger();

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
        _handleError(response);
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
        _handleError(response);
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
        _handleError(response);
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
        _handleError(response);
        return false;
      }
    } catch (e) {
      _logger.e('Excepción en la petición DELETE: $e');
      return false;
    }
  }

  // Método para manejar los errores usando el esquema RFC7807
  static void _handleError(http.Response response) {
    try {
      final decodedResponse = utf8.decode(response.bodyBytes);
      final errorStatus = errorStatusFromJson(decodedResponse);
      _logger.e(
          'Error en la petición: ${errorStatus.title}, Status: ${errorStatus.status}, Detalle: ${errorStatus.detail}, Tipo: ${errorStatus.type}, Instancia: ${errorStatus.instance}');
    } catch (e) {
      _logger.e('Error inesperado al manejar la respuesta de error: ${response.body}, Excepción: $e');
    }
  }
}
