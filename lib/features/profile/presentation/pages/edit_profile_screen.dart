import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sewa_hub/core/utils/snackbar_utils.dart';
import 'package:sewa_hub/core/widgets/button2.dart';
import 'package:sewa_hub/core/widgets/button_outline.dart';
import 'package:sewa_hub/core/widgets/custom_text_field.dart';

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
  }

  @override
  void dispose() {
    fullNameController.dispose();
    emailController.dispose();
    super.dispose();
  }

  final List<XFile> _selectedMedia = []; //images.video
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

  //code for camera
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

  //code for gallery
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

      if (!mounted) {
        SnackbarUtils.showError(
          context,
          message: "Unable to pick image from the gallery",
        );
      }
      ;
    }
  }

  //code for dialogBox: showDialog for men
  Future<void> _pickMedia() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text('Take Photo'),
                onTap: () async {
                  Navigator.of(context).pop();
                  await _cameraPermission();
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Choose from Gallery'),
                onTap: () async {
                  Navigator.of(context).pop();
                  await _galleryPermission();
                },
              ),
              ListTile(
                leading: Icon(Icons.delete),
                title: Text('Remove Photo'),
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
        title: Text("Permission required"),
        content: Text("Go to settings to grant permission"),
        actions: [
          TextButton(onPressed: () {}, child: Text('Cancel')),
          TextButton(onPressed: () {}, child: Text('Open Settings')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
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
                        : null,
                    child: _selectedMedia.isEmpty
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

            Button2(text: "Update Profile", fontSize: 20, onPressed: () {}),
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
