import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  static const double _headerH = 110;
  static const double _maxW = 520;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ---------------- HEADER ----------------
            Container(
              height: _headerH,
              width: double.infinity,
              color: AppColors.headerFooter,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new,
                      color: Colors.black87,
                    ),
                    onPressed: () => context.pop(),
                  ),
                  const Spacer(),
                  const Text(
                    "Ayuda",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black87,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),

            // ---------------- CONTENIDO ----------------
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: _maxW),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ----------- GUÍA DE USO -----------
                        const Text(
                          "¿Cómo usar AgroSoft?",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          "Explora cultivos desde el menú principal. "
                          "Al seleccionar un cultivo, podrás ver plagas, "
                          "enfermedades y malezas asociadas. "
                          "También puedes registrar tus propias parcelas "
                          "desde la sección 'Mis cultivos'.",
                          style: TextStyle(fontSize: 14),
                        ),

                        const SizedBox(height: 20),

                        // ----------- FAQ -----------
                        const Text(
                          "Preguntas frecuentes",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 12),

                        const Text(
                          "¿Necesito internet para usar la app?",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Text(
                          "No es necesario para ver tus parcelas guardadas. "
                          "Sin embargo, algunas funciones como consultar "
                          "información actualizada en línea requieren conexión.",
                          style: TextStyle(fontSize: 14),
                        ),
                        const SizedBox(height: 16),

                        const Text(
                          "¿Se guarda mi información personal?",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Text(
                          "No. AgroSoft no almacena datos personales sensibles. "
                          "Solamente se guarda la información necesaria para "
                          "mostrar y organizar tus cultivos.",
                          style: TextStyle(fontSize: 14),
                        ),

                        const SizedBox(height: 20),

                        // ----------- CONTACTO -----------
                        const Text(
                          "Contacto de soporte",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          "Si necesitas ayuda adicional, puedes escribirnos a:",
                          style: TextStyle(fontSize: 14),
                        ),
                        const SizedBox(height: 6),
                        const SelectableText(
                          "agrosoft.soporte@gmail.com",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.blueGrey,
                          ),
                        ),

                        const SizedBox(height: 30),
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
