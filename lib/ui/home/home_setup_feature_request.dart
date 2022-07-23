import 'package:flutter/material.dart';
import 'package:possystem/components/linkify.dart';
import 'package:possystem/components/style/pop_button.dart';

class HomeSetupFeatureRequestScreen extends StatelessWidget {
  const HomeSetupFeatureRequestScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: const PopButton()),
      body: Center(
        child: SingleChildScrollView(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(
              decoration: const BoxDecoration(
                // moon white
                color: Color(0xFFF4F6F0),
                shape: BoxShape.circle,
              ),
              child: Image.asset(
                'assets/feature_request_please.gif',
                key: const Key('feature_request_please'),
              ),
            ),
            const SizedBox(height: 14.0),
            Linkify.fromString(
              '覺得這裡還少了什麼嗎？\n'
              '歡迎[提供建議](https://github.com/evan361425/flutter-pos-system/issues/new/choose)。\n'
              '也可以來看看[排程中的功能](https://github.com/evan361425/flutter-pos-system/milestones)。',
              textAlign: TextAlign.center,
            )
          ]),
        ),
      ),
    );
  }
}
