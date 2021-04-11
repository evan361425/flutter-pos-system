import 'package:flutter/material.dart';
import 'package:possystem/constants/constant.dart';

import 'chart_actions.dart';
import 'chart_product_list.dart';

class ChartScreen extends StatelessWidget {
  const ChartScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {},
                child: Text('全選'),
              ),
            ),
            SizedBox(width: 4),
            Expanded(
              child: ElevatedButton(
                onPressed: () {},
                child: Text('反選'),
              ),
            ),
          ],
        ),
        Expanded(child: ChartProductList()),
        Row(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: kPadding),
              child: ChartActions(),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Row(
                  children: [
                    Text('總數：2'),
                    SizedBox(width: 4.0),
                    Text('總價：200'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
