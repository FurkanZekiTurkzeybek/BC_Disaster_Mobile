import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart' as FB;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dapp/register_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';


class FirebaseInit extends StatefulWidget {
  FirebaseInit({super.key});

  var db = FB.FirebaseFirestore.instance;

  Future<bool> checkIfSSNExists(String givenSSN) async {
    final FB.QuerySnapshot result = await FB.FirebaseFirestore.instance
        .collection("Users")
        .where("SSN", isEqualTo: givenSSN)
        .limit(1)
        .get();

    final List <FB.DocumentSnapshot> documents = result.docs;
    return documents.isNotEmpty;
  }

  Future<Person> checkIfCorrect(String givenSSN, String givenPassword) async {
    final FB.QuerySnapshot result = await FB.FirebaseFirestore.instance
        .collection("Users")
        .where("SSN", isEqualTo: givenSSN)
        .where("password",isEqualTo: givenPassword)
        .limit(1)
        .get();
    final List <FB.DocumentSnapshot> documents = result.docs;
    String docId = documents[0].id;

    DocumentReference documentRef =
      FirebaseFirestore.instance.collection('Users').doc(docId);
    DocumentSnapshot documentSnapshot = await documentRef.get();
    Map<String, dynamic> data = documentSnapshot.data() as Map<String, dynamic>;

    Person retPerson = Person(name: "def Name",
        surname: "def Surname",
        address: "def address",
        ssn: data["SSN"],
        password:data["password"],
        hash: data["hash"]);

    return retPerson;


  }

  @override
  State<FirebaseInit> createState() => _FirebaseInitState();

}

class _FirebaseInitState extends State<FirebaseInit> {
  FB.FirebaseFirestore getDB() {
    return widget.db;
  }
  late var db = getDB();

  Future<String> getContractAddress() async {
   // implement it as berke said
    return "0xb606000473A11a0e835ea8768226670f08239d7C";
  }




  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }

}

