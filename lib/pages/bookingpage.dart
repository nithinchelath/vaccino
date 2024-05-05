import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class BookingPage extends StatefulWidget {
  final String vaccineName;

  BookingPage({required this.vaccineName});

  @override
  _BookingPageState createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  String? selectedCenter;
  DateTime? selectedDate;
  String? selectedSlot;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Booking for ${widget.vaccineName}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildCenterDropdown(),
              _buildDateSelector(),
              _buildSlotSelector(),
              _buildBookButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCenterDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Vaccination Center'),
        DropdownButton<String>(
          value: selectedCenter,
          onChanged: (String? newValue) {
            setState(() {
              selectedCenter = newValue;
            });
          },
          items: ['Center 1', 'Center 2'].map((center) {
            return DropdownMenuItem<String>(
              value: center,
              child: Text(center),
            );
          }).toList(),
        ),
        if (selectedCenter != null) Text('Selected Center: $selectedCenter'),
      ],
    );
  }

  Widget _buildDateSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Select Date'),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: ElevatedButton(
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2025),
              );

              if (picked != null) {
                setState(() {
                  selectedDate = picked;
                });
              }
            },
            child: Text(
              selectedDate != null
                  ? DateFormat('yyyy-MM-dd').format(selectedDate!) // Display only date
                  : 'Select Date',
            ),
          ),
        ),
        if (selectedDate != null)
          Text('Selected Date: ${DateFormat('yyyy-MM-dd').format(selectedDate!)}'), // Only date
      ],
    );
  }

  Widget _buildSlotSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Select Time Slot'),
        ElevatedButton(
          onPressed: () async {
            final slot = await showDialog<String>(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: Text('Select Time Slot'),
                  content: SingleChildScrollView(
                    child: ListBody(
                      children: [
                        TextButton(
                          child: Text('10:00'),
                          onPressed: () => Navigator.of(context).pop('10:00'),
                        ),
                        TextButton(
                          child: Text('10:10'),
                          onPressed: () => Navigator.of(context).pop('10:10'),
                        ),
                        TextButton(
                          child: Text('10:15'),
                          onPressed: () => Navigator.of(context).pop('10:15'),
                        ),
                        // Add more slots if necessary
                      ],
                    ),
                  ),
                );
              },
            );

            if (slot != null) {
              setState(() {
                selectedSlot = slot;
              });
            }
          },
          child: Text(selectedSlot ?? 'Select Time Slot'),
        ),
        if (selectedSlot != null) Text('Selected Slot: $selectedSlot'),
      ],
    );
  }

  Widget _buildBookButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        if (selectedCenter == null || selectedDate == null || selectedSlot == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Please select a center, a date, and a time slot.'),
              duration: Duration(seconds: 3),
            ),
          );
          return;
        }

        final querySnapshot = await FirebaseFirestore.instance
            .collection('bookings')
            .where('center', isEqualTo: selectedCenter)
            .where('date', isEqualTo: DateFormat('yyyy-MM-dd').format(selectedDate!)) // Only date
            .where('timeSlot', isEqualTo: selectedSlot)
            .get();

        if (querySnapshot.docs.length >= 15) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('The selected time slot is full. Please select another slot.'),
              duration: Duration(seconds: 3),
            ),
          );
          return;
        }

        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .get();
        final userName = userDoc.data()?['name'] ?? 'Unknown';
        await FirebaseFirestore.instance.collection('bookings').add({
          'vaccineName': widget.vaccineName,
          'center': selectedCenter,
          'date': DateFormat('yyyy-MM-dd').format(selectedDate!), // Store only date
          'timeSlot': selectedSlot,
          'userId': FirebaseAuth.instance.currentUser!.uid,
          'userName': userName,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Booking confirmed for $selectedCenter on ${DateFormat('yyyy-MM-dd').format(selectedDate!)} at $selectedSlot'),
            duration: Duration(seconds: 3),
          ),
        );
      },
      
      child: Text('Book'),
    );
  }
}
