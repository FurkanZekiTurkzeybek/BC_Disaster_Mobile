import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart' as FB;
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

