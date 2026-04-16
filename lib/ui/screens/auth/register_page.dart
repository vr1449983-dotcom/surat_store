import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/auth_controller.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final controller = AuthController.to;

  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController passwordController;

  final RxBool obscurePassword = true.obs;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    emailController =
        TextEditingController(text: controller.prefillEmail.value);
    passwordController =
        TextEditingController(text: controller.prefillPassword.value);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: const Text("Create Account"),
        elevation: 0,
        centerTitle: true,
      ),

      body: SafeArea(
        child: Obx(() => Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),

                  // 🔝 Logo / Icon
                  Center(
                    child: Container(
                      height: 80,
                      width: 80,
                      decoration: BoxDecoration(
                        color: primary.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Icon(
                        Icons.storefront_rounded,
                        color: primary,
                        size: 40,
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  // Title
                  Text(
                    "Create your account",
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    "Sign up to get started",
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.hintColor,
                    ),
                  ),

                  const SizedBox(height: 30),

                  // 👤 Name
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: "Full Name",
                      prefixIcon:
                      Icon(Icons.person_outline, color: primary),
                      filled: true,
                      fillColor:
                      theme.colorScheme.surfaceVariant.withOpacity(0.3),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // 📩 Email
                  TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: "Email",
                      prefixIcon:
                      Icon(Icons.mail_outline, color: primary),
                      filled: true,
                      fillColor:
                      theme.colorScheme.surfaceVariant.withOpacity(0.3),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // 🔐 Password
                  Obx(() => TextField(
                    controller: passwordController,
                    obscureText: obscurePassword.value,
                    decoration: InputDecoration(
                      labelText: "Password",
                      prefixIcon:
                      Icon(Icons.lock_outline, color: primary),
                      filled: true,
                      fillColor: theme
                          .colorScheme.surfaceVariant
                          .withOpacity(0.3),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscurePassword.value
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: primary,
                        ),
                        onPressed: obscurePassword.toggle,
                      ),
                    ),
                  )),

                  const SizedBox(height: 30),

                  // 🔥 CREATE ACCOUNT BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: controller.isLoading.value
                        ? const Center(
                        child: CircularProgressIndicator())
                        : ElevatedButton(
                      onPressed: () {
                        controller.register(
                          name: nameController.text.trim(),
                          email: emailController.text.trim(),
                          password:
                          passwordController.text.trim(),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primary,
                        elevation: 8,
                        shadowColor: primary.withOpacity(0.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.person_add_alt_1_rounded,
                              size: 20,color: Colors.white,),
                          SizedBox(width: 10),
                          Text(
                            "CREATE ACCOUNT",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                               color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  // Already have account
                  Center(
                    child: GestureDetector(
                      onTap: () => Get.back(),
                      child: RichText(
                        text: TextSpan(
                          text: "Already have an account? ",
                          style: theme.textTheme.bodyMedium,
                          children: [
                            TextSpan(
                              text: "Login",
                              style: TextStyle(
                                color: primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        )),
      ),
    );
  }
}