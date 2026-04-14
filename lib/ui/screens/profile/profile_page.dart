import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/auth_controller.dart';
import '../../../core/services/sync_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = AuthController.to;
    final syncService = SyncService();

    const primary = Colors.deepPurple;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FC),

      /// 🎨 CLASSIC APPBAR
      appBar: AppBar(
        elevation: 0,
        backgroundColor: primary,
        centerTitle: true,
        title: const Text(
          "Profile",
          style: TextStyle(fontWeight: FontWeight.w600,color: Colors.white),
        ),
      ),

      body: Obx(() {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [

              /// 👤 CLASSIC PROFILE CARD
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 12,
                    ),
                  ],
                ),
                child: Column(
                  children: [

                    /// AVATAR
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: primary.withOpacity(0.1),
                      child: Text(
                        auth.userName.value.isNotEmpty
                            ? auth.userName.value[0].toUpperCase()
                            : "U",
                        style: TextStyle(
                          fontSize: 28,
                          color: primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    /// NAME
                    Text(
                      auth.userName.value.isEmpty
                          ? "No Name"
                          : auth.userName.value,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 6),

                    /// EMAIL
                    Text(
                      auth.userEmail.value,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                      ),
                    ),

                    const SizedBox(height: 16),

                    /// EDIT BUTTON
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _editNameDialog(auth),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text("Edit Profile",style: TextStyle(color: Colors.white),),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              /// INFO SECTION
              _sectionTitle("Account"),

              _tile(
                icon: Icons.store,
                title: "Shop ID",
                subtitle: auth.currentShopId ?? "N/A",
              ),

              const SizedBox(height: 20),

              /// ACTIONS
              _sectionTitle("Actions"),

              _tile(
                icon: Icons.sync,
                title: "Sync Data",
                subtitle: "Update your latest data",
                onTap: () async {
                  Get.dialog(
                    const Center(child: CircularProgressIndicator()),
                    barrierDismissible: false,
                  );

                  await syncService.syncData();

                  Get.back();
                  Get.snackbar("Success", "Data synced",
                      backgroundColor: Colors.green,
                      colorText: Colors.white);
                },
              ),

              _tile(
                icon: Icons.logout,
                title: "Logout",
                subtitle: "Sign out from account",
                onTap: () => _confirmLogout(auth),
              ),

              const SizedBox(height: 20),
            ],
          ),
        );
      }),
    );
  }

  /// SECTION TITLE
  Widget _sectionTitle(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade600,
          ),
        ),
      ),
    );
  }

  /// TILE
  Widget _tile({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.grey.shade700),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(subtitle,
                      style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
      ),
    );
  }

  /// EDIT NAME
  void _editNameDialog(AuthController auth) {
    final controller =
    TextEditingController(text: auth.userName.value);

    Get.bottomSheet(
      SafeArea(
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius:
            BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Update Name",
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: "Enter name",
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final name = controller.text.trim();
        
                    if (name.isEmpty) {
                      Get.snackbar("Error", "Name cannot be empty");
                      return;
                    }
        
                    await auth.updateUserName(name);
        
                    Get.back();
                    Get.snackbar("Success", "Profile updated",
                        backgroundColor: Colors.green,
                        colorText: Colors.white);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                    Get.theme.colorScheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text("Update",style: TextStyle(color: Colors.white),),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// LOGOUT
  void _confirmLogout(AuthController auth) {
    Get.defaultDialog(
      title: "Logout",
      middleText: "Do you really want to logout?",
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
