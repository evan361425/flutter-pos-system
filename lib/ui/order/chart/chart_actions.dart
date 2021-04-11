import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ChartActions extends StatelessWidget {
  const ChartActions({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DropdownButton(
      hint: Text('使所選物'),
      items: <DropdownMenuItem<String>>[
        DropdownMenuItem(
          onTap: () {},
          child: Text('刪除'),
        ),
        DropdownMenuItem(
          onTap: () {},
          child: Text('打折'),
        ),
        DropdownMenuItem(
          onTap: () {},
          child: Text('變價'),
        ),
        DropdownMenuItem(
          onTap: () {},
          child: Text('招待'),
        ),
      ],
    );
  }
}
