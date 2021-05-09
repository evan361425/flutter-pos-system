import 'package:flutter/material.dart';
import 'package:possystem/components/circular_loading.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/models/repository/stock_batch_repo.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/ui/home_container.dart';
import 'package:provider/provider.dart';

import 'widgets/stock_body.dart';

class StockScreen extends StatefulWidget {
  @override
  _StockScreenState createState() => _StockScreenState();
}

class _StockScreenState extends State<StockScreen> {
  bool initialized = false;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: StockBatchRepo.instance,
      child: SafeArea(
        child: Scaffold(
          floatingActionButton: FloatingActionButton(
            onPressed: () => Navigator.of(context).pushNamed(
              Routes.stockIngredient,
            ),
            tooltip: '新增成份',
            child: Icon(KIcons.add),
          ),
          body: initialized ? StockBody() : CircularLoading(),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 10), () {
      setState(() {
        initialized = true;
      });
    });
  }
}
