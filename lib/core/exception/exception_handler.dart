import 'package:logger/logger.dart';

class ExceptionHandler {
  static final Logger _logger = Logger();

  /// Método para manejar excepciones de manera centralizada
  static void handleException(dynamic error, {StackTrace? stackTrace}) {
    if (error is AppException) {
      _logAppException(error, stackTrace);
    } else {
      // Excepciones no específicas
      _logger.e('Unhandled exception: $error, $error, $stackTrace');
    }
  }

  // Registra las excepciones personalizadas
  static void _logAppException(AppException error, StackTrace? stackTrace) {
    if (error is NotFoundException) {
      _logger.w('NotFoundException: ${error.message}');
    } else if (error is UnauthorizedException) {
      _logger.w('UnauthorizedException: ${error.message}');
    } else if (error is BadRequestException) {
      _logger.w('BadRequestException: ${error.message}');
    } else {
      _logger.e('AppException: ${error.message}');
    }

    // Si hay stackTrace, lo agregamos para diagnóstico más detallado
    if (stackTrace != null) {
      _logger.d('Stack trace: $stackTrace');
    }
  }
}

// Base class para todas las excepciones personalizadas
abstract class AppException implements Exception {
  final String message;
  AppException(this.message);

  @override
  String toString() => '$runtimeType: $message';
}

// Excepciones personalizadas
class NotFoundException extends AppException {
  NotFoundException(String message) : super(message);
}

class UnauthorizedException extends AppException {
  UnauthorizedException(String message) : super(message);
}

class BadRequestException extends AppException {
  BadRequestException(String message) : super(message);
}

class InternalServerErrorException extends AppException {
  InternalServerErrorException(String message) : super(message);
}

class TimeoutException extends AppException {
  TimeoutException(String message) : super(message);
}
