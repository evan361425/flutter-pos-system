import 'package:flutter/material.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/routes.dart';

class OrderInfo extends StatelessWidget {
  const OrderInfo({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textStyle = theme.textTheme.headline3.copyWith(
      color: theme.primaryColor,
    );

    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        Card(
          margin: const EdgeInsets.only(bottom: 32.0),
          child: Padding(
            padding: const EdgeInsets.all(kPadding / 2),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    children: <Widget>[
                      Text('今日單量', textAlign: TextAlign.center),
                      Text(
                        '20',
                        textAlign: TextAlign.center,
                        style: textStyle,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 64),
                Expanded(
                  child: Column(
                    children: <Widget>[
                      Text('今日獲利', textAlign: TextAlign.center),
                      Text(
                        '200000',
                        textAlign: TextAlign.center,
                        style: textStyle,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          child: ElevatedButton(
            onPressed: () => Navigator.of(context).pushNamed(Routes.order),
            style: ElevatedButton.styleFrom(
              shape: CircleBorder(),
              padding: EdgeInsets.all(18.0),
            ),
            child: Text('點餐', style: theme.textTheme.headline4),
          ),
        ),
      ],
    );
  }
}
