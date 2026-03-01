import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sewa_hub/core/utils/snackbar_utils.dart';
import 'package:sewa_hub/core/widgets/button2.dart';
import 'package:sewa_hub/core/widgets/custom_text_field.dart';
import 'package:sewa_hub/features/auth/presentation/state/auth_state.dart';
import 'package:sewa_hub/features/auth/presentation/view_model/auth_view_model.dart';

class ChangePasswordForm extends ConsumerStatefulWidget {
  const ChangePasswordForm({super.key});

  @override
  ConsumerState<ChangePasswordForm> createState() => _ChangePasswordFormState();
}

class _ChangePasswordFormState extends ConsumerState<ChangePasswordForm> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      ref.read(authViewModelProvider.notifier).changePassword(
            currentPassword: _currentPasswordController.text,
            newPassword: _newPasswordController.text,
            confirmNewPassword: _confirmPasswordController.text,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);

    ref.listen<AuthState>(authViewModelProvider, (_, next) {
      if (next.status == AuthStatus.passwordChanged) {
        SnackbarUtils.showSuccess(
          context,
          message: 'Password updated successfully.',
          title: 'Success!',
        );
        _currentPasswordController.clear();
        _newPasswordController.clear();
        _confirmPasswordController.clear();
      }
      if (next.status == AuthStatus.error) {
        SnackbarUtils.showError(
          context,
          message: next.errorMessage ?? 'Failed to change password',
        );
      }
    });

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Change Password',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _currentPasswordController,
            labelText: 'Current Password',
            hintText: '********',
            errorText: 'Current password required',
            obscureText: true,
            validator: (value) {
              if (value == null || value.isEmpty) return 'Current password is required';
              if (value.length < 6) return 'Must be at least 6 characters';
              return null;
            },
          ),
          const SizedBox(height: 12),
          CustomTextField(
            controller: _newPasswordController,
            labelText: 'New Password',
            hintText: '********',
            errorText: 'New password required',
            obscureText: true,
            validator: (value) {
              if (value == null || value.isEmpty) return 'New password is required';
              if (value.length < 6) return 'Must be at least 6 characters';
              return null;
            },
          ),
          const SizedBox(height: 12),
          CustomTextField(
            controller: _confirmPasswordController,
            labelText: 'Confirm New Password',
            hintText: '********',
            errorText: 'Passwords do not match',
            obscureText: true,
            validator: (value) {
              if (value == null || value.isEmpty) return 'Please confirm your password';
              if (value != _newPasswordController.text) return 'Passwords do not match';
              return null;
            },
          ),
          const SizedBox(height: 20),
          authState.status == AuthStatus.loading
              ? const Center(child: CircularProgressIndicator(color: Color(0xFFFF7940)))
              : Button2(text: 'Update Password', onPressed: _submit),
        ],
      ),
    );
  }
}