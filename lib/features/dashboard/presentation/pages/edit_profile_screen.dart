import 'package:flutter/material.dart';
import 'package:sewa_hub/core/widgets/button2.dart';
import 'package:sewa_hub/core/widgets/button_outline.dart';
import 'package:sewa_hub/core/widgets/custom_text_field.dart';

class EditProfilePage extends StatelessWidget {
  EditProfilePage({super.key});

  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

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
                    backgroundImage: NetworkImage(
                      'https://via.placeholder.com/150',
                    ), // replace with user's photo
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      decoration: BoxDecoration(
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
