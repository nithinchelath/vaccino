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
    } else if (index == 2) {
      // Assuming the taxi services is the fourth item
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => TaxiService()),
      );
    }
    if (index == 3) {
      // Assuming the logout is the fourth item
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
              final doc = snapshot.data!.docs[index];
              final childData = Child.fromMap(
                  doc.data() as Map<String, dynamic>,
                  doc.id); // Pass the document ID as the second argument
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
            ElevatedButton(
              onPressed: () {
                // Navigate to the VaccinationSchedulePage
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        VaccinationSchedulePage(childId: child.id),
                  ),
                );
              },
              child: Text('View Vaccination Schedule'),
            ),
            // Add more details as needed
          ],
        ),
      ),
    );
  }
}

class VaccinationSchedulePage extends StatefulWidget {
  final String childId; // Add this line to accept a childId

  VaccinationSchedulePage({required this.childId}); // Modify the constructor

  @override
  _VaccinationSchedulePageState createState() =>
      _VaccinationSchedulePageState();
}

class _VaccinationSchedulePageState extends State<VaccinationSchedulePage> {
  final _formKey = GlobalKey<FormState>();
  DateTime _dob =
      DateTime.now(); // This might not be needed if you're passing the DOB
  final TextEditingController _dobController = TextEditingController();
  List<Map<String, dynamic>> _vaccinationSchedule = [];

  Future<DateTime> getChildDOB(String childId) async {
    try {
      final docSnapshot = await FirebaseFirestore.instance
          .collection('users') // Adjust the collection name as needed
          .doc(FirebaseAuth
              .instance.currentUser!.uid) // Adjust the document ID as needed
          .collection('child') // Adjust the subcollection name as needed
          .doc(childId)
          .get();

      if (docSnapshot.exists) {
        final childData = docSnapshot.data() as Map<String, dynamic>;
        final dobString = childData[
            'dob']; // Assuming 'dob' is stored as a string in Firestore
        return DateTime.parse(
            dobString); // Convert the string to a DateTime object
      } else {
        throw Exception('Child document not found');
      }
    } catch (e) {
      throw Exception('Failed to fetch child DOB: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    // Assuming getChildDOB is an asynchronous method that fetches the DOB
    getChildDOB(widget.childId).then((dob) {
      fetchVaccinationSchedule(dob);
    });
  }

  @override
  void dispose() {
    _dobController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
      title: Text('Vaccination Schedule'),
      leading: IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: () => Navigator.of(context).pop(),
      ),
    ),
      body: SafeArea(
        child: FutureBuilder<DateTime>(
          future: getChildDOB(widget.childId), // Fetch the DOB based on childId
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                  child:
                      CircularProgressIndicator()); // Show a loading indicator while waiting
            } else if (snapshot.hasError) {
              return Center(
                  child: Text(
                      'Error: ${snapshot.error}')); // Show error message if something went wrong
            } else {
              // Once the DOB is fetched, fetch and display the vaccination schedule
              // The fetchVaccinationSchedule method should be called in initState, not here.
              return SingleChildScrollView(
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
                                builder: (context) => BookingPage(
                                  vaccineName: vaccine['name'],
                                ),
                              ),
                            );
                          },
                          child: Text(vaccine['booking']),
                        )),
                      ],
                    );
                  }).toList(),
                ),
              );
            }
          },
        ),
      ),
    );
  }

  void fetchVaccinationSchedule(DateTime dob) {
    List<Map<String, dynamic>> schedule = calculateVaccinationSchedule(dob);
    setState(() {
      _vaccinationSchedule = schedule;
    });
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
      'booked': false,
    });

    date = incrementDate(date, months: 0, days: 1); // Increment 1 day

    schedule.add({
      'name': 'Hepatitis B - Birth Dose',
      'date': date,
      'timePeriod': 'At birth or as possible within 24 hours',
      'booking': 'Available',
      'booked': false,
    });

    date = incrementDate(date, months: 0, days: 15);
    schedule.add({
      'name': 'OPV-O',
      'date': date,
      'timePeriod': 'At birth or as early as possible within the first 15 days',
      'booking': 'Available',
      'booked': false,
    });

    // Calculate dates for vaccines that occur at specific intervals
    DateTime dateAt6Weeks =
        incrementDate(dob, months: 0, days: 42); // 6 weeks = 42 days
    DateTime dateAt10Weeks = incrementDate(dob,
        months: 2, days: 21); // 10 weeks = 2 months and 21 days
    DateTime dateAt14Weeks = incrementDate(dob,
        months: 3, days: 14); // 14 weeks = 3 months and 14 days

    // Add vaccines that occur at 6, 10, and 14 weeks
    schedule.addAll([
      {
        'name': 'OPV 1,2 &3',
        'date': [dateAt6Weeks, dateAt10Weeks, dateAt14Weeks],
        'timePeriod': 'At 6, 10, and 14 weeks of age',
        'booking': 'Available',
        'booked': false,
      },
      {
        'name': 'Pentavalent 1,2 & 3',
        'date': [dateAt6Weeks, dateAt10Weeks, dateAt14Weeks],
        'timePeriod':
            'At 6 weeks, 10 weeks, and 14 weeks (can be given till 1 years of age)',
        'booking': 'Available',
        'booked': false,
      },
      // Add more vaccines as needed
    ]);

    // Continue adding other vaccines and their schedules...

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
              MaterialPageRoute(
                  builder: (context) => LoginPage(
                        onTap: () {},
                      )),
            );
          },
          child: Text('Logout'),
        ),
      ),
    );
  }
}
