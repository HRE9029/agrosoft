import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme.dart';

class PoliticasPage extends StatelessWidget {
  const PoliticasPage({super.key});

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
                    onPressed: () => context.pop(),
                    icon: const Icon(
                      Icons.arrow_back_ios_new,
                      color: Colors.black87,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    "Políticas de privacidad",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),

            // ---------------- CONTENIDO ----------------
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 24),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: _maxW),
                    child: const _PoliticasContent(),
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

// =============================================================
//                 TEXTO DE POLÍTICAS (ESTÁTICO)
// =============================================================

class _PoliticasContent extends StatelessWidget {
  const _PoliticasContent();

  TextStyle get _title =>
      const TextStyle(fontSize: 15, fontWeight: FontWeight.w700);

  TextStyle get _body =>
      const TextStyle(fontSize: 14, color: Colors.black87, height: 1.35);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle("1. Recolección de datos"),
        Text(
          "AgroSoft no recopila datos personales sensibles. Solo se registra información básica proporcionada por el usuario, como nombre, datos de cultivos, fechas de siembra y actividades realizadas. Toda la información es voluntaria y permanece bajo el control del usuario.",
          style: _body,
        ),
        const SizedBox(height: 14),

        _sectionTitle("2. Uso de la información"),
        Text(
          "La información capturada se utiliza exclusivamente para mejorar la experiencia del usuario dentro de AgroSoft, generar recordatorios, cálculos y optimizar el seguimiento de cultivos. No se utiliza con fines comerciales ni publicitarios.",
          style: _body,
        ),
        const SizedBox(height: 14),

        _sectionTitle("3. Almacenamiento de datos"),
        Text(
          "Los datos se almacenan principalmente de manera local en el dispositivo del usuario. En caso de usar servicios en línea, AgroSoft no guarda información personal sin autorización previa.",
          style: _body,
        ),
        const SizedBox(height: 14),

        _sectionTitle("4. Seguridad"),
        Text(
          "AgroSoft implementa medidas básicas de seguridad para proteger los datos. La información no se comparte con terceros sin consentimiento del usuario.",
          style: _body,
        ),
        const SizedBox(height: 14),

        _sectionTitle("5. Responsabilidad"),
        Text(
          "La información agrícola que presenta AgroSoft es de carácter orientativo y educativo. Las decisiones agrícolas dependen del usuario y la app no se hace responsable por decisiones basadas únicamente en estos datos.",
          style: _body,
        ),
        const SizedBox(height: 14),

        _sectionTitle("6. Permisos del dispositivo"),
        Text(
          "Para proporcionar ciertas funciones, AgroSoft puede solicitar permisos como acceso a cámara, almacenamiento o notificaciones. El usuario puede activar o desactivar estos permisos cuando lo desee.",
          style: _body,
        ),
        const SizedBox(height: 14),

        _sectionTitle("7. Modificaciones"),
        Text(
          "Estas políticas pueden actualizarse para mejorar la seguridad y experiencia del usuario. Las nuevas versiones se mostrarán dentro de la aplicación cuando estén disponibles.",
          style: _body,
        ),
        const SizedBox(height: 14),

        _sectionTitle("8. Contacto"),
        Text(
          "Para dudas o comentarios, el usuario puede comunicarse al correo: agrosoft.soporte@gmail.com",
          style: _body,
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(text, style: _title),
    );
  }
}
