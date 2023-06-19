import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart' as FB;
import 'package:dapp/login_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:path_provider/path_provider.dart';
import 'package:web3dart/web3dart.dart';
import 'package:firebase_core/firebase_core.dart';
import 'entry_page.dart';
import 'firebase_options.dart';
import 'firebase_methods.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        fontFamily: 'iAWriterDuoS',
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'HelpChain'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({super.key, required this.title});

  final String title;

  FirebaseInit thisFirebase = new FirebaseInit();

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

const List<String> statusText = <String>[
  ("In Distress"),
  ("Need Help"),
  ("Safe")
];
final List<Color> statDefColors = [Colors.red, Colors.blue, Colors.green];

class _MyHomePageState extends State<MyHomePage> {
  late var db = widget.thisFirebase.db;

  late Client httpClient;
  late Web3Client ethClient;

  final String myAddress =
      "0xfF266b4A997E30C195C5521819b8E75baEB7b8a1"; // Metamask wallet
  final String bcURL =
      "https://sepolia.infura.io/v3/2af035557b3b4dcd9f3278edb7eb7453";

  var name = "Name";
  var surname = "Surname";
  var ssn = "123456789";
  var address = "TR";

  @override
  void initState() {
    httpClient = Client();
    ethClient = Web3Client(bcURL, httpClient);
    getContractContents();
    super.initState();
  }

  // Future<String> getContractAddress() async {
  //   final docRef = db.collection("users").doc("test");
  //   String contAddress = "";
  //   FB.DocumentSnapshot doc = await docRef.get();
  //   final data = doc.data() as Map<String, dynamic>;
  //   contAddress = data.entries.first.value.toString();
  //   print("First print is: $contAddress");
  //   return contAddress;
  // }

  Future<DeployedContract> getContract() async {
    String abiFile = await rootBundle.loadString("assets/contract.json");

    String contractAddress =
        await readContractAddress(); // deployed contract address

    final contract = DeployedContract(ContractAbi.fromJson(abiFile, "Person"),
        EthereumAddress.fromHex(contractAddress));

    return contract;
  }

  Future<List<dynamic>> callFunction(String name) async {
    final contract = await getContract();
    final function = contract.function(name);
    final result = await ethClient
        .call(contract: contract, function: function, params: []);
    return result;
  }

  Future<void> getContractContents() async {
    List<dynamic> resultsA = await callFunction("getName");
    List<dynamic> resultsB = await callFunction("getSurname");
    List<dynamic> resultsC = await callFunction("getSSN");
    List<dynamic> resultsD = await callFunction("getHomeAddress");
    name = resultsA[0];
    surname = resultsB[0];
    ssn = resultsC[0];
    address = resultsD[0];
    setState(() {});
  }

  Future<void> deploy(int statusFunction) async {
    Credentials key = EthPrivateKey.fromHex(
        "5865c125b5740e6596348f6d787e6191f3fe6db79cd9094ab2adf8f61e28197c"); // metamask wallet private key

    final contract = await getContract();

    ContractFunction function = contract.function("setSafe");

    switch (statusFunction) {
      case 0:
        {
          function = contract.function("setWreck");
        }
        break;
      case 1:
        {
          function = contract.function("setHelp");
        }
        break;
      case 2:
        {
          function = contract.function("setSafe");
        }
        break;
    }

    await ethClient.sendTransaction(
        key,
        Transaction.callContract(
            contract: contract, function: function, parameters: []),
        chainId: 11155111);

    Future.delayed(const Duration(seconds: 20), () {
      getContractContents();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black54,
        title: const Text('Log In'),
        leading: InkWell(
          onTap: () {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => EntryPage()));
          },
          child: const Icon(
            Icons.arrow_back,
          ),
        ),
      ),
      // resizeToAvoidBottomInset: false,
      body: DecoratedBox(
        decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage("assets/images/crop.jpg"), fit: BoxFit.fill)),
        child: Expanded(
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.only(bottom: 60, top: 25),
                child: Text(
                  'CURRENT STATUS',
                  style: TextStyle(fontSize: 40, color: Colors.blueGrey),
                ),
              ),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    returnStatusBox(0),
                    returnStatusBox(1),
                    returnStatusBox(2),
                    Padding(
                      padding:
                          const EdgeInsets.only(left: 35, right: 35, top: 20),
                      child: ElevatedButton(
                          onPressed: () => {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            ChangeAddressWidget(
                                              title: 'Change Address',
                                            )))
                              },
                          child: const Text(
                              style: TextStyle(fontSize: 20), "Change Address"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey,
                          )),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  SizedBox returnStatusBox(int statusIndex) {
    return SizedBox(
      width: 250.0,
      height: 80.0,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ElevatedButton(
          onPressed: () => deploy(statusIndex),
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24.0),
            ),
            backgroundColor: statusBool[statusIndex]
                ? Colors.blue
                : statusButtonColours[statusIndex]?.withOpacity(0.999999999),
          ),
          child: Text(statusText[statusIndex],
              style: const TextStyle(
                fontSize: 25,
              )),
        ),
      ),
    );
  }
}

class ChangeAddressWidget extends StatefulWidget {
  ChangeAddressWidget({super.key, required this.title});

  final String title;

  FirebaseInit thisFirebase = new FirebaseInit();

  @override
  State<StatefulWidget> createState() => _ChangeAddressWidgetState();
}

class _ChangeAddressWidgetState extends State<ChangeAddressWidget> {
  var _newAddress;

