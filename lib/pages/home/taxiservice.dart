import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vaccino/pages/bookingpage.dart';
import 'package:vaccino/pages/home/childprofile.dart';
import 'package:vaccino/pages/home/registerprofile.dart';
import 'package:vaccino/pages/login.dart';

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