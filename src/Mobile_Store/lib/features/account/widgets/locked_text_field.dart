import 'package:flutter/material.dart';

class LockedTextField extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const LockedTextField({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: value,
      enabled: false,
      style: const TextStyle(fontSize: 14, color: Colors.black54),
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.grey[200], 
        prefixIcon: Icon(icon, size: 20, color: Colors.grey),
        suffixIcon: const Icon(Icons.lock_outline, size: 16, color: Colors.grey),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}