import 'package:flutter/material.dart';
import 'package:mind_map_reminder/node_preview.dart';

class Pair {
  dynamic first;
  dynamic second;
  Pair(this.first, this.second);
}

class MindMap extends StatefulWidget {
  final double scale;
  final Offset offset;

  const MindMap({this.scale = 1.0, this.offset = Offset.zero, Key? key})
      : super(key: key);

  @override
  MindMapState createState() => MindMapState();
}

class MindMapState extends State<MindMap> {
  final List<Node> nodes = [];

  void addNode() {
    setState(() {
      Size screenSize = MediaQuery.of(context).size;
      nodes.add(Node.dummy((Offset(screenSize.width / 2, screenSize.height / 2) - const Offset(160, 76) * widget.scale / 2) / widget.scale + widget.offset));
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<NodePreview> nodePreviews = nodes
        .asMap()
        .entries
        .map((e) => NodePreview(
              e.value,
              key: e.value.key,
              scale: widget.scale,
              offset: widget.offset,
              onModified: (Offset pos) {
                setState(() {
                  nodes[e.key].lastModifyTime =
                      DateTime.now().millisecondsSinceEpoch;
                  nodes[e.key].pos = pos;
                });
              },
            ))
        .toList(growable: false);
    nodePreviews
        .sort((e1, e2) => (e1.data.lastModifyTime - e2.data.lastModifyTime));
    return Stack(
      children: [...nodePreviews],
    );
  }
}
