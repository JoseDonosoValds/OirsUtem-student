import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  /// Colores Base
  static const Color _primaryColor = Color.fromARGB(255, 29, 127, 142);
  static const Color _primaryContainerLight =
      Color.fromARGB(255, 183, 232, 240);
  static const Color _primaryContainerDark = Color.fromARGB(255, 25, 94, 107);

  static const Color _secondaryColor = Color(0xFFFFD6A5);
  static const Color _secondaryContainerLight = Color(0xFFFFE9D1);
  static const Color _secondaryContainerDark = Color.fromARGB(255, 7, 114, 160);

  static const Color _backgroundLight = Color(0xFFFAFAFA);
  static const Color _backgroundDark = Color(0xFF171918);

  static const Color _surfaceLight = Color.fromARGB(255, 237, 237, 237);
  static const Color _surfaceDark = Color.fromARGB(255, 55, 55, 55);

  static const Color _textLight = Color(0xFF333333);
  static const Color _textDark = Color(0xFFFAFAFA);

  /// Colores de Estado
  static const Color _informationLight = Color(0xFF65B5F5);
  static const Color _informationDark = Color(0xFF3A81C1);

  static const Color _suggestionLight = Color(0xFF81C783);
  static const Color _suggestionDark = Color(0xFF4D7750);

  static const Color _claimLight = Color(0xFFFFB74D);
  static const Color _claimDark = Color(0xFFCC8A33);

  /// Colores de las Tarjetas
  static const Color _cardLight = Color(0xFFEBEBEB);
  static const Color _cardDark = Color(0xFF303030);

  /// Esquemas de Colores
  static const ColorScheme _lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: _primaryColor,
    onPrimary: Colors.white,
    primaryContainer: _primaryContainerLight,
    onPrimaryContainer: _textLight,
    secondary: _secondaryColor,
    onSecondary: Colors.black,
    secondaryContainer: _secondaryContainerLight,
    onSecondaryContainer: Colors.black,
    background: _backgroundLight,
    onBackground: _textLight,
    surface: _surfaceLight,
    onSurface: _textLight,
    error: Colors.redAccent,
    onError: Colors.white,
  );

  static const ColorScheme _darkColorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: _primaryColor,
    onPrimary: Colors.white,
    primaryContainer: _primaryContainerDark,
    onPrimaryContainer: _textDark,
    secondary: _secondaryColor,
    onSecondary: Colors.white,
    secondaryContainer: _secondaryContainerDark,
    onSecondaryContainer: Colors.white,
    background: _backgroundDark,
    onBackground: _textDark,
    surface: _surfaceDark,
    onSurface: _textDark,
    error: Colors.redAccent,
    onError: Colors.black,
  );

  /// Tema Claro
  static ThemeData getLight(BuildContext context) => ThemeData(
        colorScheme: _lightColorScheme,
        useMaterial3: true, // Usar Material Design 3
        scaffoldBackgroundColor: _lightColorScheme.background,
        canvasColor: _lightColorScheme.surface,
        cardColor: _cardLight, // Color de fondo para las tarjetas
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: _lightColorScheme.surface,
          indicatorColor: _lightColorScheme.primaryContainer,
          labelTextStyle: MaterialStateProperty.all(
            GoogleFonts.roboto(
              fontSize: 12,
              color: _lightColorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        textTheme: GoogleFonts.robotoTextTheme()
            .apply(bodyColor: _lightColorScheme.onBackground),
        appBarTheme: AppBarTheme(
          backgroundColor: _lightColorScheme.primary,
          iconTheme: IconThemeData(color: _lightColorScheme.onPrimary),
          titleTextStyle: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: _lightColorScheme.onPrimary,
          ),
        ),
      );

  /// Tema Oscuro
  static ThemeData getDark(BuildContext context) => ThemeData(
        colorScheme: _darkColorScheme,
        useMaterial3: true, // Usar Material Design 3
        scaffoldBackgroundColor: _darkColorScheme.background,
        canvasColor: _darkColorScheme.surface,
        cardColor: _cardDark, // Color de fondo para las tarjetas
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: _darkColorScheme.surface,
          indicatorColor: _darkColorScheme.primaryContainer,
          labelTextStyle: MaterialStateProperty.all(
            GoogleFonts.roboto(
              fontSize: 12,
              color: _darkColorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        textTheme: GoogleFonts.robotoTextTheme()
            .apply(bodyColor: _darkColorScheme.onBackground),
        appBarTheme: AppBarTheme(
          backgroundColor: _darkColorScheme.primary,
          iconTheme: IconThemeData(color: _darkColorScheme.onPrimary),
          titleTextStyle: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: _darkColorScheme.onPrimary,
          ),
        ),
      );

  /// Métodos para obtener colores por estado
  static Color getInformationColor(bool isDarkMode) =>
      isDarkMode ? _informationDark : _informationLight;

  static Color getSuggestionColor(bool isDarkMode) =>
      isDarkMode ? _suggestionDark : _suggestionLight;

  static Color getClaimColor(bool isDarkMode) =>
      isDarkMode ? _claimDark : _claimLight;
}
