
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';

void main() {
  runApp(const MyApp());
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


  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {


  late Client httpClient;
  late Web3Client ethClient;

  final String myAddress = ""; // Metamask wallet
  final String bcURL = "https://goerli.infura.io/v3/1670a51d46d74984873f6a273c285335";

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

  Future<DeployedContract> getContract() async {
    String abiFile = await rootBundle.loadString("assets/contract.json");


    String contractAddress = ""; // deployed contract address


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

  Future<void> deploy() async {
    Credentials key = EthPrivateKey.fromHex(
        ""); // metamask wallet private key

    final contract = await getContract();

    final function = contract.function("setHomeAddress");

    await ethClient.sendTransaction(
        key,
        Transaction.callContract(
            contract: contract, function: function, parameters: ["flutter"]),
        chainId: 5);


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
            Text(name),
            Text(surname),
            Text(ssn),
            Text(address),
            ElevatedButton(
                onPressed: (){
                  setState(() {
                    deploy();
                  });
                },
                child: Text("set")),
          ],
        ),
      ),
    );
  }
}
