import 'package:flutter/material.dart';

class PartnerFormField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool isRequired;
  final TextInputType? keyboard;
  final int maxLines;

  const PartnerFormField({
    super.key,
    required this.controller,
    required this.label,
    this.isRequired = false,
    this.keyboard,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboard,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          isDense: true,
        ),
        validator: isRequired
            ? (v) => (v == null || v.trim().isEmpty) ? 'Bắt buộc' : null
            : null,
      ),
    );
  }
}
