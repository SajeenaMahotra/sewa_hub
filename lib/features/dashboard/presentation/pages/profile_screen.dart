import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sewa_hub/core/widgets/button2.dart';
import 'package:sewa_hub/features/auth/data/repositories/auth_repository.dart';
import 'package:sewa_hub/app/routes/app_routes.dart';
import 'package:sewa_hub/features/auth/presentation/pages/login_page.dart';
import 'package:sewa_hub/core/utils/snackbar_utils.dart';
import 'package:sewa_hub/features/profile/presentation/pages/edit_profile_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        elevation: 0.5,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          "My Profile",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: Colors.black87,
          ),
        ),
      ),

      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            //Profile header card
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFFBF8F4), // soft beige
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 42,
                    backgroundColor: Color.fromARGB(255, 235, 225, 225),
                  ),

                  const SizedBox(height: 12),
                  const Text(
                    "SewaHub Customer",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: 100,
                    child: Button2(
                      text: "Edit",
                      fontSize: 16,
                      onPressed: () {
                        AppRoutes.push(context, const EditProfilePage());
                      },
                    ),
                  ),
                ],
              ),
            ),

            //Menu List
            _menuItem(
              icon: Icons.location_on_outlined,
              label: "Location",
              onTap: () {},
            ),
            _menuItem(
              icon: Icons.palette_outlined,
              label: "Theme",
              onTap: () {},
              trailing: Switch(value: false, onChanged: (v) {}),
            ),
            _menuItem(
              icon: Icons.notifications_none_outlined,
              label: "Notifications",
              onTap: () {},
            ),
            _menuItem(
              icon: Icons.info_outline,
              label: "About App",
              onTap: () {},
            ),
            _menuItem(
              icon: Icons.description_outlined,
              label: "Terms & Conditions",
              onTap: () {},
            ),

            const SizedBox(height: 24),

            //Logout section
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.symmetric(vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: ListTile(
                leading: const Icon(Icons.logout, color: Colors.redAccent),
                title: const Text(
                  "Log Out",
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onTap: () async {
                  final authRepo = ref.read(authRepositoryProvider);
                  final result = await authRepo.logOut();

                  result.fold(
                    (failure) {
                      SnackbarUtils.showError(
                        context,
                        message: failure.message,
                      );
                    },
                    (success) {
                      if (success) {
                        SnackbarUtils.showSuccess(
                          context,
                          message: "Logged out successfully",
                        );
                        AppRoutes.pushReplacement(context, const LoginScreen());
                      }
                    },
                  );
                },
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // Reusable Menu Item
  Widget _menuItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: Colors.black54),
        title: Text(
          label,
          style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w500),
        ),
        trailing:
            trailing ?? const Icon(Icons.chevron_right, color: Colors.black38),
      ),
    );
  }
}
