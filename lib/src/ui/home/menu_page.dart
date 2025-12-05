import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme.dart';

class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

  static const double _headerH = 110;
  static const double _maxW = 520;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ================= HEADER =================
            Container(
              height: _headerH,
              width: double.infinity,
              color: AppColors.headerFooter,
              alignment: Alignment.center,
              child: SizedBox(
                height: 70,
                child: Image.asset("assets/images/agrosoft_logo.png"),
              ),
            ),

            // ================= CONTENIDO =================
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: _maxW),
                    child: Column(
                      children: [
                        _MenuTile(
                          icon: Icons.person_outline,
                          text: "Perfil",
                          onTap: () => context.push("/profile"),
                        ),
                        const SizedBox(height: 12),
                        _MenuTile(
                          icon: Icons.description_outlined,
                          text: "Políticas",
                          onTap: () => context.push("/politicas"),
                        ),
                        const SizedBox(height: 12),
                        _MenuTile(
                          icon: Icons.settings_outlined,
                          text: "Configuración",
                          onTap: () => context.push("/config"),
                        ),
                        const SizedBox(height: 12),
                        _MenuTile(
                          icon: Icons.help_outline,
                          text: "Ayuda",
                          onTap: () => context.push("/help"),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =========================================================
//                      TARJETA DE MENÚ
// =========================================================

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;

  const _MenuTile({
    required this.icon,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const double h = 56;
    const double stripW = 22;
    const double outerRadius = 12.0;

    return Material(
      elevation: 3,
      shadowColor: Colors.black26,
      borderRadius: BorderRadius.circular(outerRadius),
      color: Colors.transparent,
      child: Stack(
        children: [
          // 🟩 Franja IZQUIERDA (oscura)
          Positioned.fill(
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                width: stripW,
                height: h,
                decoration: const BoxDecoration(
                  color: AppColors.buttons, // negro
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(outerRadius),
                    bottomLeft: Radius.circular(outerRadius),
                  ),
                ),
              ),
            ),
          ),

          // 🟨 Botón amarillo (fondo principal)
          Padding(
            padding: const EdgeInsets.only(left: stripW),
            child: SizedBox(
              height: h,
              child: InkWell(
                onTap: onTap,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(outerRadius),
                  bottomRight: Radius.circular(outerRadius),
                ),
                child: Ink(
                  decoration: const BoxDecoration(
                    color: AppColors.fieldFill, // AMARILLO CORRECTO
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(outerRadius),
                      bottomRight: Radius.circular(outerRadius),
                    ),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 16),
                      Icon(icon, color: Colors.black87, size: 22),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          text,
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

