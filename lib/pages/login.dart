import 'package:vaccino/components/mybutton.dart';
import 'package:vaccino/components/textfils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  final Function()? onTap;
  const LoginPage({super.key, required this.onTap});
  @override
  State<LoginPage> createState() => _LoginPageState();

}

class _LoginPageState extends State<LoginPage> {
  // Corrected constructor syntax
  final usernameController = TextEditingController();

  final passwordController = TextEditingController();

  bool _isPasswordVisible = false;


  //sign in user
  void signIn() async {
    //show loading circle
    showDialog(
      context: context,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
    // try sign in
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: usernameController.text,
        password: passwordController.text,
      );
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
    showDialog(      context: context,
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


                const SizedBox(height: 10),
                //forgot password
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'Forgot Password',
                        style: TextStyle(color: Colors.lightGreenAccent),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),
                //Sign in button
                MyButton(text: "Sign in", onTap: signIn),

                //
                const SizedBox(height: 20),
                //signup
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('New user?'),
                    SizedBox(width: 2),
                    GestureDetector(
                      onTap: () {
                        if (widget.onTap != null) {
                          widget.onTap!();
                        } else {
                          print('Signup page onTap is null');
                        }
                      },
                      child: Text(
                        'Register Page',
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  ],
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }
}