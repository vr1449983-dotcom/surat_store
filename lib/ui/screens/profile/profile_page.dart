import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/auth_controller.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = AuthController.to;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        centerTitle: true,
      ),

      body: Obx(() {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [

              // 🔵 PROFILE HEADER
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 30,
                      child: Icon(Icons.person, size: 30),
                    ),
                    const SizedBox(width: 12),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            auth.userName.value.isEmpty
                                ? "No Name"
                                : auth.userName.value,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(auth.userEmail.value),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // 📊 INFO CARDS
              _infoTile(Icons.store, "Shop ID", auth.currentShopId ?? "N/A"),
              _infoTile(Icons.email, "Email", auth.userEmail.value),
              _infoTile(Icons.person, "Name", auth.userName.value),

              const SizedBox(height: 20),

              // ⚙️ ACTIONS
              _actionTile(
                icon: Icons.refresh,
                title: "Refresh Data",
                onTap: () async {
                  await auth.loadUserData();
                  Get.snackbar("Success", "Data refreshed");
                },
              ),

              _actionTile(
                icon: Icons.logout,
                title: "Logout",
                color: Colors.red,
                onTap: () => _confirmLogout(auth),
              ),
            ],
          ),
        );
      }),
    );
  }

  // ================= WIDGETS =================

  Widget _infoTile(IconData icon, String title, String value) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(value),
      ),
    );
  }

  Widget _actionTile({
    required IconData icon,
    required String title,
    Color? color,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(title),
        onTap: onTap,
      ),
    );
  }

  // ================= LOGOUT DIALOG =================

  void _confirmLogout(AuthController auth) {
    Get.defaultDialog(
      title: "Confirm Logout",
      middleText: "Are you sure you want to logout?",
      textCancel: "Cancel",
      textConfirm: "Logout",
      confirmTextColor: Colors.white,
      onConfirm: () {
        Get.back();
        auth.logout();
      },
    );
  }
}