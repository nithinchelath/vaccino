import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:vaccino/pages/login.dart';

class adminHomePage extends StatefulWidget {
  const adminHomePage({Key? key}) : super(key: key);

  @override
  _adminHomePageState createState() => _adminHomePageState();
}

class _adminHomePageState extends State<adminHomePage> {

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _verifyDoctor(String doctorId, bool isVerified) async {
    await _firestore.collection('doctors').doc(doctorId).update({
      'isVerified': isVerified,
    });
  }

  Future<void> _logout() async {
    await _auth.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage(onTap: () {  },)),
    );
  }

  @override
   @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Home Page'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ParentsList(onParentTap: (parentId) {
              // Handle parent tap
            }),
          ),
          Expanded(
            child: HealthcareProfessionalsList(),
          ),
        ],
      ),
    );
  }
}
class ImagePage extends StatelessWidget {
  final String imageUrl;

  const ImagePage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("ID Card Image"),
      ),
      body: Center(
        child: Image.network(
          imageUrl,
          height: 400,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}


class ParentsList extends StatelessWidget {
  final Function(String) onParentTap;

  const ParentsList({Key? key, required this.onParentTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('parents').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final parents = snapshot.data!.docs;
        return ListView.builder(
          itemCount: parents.length,
          itemBuilder: (context, index) {
            final parent = parents[index];
            final data = parent.data() as Map<String, dynamic>?;

            if (data == null) {
              return ListTile(
                title: Text('Parent ${parent.id}'),
                subtitle: const Text("No data available"),
              );
            }

            // Fetch the parent's name
            final parentName = data.containsKey('name')
             ? data['name']
                : 'Unknown';

            // Fetch the number of children registered
            final childrenCount = data.containsKey('childrenCount')
             ? data['childrenCount']
                : 0;

            return ListTile(
              title: Text('Parent $parentName'), // Display parent's name
              subtitle: Text('Children Count: $childrenCount'),
              onTap: () => onParentTap(parent.id),
            );
          },
        );
      },
    );
  }
}


class HealthcareProfessionalsList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('doctors').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final doctors = snapshot.data!.docs;
        return ListView.builder(
          itemCount: doctors.length,
          itemBuilder: (context, index) {
            final doctor = doctors[index];
            final data = doctor.data() as Map<String, dynamic>?;

            if (data == null) {
              return ListTile(
                title: Text('Doctor ${doctor.id}'),
                subtitle: const Text("No data available"),
              );
            }

            final isVerified = data.containsKey('isVerified')
              ? data['isVerified']
                : false;

                final imageUrl = data.containsKey('idCardUrl')
              ? data['idCardUrl']
                : 'https://via.placeholder.com/150'; // Default imag

            // Use the username instead of the user ID
            final username = data.containsKey('username')
              ? data['username']
                : 'Unknown';

            return ListTile(
              title: Text('Doctor $username'), // Display username
              subtitle: isVerified
                ? const Text(
                      "Verified",
                      style: TextStyle(color: Colors.green),
                    )
                  : const Text(
                      "Unverified",
                      style: TextStyle(color: Colors.red),
                    ),
                     trailing: IconButton(
                icon: const Icon(Icons.image),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ImagePage(imageUrl: imageUrl),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}
