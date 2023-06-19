import 'package:dapp/register_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import 'firebase_methods.dart';
import 'main.dart';

class LoginPage extends StatefulWidget {
  FirebaseInit thisFirebase = new FirebaseInit();

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class Login {
  final String SSN;
  final String password;

  Login({required this.SSN, required this.password});
}

class _LoginPageState extends State<LoginPage> {
  var _SSN;
  var _password;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black54,
        title: Text('Log In'),
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
              buildRegisterTextField("SSN", (value) {
                setState(() {
                  _SSN = value;
                });
              }),
              buildRegisterTextFieldPassword("Password", (value) {
                setState(() {
                  _password = value;
                });
              }),
              const SizedBox(height: 16.0),
              Padding(
                padding: const EdgeInsets.only(left: 35, right: 35),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                  ),
                  onPressed: () async {
                    Person userPerson = await widget.thisFirebase
                        .checkIfCorrect(_SSN, _password);
                    if (userPerson != null) {
                      writeFile(userPerson);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const MyApp()));
                    } else {
                      print("There are no such accounts");
                    }
                  },
                  child: const Text(style: TextStyle(fontSize: 25),'Log In'),
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
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
        ],
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

  Padding buildRegisterTextFieldPassword(
      String labelText, Function(String) onChangedCallback) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        obscureText: true,
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

Future<void> writeFile(Person thisUser) async {
  final directory = await getApplicationDocumentsDirectory();
  final file = File("${directory.path}/file.txt");
  await file.writeAsString(thisUser.hash);
}
