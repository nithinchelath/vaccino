import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vaccino/pages/home/doctorhome.dart';
import 'package:vaccino/pages/home/homepage.dart';
import 'package:vaccino/pages/home/adminHome.dart';

 // Import your AdminHomePage

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Profile Setup'),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .get(),
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }

            if (snapshot.data!.exists) {
              // Document exists, navigate based on the role
              Map<String, dynamic> userData =
                  snapshot.data!.data() as Map<String, dynamic>;
              String role = userData['role'];
              String email = FirebaseAuth.instance.currentUser!.email!;

              WidgetsBinding.instance!.addPostFrameCallback((_) {
                if (email == 'admin@gmail.com') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AdminHomePage()),
                  );
                } else if (role == 'Parent') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => HomePage()),
                  );
                } else if (role == 'Health Care Professional') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => DoctorHomePage()),
                  );
                }
              });
              return Center(child: CircularProgressIndicator());
            } else {
              // Document does not exist, show form to create user profile
              return UserProfileForm();
            }
          } else {
            // Waiting for future to complete
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}


class UserProfileForm extends StatefulWidget {
  @override
  _UserProfileFormState createState() => _UserProfileFormState();
}

class _UserProfileFormState extends State<UserProfileForm> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedRole;
  String _name = '';

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          DropdownButtonFormField<String>(
            value: _selectedRole,
            icon: const Icon(Icons.arrow_downward),
            decoration: const InputDecoration(
              labelText: 'Role',
            ),
            items: <String>['Parent', 'Health Care Professional']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                _selectedRole = newValue;
              });
            },
            validator: (String? value) {
              if (value == null) {
                return 'Please select a role';
              }
              return null;
            },
          ),
          TextFormField(
            decoration: const InputDecoration(labelText: 'Name'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your name';
              }
              return null;
            },
            onSaved: (value) => _name = value!,
          ),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();
                _createUserProfile();
              }
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  void _createUserProfile() async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .set({
        'role': _selectedRole,
        'name': _name,
        'id_card': null,
        'verified': false,
        'visible': false,
        'pending': false,
      });
      // Navigate based on the selected role
      if (_selectedRole == 'Parent') {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      } else if (_selectedRole == 'Health Care Professional') {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => DoctorHomePage()),
        );
      }
    } catch (e) {
      print('Error creating user profile: $e');
    }
  }
}
