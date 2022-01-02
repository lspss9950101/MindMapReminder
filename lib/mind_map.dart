import 'package:flutter/material.dart';
import 'package:mind_map_reminder/main_scale_offset.dart';
import 'package:mind_map_reminder/node.dart';

typedef NodeListUpdateFunction = void Function();
typedef NodeListAspect = UniqueKey;
typedef NodeListOnModifiedFunction = void Function(NodeListAspect key);

class NodeListModel extends InheritedModel<NodeListAspect> {
  late final Map<UniqueKey, Node> _nodeMap;

  NodeListModel(
      {required Map<UniqueKey, Node> nodeMap, required Widget child, Key? key})
      : super(child: child, key: key) {
    _nodeMap = nodeMap;
  }

  static Node of(BuildContext context, NodeListAspect aspect) {
    final NodeListModel? nodeList =
        InheritedModel.inheritFrom<NodeListModel>(context, aspect: aspect);
    final Node? node = nodeList?._nodeMap[aspect];
    assert(nodeList != null, 'No MainScaleOffset found in context');
    assert(node != null, 'Node not exist');
    return node!;
  }

  @override
  bool updateShouldNotify(NodeListModel oldWidget) =>
      _nodeMap.length != oldWidget._nodeMap.length ||
      _nodeMap.keys.any((key) => _nodeMap[key] != oldWidget._nodeMap[key]);

  @override
  bool updateShouldNotifyDependent(
      NodeListModel oldWidget, Set<UniqueKey?> dependencies) {
    bool ret = false;
    for (UniqueKey? dependency in dependencies) {
      if (dependency == null) {
        ret |= updateShouldNotify(oldWidget);
      } else {
        ret |= oldWidget._nodeMap[dependency] != _nodeMap[dependency];
      }
    }
    return ret;
  }
}

class MindMap extends StatefulWidget {
  final NodeMap nodeMap;

  const MindMap({required this.nodeMap, Key? key}) : super(key: key);

  @override
  MindMapState createState() => MindMapState();
}

class MindMapState extends State<MindMap> {
  late final void Function() onNodeMapChanged;

  @override
  void initState() {
    onNodeMapChanged = () {
      setState(() {});
    };
    widget.nodeMap.addListener(onNodeMapChanged);
    super.initState();
  }

  @override
  void dispose() {
    widget.nodeMap.removeListener(onNodeMapChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NodeListModel(
      nodeMap: widget.nodeMap.nodes,
      child: Builder(
        builder: (BuildContext innerContext) {
          MainScaleOffset mainScaleOffset =
              MainScaleOffset.of(innerContext, MainScaleOffsetAspect.dynamic);
          return Transform(
            transform: Matrix4.identity()
              ..scale(mainScaleOffset.dynamicScale)
              ..translate(-mainScaleOffset.dynamicOffset.dx,
                  -mainScaleOffset.dynamicOffset.dy),
            child: Stack(
              clipBehavior: Clip.none,
              children: widget.nodeMap.widgets,
            ),
          );
        },
      ),
    );
  }
}
