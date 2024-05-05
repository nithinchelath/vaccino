import 'package:vaccino/components/mybutton.dart';
import 'package:vaccino/components/textfils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SignupPage extends StatefulWidget {
  final Function()? onTap;
  const SignupPage({super.key, required this.onTap});
  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  // Corrected constructor syntax
  final usernameController = TextEditingController();

  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  bool _isPasswordVisible = false;


  //sign up user
  void signUp() async {
    //show loading circle
    showDialog(
      context: context,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
    // try creating the user
    try {
      if (passwordController.text == confirmPasswordController.text) {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: usernameController.text,
          password: passwordController.text,
        );
      } else {
        //show error message
        showErrorMessage("Passwords don't match!");
      }
      // pop the loading circle
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      // pop the loading circle
      Navigator.pop(context);
      //error
      showErrorMessage(e.code);
    }
  }

  //error message
  void showErrorMessage(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.deepPurple,
          title: Center(
            child: Text(
              message,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Removed const from here
      backgroundColor: Colors.grey,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(
                    Icons.lock,
                    size: 100,
                  ),
                ),
                const SizedBox(height: 40),
                Text(
                  'Welcome back',
                  style: TextStyle(
                    color: Colors.blueGrey,
                    fontSize: 16,
                  ),
                ),
                //username
                const SizedBox(height: 40),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: MyText(
                    controller: usernameController,
                    hintText: 'Username',
                    obscureText: false,
                  ),
                ),
                //password
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: MyText(
                    controller: passwordController,
                    hintText: 'Password',
                    obscureText: true,
                  ),
                ),

                //confirm password
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: MyText(
                    controller: confirmPasswordController,
                    hintText: 'confirm Password',
                    obscureText: !_isPasswordVisible,
                  ),
                ),
                CheckboxListTile(
                  title: Text("Show Password"),
                  value: _isPasswordVisible,
                  onChanged: (bool? value) {
                    setState(() {
                      _isPasswordVisible = value!;
                    });
                  },
                ),

                const SizedBox(height: 25),
                //Sign in button
                MyButton(text: "Sign Up", onTap: signUp),

                //
                const SizedBox(height: 20),
                //signup
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an acccount?',
                      style: TextStyle(color: Colors.blueGrey),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: widget.onTap,
                      child: const Text(
                        'Login now',
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}