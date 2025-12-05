import 'package:flutter/material.dart';
import 'package:sewa_hub/commons/snackbar.dart';
import 'package:sewa_hub/screens/dashboard_screen.dart';
import 'package:sewa_hub/screens/signup_screen.dart';
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
  final TextEditingController _passwordController = TextEditingController();
  bool _isForgotPasswordHovered = false;

  @override
  void dispose() {
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
            MaterialPageRoute(builder: (context) => const DashboardScreen()),
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 50),
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
                  "Welcome Back!",
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                const Text(
                  "Your Trusted Services Await",
                  style: TextStyle(fontSize: 20),
                ),
                const SizedBox(height: 30),
                Form(
                  key: _formKey,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
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
                        // Forgot Password Link
                        Align(
                          alignment: Alignment.centerRight,
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
                        const SizedBox(height: 25),
                        // Login Button
                        Button2(text: "Login", onPressed: _validateAndLogin),
                        const SizedBox(height: 20),
                        // Don't have account link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Don't have an account? ",
                              style: TextStyle(fontSize: 14),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const SignupScreen(),
                                  ),
                                );
                              },
                              child: const Text(
                                "Create One",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFFF7940),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
