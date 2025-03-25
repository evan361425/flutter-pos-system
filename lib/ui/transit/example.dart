import 'package:flutter/material.dart';

/// Flutter code sample for [SliverAppBar].

void main() => runApp(const AppBarApp());

class AppBarApp extends StatelessWidget {
  const AppBarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: SliverAppBarExample());
  }
}

class SliverAppBarExample extends StatefulWidget {
  const SliverAppBarExample({super.key});

  @override
  State<SliverAppBarExample> createState() => _SliverAppBarExampleState();
}

class _SliverAppBarExampleState extends State<SliverAppBarExample> {
  bool _pinned = false;
  bool _snap = false;
  bool _floating = true;
  final scrollController = ScrollController();
  final scrollable = ValueNotifier(false);

  // [SliverAppBar]s are typically used in [CustomScrollView.slivers], which in
  // turn can be placed in a [Scaffold.body].
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            print('innerBoxIsScrolled: $innerBoxIsScrolled');
            scrollable.value = innerBoxIsScrolled;
            return [
              SliverAppBar(
                automaticallyImplyLeading: false,
                //               primary: false,
                pinned: _pinned,
                snap: _snap,
                floating: _floating,
                title: const Text(
                  'Hello World',
                  style: TextStyle(decoration: TextDecoration.underline),
                ),
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(48.0),
                  child: DropdownButtonFormField<bool>(
                    value: false,
                    onChanged: (value) {},
                    decoration: const InputDecoration(
                      label: Text('Hello World'),
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                    ),
                    items: const [
                      DropdownMenuItem(value: false, child: Text('Hello')),
                      DropdownMenuItem(value: true, child: Text('World')),
                    ],
                  ),
                ),
              ),
            ];
          },
          body: CustomScrollView(
            slivers: <Widget>[
              SliverPersistentHeader(
                pinned: true,
                delegate: _SliverAppBarDelegate(
                  TabBar(
                    tabs: [
                      Tab(text: 'Tab 1'),
                      Tab(text: 'Tab 2'),
                      // 更多 Tab
                    ],
                  ),
                ),
              ),
              SliverFillRemaining(
                child: TabBarView(
                  children: [
                    // 對應每個 Tab 的內容
                    Container(color: Colors.red),
                    Container(
                      color: Colors.blue,
                      child: ListView(
                        physics: MyScrollPhysics(scrollable: scrollable),
                        children: [
                          for (var i = 0; i < 30; i++) ListTile(title: Text(i.toString())),
                        ],
                      ),
                    ),
                    // 更多內容
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _SliverAppBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(color: Colors.white, child: tabBar);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}

class MyScrollPhysics extends ScrollPhysics {
  final ValueNotifier<bool> scrollable;

  const MyScrollPhysics({super.parent, required this.scrollable});

  @override
  MyScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return MyScrollPhysics(
      parent: buildParent(ancestor),
      scrollable: scrollable,
    );
  }

  @override
  bool get allowUserScrolling => true;

  @override
  bool get allowImplicitScrolling => true;

  @override
  bool shouldAcceptUserOffset(ScrollMetrics position) => scrollable.value || position.pixels != 0.0;
}
