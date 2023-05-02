import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:web3dart/credentials.dart';
import 'main.dart';

const List<Widget> statusText = <Widget>[
  Text("I'm in wreck"),
  Text("I need aid"),
  Text("I'm safe")
];
final List<bool> statusBool = <bool>[false, false, false];
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
