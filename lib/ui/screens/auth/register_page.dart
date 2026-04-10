import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';

import '../../../controllers/auth_controller.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = AuthController.to;

    final nameController = TextEditingController();
    final emailController = TextEditingController(text: controller.prefillEmail.value);
    final passwordController = TextEditingController(text: controller.prefillPassword.value);

    return Scaffold(
      appBar: AppBar(title: const Text("Register")),
      body: Obx(() => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Name"),
            ),
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
                controller.register(
                  name: nameController.text.trim(),
                  email: emailController.text.trim(),
                  password: passwordController.text.trim(),
                );
              },
              child: const Text("Register"),
            ),
          ],
        ),
      )),
    );
  }
}