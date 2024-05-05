import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:vaccino/pages/login.dart';
import 'package:vaccino/pages/loginsignup.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({Key? key}) : super(key: key);

  @override
  _AdminHomePageState createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<QueryDocumentSnapshot> _users = [];

  @override
  void initState() {
    super.initState();
    _fetchVisibleUsers();
  }

  Future<void> _fetchVisibleUsers() async {
    final querySnapshot = await _firestore
        .collection('users')
        .where('visible', isEqualTo: true)
        .get();
    setState(() {
      _users = querySnapshot.docs;
    });
  }

  Future<void> _toggleUserStatus(String uid, bool isVerified) async {
    await _firestore.collection('users').doc(uid).update({
      'pending': !isVerified,
      'verified': isVerified,
    });
    _fetchVisibleUsers(); // Refresh the list
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Home Page'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _users.length,
        itemBuilder: (context, index) {
          final user = _users[index];
          bool isVerified =
              user['verified'] ?? false; // Default to false if not set
          return ListTile(
            leading: IconButton(
              icon: Icon(Icons.visibility),
              onPressed: () {
                // Show ID card
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    content: Image.network(user['id_card']),
                  ),
                );
              },
            ),
            title: Text(user['name']),
            trailing: Switch(
              value: isVerified,
              onChanged: (value) {
                _toggleUserStatus(user.id, value);
              },
            ),
          );
        },
      ),
    );
  }

  Future<void> _logout() async {
    await _auth.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginSignupPage()),
    );
  }
}
