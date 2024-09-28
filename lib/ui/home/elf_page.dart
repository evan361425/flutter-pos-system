import 'package:flutter/material.dart';
import 'package:possystem/components/linkify.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/translator.dart';

class ElfPage extends StatelessWidget {
  const ElfPage({super.key});

  @override
  Widget build(BuildContext context) {
    // vertical center
    return Center(
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
              key: const Key('elf_page'),
            ),
          ),
          const SizedBox(height: 14.0),
          Linkify.fromString(
            S.settingElfContent,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: kFABSpacing),
        ]),
      ),
    );
  }
}
