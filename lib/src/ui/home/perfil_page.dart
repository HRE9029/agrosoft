import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../theme.dart';
import '../../services/local_profile.dart';
import 'package:go_router/go_router.dart';

class PerfilPage extends StatefulWidget {
  const PerfilPage({super.key});

  @override
  State<PerfilPage> createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage> {
  File? profileImage;

  final userCtrl = TextEditingController(); 
  final nameCtrl = TextEditingController();
  final ageCtrl = TextEditingController();
  final emailCtrl = TextEditingController();

  bool loading = true;
  String uid = "";

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  // ===================================================
  // CARGAR DATOS DESDE FIRESTORE + LOCAL
  // ===================================================
  Future<void> loadUser() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      context.go('/login');
      return;
    }

    uid = user.uid;

    // Firebase
    final snap = await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .get();

    final data = snap.data() ?? {};

    // Llenar campos
    emailCtrl.text = user.email ?? "";
    nameCtrl.text = data["name"] ?? "";
    ageCtrl.text = data["age"]?.toString() ?? "";
    userCtrl.text = data["username"] ?? "";

    // ===== Cargar foto local =====
    final local = await LocalProfile.getProfile();
    if (local != null && (local["imagePath"] ?? "").isNotEmpty) {
      profileImage = File(local["imagePath"]);
    }

    setState(() => loading = false);
  }

  // ===================================================
  // ELEGIR FOTO DESDE GALERÍA
  // ===================================================
  Future<void> pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() {
        profileImage = File(picked.path);
      });
    }
  }

  // ===================================================
  // GUARDAR CAMBIOS (solo username + foto local)
  // ===================================================
  Future<void> saveProfile() async {
    final newUsername = userCtrl.text.trim();

    // Firebase
    await FirebaseFirestore.instance.collection("users").doc(uid).update({
      "username": newUsername,
    });

    // Local
    await LocalProfile.saveProfile({
      "username": newUsername,
      "name": nameCtrl.text,
      "age": ageCtrl.text,
      "email": emailCtrl.text,
      "imagePath": profileImage?.path ?? "",
    });

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Cambios guardados")),
    );
  }

  // ===================================================
  // LOGOUT
  // ===================================================
  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    const double headerHeight = 110;
    const double maxWidth = 520;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ---------------- HEADER ----------------
            Container(
              height: headerHeight,
              width: double.infinity,
              color: AppColors.headerFooter,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new,
                        color: Colors.black87),
                    onPressed: () => context.pop(),
                  ),
                  const Spacer(),
                  const Text(
                    "Perfil",
                    style: TextStyle(
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
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: maxWidth),
                    child: Column(
                      children: [
                        const SizedBox(height: 10),

                        Text(
                          "Hola, ${nameCtrl.text}",
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),

                        const SizedBox(height: 20),

                        // ---------------- FOTO DE PERFIL ----------------
                        Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            CircleAvatar(
                              radius: 55,
                              backgroundColor: Colors.grey.shade300,
                              backgroundImage:
                                  profileImage != null ? FileImage(profileImage!) : null,
                              child: profileImage == null
                                  ? const Icon(Icons.person, size: 60)
                                  : null,
                            ),
                            GestureDetector(
                              onTap: pickImage,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(
                                  color: Colors.black87,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.edit,
                                    color: Colors.white, size: 18),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 30),

                        // ---------------- CAMPOS ----------------
                        _EditableField(
                          label: "Usuario (editable)",
                          controller: userCtrl,
                        ),
                        const SizedBox(height: 16),

                        _ReadOnlyField(label: "Nombre", controller: nameCtrl),
                        const SizedBox(height: 16),

                        _ReadOnlyField(label: "Edad", controller: ageCtrl),
                        const SizedBox(height: 16),

                        _ReadOnlyField(label: "Correo", controller: emailCtrl),
                        const SizedBox(height: 20),

                        // GUARDAR
                        GestureDetector(
                          onTap: saveProfile,
                          child: Container(
                            height: 48,
                            decoration: BoxDecoration(
                              color: AppColors.buttons,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            alignment: Alignment.center,
                            child: const Text(
                              "Guardar cambios",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 30),

                        // LOGOUT
                        GestureDetector(
                          onTap: logout,
                          child: Container(
                            height: 48,
                            decoration: BoxDecoration(
                              color: Colors.black87,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            alignment: Alignment.center,
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.logout, color: Colors.white),
                                SizedBox(width: 8),
                                Text(
                                  "Cerrar sesión",
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

                        const SizedBox(height: 60),
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

// ------------------------------------------------------------
// CAMPOS
// ------------------------------------------------------------

class _EditableField extends StatelessWidget {
  final String label;
  final TextEditingController controller;

  const _EditableField({
    required this.label,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return _FieldBase(
      label: label,
      controller: controller,
      readOnly: false,
    );
  }
}

class _ReadOnlyField extends StatelessWidget {
  final String label;
  final TextEditingController controller;

  const _ReadOnlyField({
    required this.label,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return _FieldBase(
      label: label,
      controller: controller,
      readOnly: true,
    );
  }
}

class _FieldBase extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool readOnly;

  const _FieldBase({
    required this.label,
    required this.controller,
    required this.readOnly,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            )),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          readOnly: readOnly,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.fieldFill,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}
