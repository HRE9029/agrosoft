import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';

import '../../theme.dart';
import '../../widgets/loading_overlay.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final userCtrl = TextEditingController();
  final nameCtrl = TextEditingController();
  final lastCtrl = TextEditingController();
  final ageCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();

  bool _obscurePass = true;

  Map<String, String?> errors = {};

  // ---------------------- VALIDACIONES ----------------------
  bool validateFields() {
    errors.clear();

    if (userCtrl.text.trim().isEmpty) {
      errors["username"] = "El usuario es obligatorio";
    }

    if (nameCtrl.text.trim().isEmpty) {
      errors["name"] = "El nombre es obligatorio";
    }

    if (lastCtrl.text.trim().isEmpty) {
      errors["lastName"] = "Los apellidos son obligatorios";
    }

    if (ageCtrl.text.trim().isEmpty) {
      errors["age"] = "La edad es obligatoria";
    } else if (int.tryParse(ageCtrl.text) == null) {
      errors["age"] = "Solo números";
    }

    if (emailCtrl.text.trim().isEmpty) {
      errors["email"] = "El correo es obligatorio";
    } else if (!emailCtrl.text.contains("@")) {
      errors["email"] = "Correo inválido";
    }

    if (passCtrl.text.trim().length < 6) {
      errors["password"] = "Mínimo 6 caracteres";
    }

    setState(() {});
    return errors.isEmpty;
  }

  // ---------------------- REGISTRO ----------------------
  Future<void> register() async {
    if (!validateFields()) return;

    // Cierra el teclado
    FocusScope.of(context).unfocus();

    LoaderOverlay.show(context);

    try {
      // Crear usuario en Firebase Auth
      UserCredential user = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: emailCtrl.text.trim(),
            password: passCtrl.text.trim(),
          );

      // Guardar en Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.user!.uid)
          .set({
            'username': userCtrl.text.trim(),
            'name': nameCtrl.text.trim(),
            'lastName': lastCtrl.text.trim(),
            'age': ageCtrl.text.trim(),
            'email': emailCtrl.text.trim(),
            'createdAt': DateTime.now(),
          });

      // Espera micro tiempo y navega SIN CRASHEAR EN WEB
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
          //---------------- HEADER ----------------
          Container(
            height: 120,
            width: double.infinity,
            color: AppColors.headerFooter,
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios_new,
                    color: Colors.black87,
                  ),
                  onPressed: () => context.go('/login'),
                ),
                const Spacer(),
                SizedBox(
                  height: 60,
                  child: Image.asset("assets/images/agrosoft_logo.png"),
                ),
                const Spacer(),
              ],
            ),
          ),

          //---------------- FORMULARIO ----------------
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Label("Usuario"),
                  _Field(controller: userCtrl, error: errors["username"]),
                  const SizedBox(height: 16),

                  _Label("Nombre"),
                  _Field(controller: nameCtrl, error: errors["name"]),
                  const SizedBox(height: 16),

                  _Label("Apellidos"),
                  _Field(controller: lastCtrl, error: errors["lastName"]),
                  const SizedBox(height: 16),

                  _Label("Edad"),
                  _Field(
                    controller: ageCtrl,
                    keyboard: TextInputType.number,
                    error: errors["age"],
                  ),
                  const SizedBox(height: 16),

                  _Label("Correo"),
                  _Field(controller: emailCtrl, error: errors["email"]),
                  const SizedBox(height: 16),

                  _Label("Contraseña"),
                  _Field(
                    controller: passCtrl,
                    obscure: _obscurePass,
                    showToggle: true,
                    onToggle: () =>
                        setState(() => _obscurePass = !_obscurePass),
                    error: errors["password"],
                  ),
                  const SizedBox(height: 26),
                ],
              ),
            ),
          ),

          //---------------- FOOTER ----------------
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
                  onPressed: register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.buttons,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text("Crear"),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------- LABEL ----------------
class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.w700,
        color: Colors.black87,
        fontSize: 15,
      ),
    );
  }
}

// ---------------- FIELD ----------------
class _Field extends StatelessWidget {
  final TextEditingController controller;
  final bool obscure;
  final bool showToggle;
  final VoidCallback? onToggle;
  final TextInputType keyboard;
  final String? error;

  const _Field({
    required this.controller,
    this.obscure = false,
    this.showToggle = false,
    this.onToggle,
    this.keyboard = TextInputType.text,
    this.error,
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
          keyboardType: keyboard,
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
            enabledBorder: OutlineInputBorder(
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
