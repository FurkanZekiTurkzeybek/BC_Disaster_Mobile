import 'dart:convert';

import 'package:dapp/main.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as HTTP;

// void main() {
//   runApp(MaterialApp(
//     title: "randomTitle",
//     home: InputPage(),
//   ));
// }
import 'dart:io';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MaterialApp(
    title: "randomTitle",
    home: InputPage(),
  ));
  var client = HttpClient();
  var request = await client.getUrl(
      Uri.parse('https://10.0.2.2:3000')); //server ile ilgili seyler calismadi
  var response = await request.close();
  var responseBody = await response.transform(utf8.decoder).join();
  print(responseBody);
}

class InputPage extends StatefulWidget {
  @override
  _InputPageState createState() {
    return _InputPageState();
  }
}

class Person {
  final String name;
  final String surname;
  final String address;
  final String ssn;

  Person(
      {required this.name,
      required this.surname,
      required this.address,
      required this.ssn});
}

class _InputPageState extends State<InputPage> {
  var _name;
  var _surname;
  var _address;
  var _ssn;

  // get http => "https://10.0.2.2:3000"; //localhost:3000/api/person;

//flutterdan alinan inputlar ile person objesi olusuyo. submite basinca da status screene yonlendiriyor.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Input Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              decoration: InputDecoration(labelText: 'Name'),
              onChanged: (value) {
                setState(() {
                  _name = value;
                });
              },
            ),
            TextField(
              decoration: InputDecoration(labelText: 'Surname'),
              onChanged: (value) {
                setState(() {
                  _surname = value;
                });
              },
            ),
            TextField(
              decoration: InputDecoration(labelText: 'Address'),
              onChanged: (value) {
                setState(() {
                  _address = value;
                });
              },
            ),
            TextField(
              decoration: InputDecoration(labelText: 'SSN'),
              onChanged: (value) {
                setState(() {
                  _ssn = value;
                });
              },
            ),
            SizedBox(height: 16.0),
            // ElevatedButton(
            //   onPressed: () {
            //     Person person = Person(
            //         name: _name,
            //         surname: _surname,
            //         address: _address,
            //         ssn: _ssn);
            //     print('Name: ${person.name}');
            //     print('Surname: ${person.surname}');
            //     print('Address: ${person.address}');
            //     print('SSN: ${person.ssn}');
            //     Navigator.push(context,
            //         MaterialPageRoute(builder: (context) => const MyApp()));
            //   },
            //   child: Text('Submit'),
            // ),

            ElevatedButton(
              onPressed: () async {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const MyApp()));
                Person person = Person(
                    name: _name,
                    surname: _surname,
                    address: _address,
                    ssn: _ssn);
                final url = Uri.parse('http://10.0.2.2:3000/api/person');
                final response = await HTTP.post(
                  url,
                  headers: {'Content-Type': 'application/json'},
                  body: json.encode({
                    'name': person.name,
                    'surname': person.surname,
                    'address': person.address,
                    'ssn': person.ssn,
                  }),
                );
                if (response.statusCode == 200) {
                  print('Person saved successfully!');
                } else {
                  print('Failed to save person: ${response.statusCode}');
                }
              },
              child: const Text('Submit'),
            ),

            // bu kisim server js ile ilgili
          ],
        ),
      ),
    );
  }
}
