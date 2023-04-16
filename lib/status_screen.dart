import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

const List<Widget> fruits = <Widget>[
  Text("I'm in wreck"),
  Text("I need aid"),
  Text("I'm safe")
];
final List<bool> status = <bool>[false, false, false];

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
          ToggleButtons(isSelected: status, children: fruits,
          onPressed: (int index) => {
            setState(() {
              for (int i = 0; i < status.length; i++) {
                status[i] = i == index;
              }
              print(fruits[index]);
            })
          },),
        ],
      ),
    );
  }
}
