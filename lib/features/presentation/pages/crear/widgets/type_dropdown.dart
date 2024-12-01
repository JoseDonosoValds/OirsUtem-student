import 'package:flutter/material.dart';

class TypeDropdown extends StatelessWidget {
  final bool isLoading;
  final List<String> types;
  final String? selectedType;
  final ValueChanged<String?> onTypeChanged;

  const TypeDropdown({
    super.key,
    required this.isLoading,
    required this.types,
    required this.selectedType,
    required this.onTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return DropdownButton<String>(
      isExpanded: true,
      value: selectedType,
      hint: const Text('Selecciona un tipo de solicitud'),
      items: types.map((type) {
        return DropdownMenuItem(
          value: type,
          child: Text(type),
        );
      }).toList(),
      onChanged: onTypeChanged,
    );
  }
}
