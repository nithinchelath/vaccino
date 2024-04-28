import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vaccino/pages/bookingpage.dart';
import 'package:vaccino/pages/home/childprofile.dart';
import 'package:vaccino/pages/home/registerprofile.dart';
import 'package:vaccino/pages/login.dart'; // Ensure this import path is correct

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  static const List<Widget> _widgetOptions = <Widget>[
    Text('Home'),
    Text('Profile'),
    Text('Schedule'),
    Text('Logout')
    // Add more pages as needed
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // Navigation logic for the "Register" item
    if (index == 1) {
      // Assuming the "Register" item is at index 1
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => RegistrationPage(onRegisterSuccess: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Child registered successfully!'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                })),
      );
    }
    if (index == 2) {
      // Assuming the vaccination schedule is the third item
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => VaccinationSchedulePage()),
      );
    } else if (index == 3) {
      // Assuming the taxi services is the fourth item
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => TaxiService()),
      );
    }
    if (index == 4) { // Assuming the logout is the fourth item
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LogoutPage()),
    );
 }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .collection('child')
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('Something went wrong');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("No children registered yet."),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                RegistrationPage(onRegisterSuccess: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          'Child registered successfully!'),
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                })),
                      );
                    },
                    child: Text("Register New Child"),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final childData = Child.fromMap(
                  snapshot.data!.docs[index].data() as Map<String, dynamic>);
              return ListTile(
                title: Text(childData.name),
                subtitle: Text(
                    'Date of Birth: ${DateFormat('yyyy-MM-dd').format(childData.dob)}'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ChildProfile(child: childData)),
                  );
                },
              );
            },
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add, color: Colors.pink),
            label: 'Register',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today, color: Colors.pink),
            label: 'Schedule',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.directions_car, color: Colors.pink),
            label: 'Taxi Services',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.logout, color: Colors.pink),
            label: 'Logout',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
    );
  }
}

class ChildProfile extends StatelessWidget {
  final Child child;

  ChildProfile({required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(child.name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Name: ${child.name}'),
            Text(
                'Date of Birth: ${DateFormat('yyyy-MM-dd').format(child.dob)}'),
            Text('Gender: ${child.gender}'),
            // Add more details as needed
          ],
        ),
      ),
    );
  }
}

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

class TaxiService extends StatefulWidget {
  @override
  _TaxiServicePageState createState() => _TaxiServicePageState();
}

class _TaxiServicePageState extends State<TaxiService> {
  String _taxiServiceNumber = '';
  bool _isLoading = false;

  void _fetchTaxiServiceNumber(String place) async {
    setState(() {
      _isLoading = true;
    });
    try {
      final CollectionReference taxiServices =
          FirebaseFirestore.instance.collection('taxiServices');
      final QuerySnapshot result =
          await taxiServices.where('place1', isEqualTo: place).get();
      final List<DocumentSnapshot> documents = result.docs;

      if (documents.isNotEmpty) {
        setState(() {
          _taxiServiceNumber = documents.first['phoneNumber'];
          _isLoading = false;
        });
      } else {
        setState(() {
          _taxiServiceNumber = 'No service available for this place.';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _taxiServiceNumber = 'Error fetching service number.';
        _isLoading = false;
      });
    }
  }

  void _makeCall(String number) async {
    final String url = "tel:$number";
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Taxi Service'),
      ),
      body: Center(
        child: _isLoading
            ? CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(_taxiServiceNumber),
                  ElevatedButton(
                    onPressed: () async {
                      final String? place = await showDialog<String>(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Enter Place'),
                            content: TextField(
                              onSubmitted: (value) {
                                Navigator.of(context).pop(value);
                              },
                            ),
                            actions: <Widget>[
                              TextButton(
                                child: Text('OK'),
                                onPressed: () {
                                  Navigator.of(context).pop(null);
                                },
                              ),
                            ],
                          );
                        },
                      );
                      if (place != null) {
                        _fetchTaxiServiceNumber(place);
                      }
                    },
                    child: Text('Get Taxi Service Number'),
                  ),
                  ElevatedButton(
                    onPressed: _taxiServiceNumber.isEmpty
                        ? null
                        : () => _makeCall(_taxiServiceNumber),
                    child: Text('Call Taxi Service'),
                  ),
                ],
              ),
      ),
    );
  }
}

class LogoutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Logout'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            await FirebaseAuth.instance.signOut();
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => LoginPage(onTap: () {  },)),
            );
          },
          child: Text('Logout'),
        ),
      ),
    );
  }
}
