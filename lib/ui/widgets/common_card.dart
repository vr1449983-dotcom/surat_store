import 'package:flutter/material.dart';

class CommonCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;

  const CommonCard({
    super.key,
    required this.child,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: child,
        ),
      ),
    );
  }
}