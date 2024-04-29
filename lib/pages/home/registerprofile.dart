import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vaccino/pages/home/childprofile.dart';
import 'package:intl/intl.dart';

class RegistrationPage extends StatefulWidget {
  final Function onRegisterSuccess;

  RegistrationPage({required this.onRegisterSuccess});

  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  DateTime _dob = DateTime.now();
  String _gender = 'Male';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Register Child'),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              TextFormField(
                decoration: InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the child\'s name';
                  }
                  return null;
                },
                onSaved: (value) => _name = value!,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Date of Birth'),
                onTap: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) {
                    setState(() {
                      _dob = picked;
                    });
                  }
                },
                readOnly: true,
                controller: TextEditingController(text: DateFormat('yyyy-MM-dd').format(_dob)),
              ),
              DropdownButton<String>(
                value: _gender,
                onChanged: (String? newValue) {
                  setState(() {
                    _gender = newValue!;
                  });
                },
                items: <String>['Male', 'Female']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    await _registerChild();
                  }
                },
                child: Text('Register'),
              ),
            ],
          ),
        ),
      ),
    );
  }
 Future<void> _registerChild() async {
    final child = Child(id: '', name: _name, dob: _dob, gender: _gender); // Temporary ID
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final docRef = await FirebaseFirestore.instance.collection('users').doc(user.uid).collection('child').add(child.toMap());
        final childWithId = Child(id: docRef.id, name: _name, dob: _dob, gender: _gender); // Use the document ID
        // You might want to do something with childWithId, like updating the UI or storing it locally
        widget.onRegisterSuccess();
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No user is currently signed in.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to register child: $e')),
      );
    }
 }


}