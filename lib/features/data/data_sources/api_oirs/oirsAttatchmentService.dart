import 'dart:convert';
import 'package:logger/logger.dart';
import '/features/data/data_sources/api_oirs/oirsBaseService.dart';
//import '/features/domain/entities/ticket_entity.dart';
//import '/features/data/data_sources/api_oirs/oirsInfoService.dart';
import 'package:http/http.dart' as http;

class attachmentsService extends BaseService {
  final _logger = Logger();
  //final InfoService _infoService = InfoService();

  // Manejo genérico de respuestas JSON
  dynamic _handleResponse(http.Response response) {
    if (response.statusCode > 200 || response.statusCode <= 300) {
      return json.decode(utf8.decode(response.bodyBytes));
    } else {
      _logger.e('Error en la solicitud: ${response.statusCode}');
      throw Exception('Failed with status code ${response.statusCode}');
    }
  }

  String get url => '/v1/attachments/';

  /// {                           ///
  /// "name": "archivo.pdf",      ///
  /// "mime": "application/pdf",  ///
  /// "data": "dGVzdCBkYXRhCg=="  ///
  /// }                           ///

  /// Crea un nuevo attatchment
  Future<Map<String, dynamic>> createAttachment(
      Map<String, dynamic> headers, Map<String, dynamic> requestBody) async {
    final categoryToken = headers['categoryToken'];
    try {
      final response = await post('$url/$categoryToken/upload', requestBody);
      final Map<String, dynamic> res = _handleResponse(response);
      _logger.d(res);
      return res;
    } catch (error) {
      _logger.e('Error al crear el ticket: $error');
      throw Exception('Failed to create ticket: $error');
    }
  }
}
