// widgets/filter_button.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FilterButton extends StatelessWidget {
  final String label;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const FilterButton({
    required this.label,
    required this.color,
    required this.isSelected,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4.0),
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color.fromARGB(128, 7, 84, 98)
              : color,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            color: const Color(0xFF04347c),
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
