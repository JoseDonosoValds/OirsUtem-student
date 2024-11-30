import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FilterButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const FilterButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4.0),
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary.withOpacity(0.8)
              : theme.colorScheme.surface.withOpacity(0.6), // Fondo dinámico
          borderRadius: BorderRadius.circular(15),
          border: isSelected
              ? Border.all(
                  color: theme.colorScheme.primary, width: 1.5) // Borde activo
              : Border.all(
                  color: theme.colorScheme.onSurface
                      .withOpacity(0.3), // Borde inactivo
                  width: 1),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            color: isSelected
                ? theme.colorScheme.onPrimary // Texto seleccionado
                : theme.colorScheme.onSurface, // Texto no seleccionado
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
