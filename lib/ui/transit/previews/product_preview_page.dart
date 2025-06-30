import 'package:flutter/material.dart';
import 'package:possystem/components/meta_block.dart';
import 'package:possystem/helpers/util.dart';
import 'package:possystem/models/menu/product.dart';
import 'package:possystem/translator.dart';
import 'package:possystem/ui/transit/formatter/formatter.dart';

import 'preview_page.dart';

class ProductPreviewPage extends PreviewPage<Product> {
  const ProductPreviewPage({
    super.key,
    required super.model,
    required super.items,
    super.progress,
    super.physics,
  });

  @override
  Iterable<Widget> buildDetails(
    BuildContext context,
    Iterable<FormattedItem> items,
  ) sync* {
    String catalogName = '';

    for (final item in items) {
      if (item.hasError) {
        yield PreviewErrorListTile(item);
        continue;
      }

      final product = (item.item! as Product);
      if (product.catalog.name != catalogName) {
        catalogName = product.catalog.name;

        yield const SizedBox(height: 12.0);
        yield Padding(
          padding: const EdgeInsets.only(left: 4.0),
          child: ImporterColumnStatus(
            name: catalogName,
            status: product.catalog.statusName,
            fontWeight: FontWeight.bold,
          ),
        );
      }

      yield buildItem(context, product);
    }
  }

  @override
  Widget buildItem(BuildContext context, Product item) {
    final textTheme = Theme.of(context).textTheme;
    final textStyle = textTheme.bodyMedium?.copyWith(
      color: textTheme.bodySmall?.color,
    );

    return ExpansionTile(
      key: Key('transit_preview.menu.${item.id}'),
      title: ImporterColumnStatus(
        name: item.name,
        status: item.statusName,
      ),
      subtitle: MetaBlock.withString(
        context,
        item.items.map((e) => e.name),
        emptyText: S.menuProductEmptyIngredients,
        textStyle: textStyle,
      ),
      childrenPadding: const EdgeInsets.symmetric(horizontal: 8.0),
      children: [
        MetaBlock.withString(context, <String>[
          S.menuProductMetaPrice(item.price),
          S.menuProductMetaCost(item.cost),
        ])!,
        const SizedBox(height: 8.0),
        for (final ingredient in item.items)
          Column(children: [
            ListTile(
              title: ImporterColumnStatus(
                name: ingredient.name,
                status: ingredient.statusName,
              ),
              subtitle: Text(S.menuIngredientMetaAmount(ingredient.amount)),
              visualDensity: VisualDensity.compact,
              minVerticalPadding: 0,
            ),
            for (final quantity in ingredient.items)
              ListTile(
                title: ImporterColumnStatus(
                  name: quantity.name,
                  status: quantity.statusName,
                ),
                subtitle: MetaBlock.withString(
                  context,
                  <String>[
                    S.menuQuantityMetaAmount(quantity.amount),
                    S.menuQuantityMetaAdditionalPrice(quantity.additionalPrice.toCurrency()),
                    S.menuQuantityMetaAdditionalCost(quantity.additionalCost.toCurrency()),
                  ],
                  textStyle: textStyle,
                ),
                leading: const Text(MetaBlock.string),
                visualDensity: VisualDensity.compact,
                minLeadingWidth: 0,
                minVerticalPadding: 0,
              ),
          ]),
        const SizedBox(height: 8.0),
      ],
    );
  }
}
