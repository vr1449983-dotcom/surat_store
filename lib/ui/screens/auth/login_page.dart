import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:surat_store/ui/screens/auth/register_page.dart';

import '../../../controllers/auth_controller.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = AuthController.to;

    final emailController = TextEditingController(text: controller.prefillEmail.value);
    final passwordController = TextEditingController(text: controller.prefillPassword.value);

    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Obx(() => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: "Password"),
              obscureText: true,
            ),
            const SizedBox(height: 20),

            controller.isLoading.value
                ? const CircularProgressIndicator()
                : ElevatedButton(
              onPressed: () {
                controller.login(
                  email: emailController.text.trim(),
                  password: passwordController.text.trim(),
                );
              },
              child: const Text("Login"),
            ),

            TextButton(
              onPressed: () => Get.to(() => const RegisterScreen()),
              child: const Text("Create Account"),
            )
          ],
        ),
      )),
    );
  }
}