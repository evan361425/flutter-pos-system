import 'package:flutter/material.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/ui/home/widgets/icon_actions.dart';
import 'package:possystem/ui/home/widgets/order_info.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: WillPopScope(
          onWillPop: () => _showConfirmDialog(context),
          child: Padding(
            padding: const EdgeInsets.all(kPadding),
            child: Column(
              children: [
                OrderInfo(),
                SizedBox(height: kMargin),
                Expanded(child: IconActions()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> _showConfirmDialog(BuildContext context) async {
    final result = await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('確定要離開 APP 嗎？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('確認'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('取消'),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}
