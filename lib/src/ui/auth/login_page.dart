import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

import '../../theme.dart';
import '../../widgets/loading_overlay.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();

  bool _obscurePass = true;

  Map<String, String?> errors = {};

  // ================= VALIDACIONES =================
  bool validateFields() {
    errors.clear();

    if (emailCtrl.text.trim().isEmpty) {
      errors["email"] = "El correo es obligatorio";
    } else if (!emailCtrl.text.contains("@")) {
      errors["email"] = "Correo no válido";
    }

    if (passCtrl.text.trim().isEmpty) {
      errors["password"] = "La contraseña es obligatoria";
    } else if (passCtrl.text.trim().length < 6) {
      errors["password"] = "Mínimo 6 caracteres";
    }

    setState(() {});
    return errors.isEmpty;
  }

  // ================= LOGIN =================
  Future<void> login() async {
    if (!validateFields()) return;

    FocusScope.of(context).unfocus(); // cerrar teclado
    LoaderOverlay.show(context);

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailCtrl.text.trim(),
        password: passCtrl.text.trim(),
      );

      // Esperar un poquito para evitar crash en web
      await Future.delayed(const Duration(milliseconds: 120));

      if (mounted) {
        LoaderOverlay.hide(context);
        context.go('/home');
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        LoaderOverlay.hide(context);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.message ?? "Error")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // ---------------- HEADER ----------------
          Container(
            height: 120,
            width: double.infinity,
            color: AppColors.headerFooter,
            child: Center(
              child: SizedBox(
                height: 60,
                child: Image.asset(
                  'assets/images/agrosoft_logo.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),

          // ---------------- CONTENIDO ----------------
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
              child: Column(
                children: [
                  // ICONO
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey.shade300,
                    child: const Icon(
                      Icons.person,
                      size: 60,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // EMAIL
                  _Label("Usuario"),
                  _Field(controller: emailCtrl, error: errors["email"]),
                  const SizedBox(height: 20),

                  // PASSWORD
                  _Label("Contraseña"),
                  _Field(
                    controller: passCtrl,
                    obscure: _obscurePass,
                    error: errors["password"],
                    showToggle: true,
                    onToggle: () =>
                        setState(() => _obscurePass = !_obscurePass),
                  ),
                  const SizedBox(height: 22),

                  // LINK A REGISTRO
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "¿No tienes cuenta?",
                        style: TextStyle(color: Colors.black87),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () => context.go('/register'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.buttons,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: const Text("Crear cuenta"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ---------------- BOTÓN INFERIOR ----------------
          Container(
            height: 110,
            width: double.infinity,
            color: AppColors.headerFooter,
            padding: const EdgeInsets.symmetric(horizontal: 22),
            child: Center(
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.buttons,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text("Ingresar"),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ================= LABEL =================
class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.black87,
          fontWeight: FontWeight.w700,
          fontSize: 15,
        ),
      ),
    );
  }
}

// ================= FIELD =================
class _Field extends StatelessWidget {
  final TextEditingController controller;
  final bool obscure;
  final String? error;
  final bool showToggle;
  final VoidCallback? onToggle;

  const _Field({
    required this.controller,
    this.obscure = false,
    this.error,
    this.showToggle = false,
    this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final hasError = error != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          obscureText: obscure,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.fieldFill,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            suffixIcon: showToggle
                ? IconButton(
                    icon: Icon(
                      obscure ? Icons.visibility_off : Icons.visibility,
                      color: Colors.black87,
                    ),
                    onPressed: onToggle,
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: hasError
                  ? const BorderSide(color: Colors.red, width: 2)
                  : BorderSide.none,
            ),
          ),
        ),

        if (hasError)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 4),
            child: Text(
              error!,
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
      ],
    );
  }
}
