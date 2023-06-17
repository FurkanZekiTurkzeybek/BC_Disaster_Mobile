import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dapp/main.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:http/http.dart' as HTTP;

import 'dart:io';
import 'firebase_options.dart';

import "firebase_methods.dart";
import 'package:path_provider/path_provider.dart';

class RegisterPage extends StatefulWidget {
  FirebaseInit thisFirebase = new FirebaseInit();

  @override
  _RegisterPageState createState() {
    return _RegisterPageState();
  }
}

class Person {
  final String name;
  final String surname;
  final String address;
  final String ssn;
  final String password;
  final String hash;

  Person(
      {required this.name,
      required this.surname,
      required this.address,
      required this.ssn,
      required this.password,
      required this.hash});
}

class _RegisterPageState extends State<RegisterPage> {
  var _name;
  var _surname;
  var _address;
  var _ssn;
  var _password;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black54,
        title: Text('Register'),
      ),
      resizeToAvoidBottomInset: false,
      body: DecoratedBox(
        decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage("assets/images/crop.jpg"), fit: BoxFit.fill)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              buildRegisterTextField("Name", (value) {
                setState(() {
                  _name = value;
                });
              }),
              buildRegisterTextField("Surname", (value) {
                setState(() {
                  _surname = value;
                });
              }),
              buildRegisterTextField("Address", (value) {
                setState(() {
                  _address = value;
                });
              }),
              buildRegisterTextField("SSN", (value) {
                setState(() {
                  _ssn = value;
                });
              }),
              buildRegisterTextField("Password", (value) {
                setState(() {
                  _password = value;
                });
              }),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () async {
                  bool SSNnotFound =
                      await widget.thisFirebase.checkIfSSNExists(_ssn);

                  if (SSNnotFound == false) {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => const MyApp()));
                    Person person = Person(
                      hash: "",
                      name: _name,
                      surname: _surname,
                      address: _address,
                      ssn: _ssn,
                      password: _password,
                    );
                    final url = Uri.parse('http://10.0.2.2:3000/api/person');
                    final response = await HTTP.post(
                      url,
                      headers: {'Content-Type': 'application/json'},
                      body: json.encode({
                        'name': person.name,
                        'surname': person.surname,
                        'address': person.address,
                        'ssn': person.ssn,
                        'password': person.password
                      }),
                    );

                    if (response.statusCode == 200) {
                      // hash = response.body;
                      // print('Person saved successfully!');
                      // print(hash);
                      await writeFile(response.body.toString());
                    } else {
                      print('Failed to save person: ${response.statusCode}');
                    }
                  } else {
                    //print a box that informs the user.
                    print("The SSN is already exists");
                  }
                },
                child: const Text('Register'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Padding buildRegisterTextField(
      String labelText, Function(String) onChangedCallback) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        onChanged: onChangedCallback,
        style: const TextStyle(color: Colors.white),
        cursorColor: Colors.white,
        decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white24,
            labelText: labelText,
            labelStyle: const TextStyle(
              color: Colors.white,
            ),
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(100)),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.white),
              // Set the desired border color when focused
              borderRadius: BorderRadius.circular(100),
            )),
      ),
    );
  }
}

Future<void> writeFile(String content) async {
  final directory = await getApplicationDocumentsDirectory();
  final file = File("${directory.path}/file.txt");
  await file.writeAsString(content);
}
