import 'package:flutter/material.dart';
import '../../theme.dart';
import 'package:provider/provider.dart';
import '../../providers/settings_provider.dart';

class ConfigPage extends StatefulWidget {
  const ConfigPage({super.key});

  @override
  State<ConfigPage> createState() => _ConfigPageState();
}

class _ConfigPageState extends State<ConfigPage> {
  static const double headerH = 110;
  static const double maxW = 520;

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ===== HEADER =====
            Container(
              height: headerH,
              width: double.infinity,
              color: AppColors.headerFooter,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Spacer(),
                  const Text(
                    "Ajustes",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),

            // ===== CONTENIDO =====
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: maxW),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // =============================
                        //       TAMAÑO DE LETRA
                        // =============================
                        const Text(
                          "Tamaño de letra",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 8),

                        Row(
                          children: [
                            _OptionButton(
                              text: "Normal",
                              selected: !settings.isLargeFont,
                              onTap: () => settings.updateFontSize(false),
                            ),
                            const SizedBox(width: 10),
                            _OptionButton(
                              text: "Grande",
                              selected: settings.isLargeFont,
                              onTap: () => settings.updateFontSize(true),
                            ),
                          ],
                        ),

                        const SizedBox(height: 22),

                        // =============================
                        //        NOTIFICACIONES
                        // =============================
                        const Text(
                          "Notificaciones",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 10),

                        _SwitchTile(
                          label: "Riego",
                          value: settings.notifRiego,
                          onChanged: (v) => settings.updateNotifRiego(v),
                        ),
                        _SwitchTile(
                          label: "Cosecha",
                          value: settings.notifCosecha,
                          onChanged: (v) => settings.updateNotifCosecha(v),
                        ),
                        _SwitchTile(
                          label: "Sonido",
                          value: settings.notifSound,
                          onChanged: (v) => settings.updateNotifSound(v),
                        ),

                        const SizedBox(height: 40),
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

// ====================================================================
//                 BOTÓN DE OPCIÓN
// ====================================================================
class _OptionButton extends StatelessWidget {
  final String text;
  final bool selected;
  final VoidCallback onTap;

  const _OptionButton({
    required this.text,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: selected ? AppColors.fieldFill : Colors.black87,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            text,
            style: TextStyle(
              color: selected ? Colors.black87 : Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

// ====================================================================
//                 SWITCH REUTILIZABLE
// ====================================================================
class _SwitchTile extends StatelessWidget {
  final String label;
  final bool value;
  final Function(bool) onChanged;

  const _SwitchTile({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeTrackColor: Colors.black.withValues(alpha: 0.06),
          activeThumbColor: AppColors.fieldFill,
        ),
      ],
    );
  }
}
