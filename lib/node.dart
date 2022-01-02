import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:mind_map_reminder/node_preview.dart';

class Node extends ChangeNotifier {
  String title;
  String description;
  Color color;
  final UniqueKey key = UniqueKey();

  late int lastModifyTime;
  Offset pos;

  Node(
      {required this.title,
      required this.description,
      required this.color,
      this.pos = Offset.zero}) {
    lastModifyTime = DateTime.now().millisecondsSinceEpoch;
  }

  Node.dummy({Offset pos = Offset.zero})
      : this(
            title: "Title",
            description: DateFormat('yyyy/MM/dd').format(DateTime.now()),
            color: Colors.deepPurple,
            pos: pos);

  void update(
      {String? title, String? description, Color? color, Offset? position}) {
    this.title = title ?? this.title;
    this.description = description ?? this.description;
    this.color = color ?? this.color;
    pos = position ?? pos;
    lastModifyTime = DateTime.now().millisecondsSinceEpoch;
    notifyListeners();
  }

  @override
  bool operator ==(Object other) =>
      other is Node &&
      other.title == title &&
      other.description == description &&
      other.color == color;

  @override
  int get hashCode => Object.hashAll([title, description, color]);
}

class _NodeMapEntry {
  Node node;
  Widget widget;
  void Function() onUpdate;

  _NodeMapEntry(
      {required this.node, required this.widget, required this.onUpdate});
}

class NodeMap extends ChangeNotifier {
  final Map<UniqueKey, _NodeMapEntry> _nodeMap = {};

  void add(Node node) {
    assert(!_nodeMap.containsKey(node.key), 'Node already exists');
    _NodeMapEntry newEntry = _NodeMapEntry(
      node: node,
      widget: buildNodePreview(node),
      onUpdate: () {
        update(node.key);
      },
    );
    _nodeMap[node.key] = newEntry;
    node.addListener(newEntry.onUpdate);
    notifyListeners();
  }

  void remove(UniqueKey key) {
    assert(_nodeMap.containsKey(key), 'Node not exists');
    _NodeMapEntry entry = _nodeMap[key]!;
    entry.node.removeListener(entry.onUpdate);
    _nodeMap.remove(key);
    notifyListeners();
  }

  void update(UniqueKey key) {
    assert(_nodeMap.containsKey(key), 'Node not exists');
    //_NodeMapEntry entry = _nodeMap[key]!;
    //entry.widget = buildNodePreview(entry.node);
    notifyListeners();
  }

  List<Widget> get widgets => (_nodeMap.values.toList(growable: false)
        ..sort((_NodeMapEntry a, _NodeMapEntry b) =>
            a.node.lastModifyTime - b.node.lastModifyTime))
      .map((_NodeMapEntry e) => e.widget)
      .toList(growable: false);

  Map<UniqueKey, Node> get nodes =>
      {for (var e in _nodeMap.entries) (e).key: (e).value.node};

  static Widget buildNodePreview(Node node) {
    return NodePreview(nodeKey: node.key);
  }
}
