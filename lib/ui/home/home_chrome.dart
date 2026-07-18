import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:possystem/components/tutorial.dart';
import 'package:possystem/constants/app_themes.dart';
import 'package:possystem/routes/app_route_names.dart';
import 'package:possystem/translator.dart';
import 'package:spotlight_ant/spotlight_ant.dart';

/// Shared gradient AppBar background for home scaffolds.
class HomeFlexibleSpace extends StatelessWidget {
  const HomeFlexibleSpace({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: Theme.of(context).gradientColors,
          tileMode: .clamp,
        ),
      ),
    );
  }
}

/// Floating action button that opens the order screen.
class HomeOrderFab extends StatelessWidget {
  const HomeOrderFab({super.key});

  @override
  Widget build(BuildContext context) {
    return Tutorial(
      id: 'home.order',
      index: 100,
      spotlightBuilder: const SpotlightRectBuilder(borderRadius: 16.0),
      title: S.orderTutorialTitle,
      message: S.orderTutorialContent,
      preferVertical: true,
      child: FloatingActionButton.extended(
        key: const Key('home.order'),
        heroTag: null,
        onPressed: () => context.pushNamed(AppRouteNames.order),
        icon: const Icon(Icons.store_outlined),
        label: Text(S.orderBtn),
      ),
    );
  }
}
