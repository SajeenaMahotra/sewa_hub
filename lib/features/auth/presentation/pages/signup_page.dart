import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sewa_hub/app/routes/app_routes.dart';
import 'package:sewa_hub/core/utils/snackbar_utils.dart';
import 'package:sewa_hub/features/auth/presentation/pages/login_page.dart';
import 'package:sewa_hub/core/widgets/button1.dart';
import 'package:sewa_hub/core/widgets/button2.dart';
import 'package:sewa_hub/core/widgets/custom_text_field.dart';
import 'package:sewa_hub/features/auth/presentation/state/auth_state.dart';
import 'package:sewa_hub/features/auth/presentation/view_model/auth_view_model.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
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

  Future<void> _validateAndSignup() async {
    if (_formKey.currentState!.validate()) {
      // Form is valid, proceed with registration
      ref
          .read(authViewModelProvider.notifier)
          .register(
            fullName: _fullnameController.text,
            email: _emailController.text,
            password: _passwordController.text,
          );
    } else {
      // Form validation failed, show error snackbar
      SnackbarUtils.showError(
        context,
        message: "Please fix the errors in the form",
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    ref.listen<AuthState>(authViewModelProvider, (previous, next) {
      if (next.status == AuthStatus.error) {
        SnackbarUtils.showError(
          context,
          message: next.errorMessage ?? 'Failed to register',
        );
      }

      if (next.status == AuthStatus.registered) {
        SnackbarUtils.showSuccess(context, message: 'Registration successful');

        // Clear fields
        _fullnameController.clear();
        _emailController.clear();
        _passwordController.clear();
        _confirmpasswordController.clear();

        AppRoutes.pushReplacement(context, const LoginScreen());
      }
    });

    final authstate = ref.watch(authViewModelProvider);

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
                          Padding(
                            padding: const EdgeInsets.only(right: 10, left: 10),
                            child: CustomTextField(
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
                          ),
                          const SizedBox(height: 15),
                          // Email Field
                          Padding(
                            padding: const EdgeInsets.only(right: 10, left: 10),
                            child: CustomTextField(
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
                          ),
                          const SizedBox(height: 15),
                          // Password Field
                          Padding(
                            padding: const EdgeInsets.only(right: 10, left: 10),
                            child: CustomTextField(
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
                          ),
                          const SizedBox(height: 15),
                          // Confirm Password Field
                          Padding(
                            padding: const EdgeInsets.only(right: 10, left: 10),
                            child: CustomTextField(
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
                          ),
                          const SizedBox(height: 20),
                          // Sign Up Button
                          Padding(
                            padding: const EdgeInsets.only(right: 10, left: 10),
                            child: Button2(
                              text: "Sign Up",
                              onPressed: _validateAndSignup,
                            ),
                          ),
                          const SizedBox(height: 20),
                          // Already have account link
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "Already have an account? ",
                                style: TextStyle(fontSize: 15),
                              ),
                              GestureDetector(
                                onTap: () {
                                  AppRoutes.pushReplacement(
                                    context,
                                    const LoginScreen(),
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
                          const Text(
                            "Or continue with",
                            style: TextStyle(
                              fontSize: 16,
                              color: Color.fromARGB(255, 120, 120, 120),
                            ),
                          ),
                          const SizedBox(height: 25),
                          // Google and Apple Buttons
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Button1(
                                logoPath: 'assets/images/google_logo.png',
                                onPressed: () {
                                  // Add Google login logic
                                },
                                logoSize: 60,
                              ),
                              const SizedBox(width: 16),
                              Button1(
                                logoPath: 'assets/images/apple_logo.png',
                                onPressed: () {
                                  // Add Apple login logic
                                },
                                logoSize: 60,
                              ),
                            ],
                          ),
                          const SizedBox(height: 30),

                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24.0,
                            ),
                            child: Text(
                              "By signing up, you agree to our Terms and Conditions and Privacy Policy.",
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 15),
                            ),
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
      ),
    );
  }
}
