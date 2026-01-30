import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sewa_hub/app/routes/app_routes.dart';
import 'package:sewa_hub/core/utils/snackbar_utils.dart';
import 'package:sewa_hub/features/dashboard/presentation/pages/dashboard_screen.dart';
import 'package:sewa_hub/features/auth/presentation/pages/signup_page.dart';
import 'package:sewa_hub/core/widgets/button1.dart';
import 'package:sewa_hub/core/widgets/button2.dart';
import 'package:sewa_hub/core/widgets/custom_text_field.dart';
import 'package:sewa_hub/features/auth/presentation/state/auth_state.dart';
import 'package:sewa_hub/features/auth/presentation/view_model/auth_view_model.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
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

  Future<void> _validateAndLogin() async {
    if (_formKey.currentState!.validate()) {
      // Form is valid, proceed with login
      ref.read(authViewModelProvider.notifier).login(
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
    final authState = ref.watch(authViewModelProvider);

    ref.listen<AuthState>(authViewModelProvider, (previous, next) {
      if (next.status == AuthStatus.error) {
        SnackbarUtils.showError(
          context,
          message: next.errorMessage ?? 'Failed to login',
        );
      }

      if (next.status == AuthStatus.authenticated) {
        SnackbarUtils.showSuccess(
          context,
          message: "You're now logged in",
          title: 'Login Successful!',
        );

        // Clear fields
        _emailController.clear();
        _passwordController.clear();

        AppRoutes.pushReplacement(
          context,
          const DashboardScreen(),
        );
      }
    });

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 500),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 10),
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
                                // Add forgot password logic here
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
                        const SizedBox(height: 20),
                        // Login Button
                        Padding(
                          padding: const EdgeInsets.only(right: 10, left: 10),
                          child: Button2(
                            text: "Login",
                            onPressed: _validateAndLogin,
                          ),
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
                        SingleChildScrollView(
                          child: Row(
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
                        ),
                        const SizedBox(height: 30),
                        // Don't have account link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Don't have an account? ",
                              style: TextStyle(fontSize: 15),
                            ),
                            GestureDetector(
                              onTap: () {
                               AppRoutes.push(context,const SignupScreen(),);
                              },
                              child: const Text(
                                "Create One",
                                style: TextStyle(
                                  fontSize: 15,
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