  late var db = widget.thisFirebase.db;

  late Client httpClient;
  late Web3Client ethClient;

  final String myAddress =
      "0xfF266b4A997E30C195C5521819b8E75baEB7b8a1"; // Metamask wallet
  final String bcURL =
      "https://sepolia.infura.io/v3/2af035557b3b4dcd9f3278edb7eb7453";

  var name = "Name";
  var surname = "Surname";
  var ssn = "123456789";
  var address = "TR";

  @override
  void initState() {
    httpClient = Client();
    ethClient = Web3Client(bcURL, httpClient);
    getContractContents();
    super.initState();
  }

  // Future<String> getContractAddress() async {
  //   final docRef = db.collection("users").doc("test");
  //   String contAddress = "";
  //   FB.DocumentSnapshot doc = await docRef.get();
  //   final data = doc.data() as Map<String, dynamic>;
  //   contAddress = data.entries.first.value.toString();
  //   print("First print is: $contAddress");
  //   return contAddress;
  // }

  Future<DeployedContract> getContract() async {
    String abiFile = await rootBundle.loadString("assets/contract.json");

    String contractAddress =
        await readContractAddress(); // deployed contract address

    final contract = DeployedContract(ContractAbi.fromJson(abiFile, "Person"),
        EthereumAddress.fromHex(contractAddress));

    return contract;
  }

  Future<List<dynamic>> callFunction(String name) async {
    final contract = await getContract();
    final function = contract.function(name);
    final result = await ethClient
        .call(contract: contract, function: function, params: []);
    return result;
  }

  Future<void> getContractContents() async {
    List<dynamic> resultsA = await callFunction("getName");
    List<dynamic> resultsB = await callFunction("getSurname");
    List<dynamic> resultsC = await callFunction("getSSN");
    List<dynamic> resultsD = await callFunction("getHomeAddress");
    name = resultsA[0];
    surname = resultsB[0];
    ssn = resultsC[0];
    address = resultsD[0];
    setState(() {});
  }

  Future<void> deploy(String newAddress) async {
    Credentials key = EthPrivateKey.fromHex(
        "5865c125b5740e6596348f6d787e6191f3fe6db79cd9094ab2adf8f61e28197c"); // metamask wallet private key

    final contract = await getContract();

    ContractFunction function = contract.function("setHomeAddress");

    await ethClient
        .sendTransaction(
            key,
            Transaction.callContract(
                contract: contract,
                function: function,
                parameters: [newAddress]),
            chainId: 11155111)
        .then((value) async {
      ContractFunction function = contract.function("setSafe");

      await ethClient.sendTransaction(
          key,
          Transaction.callContract(
              contract: contract, function: function, parameters: []),
          chainId: 11155111);
    });

    // deploySafe();

    Future.delayed(const Duration(seconds: 20), () {
      getContractContents();
    });
  }

  Future<void> deploySafe() async {
    Credentials key = EthPrivateKey.fromHex(
        "5865c125b5740e6596348f6d787e6191f3fe6db79cd9094ab2adf8f61e28197c"); // metamask wallet private key

    final contract = await getContract();

    ContractFunction function = contract.function("setSafe");

    await ethClient.sendTransaction(
        key,
        Transaction.callContract(
            contract: contract, function: function, parameters: []),
        chainId: 11155111);

    // Future.delayed(const Duration(seconds: 20), () {
    //   getContractContents();
    // });
  }

  final TextEditingController _controller = new TextEditingController();

  bool _validateTheChangedAddress() {
    if (_controller.text.isEmpty) {
      return false;
    } else {
      return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black54,
        title: Text('Change Address'),
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
              SizedBox(
                width: 200.0,
                height: 200.0,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        controller: _controller,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'.*')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _newAddress = value;
                          });
                        },
                        style: const TextStyle(color: Colors.white),
                        cursorColor: Colors.white,
                        decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white24,
                            labelText: "Change Address",
                            labelStyle: const TextStyle(
                              color: Colors.white,
                            ),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(100)),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.white),
                              // Set the desired border color when focused
                              borderRadius: BorderRadius.circular(100),
                            )),
                      ),
                    ),
                    Container(
                      width: double.infinity, // Button width takes full width
                      padding:
                          const EdgeInsets.only(left: 35, right: 35, top: 10),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey,
                        ),
                        onPressed: () async {
                          if (_validateTheChangedAddress() == true) {
                            deploy(_newAddress);
                          } else {
                            print("You need to fill the text-field");
                          }
                        },
                        child: const Text(
                            style: TextStyle(fontSize: 25), 'Update'),
                      ),
                    ),
                  ]),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

//some methods and variables to reuse for the buttons
List statusButtonColours = [
  Colors.red[800],
  Colors.blue[800],
  Colors.green[800]
];
final List<bool> statusBool = <bool>[false, false, false];

// Future<String> readContractAddress() async {
//   String fileContent = await rootBundle.loadString('assets/hash.txt');
//   if (fileContent != null) {
//     return fileContent;
//   } else {
//     return "1";
//   }
// }

Future<String> readContractAddress() async {
  print("readContAddrr method is working");
  final directory = await getApplicationDocumentsDirectory();
  final file = File("${directory.path}/file.txt");

  final data = await file.readAsString(encoding: utf8);
  return data;

  // if(await file.exists()) {
  //   print("readContrAddrr: File exists");
  //   return await file.readAsString();
  // }
  // else {
  //   print("readContrAddrr: File does not exist");
  //   return "file does not exitst";
  // }
}
