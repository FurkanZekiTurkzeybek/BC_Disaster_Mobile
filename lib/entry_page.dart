import 'dart:convert';
import 'dart:io';

import 'package:dapp/register_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MaterialApp(
    title: "randomTitle",
    home: EntryPage(),
  ));
  var client = HttpClient();
  var request = await client.getUrl(
      Uri.parse('https://10.0.2.2:3000')); //server ile ilgili seyler calismadi
  var response = await request.close();
  var responseBody = await response.transform(utf8.decoder).join();
  print(responseBody);
}

class EntryPage extends StatelessWidget {
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
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () => {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => RegisterPage()))
                },
                child: const Text('Register'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey,
                ),
              ),
              ElevatedButton(
                onPressed: () => {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => LoginPage()))
                },
                child: const Text('Login'),
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
}
