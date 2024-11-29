import 'dart:convert';
import 'package:logger/logger.dart';
import '/features/data/data_sources/api_oirs/oirsBaseService.dart';
import '/features/domain/entities/ticket_entity.dart';
import '/features/data/data_sources/api_oirs/oirsInfoService.dart';
import 'package:http/http.dart' as http;

class IcsoService extends BaseService {
  final Logger _logger = Logger();
  final InfoService _infoService = InfoService();

  /// url
  /// {{baseUrl}}/v1/icso
  String get url => '/v1/icso';

  // Manejo genérico de respuestas JSON
  dynamic _handleResponse(http.Response response) {
    if (response.statusCode == 200) {
      return json.decode(utf8.decode(response.bodyBytes));
    } else {
      _logger.e('Error en la solicitud: ${response.statusCode}');
      throw Exception('Failed with status code ${response.statusCode}');
    }
  }

  /// Obtiene todos los tickets de una categoría
  Future<List<dynamic>> getAllTokenByCategory(
      Map<String, dynamic> headers) async {
    final categoryToken = headers['categoryToken'];
    try {
      final response = await get('$url/$categoryToken/tickets');
      final List<dynamic> tickets = _handleResponse(response);
      _logger.d(tickets);
      return tickets;
    } catch (error) {
      _logger.e('Error al obtener los datos: $error');
      throw Exception('Failed to fetch Tokens by category: $error');
    }
  }

  /// Crea un nuevo ticket
  Future<Map<String, dynamic>> createTicket(
      Map<String, dynamic> headers, Map<String, dynamic> requestBody) async {
    final categoryToken = headers['categoryToken'];
    try {
      final response = await post('$url/$categoryToken/ticket', requestBody);
      final Map<String, dynamic> res = _handleResponse(response);
      _logger.d(res);
      return res;
    } catch (error) {
      _logger.e('Error al crear el ticket: $error');
      throw Exception('Failed to create ticket: $error');
    }
  }

  /// Obtiene un ticket por token
  Future<Map<String, dynamic>> getTicketByToken(
      Map<String, dynamic> headers) async {
    final ticketToken = headers['ticketToken'];
    try {
      final response = await get('$url/$ticketToken/ticket');
      final Map<String, dynamic> ticket = _handleResponse(response);
      _logger.d(ticket);
      return ticket;
    } catch (error) {
      _logger.e('Error al obtener el ticket: $error');
      throw Exception('Failed to fetch ticket by token: $error');
    }
  }

  /// Actualiza un ticket existente
  Future<Map<String, dynamic>> updateTicket(
      Map<String, dynamic> headers, Map<String, dynamic> requestBody) async {
    final ticketToken = headers['ticketToken'];
    try {
      final response = await put('$url/$ticketToken/ticket', requestBody);
      final Map<String, dynamic> updatedTicket = _handleResponse(response);
      _logger.d(updatedTicket);
      return updatedTicket;
    } catch (error) {
      _logger.e('Error al actualizar el ticket: $error');
      throw Exception('Failed to update ticket: $error');
    }
  }

  /// Elimina un ticket
  Future<Map<String, dynamic>> deleteTicket(
      Map<String, dynamic> headers) async {
    final ticketToken = headers['ticketToken'];
    try {
      final response = await delete('$url/$ticketToken/ticket');
      final Map<String, dynamic> deletedTicket = _handleResponse(response);
      _logger.d(deletedTicket);
      return deletedTicket;
    } catch (error) {
      _logger.e('Error al eliminar el ticket: $error');
      throw Exception('Failed to delete ticket: $error');
    }
  }

  /// Obtiene todos los tickets
  Future<List<Ticket>> getAllTickets() async {
    List<dynamic> categories = await _infoService.getCategories();
    Set<String> tokens = {};
    List<Ticket> responses = [];

    _logger.d('Categories fetched: $categories');
    for (var category in categories) {
      tokens.add(category['token']);
    }

    _logger.d('Tokens extracted: $tokens');

    for (var token in tokens) {
      try {
        final response = await get('$url/$token/tickets?type=&status=');
        _logger.d('Response for token $token: ${response.statusCode}');

        if (response.statusCode == 200) {
          final decodedResponse = json.decode(utf8.decode(response.bodyBytes));
          _logger.d('Decoded response for token $token: $decodedResponse');

          if (decodedResponse is List) {
            for (var item in decodedResponse) {
              responses.add(Ticket.fromJson(item));
            }
          } else if (decodedResponse is Map) {
            responses
                .add(Ticket.fromJson(decodedResponse as Map<String, dynamic>));
          }
        } else {
          _logger.e(
              'Failed to fetch tickets for token $token: ${response.statusCode}');
        }
      } catch (error) {
        _logger.e('Error al obtener los datos para token $token: $error');
        throw Exception('Failed to fetch all tokens: $error');
      }
    }

    _logger.d('Total tickets fetched: ${responses.length}');
    return responses;
  }

  /// Método de ejemplo para obtener todos los tickets sin filtrar
  Future<List<Ticket>> getAll() async {
    List<dynamic> categories = await _infoService.getCategories();
    Set<String> tokens = {};
    List<Ticket> responses = [];

    _logger.d('Categories fetched: $categories');
    for (var category in categories) {
      tokens.add(category['token']);
    }

    _logger.d('Tokens extracted: $tokens');

    for (var token in tokens) {
      try {
        final response = await get('$url/$token/tickets?type=&status=');
        _logger.d('Response for token $token: ${response.statusCode}');

        if (response.statusCode == 200) {
          final decodedResponse = json.decode(utf8.decode(response.bodyBytes));
          _logger.d('Decoded response for token $token: $decodedResponse');

          if (decodedResponse is List) {
            for (var item in decodedResponse) {
              responses.add(Ticket.fromJson(item));
            }
          } else if (decodedResponse is Map) {
            responses
                .add(Ticket.fromJson(decodedResponse as Map<String, dynamic>));
          }
        } else {
          _logger.e(
              'Failed to fetch tickets for token $token: ${response.statusCode}');
        }
      } catch (error) {
        _logger.e('Error al obtener los datos para token $token: $error');
        throw Exception('Failed to fetch all tokens: $error');
      }
    }

    _logger.d('Total tickets fetched: ${responses.length}');
    return responses;
  }
}
