import 'dart:convert';
import './oirsBaseService.dart';
import 'package:logger/logger.dart';
//import 'package:shared_preferences/shared_preferences.dart'; // Para SharedPreferences

class InfoService extends BaseService {
  final Logger _logger = Logger();

  /// url información
  String get v1 => '/v1/info';

  /// Obtener todos los tipos de requerimientos
  Future<List<dynamic>> getTypes() async {
    try {
      final response = await get('$v1/types');
      final List<dynamic> types = json.decode(utf8.decode(response.bodyBytes));
      return types;
    } catch (error) {
      _logger.e('Error al obtener los tipos: $error');
      throw Exception('Failed to fetch types: $error');
    }
  }

  /// Obtener todos los estados de requerimientos
  Future<List<dynamic>> getStatus() async {
    try {
      final response = await get('$v1/status');
      final List<dynamic> status = json.decode(utf8.decode(response.bodyBytes));
      return status;
    } catch (error) {
      _logger.e('Error al obtener los estados: $error');
      throw Exception('Failed to fetch status: $error');
    }
  }

  /// Obtener todas las categorías
  Future<List<dynamic>> getCategories() async {
    try {
      final response = await get('$v1/categories');
      final List<dynamic> categories =
          json.decode(utf8.decode(response.bodyBytes));
      return categories;
    } catch (error) {
      _logger.e('Error al obtener las categorías: $error');
      throw Exception('Failed to fetch categories: $error');
    }
  }
}
