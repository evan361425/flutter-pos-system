import 'package:flutter/material.dart';
import 'package:possystem/components/meta_block.dart';
import 'package:possystem/helpers/formatter/formatter.dart';
import 'package:possystem/models/menu/product.dart';
import 'package:possystem/translator.dart';
import 'package:possystem/ui/exporter/previews/previewer_screen.dart';

class ProductPreviewer extends PreviewerScreen {
  const ProductPreviewer({
    Key? key,
    required List<FormattedItem> items,
  }) : super(key: key, items: items);

  @override
  Iterable<Widget> getDetails(
    BuildContext context,
    Iterable<FormattedItem> items,
  ) sync* {
    final textTheme = Theme.of(context).textTheme;
    final textStyle = textTheme.bodyMedium?.copyWith(
      color: textTheme.caption?.color,
    );
    String catalogName = '';

    for (final item in items) {
      if (item.hasError) {
        yield PreviewerErrorListTile(item);
        continue;
      }

      final product = (item.item as Product);
      if (product.catalog.name != catalogName) {
        catalogName = product.catalog.name;

        yield const SizedBox(height: 12.0);
        yield ImporterColumnStatus(
          name: catalogName,
          status: product.catalog.statusName,
          fontWeight: FontWeight.bold,
        );
      }

      yield ExpansionTile(
        title: ImporterColumnStatus(
          name: product.name,
          status: product.statusName,
        ),
        subtitle: MetaBlock.withString(
          context,
          product.items.map((e) => e.name),
          emptyText: S.menuProductListEmptyIngredient,
          textStyle: textStyle,
        ),
        childrenPadding: const EdgeInsets.symmetric(horizontal: 8.0),
        children: [
          MetaBlock.withString(context, <String>[
            S.menuProductMetaTitle,
            S.menuProductMetaPrice(product.price),
            S.menuProductMetaCost(product.cost),
          ])!,
          const SizedBox(height: 8.0),
          for (final ingredient in product.items)
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
                      S.menuQuantityMetaPrice(quantity.additionalPrice),
                      S.menuQuantityMetaCost(quantity.additionalCost),
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
}
