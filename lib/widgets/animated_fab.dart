import 'package:flutter/material.dart';

class AnimatedFab extends StatelessWidget {
  final VoidCallback onPressed;
  const AnimatedFab({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onPressed,
      child: const Icon(Icons.add),
    );
  }
}
