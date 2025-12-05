import 'package:flutter/material.dart';
import 'package:sewa_hub/commons/snackbar.dart';
import 'package:sewa_hub/screens/login_screen.dart';
import 'package:sewa_hub/widget/button2.dart';
import 'package:sewa_hub/widget/custom_text_field.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _fullnameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmpasswordController =
      TextEditingController();

  @override
  void dispose() {
    _fullnameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmpasswordController.dispose();
    super.dispose();
  }

  void _validateAndSignup() {
    if (_formKey.currentState!.validate()) {
      // Signup successful
      showSnackbar(
        context: context,
        message: "Signup Successful!",
        color: Colors.green,
      );
      // Clear fields after successful signup
      _fullnameController.clear();
      _emailController.clear();
      _passwordController.clear();
      _confirmpasswordController.clear();
      // Navigate to Login after 1 second delay
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        }
      });
    } else {
      showSnackbar(
        context: context,
        message: "Please fix the errors",
        color: Colors.red,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 500),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 500),
              child: Column(
                children: [
                  const SizedBox(height: 100),
                  SizedBox(
                    height: 60,
                    width: 300,
                    child: Image.asset(
                      'assets/images/sewahub_logo.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Create Your Account",
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    "Sign up to access reliable services anytime, anywhere.",
                    style: TextStyle(fontSize: 15),
                  ),
                  const SizedBox(height: 30),
                  Form(
                    key: _formKey,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          // Full Name Field
                          CustomTextField(
                            controller: _fullnameController,
                            labelText: "Full Name",
                            errorText: "Please enter your full name",
                            hintText: 'John Doe',
                            obscureText: false,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Full name is required";
                              }
                              if (value.length < 3) {
                                return "Full name must be at least 3 characters";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 15),
                          // Email Field
                          CustomTextField(
                            controller: _emailController,
                            labelText: "Email",
                            errorText: "Please enter your email address",
                            hintText: 'johndoe@gmail.com',
                            obscureText: false,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Email is required";
                              }
                              if (!RegExp(
                                r'^[^@]+@[^@]+\.[^@]+',
                              ).hasMatch(value)) {
                                return "Please enter a valid email";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 15),
                          // Password Field
                          CustomTextField(
                            controller: _passwordController,
                            labelText: "Password",
                            errorText: "Please enter your password",
                            hintText: '********',
                            obscureText: true,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Password is required";
                              }
                              if (value.length < 6) {
                                return "Password must be at least 6 characters";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 15),
                          // Confirm Password Field
                          CustomTextField(
                            controller: _confirmpasswordController,
                            labelText: "Confirm Password",
                            errorText: "Passwords do not match",
                            hintText: '********',
                            obscureText: true,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Confirm password is required";
                              }
                              if (value != _passwordController.text) {
                                return "Passwords do not match";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 25),
                          // Sign Up Button
                          Button2(
                            text: "Sign Up",
                            onPressed: _validateAndSignup,
                          ),
                          const SizedBox(height: 20),
                          // Already have account link
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "Already have an account? ",
                                style: TextStyle(fontSize: 14),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const LoginScreen(),
                                    ),
                                  );
                                },
                                child: const Text(
                                  "Login",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFFF7940),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
