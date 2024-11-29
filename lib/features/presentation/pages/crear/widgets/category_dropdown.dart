import 'package:flutter/material.dart';
import '/features/domain/entities/category_entity.dart';

class CategoryDropdown extends StatelessWidget {
  final List<CategoryTicketTypes> categories;
  final CategoryTicketTypes? selectedCategory;
  final ValueChanged<CategoryTicketTypes?> onCategoryChanged;

  const CategoryDropdown({
    Key? key,
    required this.categories,
    required this.selectedCategory,
    required this.onCategoryChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DropdownButton<CategoryTicketTypes>(
      isExpanded: true,
      value: selectedCategory,
      hint: const Text('Selecciona una categoría'),
      items: categories.map((category) {
        return DropdownMenuItem(
          value: category,
          child: Text(category.name),
        );
      }).toList(),
      onChanged: onCategoryChanged,
    );
  }
}
