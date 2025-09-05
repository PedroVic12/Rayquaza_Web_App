import 'package:flutter/material.dart';

import '../exceptions/validate_exception.dart';

class TextInput extends StatelessWidget {
  final TextEditingController? controller;
  final void Function(String value)? validator;
  final String? hint;
  final bool enabled;

  const TextInput({
    super.key,
    this.enabled = true,
    this.controller,
    this.validator,
    this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      autovalidateMode: AutovalidateMode.always,
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        hintText: hint,
      ),
      validator: (name) {
        try {
          validator?.call(name ?? '');
          return null;
        } on ValidateException catch (e) {
          return e.message;
        }
      },
    );
  }
}