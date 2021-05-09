import 'package:flutter/material.dart';
import 'package:possystem/components/search_bar_inline.dart';
import 'package:possystem/constants/constant.dart';

class AnalysisScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          padding: EdgeInsets.all(kPadding),
          child: Column(
            // crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Row(
                children: [
                  Expanded(
                    child: SearchBarInline(
                      heroTag: 'analysis.product.search',
                      hintText: '產品或成份名稱',
                      onTap: (BuildContext context) async {},
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Icon(Icons.date_range_sharp),
                  )
                ],
              ),
              Divider(),
              Expanded(
                child: ListView.builder(
                  itemBuilder: (context, index) => Text(index.toString()),
                  itemCount: 2,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
