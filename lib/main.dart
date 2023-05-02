import 'package:cloud_firestore/cloud_firestore.dart' as FB;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'status_screen.dart';

Future<void> main() async {
  runApp(const MyApp());
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  ).whenComplete(() {
    print("completed");
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({super.key, required this.title});

  final String title;

  var db = FB.FirebaseFirestore.instance;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

const List<Widget> statusText = <Widget>[
  Text("I'm in wreck"),
  Text("I need aid"),
  Text("I'm safe")
];
final List<Color> statDefColors = [Colors.red, Colors.blue, Colors.green];

class ToggleStatus extends StatefulWidget {
  @override
  State<ToggleStatus> createState() => _ToggleStatusState();
}

class _ToggleStatusState extends State<ToggleStatus> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Center(
      child: Column(
        children: [
          ToggleButtons(
            isSelected: statusBool,
            children: statusText,
            onPressed: (int index) => {
              setState(() {
                for (int i = 0; i < statusBool.length; i++) {
                  statusBool[i] = i == index;
                }
                switch (index) {
                  case 0:
                    {}
                    break;

                  case 1:
                    {}
                    break;

                  case 2:
                    {}
                    break;
                }
                print(statusText[index]);
              })
            },
          ),
        ],
      ),
    );
  }
}

class _MyHomePageState extends State<MyHomePage> {
  FB.FirebaseFirestore getDB() {
    return widget.db;
  }

  late var db = getDB();

  late Client httpClient;
  late Web3Client ethClient;

  final String myAddress =
      "0x1cEDc507F8478ECAc0fc6b710c8C039050AD0aa8"; // Metamask wallet
  final String bcURL =
      "https://sepolia.infura.io/v3/1670a51d46d74984873f6a273c285335";

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

  Future<String> getContractAddress() async {
    final docRef = db.collection("users").doc("test");
    String contAddress = "";
    FB.DocumentSnapshot doc = await docRef.get();
    final data = doc.data() as Map<String, dynamic>;
    contAddress = data.entries.first.value.toString();
    print("First print is: $contAddress");
    return contAddress;
  }

  Future<DeployedContract> getContract() async {
    String abiFile = await rootBundle.loadString("assets/contract.json");

    String contractAddress =
        await getContractAddress(); // deployed contract address

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

  Future<void> deploy(int func) async {
    Credentials key = EthPrivateKey.fromHex(
        "5097a6d03dc87e60520a428433f4ad15aaab20d5aaba9e4188ccb82c7ad2196f"); // metamask wallet private key

    final contract = await getContract();

    ContractFunction function = contract.function("setSafe");

    switch (func) {
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
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Center(
              child: Column(
                children: [
                  ToggleButtons(
                    isSelected: statusBool,
                    children: statusText,
                    onPressed: (int index) => {
                      setState(() {
                        for (int i = 0; i < statusBool.length; i++) {
                          statusBool[i] = i == index;
                        }
                        deploy(index);

                        print(statusText[index]);
                      })
                    },
                  ),
                ],
              ),
            ), /*Text(name),
            Text(surname),
            Text(ssn),
            Text(address),
            ElevatedButton(
                onPressed: () {
                  setState(() {
                    deploy();
                  });
                },
                child: Text("set"))*/
          ],
        ),
      ),
    );
  }
}
