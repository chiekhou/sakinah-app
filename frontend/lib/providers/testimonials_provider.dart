import 'package:flutter/material.dart';
import 'package:sakinah_app/services/testimonial_service.dart';

class TestimonialsProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _testimonials = [];
  bool _isLoading = false;
  String? _error;

  List<Map<String, dynamic>> get testimonials => _testimonials;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Charge tous les témoignages depuis le serveur
  Future<void> loadTestimonials(String? token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await TestimonialService.getAllTestimonials(token: token);
      _testimonials = data.cast<Map<String, dynamic>>();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Toggle like avec optimistic update — seule source de vérité pour les likes
  Future<void> toggleLike(String testimonialId, String token) async {
    final index = _testimonials.indexWhere(
      (t) => t['id'].toString() == testimonialId,
    );
    if (index == -1) return;

    final original = Map<String, dynamic>.from(_testimonials[index]);
    final wasLiked = original['has_liked'] as bool? ?? false;
    final oldCount = original['likes_count'] as int? ?? 0;

    // Optimistic update (.clamp pour éviter les -1)
    _testimonials[index] = Map<String, dynamic>.from(original)
      ..['has_liked'] = !wasLiked
      ..['likes_count'] =
          wasLiked ? (oldCount - 1).clamp(0, 99999) : oldCount + 1;
    notifyListeners();

    try {
      await TestimonialService.toggleLike(
        token: token,
        testimonialId: testimonialId,
      );
    } catch (e) {
      // Revert en cas d'erreur
      _testimonials[index] = original;
      notifyListeners();
      rethrow;
    }
  }

  /// État du like pour un témoignage (utilisé par l'écran détail)
  bool getLikeState(String testimonialId) {
    try {
      final t = _testimonials.firstWhere(
        (t) => t['id'].toString() == testimonialId,
      );
      return t['has_liked'] as bool? ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Compteur de likes pour un témoignage (utilisé par l'écran détail)
  int getLikesCount(String testimonialId) {
    try {
      final t = _testimonials.firstWhere(
        (t) => t['id'].toString() == testimonialId,
      );
      return t['likes_count'] as int? ?? 0;
    } catch (_) {
      return 0;
    }
  }

  /// Indique si un témoignage est présent dans la liste chargée
  bool containsTestimonial(String testimonialId) {
    return _testimonials.any((t) => t['id'].toString() == testimonialId);
  }
}
