import 'package:cloud_firestore/cloud_firestore.dart';

class Child {
 final String id;
 final String name;
 final DateTime dob;
 final String gender;

 Child({required this.id, required this.name, required this.dob, required this.gender});

 factory Child.fromMap(Map<String, dynamic> map, String id) {
    return Child(
      id: id,
      name: map['name'],
      dob: DateTime.parse(map['dob']),
      gender: map['gender'],
    );
 }

 Map<String, dynamic> toMap() {
    return {
      'name': name,
      'dob': dob.toIso8601String(),
      'gender': gender,
    };
 }
}