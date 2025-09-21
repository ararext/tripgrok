import 'package:flutter/material.dart';

class EmergencyButton extends StatelessWidget {
  final VoidCallback onPressed;
  const EmergencyButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: onPressed,
      icon: const Icon(Icons.warning, color: Colors.white),
      label: const Text("SOS"),
      backgroundColor: Colors.red,
    );
  }
}
