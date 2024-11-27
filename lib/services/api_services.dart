import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import '../utils/classes/get/error_status.dart'; // Importar ErrorStatus

class ApiService {
  static final Logger _logger = Logger();

  // Helper para manejar respuestas exitosas
  static dynamic _handleSuccess(http.Response response) {
    final decodedResponse = utf8.decode(response.bodyBytes);
    try {
      return jsonDecode(decodedResponse);
    } catch (e) {
      _logger.e('Error al decodificar respuesta JSON: $e');
      return null;
    }
  }

  // Helper para manejar errores
  static void _handleError(http.Response response) {
    try {
      final decodedResponse = utf8.decode(response.bodyBytes);
      _logger.e('Respuesta de error decodificada: $decodedResponse');

      final errorStatus = errorStatusFromJson(decodedResponse);
      _logger.e(
        'Error detallado: ${errorStatus.title}, '
        'Status: ${errorStatus.status}, '
        'Detalle: ${errorStatus.detail}, '
        'Tipo: ${errorStatus.type}, '
        'Instancia: ${errorStatus.instance}',
      );
    } catch (e) {
      _logger.e(
        'Error inesperado al manejar la respuesta de error: ${response.body}, '
        'Excepción: $e',
      );
    }
  }

  // Método GET para obtener datos de la API, autenticado con idToken
  static Future<dynamic> get(String url, String idToken) async {
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $idToken',
          'Content-Type': 'application/json',
          'accept': 'application/json',
        },
      );

      switch (response.statusCode) {
        case 200:
          return _handleSuccess(response);
        case 401:
          _logger.e('Error de autenticación: ${response.body}');
          throw Exception('No autorizado');
        case 403:
          _logger.e('Acceso denegado: ${response.body}');
          throw Exception('Acceso denegado');
        default:
          _handleError(response);
          return null;
      }
    } catch (e) {
      _logger.e('Excepción en la petición GET: $e');
      return null;
    }
  }

  // Método POST para enviar datos a la API
  static Future<dynamic> post(
      String url, String idToken, Map<String, dynamic> body) async {
    final jsonBody = jsonEncode(body);
    _logger.i('Enviando POST a $url con payload: $jsonBody');

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

      switch (response.statusCode) {
        case 200:
        case 201:
          return _handleSuccess(response);
        case 400:
          _logger.e('Solicitud incorrecta: ${response.body}');
          throw Exception('Solicitud incorrecta');
        case 401:
          _logger.e('Error de autenticación: ${response.body}');
          throw Exception('No autorizado');
        case 403:
          _logger.e('Acceso denegado: ${response.body}');
          throw Exception('Acceso denegado');
        default:
          _handleError(response);
          return null;
      }
    } catch (e) {
      _logger.e('Excepción en la petición POST: $e');
      return null;
    }
  }

  // Método PUT para actualizar datos en la API
  static Future<dynamic> put(
      String url, String idToken, Map<String, dynamic> body) async {
    final jsonBody = jsonEncode(body);
    _logger.i('Enviando PUT a $url con payload: $jsonBody');

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

      switch (response.statusCode) {
        case 200 || 201 || 202:
          return _handleSuccess(response);
        case 400:
          _logger.e('Solicitud incorrecta: ${response.body}');
          throw Exception('Solicitud incorrecta');
        case 401:
          _logger.e('Error de autenticación: ${response.body}');
          throw Exception('No autorizado');
        case 403:
          _logger.e('Acceso denegado: ${response.body}');
          throw Exception('Acceso denegado');
        default:
          _handleError(response);
          return null;
      }
    } catch (e) {
      _logger.e('Excepción en la petición PUT: $e');
      return null;
    }
  }

  // Método DELETE para eliminar datos de la API
  static Future<bool> delete(String url, String idToken,
      {Map<String, dynamic>? body}) async {
    String? jsonBody;
    if (body != null) {
      jsonBody = jsonEncode(body);
      _logger.i('Enviando DELETE a $url con payload: $jsonBody');
    }

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

      switch (response.statusCode) {
        case 200:
          return true;
        case 401:
          _logger.e('Error de autenticación: ${response.body}');
          throw Exception('No autorizado');
        case 403:
          _logger.e('Acceso denegado: ${response.body}');
          throw Exception('Acceso denegado');
        case 404:
          _logger.e('Recurso no encontrado: ${response.body}');
          throw Exception('Recurso no encontrado');
        default:
          _handleError(response);
          return false;
      }
    } catch (e) {
      _logger.e('Excepción en la petición DELETE: $e');
      return false;
    }
  }
}
