import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:sewa_hub/commons/snackbar.dart';
import 'package:sewa_hub/screens/dashboard_screen.dart';
import 'package:sewa_hub/widget/button2.dart';
import 'package:sewa_hub/widget/custom_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController= TextEditingController();
  bool _isForgotPasswordHovered = false;
  
  @override
  void dispose(){
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _validateAndLogin() {
    if (_formKey.currentState!.validate()) {
      // Login successful
      showSnackbar(
        context: context,
        message: "Login Successful!",
        color: Colors.green,
      );
      // Clear fields after successful login
      _emailController.clear();
      _passwordController.clear();
    // Navigate to Dashboard after 1 second delay
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const DashboardScreen(),
            ),
          );
        }
      });
    } 
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 150,),
            SizedBox(
              height: 60,
              width: 300,
              child: Image.asset('assets/images/sewahub_logo.png',fit:BoxFit.contain)),
              SizedBox(height: 20,),
              Text("Welcome Back!", style: TextStyle(fontSize: 30,fontWeight: FontWeight.bold),),
              SizedBox(height: 5,),
              Text("Your Trusted Services Await",style: TextStyle(fontSize: 20),),
              SizedBox(height: 30,),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: CustomTextField(controller: _emailController,
                      labelText: "Email",
                      errorText: "Please enter your email address",
                      hintText: 'johndoe@gmail.com',
                      obscureText: false,
                      validator: (value){
                        if (value == null || value.isEmpty){
                          return "Email is required";
                        }
                        if ( !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)){
                          return "Please enter a valid email";
                        }
                        return null;
                      },),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10,),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: CustomTextField(controller: _passwordController,
                labelText: "Password",
                errorText: "Please enter your password",
                hintText: '********',
                obscureText: true,
                validator: (value){
                  if(value == null || value.isEmpty){
                    return "Password is required";
                  }
                  if(value.length < 6){
                    return "Password must be at least 6 characters";
                  }
                  return null;
                },
                ),
              ),
              const SizedBox(height: 2),
                  // Forgot Password Link
                  Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        onEnter: (_) {
                          setState(() {
                            _isForgotPasswordHovered = true;
                          });
                        },
                        onExit: (_) {
                          setState(() {
                            _isForgotPasswordHovered = false;
                          });
                        },
                        child: GestureDetector(
                          onTap: () {
                            // TODO: Add forgot password logic here
                            },
                          child: Text(
                            "Forgot Password?",
                            style: TextStyle(
                              color: _isForgotPasswordHovered
                                  ? const Color(0xFFFF7940)
                                  : Colors.black,
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

              SizedBox(height: 20,),
              Button2(text: "Login", onPressed:_validateAndLogin,),
              ],
        ),
      ),
    );
  }
}