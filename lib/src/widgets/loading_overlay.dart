import 'package:flutter/material.dart';

class LoaderOverlay {
  static OverlayEntry? _currentOverlay;
  static bool _visible = false;

  // ⭐ MOSTRAR OVERLAY
  static void show(BuildContext context) {
    if (_visible) return; // Evita duplicados
    _visible = true;

    _currentOverlay = OverlayEntry(
      builder: (context) => Stack(
        children: [
          // Fondo oscuro semi-transparente
          Positioned.fill(
            child: Container(color: Colors.black.withValues(alpha: 0.45)),
          ),

          // Animación + logo + texto
          Positioned.fill(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TweenAnimationBuilder(
                    tween: Tween<double>(begin: 0.85, end: 1.15),
                    duration: const Duration(seconds: 1),
                    curve: Curves.easeInOut,
                    builder: (_, value, __) {
                      return Transform.scale(
                        scale: value,
                        child: Image.asset(
                          'assets/images/agrosoft_logo.png',
                          width: 120,
                          height: 120,
                        ),
                      );
                    },
                    onEnd: () {}, // sin warnings
                  ),

                  const SizedBox(height: 16),

                  const Text(
                    "Cargando...",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );

    Overlay.of(context).insert(_currentOverlay!);
  }

  // ⭐ OCULTAR OVERLAY
  static void hide(BuildContext context) {
    if (!_visible) return;

    _visible = false;

    try {
      _currentOverlay?.remove();
    } catch (_) {
      // Evita errores si ya fue removido
    }

    _currentOverlay = null;
  }
}
