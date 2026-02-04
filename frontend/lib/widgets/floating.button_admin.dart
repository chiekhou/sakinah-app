import 'package:flutter/material.dart';

class FloatingAdminButton extends StatelessWidget {
  final VoidCallback onTap;

  const FloatingAdminButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 16,
      right: 80, // À gauche du bouton notifications
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(28),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.deepPurple.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.admin_panel_settings,
              color: Colors.deepPurple,
              size: 24,
            ),
          ),
        ),
      ),
    );
  }
}
