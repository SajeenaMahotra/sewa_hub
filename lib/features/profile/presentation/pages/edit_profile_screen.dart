import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sewa_hub/core/utils/snackbar_utils.dart';
import 'package:sewa_hub/core/widgets/button2.dart';
import 'package:sewa_hub/core/widgets/button_outline.dart';
import 'package:sewa_hub/core/widgets/custom_text_field.dart';
import 'package:sewa_hub/features/profile/presentation/state/profile_state.dart';
import 'package:sewa_hub/features/profile/presentation/view_model/profile_view_model.dart';

class EditProfilePage extends ConsumerStatefulWidget {
  const EditProfilePage({super.key});

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  late TextEditingController fullNameController;
  late TextEditingController emailController;

  @override
  void initState() {
    super.initState();
    fullNameController = TextEditingController();
    emailController = TextEditingController();

    // Fetch profile on page load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(profileViewModelProvider.notifier).getProfile();
    });
  }

  @override
  void dispose() {
    fullNameController.dispose();
    emailController.dispose();
    super.dispose();
  }

  final List<XFile> _selectedMedia = [];
  final ImagePicker _imagePicker = ImagePicker();

  Future<bool> _askUserPermission(Permission permission) async {
    final status = await permission.status;
    if (status.isGranted) {
      return true;
    }

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

  Future<void> _galleryPermission({bool allowMultiple = false}) async {
    try {
      if (allowMultiple) {
        final List<XFile>? images = await _imagePicker.pickMultiImage(
          imageQuality: 80,
        );

        if (images != null && images.isNotEmpty) {
          setState(() {
            _selectedMedia.clear();
            _selectedMedia.addAll(images);
          });
        }
      } else {
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
      }
    } catch (e) {
      debugPrint("Error picking image: $e");

      if (mounted) {
        SnackbarUtils.showError(
          context,
          message: "Unable to pick image from the gallery",
        );
      }
    }
  }

  Future<void> _pickMedia() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take Photo'),
                onTap: () async {
                  Navigator.of(context).pop();
                  await _cameraPermission();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () async {
                  Navigator.of(context).pop();
                  await _galleryPermission();
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text('Remove Photo'),
                onTap: () {
                  Navigator.of(context).pop();
                  setState(() {
                    _selectedMedia.clear();
                  });
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
        title: const Text("Permission required"),
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

    // Populate fields when profile loads
    ref.listen<ProfileState>(profileViewModelProvider, (previous, next) {
      if (next.status == ProfileStatus.loaded && next.profileEntity != null) {
        fullNameController.text = next.profileEntity!.fullName;
        emailController.text = next.profileEntity!.email;
      }

      if (next.status == ProfileStatus.updated) {
        SnackbarUtils.showSuccess(
          context,
          message: 'Profile updated successfully',
        );
      }

      if (next.status == ProfileStatus.error && next.errorMessage != null) {
        SnackbarUtils.showError(context, message: next.errorMessage!);
      }
    });

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: profileState.status == ProfileStatus.loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile photo
                  Center(
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundColor: Colors.orange.shade100,
                          backgroundImage: _selectedMedia.isNotEmpty
                              ? FileImage(File(_selectedMedia.first.path))
                              : profileState.profileEntity?.profilePicture !=
                                    null
                              ? NetworkImage(
                                  'http://10.0.2.2:5050${profileState.profileEntity!.profilePicture!}', // ← Add base URL
                                )
                              : null,
                          child:
                              _selectedMedia.isEmpty &&
                                  profileState.profileEntity?.profilePicture ==
                                      null
                              ? const Icon(
                                  Icons.person,
                                  size: 50,
                                  color: Colors.orange,
                                )
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: () async {
                              await _pickMedia();
                            },
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Colors.orange,
                                shape: BoxShape.circle,
                              ),
                              padding: const EdgeInsets.all(8),
                              child: const Icon(
                                Icons.edit,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  const Text(
                    "Edit Profile",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),

                  CustomTextField(
                    controller: fullNameController,
                    labelText: "Full Name",
                    hintText: "Enter your full name",
                    errorText: "Full name is required",
                    obscureText: false,
                  ),
                  const SizedBox(height: 20),

                  CustomTextField(
                    controller: emailController,
                    labelText: "Email",
                    hintText: "Enter your email",
                    errorText: "Email is required",
                    obscureText: false,
                  ),
                  const SizedBox(height: 30),

                  Button2(
                    text: "Update Profile",
                    fontSize: 20,
                    onPressed: () {
                      if (fullNameController.text.isEmpty ||
                          emailController.text.isEmpty) {
                        SnackbarUtils.showError(
                          context,
                          message: 'Please fill all fields',
                        );
                        return;
                      }

                      // Convert XFile to File if image is selected
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
                    },
                  ),
                  const SizedBox(height: 15),

                  ButtonOutline(
                    text: "Change Password",
                    onPressed: () {},
                    color: Colors.red,
                  ),
                ],
              ),
            ),
    );
  }
}
