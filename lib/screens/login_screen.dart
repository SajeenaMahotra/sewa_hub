import 'package:flutter/material.dart';
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
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
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: CustomTextField(controller: _emailController,
              labelText: "Email",
              errorText: "Please enter your email address",
              hintText: 'johndoe@gmail.com',),
            ),
            SizedBox(height: 10,),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: CustomTextField(controller: _passwordController,
              labelText: "Password",
              errorText: "Please enter your password",
              hintText: '********',),
            ),
            SizedBox(height: 20,),
            Button2(text: "Login", onPressed: () {},),
            ],
      ),
    );
  }
}