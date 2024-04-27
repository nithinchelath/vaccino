import 'package:flutter/material.dart';

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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Vaccination Center'),
            DropdownButton<String>(
              value: selectedCenter,
              onChanged: (String? newValue) {
                setState(() {
                  selectedCenter = newValue;
                });
              },
              items: <String>['Center 1', 'Center 2']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            if (selectedCenter != null) Text('Selected Center: $selectedCenter'),
            Text('Select Date'),
            Container(
              margin: EdgeInsets.symmetric(vertical: 10.0),
              padding: EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: ElevatedButton(
                onPressed: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2025),
                  );
                  setState(() {
                    selectedDate = picked;
                  });
                },
                child: Text(selectedDate != null ? selectedDate!.toIso8601String() : 'Select Date'),
              ),
            ),
            if (selectedDate != null) Text('Selected Date: ${selectedDate!.toIso8601String()}'),
            Text('Select Time Slot'),
            Container(
              margin: EdgeInsets.symmetric(vertical: 10.0),
              padding: EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child:ElevatedButton(
                onPressed: () async {
                  final String? newSelectedSlot = await showDialog<String>(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Select Time Slot'),
                        content: SingleChildScrollView(
                          child: ListBody(
                            children: <Widget>[
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
                              // Add more slots as needed
                            ],
                          ),
                        ),
                      );
                    },
                  );
                  setState(() {
                    selectedSlot = newSelectedSlot; // Use the class-level variable
                  });
                },
                child: Text(selectedSlot ?? 'Select Time Slot'),
              ),


            ),

            if (selectedSlot != null) Text('Selected Slot: $selectedSlot'),
            ElevatedButton(
              onPressed: () {
                // Handle booking logic here
                if (selectedCenter != null && selectedDate != null && selectedSlot != null) {
                  print('Booking confirmed for $selectedCenter on ${selectedDate!.toIso8601String()} at $selectedSlot');
                  // You can now use the selectedCenter, selectedDate, and selectedSlot for further processing

                  // Show a SnackBar with the confirmation message
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Booking confirmed for $selectedCenter on ${selectedDate!.toIso8601String()} at $selectedSlot'),
                      duration: Duration(seconds: 3), // Show for 3 seconds
                    ),
                  );
                } else {
                  print('Please select a center, a date, and a time slot.');
                  // Optionally, show a SnackBar to prompt the user to fill in all fields
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Please select a center, a date, and a time slot.'),
                      duration: Duration(seconds: 3), // Show for 3 seconds
                    ),
                  );
                }
              },
              child: Text('Book'),
            ),
          ],
        ),
      ),
    );
  }
}
