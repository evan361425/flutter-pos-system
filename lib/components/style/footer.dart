import 'package:flutter/material.dart';
import 'package:possystem/components/linkify.dart';
import 'package:possystem/components/meta_block.dart';

class Footer extends StatelessWidget {
  const Footer({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(alignment: WrapAlignment.center, crossAxisAlignment: WrapCrossAlignment.center, children: [
      TextButton(
        onPressed: _links[0].launch,
        child: Text(_links[0].text),
      ),
      const Text(MetaBlock.string),
      TextButton(
        onPressed: _links[1].launch,
        child: Text(_links[1].text),
      ),
    ]);
  }
}

const _links = <LinkifyData>[
  LinkifyData('Privacy Policy', 'https://evan361425.github.io/flutter-pos-system/PRIVACY_POLICY/'),
  LinkifyData('License', 'https://evan361425.github.io/flutter-pos-system/LICENSE/'),
];
