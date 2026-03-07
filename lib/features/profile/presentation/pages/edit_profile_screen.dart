import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sewa_hub/core/utils/snackbar_utils.dart';
import 'package:sewa_hub/core/widgets/button2.dart';
import 'package:sewa_hub/core/widgets/custom_text_field.dart';
import 'package:sewa_hub/features/auth/presentation/state/auth_state.dart';
import 'package:sewa_hub/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:sewa_hub/features/profile/domain/usecases/change_password_usecase.dart';
import 'package:sewa_hub/features/profile/presentation/state/profile_state.dart';
import 'package:sewa_hub/features/profile/presentation/view_model/profile_view_model.dart';

class EditProfilePage extends ConsumerStatefulWidget {
  const EditProfilePage({super.key});

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage>
    with SingleTickerProviderStateMixin {
  late TextEditingController fullNameController;
  late TextEditingController emailController;
  late TextEditingController currentPasswordController;
  late TextEditingController newPasswordController;
  late TextEditingController confirmPasswordController;
  late TabController _tabController;

  final _profileFormKey = GlobalKey<FormState>();
  final _passwordFormKey = GlobalKey<FormState>();

  final List<XFile> _selectedMedia = [];
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    fullNameController = TextEditingController();
    emailController = TextEditingController();
    currentPasswordController = TextEditingController();
    newPasswordController = TextEditingController();
    confirmPasswordController = TextEditingController();
    _tabController = TabController(length: 2, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(profileViewModelProvider.notifier).getProfile();
    });
  }

  @override
  void dispose() {
    fullNameController.dispose();
    emailController.dispose();
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<bool> _askUserPermission(Permission permission) async {
    final status = await permission.status;
    if (status.isGranted) return true;
    if (status.isDenied) {
      final result = await permission.request();
      return result.isGranted;
    }
    if (status.isPermanentlyDenied) {
      _showPermissionDeniedDialog();
      return false;
    }
    return false;
  }

  Future<void> _cameraPermission() async {
    final hasPermission = await _askUserPermission(Permission.camera);
    if (!hasPermission) return;
    final XFile? photo = await _imagePicker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );
    if (photo != null) {
      setState(() {
        _selectedMedia.clear();
        _selectedMedia.add(photo);
      });
    }
  }

  Future<void> _galleryPermission() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (image != null) {
        setState(() {
          _selectedMedia.clear();
          _selectedMedia.add(image);
        });
      }
    } catch (e) {
      if (mounted) {
        SnackbarUtils.showError(context, message: "Unable to pick image");
      }
    }
  }

  Future<void> _pickMedia() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Profile Photo',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _BottomSheetOption(
                icon: Icons.camera_alt_outlined,
                label: 'Take Photo',
                onTap: () async {
                  Navigator.pop(context);
                  await _cameraPermission();
                },
              ),
              _BottomSheetOption(
                icon: Icons.photo_library_outlined,
                label: 'Choose from Gallery',
                onTap: () async {
                  Navigator.pop(context);
                  await _galleryPermission();
                },
              ),
              if (_selectedMedia.isNotEmpty)
                _BottomSheetOption(
                  icon: Icons.delete_outline,
                  label: 'Remove Photo',
                  iconColor: Colors.red,
                  onTap: () {
                    Navigator.pop(context);
                    setState(() => _selectedMedia.clear());
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Permission Required"),
        content: const Text("Go to settings to grant permission"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileViewModelProvider);
    final authState = ref.watch(authViewModelProvider);
    const primaryColor = Color(0xFFFF7940);

    ref.listen<ProfileState>(profileViewModelProvider, (previous, next) {
      if (next.status == ProfileStatus.loaded && next.profileEntity != null) {
        if (fullNameController.text.isEmpty) {
          fullNameController.text = next.profileEntity!.fullName;
        }
        if (emailController.text.isEmpty) {
          emailController.text = next.profileEntity!.email;
        }
      }
      if (next.status == ProfileStatus.updated) {
        SnackbarUtils.showSuccess(context, message: 'Profile updated successfully');
      }
      if (next.status == ProfileStatus.error && next.errorMessage != null) {
        SnackbarUtils.showError(context, message: next.errorMessage!);
      }
    });

    ref.listen<AuthState>(authViewModelProvider, (previous, next) {
      if (next.status == AuthStatus.passwordChanged) {
        SnackbarUtils.showSuccess(context, message: 'Password changed successfully');
        currentPasswordController.clear();
        newPasswordController.clear();
        confirmPasswordController.clear();
      }
      if (next.status == AuthStatus.error) {
        SnackbarUtils.showError(
          context,
          message: next.errorMessage ?? 'Something went wrong',
        );
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      body: CustomScrollView(
        slivers: [
          // ── Sliver App Bar with Avatar ──
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: Colors.white,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.black),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFFF7940), Color(0xFFFF9A6C)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      GestureDetector(
                        onTap: _pickMedia,
                        child: Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 3),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.15),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: CircleAvatar(
                                radius: 52,
                                backgroundColor: Colors.white,
                                backgroundImage: _selectedMedia.isNotEmpty
                                    ? FileImage(File(_selectedMedia.first.path))
                                    : profileState.profileEntity?.profilePicture != null
                                        ? NetworkImage(
                                            'http://192.168.1.76:5050${profileState.profileEntity!.profilePicture!}',
                                          )
                                        : null,
                                child: _selectedMedia.isEmpty &&
                                        profileState.profileEntity?.profilePicture == null
                                    ? const Icon(Icons.person, size: 52, color: Color(0xFFFF7940))
                                    : null,
                              ),
                            ),
                            Positioned(
                              bottom: 2,
                              right: 2,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.camera_alt,
                                  size: 16,
                                  color: Color(0xFFFF7940),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        profileState.profileEntity?.fullName ?? '',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        profileState.profileEntity?.email ?? '',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(48),
              child: Container(
                color: Colors.white,
                child: TabBar(
                  controller: _tabController,
                  labelColor: primaryColor,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: primaryColor,
                  indicatorWeight: 3,
                  tabs: const [
                    Tab(text: 'Edit Profile'),
                    Tab(text: 'Change Password'),
                  ],
                ),
              ),
            ),
          ),

          // ── Tab Content ──
          SliverFillRemaining(
            child: TabBarView(
              controller: _tabController,
              children: [
                // ── Tab 1: Edit Profile ──
                profileState.status == ProfileStatus.loading
                    ? const Center(child: CircularProgressIndicator(color: primaryColor))
                    : SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: Form(
                          key: _profileFormKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 8),
                              _SectionLabel(label: 'Full Name'),
                              const SizedBox(height: 8),
                              CustomTextField(
                                controller: fullNameController,
                                labelText: 'Full Name',
                                hintText: 'Enter your full name',
                                errorText: 'Full name is required',
                                obscureText: false,
                                validator: (value) {
                                  if (value == null || value.isEmpty) return 'Full name is required';
                                  return null;
                                },
                              ),
                              const SizedBox(height: 20),
                              _SectionLabel(label: 'Email Address'),
                              const SizedBox(height: 8),
                              CustomTextField(
                                controller: emailController,
                                labelText: 'Email',
                                hintText: 'Enter your email',
                                errorText: 'Email is required',
                                obscureText: false,
                                validator: (value) {
                                  if (value == null || value.isEmpty) return 'Email is required';
                                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                                    return 'Enter a valid email';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 32),
                              profileState.status == ProfileStatus.loading
                                  ? const Center(
                                      child: CircularProgressIndicator(color: primaryColor),
                                    )
                                  : Button2(
                                      text: 'Update Profile',
                                      onPressed: () {
                                        if (_profileFormKey.currentState!.validate()) {
                                          File? imageFile;
                                          if (_selectedMedia.isNotEmpty) {
                                            imageFile = File(_selectedMedia.first.path);
                                          }
                                          ref
                                              .read(profileViewModelProvider.notifier)
                                              .updateProfile(
                                                fullName: fullNameController.text.trim(),
                                                email: emailController.text.trim(),
                                                imageFile: imageFile,
                                              );
                                        }
                                      },
                                    ),
                            ],
                          ),
                        ),
                      ),

                // ── Tab 2: Change Password ──
                SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _passwordFormKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: primaryColor.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: primaryColor.withOpacity(0.2)),
                          ),
                          child: Row(
                            children: const [
                              Icon(Icons.info_outline, color: primaryColor, size: 20),
                              SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Password must be at least 6 characters.',
                                  style: TextStyle(color: primaryColor, fontSize: 13),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        _SectionLabel(label: 'Current Password'),
                        const SizedBox(height: 8),
                        CustomTextField(
                          controller: currentPasswordController,
                          labelText: 'Current Password',
                          hintText: '••••••••',
                          errorText: 'Current password is required',
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'Current password is required';
                            if (value.length < 6) return 'Minimum 6 characters';
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        _SectionLabel(label: 'New Password'),
                        const SizedBox(height: 8),
                        CustomTextField(
                          controller: newPasswordController,
                          labelText: 'New Password',
                          hintText: '••••••••',
                          errorText: 'New password is required',
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'New password is required';
                            if (value.length < 6) return 'Minimum 6 characters';
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        _SectionLabel(label: 'Confirm New Password'),
                        const SizedBox(height: 8),
                        CustomTextField(
                          controller: confirmPasswordController,
                          labelText: 'Confirm Password',
                          hintText: '••••••••',
                          errorText: 'Passwords do not match',
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'Please confirm password';
                            if (value != newPasswordController.text) return 'Passwords do not match';
                            return null;
                          },
                        ),
                        const SizedBox(height: 32),
                        authState.status == AuthStatus.loading
                            ? const Center(
                                child: CircularProgressIndicator(color: primaryColor),
                              )
                            : Button2(
                                text: 'Change Password',
                                onPressed: () {
                                  if (_passwordFormKey.currentState!.validate()) {
                                    ref.read(authViewModelProvider.notifier).changePassword(
                                          currentPassword: currentPasswordController.text,
                                          newPassword: newPasswordController.text,
                                          confirmNewPassword: confirmPasswordController.text,
                                        );
                                  }
                                },
                              ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Helper Widgets ──

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Color(0xFF555555),
        letterSpacing: 0.3,
      ),
    );
  }
}

class _BottomSheetOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color iconColor;

  const _BottomSheetOption({
    required this.icon,
    required this.label,
    required this.onTap,
    this.iconColor = const Color(0xFFFF7940),
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: iconColor, size: 22),
      ),
      title: Text(label, style: const TextStyle(fontSize: 15)),
      onTap: onTap,
    );
  }
}