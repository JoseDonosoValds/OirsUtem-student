import 'package:http/http.dart' as http;
import 'dart:convert'; // Para json.encode y json.decode
import 'package:appcm202402/core/exception/exception_handler.dart'; // Asegúrate de que este es el path correcto
import 'package:shared_preferences/shared_preferences.dart'; // Para SharedPreferences

class BaseService {
  static const String _baseUrl = 'https://api.sebastian.cl/oirs-utem';
  static const String _contentType = "application/json";

  Future<Map<String, String>> _getHeaders() async {
    // Obtener el token JWT desde SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    String? jwt = prefs.getString('idToken');
    if (jwt == null) {
      throw UnauthorizedException(
          "El token de autenticación no está disponible.");
    }
    return {
      'accept': _contentType,
      'Content-Type': _contentType,
      'Authorization': "Bearer $jwt"
    };
  }

  /// Base Get
  Future<http.Response> get(String endpoint) async {
    Uri url = Uri.parse('$_baseUrl$endpoint');
    Map<String, String> headers = await _getHeaders();
    try {
      final response = await http.get(url, headers: headers);
      return response;
    } catch (error, stackTrace) {
      ExceptionHandler.handleException(error, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Base Post
  Future<http.Response> post(
      String endpoint, Map<String, dynamic> requestBody) async {
    Uri url = Uri.parse('$_baseUrl$endpoint');
    Map<String, String> headers = await _getHeaders();

    // Serializar el cuerpo de la solicitud a JSON
    final jsonBody = json.encode(requestBody);

    try {
      // Enviar el cuerpo como una cadena JSON
      final response = await http.post(
        url,
        headers: headers,
        body: jsonBody, // Aquí pasamos el cuerpo serializado a JSON
      );
      return response;
    } catch (error, stackTrace) {
      ExceptionHandler.handleException(error, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Base Put
  Future<http.Response> put(
      String endpoint, Map<String, dynamic> requestBody) async {
    Uri url = Uri.parse('$_baseUrl$endpoint');
    Map<String, String> headers = await _getHeaders();

    // Serializar el cuerpo de la solicitud a JSON
    final jsonBody = json.encode(requestBody);

    try {
      // Enviar el cuerpo como una cadena JSON
      final response = await http.put(
        url,
        headers: headers,
        body: jsonBody, // Aquí pasamos el cuerpo serializado a JSON
      );
      return response;
    } catch (error, stackTrace) {
      ExceptionHandler.handleException(error, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Base Delete
  Future<http.Response> delete(String endpoint) async {
    Uri url = Uri.parse('$_baseUrl$endpoint');
    Map<String, String> headers = await _getHeaders();
    try {
      final response = await http.delete(url, headers: headers);
      return response;
    } catch (error, stackTrace) {
      ExceptionHandler.handleException(error, stackTrace: stackTrace);
      rethrow;
    }
  }
}
