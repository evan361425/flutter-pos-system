import 'package:flutter/material.dart';
import 'package:possystem/components/tip.dart';
import 'package:possystem/services/cache.dart';

class TipRadio extends StatefulWidget {
  static final groups = <String, _RadioGroup>{};

  final String id;

  final String groupId;

  final String? title;

  final String message;

  final int version;

  final Widget child;

  TipRadio({
    required this.id,
    required this.groupId,
    this.title,
    required this.message,
    this.version = 0,
    required this.child,
    int? order,
    Key? key,
  }) : super(key: key) {
    group.addCandidate(id: id, version: version, order: order);
  }

  _RadioGroup get group {
    var group = groups[groupId];
    if (group == null) {
      group = _RadioGroup(groupId);
      groups[groupId] = group;
    }

    return group;
  }

  bool get isDisabled => group.isNotLeader(id);

  @override
  _TipRadioState createState() => _TipRadioState();

  void initialize(VoidCallback builder) {
    final g = group;

    g.setupBuilder(id, builder);
    if (g.isNotReady) {
      g.startElection();
    }
  }
}

class _RadioGroup {
  String? leader;

  List<_RadioGroupCandidate> sortedCandidates = <_RadioGroupCandidate>[];

  final candidates = <String, _RadioGroupCandidate>{};

  final String groupId;

  _RadioGroup(this.groupId);

  bool get isNotReady => sortedCandidates.length != candidates.length;

  void addCandidate({
    required String id,
    required int version,
    int? order,
  }) {
    if (candidates[id] == null) {
      candidates[id] = _RadioGroupCandidate(
        id: id,
        order: order,
        version: version,
      );
    }
  }

  /// Disable all if current is not set
  bool isNotLeader(String id) {
    return leader == null ? true : leader != id;
  }

  void removeCandidate(String id) {
    candidates.remove(id);
    if (candidates.isEmpty) {
      TipRadio.groups.remove(groupId);
    }
  }

  void reset() {
    startElection();
    candidates.values.forEach((candidate) {
      candidate.builder();
    });
  }

  void retire(String id) async {
    await Cache.instance.tipRead('$groupId.$id', candidates[id]?.version ?? 0);
    // there is no tip enabled, now we can research
    Future.delayed(Duration(seconds: 0), () => reset());
  }

  void setup() {
    sortedCandidates = candidates.values.toList()
      ..sort((a, b) {
        if (a.order == null) {
          return b.order == null ? 0 : -1;
        } else {
          return b.order == null ? 1 : a.order!.compareTo(b.order!);
        }
      });
  }

  void setupBuilder(String id, VoidCallback builder) {
    if (candidates[id] != null) {
      candidates[id]!.builder = builder;
    }
  }

  void startElection() {
    if (isNotReady) setup();

    leader = null;
    for (final candidate in sortedCandidates) {
      if (Cache.instance
          .neededTip('$groupId.${candidate.id}', candidate.version)) {
        leader = candidate.id;
        break;
      }
    }
  }
}

class _RadioGroupCandidate {
  final String id;
  final int? order;
  final int version;
  late VoidCallback builder;

  _RadioGroupCandidate({
    required this.id,
    required this.version,
    this.order,
  });
}

class _TipRadioState extends State<TipRadio> {
  @override
  Widget build(BuildContext context) {
    return Tip(
      title: widget.title,
      message: widget.message,
      disabled: widget.isDisabled,
      onClosed: widget.isDisabled ? null : () => widget.group.retire(widget.id),
      child: widget.child,
    );
  }

  @override
  void dispose() {
    super.dispose();
    widget.group.removeCandidate(widget.id);
  }

  @override
  void initState() {
    super.initState();
    widget.initialize(() => setState(() {}));
  }
}
