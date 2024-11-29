import 'package:flutter/material.dart';

class RequestForm extends StatelessWidget {
  final TextEditingController subjectController;
  final TextEditingController bodyController;

  const RequestForm({
    Key? key,
    required this.subjectController,
    required this.bodyController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: subjectController,
          decoration: const InputDecoration(
            labelText: 'Asunto',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16.0),
        TextField(
          controller: bodyController,
          maxLines: 5,
          decoration: const InputDecoration(
            labelText: 'Mensaje',
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }
}
