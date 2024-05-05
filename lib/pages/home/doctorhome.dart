import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vaccino/pages/login.dart';
import 'package:vaccino/pages/loginsignup.dart';

class DoctorHomePage extends StatefulWidget {
  const DoctorHomePage({Key? key}) : super(key: key);

  @override
  _DoctorHomePageState createState() => _DoctorHomePageState();
}

class _DoctorHomePageState extends State<DoctorHomePage> {
  final _picker = ImagePicker();
  XFile? _selectedImage;
  String? _downloadUrl;
  bool _isUploading = false;
  String _uploadStatusMessage = '';
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool? _isVerified;
  List<Map<String, dynamic>> _bookings = [];

  @override
  void initState() {
    super.initState();
    _fetchVerificationStatus();
    _fetchBookings();
    _fetchIdCardUrl(); // Fetch the ID card URL on load
  }

  Future<void> _fetchBookings() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    final querySnapshot =
        await FirebaseFirestore.instance.collection('bookings').get();
        

    setState(() {
      _bookings = querySnapshot.docs.map((doc) => doc.data()).toList();
    });
  }

  Future<void> _deleteBooking(String? bookingId) async {
    if (bookingId == null) {
      print("Error: bookingId is null");
      return;
    }

    await FirebaseFirestore.instance
        .collection('bookings')
        .doc(bookingId)
        .delete();
    setState(() {
    _bookings.removeWhere((booking) => booking['bookingId'] == bookingId);
    });
}


  Future<void> _fetchVerificationStatus() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    final doc = await _firestore.collection('users').doc(uid).get();
    if (doc.exists && doc.data() != null) {
      setState(() {
        _isVerified = doc['verified'];
      });
    }
  }

  Future<void> _selectImage() async {
    final image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = image;
        _downloadUrl = null;
        _uploadStatusMessage = '';
      });
    }
  }

  Future<void> _uploadImage() async {
    if (_selectedImage == null) return;

    setState(() {
      _isUploading = true;
    });

    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) throw Exception('User not authenticated');

      final ref = _storage.ref().child('doctor_id_cards/$uid.jpg');
      final uploadTask = ref.putFile(File(_selectedImage!.path));
      final snapshot = await uploadTask;

      final downloadUrl = await snapshot.ref.getDownloadURL();
      await _firestore.collection('users').doc(uid).set(
          {
            'id_card': downloadUrl,
            'pending': true,
            'visible': true,
          },
          SetOptions(
              merge: true)); // Use merge to update only the specified fields

      setState(() {
        _downloadUrl = downloadUrl;
        _uploadStatusMessage = 'ID card successfully uploaded!';
      });
    } catch (e) {
      setState(() {
        _uploadStatusMessage = 'Error uploading ID card: $e';
      });
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  Future<void> _fetchIdCardUrl() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    final doc = await _firestore.collection('users').doc(uid).get();
    if (doc.exists && doc.data() != null) {
      setState(() {
        _downloadUrl = doc['id_card'];
      });
    } else {
      setState(() {
        _downloadUrl = null; // Set to null if id_card field is not found
      });
    }
  }

  Future<void> _logout() async {
    await _auth.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginSignupPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Doctor Home Page'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_selectedImage != null)
              Column(
                children: [
                  Image.file(
                    File(_selectedImage!.path),
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _uploadImage,
                    child: _isUploading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("Upload Image"),
                  ),
                ],
              )
            else if (_downloadUrl == null) // Check if _downloadUrl is null
              Column(
                children: [
                  const Text("No ID Card uploaded. Please upload an ID card."),
                  ElevatedButton(
                    onPressed: _selectImage,
                    child: const Text("Upload ID Card"),
                  ),
                ],
              )
            else
              Column(
                children: [
                  const Text("Uploaded ID Card:"),
                  Image.network(_downloadUrl!, height: 200, fit: BoxFit.cover),
                ],
              ),

            if (_uploadStatusMessage.isNotEmpty)
              Text(
                _uploadStatusMessage,
                style: TextStyle(
                  color: _uploadStatusMessage.contains('success')
                      ? Colors.green
                      : Colors.red,
                ),
              ),

            const SizedBox(height: 20),

            if (_isVerified == true)
              const Text(
                "Document verified successfully",
                style: TextStyle(color: Colors.green, fontSize: 18),
              )
            else if (_isVerified == false)
              const Text(
                "Pending verification",
                style: TextStyle(color: Colors.orange, fontSize: 18),
              ),
            if (_isVerified == true)
            if (_bookings.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: _bookings.length,
                  itemBuilder: (context, index) {
                    final booking = _bookings[index];
                    return ListTile(
                      title: Text('Booking for ${booking['vaccineName']}'),
                      subtitle: Text(
                          'Name: ${booking['userName']}   Center: ${booking['center']} Date: ${booking['date']} Time: ${booking['timeSlot']}'),
                      trailing: IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          if (booking['bookingId'] != null) {
                            _deleteBooking(booking['bookingId']);
                          } else {
                            print("Error: bookingId is null in the list");
                          }
                        },
                      ),

                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
