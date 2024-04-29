import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vaccino/pages/bookingpage.dart';
import 'package:vaccino/pages/home/childprofile.dart';
import 'package:vaccino/pages/home/registerprofile.dart';
import 'package:vaccino/pages/login.dart';



class VaccinationSchedulePage extends StatefulWidget {
  @override
  _VaccinationSchedulePageState createState() =>
      _VaccinationSchedulePageState();
}

class _VaccinationSchedulePageState extends State<VaccinationSchedulePage> {
  final _formKey = GlobalKey<FormState>();
  DateTime _dob = DateTime.now();
  final TextEditingController _dobController = TextEditingController();
  List<Map<String, dynamic>> _vaccinationSchedule = [];

  @override
  void dispose() {
    _dobController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        // Ensure this wraps the entire content
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: _dobController,
                decoration: InputDecoration(labelText: 'Date of Birth'),
                onTap: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: _dob,
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null && picked != _dob) {
                    setState(() {
                      _dob = picked;
                      _dobController.text = _dob.toString();
                    });
                  }
                },
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your date of birth';
                  }
                  return null;
                },
              ),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    fetchVaccinationSchedule(_dob);
                  }
                },
                child: Text('Submit'),
              ),
              if (_vaccinationSchedule.isNotEmpty)
                SingleChildScrollView(
                  // Wrap the DataTable in a SingleChildScrollView for horizontal scrolling
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columnSpacing: 6.0,
                    dataRowHeight: 100.0,
                    headingRowHeight: 50.0,
                    dividerThickness: 2.0,
                    border: TableBorder.all(
                      color: Colors.grey,
                      width: 2.0,
                    ),
                    columns: const <DataColumn>[
                      DataColumn(label: Text('Vaccination')),
                      DataColumn(label: Text('Date')),
                      DataColumn(label: Text('Time Period')),
                      DataColumn(label: Text('Booking')),
                    ],
                    rows: _vaccinationSchedule.map((vaccine) {
                      return DataRow(
                        cells: <DataCell>[
                          DataCell(Text(vaccine['name'])),
                          DataCell(Text(vaccine['date'].toString())),
                          DataCell(Text(vaccine['timePeriod'])),
                          DataCell(TextButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      BookingPage(vaccineName: vaccine['name']),
                                ),
                              );
                            },
                            child: Text(vaccine['booking']),
                          )),
                        ],
                      );
                    }).toList(),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void fetchVaccinationSchedule(DateTime dob) async {
    // Assuming you have a method to calculate the vaccination schedule based on DOB
    _vaccinationSchedule = calculateVaccinationSchedule(dob);
    setState(() {});
  }

  List<Map<String, dynamic>> calculateVaccinationSchedule(DateTime dob) {
    List<Map<String, dynamic>> schedule = [];

    // Define vaccination schedule based on DOB
    DateTime date = dob;
    schedule.add({
      'name': 'BCG',
      'date': date,
      'timePeriod': 'At birth or as early as possible till one year of age',
      'booking': 'Available',
      'booked': 'false',
    });

    date = incrementDate(date, months: 0, days: 1); // Increment 1 day

    schedule.add({
      'name': 'Hepatitis B - Birth Dose',
      'date': date,
      'timePeriod': 'At birth or as possible within 24 hours',
      'booking': 'Available',
      'booked': 'false',
    });

    date = incrementDate(date, months: 0, days: 15);
    schedule.add({
      'name': 'OPV-O',
      'date': date,
      'timePeriod': 'At birth or as early as possible within the first 15 days',
      'booking': 'Available',
      'booked': 'false',
    });
    DateTime dateAt6Weeks =
        incrementDate(dob, months: 0, days: 42); // 6 weeks = 42 days
    DateTime dateAt10Weeks = incrementDate(dob,
        months: 2, days: 21); // 10 weeks = 2 months and 21 days
    DateTime dateAt14Weeks = incrementDate(dob,
        months: 3, days: 14); // 14 weeks = 3 months and 14 days

    schedule.add({
      'name': 'OPV 1,2 &3',
      'date': [
        dateAt6Weeks,
        dateAt10Weeks,
        dateAt14Weeks,
      ],
      'timePeriod': 'At 6, 10, and 14 weeks of age',
      'booking': 'Available',
      'booked': 'false',
    });

    schedule.add({
      'name': 'Pentavalent 1,2 & 3',
      'date': [
        dateAt6Weeks,
        dateAt10Weeks,
        dateAt14Weeks,
      ],
      'timePeriod':
          'At 6 weeks, 10 weeks, and 14 weeks (can be given till 1 years of age)',
      'booking': 'Available',
      'booked': 'false',
    });
    // Add more vaccines as needed

    schedule.add({
      'name': 'Rotavirus#',
      'date': [
        dateAt6Weeks,
        dateAt10Weeks,
        dateAt14Weeks,
      ],
      'timePeriod':
          'At 6 weeks, 10 weeks, and 14 weeks (can be given till 1 years of age)',
      'booking': 'Available',
      'booked': 'false',
    });

    schedule.add({
      'name': 'IPV',
      'date': [
        dateAt6Weeks,
        dateAt14Weeks,
      ],
      'timePeriod': 'Two Fractional dose  at 6 and 14 weeks of age',
      'booking': 'Available',
      'booked': 'false',
    });

    schedule.add({
      'name': 'PCV',
      'date': [
        dateAt6Weeks,
        dateAt14Weeks,
      ],
      'timePeriod': 'At 6 and 14 weeks of age',
      'booking': 'Available',
      'booked': 'false',
    });
    DateTime dateAt16mon =
        incrementDate(dob, months: 16, days: 0); // 6 weeks = 42 days/

    schedule.add({
      'name': 'DPT Booster 1',
      'date': dateAt16mon,
      'timePeriod': 'Between 16-24 months',
      'booking': 'Available',
      'booked': 'false',
    });
    schedule.add({
      'name': 'Vitamin-A 2',
      'date': dateAt16mon,
      'timePeriod': 'Between 16-24 months',
      'booking': 'Available',
      'booked': 'false',
    });
    schedule.add({
      'name': 'MR',
      'date': dateAt16mon,
      'timePeriod': 'Between 16-24 months',
      'booking': 'Available',
      'booked': 'false',
    });
    schedule.add({
      'name': 'JE',
      'date': dateAt16mon,
      'timePeriod': 'Between 16-24 months',
      'booking': 'Available',
      'booked': 'false',
    });

    schedule.add({
      'name': 'OPV',
      'date': dateAt16mon,
      'timePeriod': 'Between 16-24 months',
      'booking': 'Available',
      'booked': 'false',
    });
    DateTime dateAt5year = incrementDate(dob, months: 0, year: 5, days: 0);
    schedule.add({
      'name': 'DPT Booster 2',
      'date': dateAt5year,
      'timePeriod': 'Between 5-6 years of age',
      'booking': 'Available',
      'booked': 'false',
    });
    DateTime dateAt10year = incrementDate(dob, months: 0, year: 10, days: 0);
    schedule.add({
      'name': 'TD',
      'date': dateAt10year,
      'timePeriod': 'At 10 years of age',
      'booking': 'Available',
      'booked': 'false',
    });
    DateTime dateAt16year = incrementDate(dob, months: 0, year: 16, days: 0);
    schedule.add({
      'name': 'TD',
      'date': dateAt16year,
      'timePeriod': 'At 16 years of age',
      'booking': 'Available',
      'booked': 'false',
    });
    return schedule;
  }

  void bookVaccine(String vaccineName) {
    // Find the vaccine in the schedule and update its 'booked' field
    for (var vaccine in _vaccinationSchedule) {
      if (vaccine['name'] == vaccineName) {
        vaccine['booked'] = true;
        break;
      }
    }
    // Update the UI to reflect the change
    setState(() {});
  }
}

DateTime incrementDate(DateTime date,
    {int months = 0, int year = 0, int days = 0}) {
  // Increment date by given months and days
  int year = date.year;
  int month = date.month + months;
  int day = date.day + days;

  // Adjust if month exceeds 12
  if (month > 12) {
    month -= 12;
    year++;
  }

  // Adjust if day exceeds 31
  while (day > 31) {
    if ([4, 6, 9, 11].contains(month)) {
      // April, June, September, November have 30 days
      day -= 30;
      month++;
    } else if (month == 2) {
      // February has 28 days (for simplicity)
      day -= 28;
      month++;
    } else {
      day -= 31;
      month++;
    }

    // Adjust if month exceeds 12
    if (month > 12) {
      month -= 12;
      year++;
    }
  }

  return DateTime(year, month, day);
}
