import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sewa_hub/features/auth/data/repositories/auth_repository.dart';
import 'package:sewa_hub/core/widgets/button2.dart';
import 'package:sewa_hub/app/routes/app_routes.dart';
import 'package:sewa_hub/features/auth/presentation/pages/login_page.dart';
import 'package:sewa_hub/core/utils/snackbar_utils.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Button2(
            text: "Logout",
            onPressed: () async {
              final authRepo = ref.read(authRepositoryProvider);
              final result = await authRepo.logOut();

              result.fold(
                (failure) {
                  // Show error snackbar
                  SnackbarUtils.showError(
                    context,
                    message: failure.message,
                  );
                },
                (success) {
                  if (success) {
                    // Show success snackbar
                    SnackbarUtils.showSuccess(
                      context,
                      message: "Logged out successfully",
                    );
                    // Navigate to Login screen
                    AppRoutes.pushReplacement(context, const LoginScreen());
                  }
                },
              );
            },
            
          ),
        ),
      ),
    );
  }
}
