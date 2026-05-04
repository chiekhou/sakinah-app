import 'package:flutter/material.dart';
import 'package:sakinah_app/constants/app_theme.dart';

/// Dialog de rappel de sécurité affiché aux mineurs
/// avant d'accéder aux fonctionnalités communautaires.
/// Retourne true si l'utilisateur accepte, false sinon.
Future<bool> showSafetyReminderDialog(
  BuildContext context, {
  required String feature,
}) async {
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.shield_outlined,
                color: Colors.orange,
                size: 40,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Rappel de sécurité',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Avant d\'accéder à $feature, rappelle-toi :',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            _buildRule(
              Icons.person_off_outlined,
              'Ne partage jamais ton nom, adresse, école ou numéro de téléphone.',
            ),
            const SizedBox(height: 10),
            _buildRule(
              Icons.lock_outline,
              'Ne partage aucune photo ou information personnelle avec des inconnus.',
            ),
            const SizedBox(height: 10),
            _buildRule(
              Icons.family_restroom,
              'Ton parent ou tuteur peut voir tes activités sur cette application.',
            ),
            const SizedBox(height: 10),
            _buildRule(
              Icons.report_outlined,
              'En cas de comportement inapproprié, signale-le immédiatement.',
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: Text(
            'Annuler',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: const Text(
            'J\'ai compris',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    ),
  );
  return result ?? false;
}

Widget _buildRule(IconData icon, String text) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(icon, size: 18, color: Colors.orange),
      const SizedBox(width: 10),
      Expanded(
        child: Text(
          text,
          style: const TextStyle(fontSize: 13, color: AppTheme.textPrimary),
        ),
      ),
    ],
  );
}
