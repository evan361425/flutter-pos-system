import 'package:flutter/material.dart';
import 'package:possystem/components/label_switch.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/localizations.dart';
import 'package:possystem/models/product_model.dart';

class ProductScreen extends StatelessWidget {
  final scrollController = ScrollController();
  @override
  Widget build(BuildContext context) {
    final product = ProductModel(
      'Ham Burger',
      index: 1,
      catalogName: 'Burger',
      price: 50,
    );

    return Scaffold(
      body: CustomScrollView(
        controller: scrollController,
        slivers: <Widget>[
          ProductAppBar(product: product, scrollController: scrollController),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                ProductMetadata(product: product),
                ListTile(
                  title: Center(
                    child: Text(
                      Local.of(context).t('menu.ingredient.title'),
                      style: Theme.of(context).textTheme.headline5,
                    ),
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.add),
                    onPressed: () {},
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _ingr(BuildContext context) {
    return AlertDialog(
      title: Text('ham'),
      contentPadding: EdgeInsets.zero,
      content: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const <DataColumn>[
            DataColumn(
              label: Text(
                'Status',
                style: TextStyle(fontStyle: FontStyle.italic),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            DataColumn(
              label: Text(
                'Amount',
                style: TextStyle(fontStyle: FontStyle.italic),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            DataColumn(
              label: Text(
                'Additional Cost',
                style: TextStyle(fontStyle: FontStyle.italic),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
          rows: <DataRow>[
            DataRow(
              cells: <DataCell>[
                DataCell(Text('Normal')),
                DataCell(
                  TextFormField(
                    initialValue: '10',
                    decoration: InputDecoration(
                      filled: false,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                    ),
                  ),
                ),
                DataCell(Text('0')),
              ],
            ),
          ],
        ),
      ),
      actions: [
        FlatButton(
          onPressed: () => Navigator.pop(context),
          child: Text('關閉'),
        ),
      ],
    );
  }

  ExpansionPanel expansionPanel() {
    return ExpansionPanel(
      headerBuilder: (_, __) => ListTile(
        title: Text('hello'),
        trailing: IconButton(
          icon: Icon(Icons.add),
          onPressed: () {},
        ),
      ),
      body: ListTile(
        leading: CircleAvatar(
          child: Text('0'),
        ),
        title: Text('normal'),
        subtitle: Text('50'),
      ),
    );
  }
}

class ProductAppBar extends StatelessWidget {
  ProductAppBar({
    Key key,
    @required this.product,
    @required this.scrollController,
  }) : super(key: key);

  final ProductModel product;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_rounded),
        onPressed: () => print('hi'), //Navigator.of(context).pop(),
      ),
      stretch: true,
      pinned: true,
      centerTitle: true,
      expandedHeight: 100,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        title: TextFormField(
          initialValue: product.name,
          maxLength: 30,
          keyboardType: TextInputType.text,
          textAlign: TextAlign.center,
          decoration: InputDecoration(
            hintText: Local.of(context).t('menu.product.title'),
            counterText: '',
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            filled: false,
            isDense: true,
            contentPadding: EdgeInsets.zero,
          ),
          onTap: () => scrollController.animateTo(
            scrollController.position.minScrollExtent,
            curve: Curves.fastOutSlowIn,
            duration: Duration(milliseconds: defaultAnimationDuration),
          ),
        ),
      ),
    );
  }
}

class ProductMetadata extends StatelessWidget {
  const ProductMetadata({
    Key key,
    @required this.product,
  }) : super(key: key);

  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Column(
        children: <Widget>[
          LabeledSwitch(
            label: '啟用',
            value: true,
            tooltip: '是否顯示在點餐系統',
            onChanged: (bool value) {},
          ),
          TextFormField(
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: Local.of(context).t('menu.product.price'),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              filled: false,
            ),
            initialValue: product.price.toString(),
          ),
          TextFormField(
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: Local.of(context).t('menu.product.cost'),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              filled: false,
            ),
          ),
        ],
      ),
    );
  }
}
