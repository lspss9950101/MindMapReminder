import 'dart:math';
import 'package:flutter/material.dart';
import 'package:mind_map_reminder/main_scale_offset.dart';
import 'package:mind_map_reminder/mind_map.dart';
import 'package:mind_map_reminder/node.dart';
import 'package:mind_map_reminder/styles.dart';
import 'package:mind_map_reminder/utilities.dart';

class _NodePreviewContent extends StatelessWidget {
  final Size renderSize;
  final String title;
  final String description;
  final Color color;
  final double scale;

  const _NodePreviewContent(
      {required this.title,
      required this.description,
      required this.color,
      required this.renderSize,
      required this.scale,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: renderSize.height,
      width: renderSize.width,
      transform: Matrix4.identity()..scale(scale),
      color: color,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Container(
              alignment: Alignment.center,
              width: getTextSize(title, nodeTitleStyle, minWidth: 28).width,
              child: Text(
                title,
                style: nodeTitleStyle,
              ),
            ),
          ),
          if (description.isNotEmpty) ...[
            Container(
              width: 8,
              height: renderSize.height,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Colors.black38,
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Text(
                description,
                style: nodeDescStyle,
              ),
            ),
          ]
        ],
      ),
    );
  }
}

class _NodePreviewShadow extends StatelessWidget {
  final Size renderSize;
  final double scale;

  const _NodePreviewShadow(
      {required this.renderSize, required this.scale, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Offset renderSizeOffset = Offset(renderSize.width, renderSize.height);
    final double shadowLength = renderSizeOffset.distance * 0.7;
    final double cos = renderSizeOffset.dx / renderSizeOffset.distance;
    final double sin = renderSizeOffset.dy / renderSizeOffset.distance;
    final double theta = acos(cos);

    final double height = shadowLength * (cos * 0.5 + sin * sqrt(3) * 0.5);
    final double width = renderSizeOffset.distance;

    return Transform(
      transform: Matrix4.identity()
        ..scale(scale)
        ..translate(0.0, renderSize.height)
        ..rotateZ(-theta),
      child: Container(
        transform: Matrix4.skewX(pi / 3 - theta),
        width: width,
        height: height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black12,
              Colors.transparent,
            ],
          ),
        ),
      ),
    );
  }
}

class NodePreview extends StatefulWidget {
  final UniqueKey nodeKey;

  const NodePreview({required this.nodeKey, Key? key}) : super(key: key);

  @override
  _NodePreviewState createState() => _NodePreviewState();
}

class _NodePreviewState extends State<NodePreview> {
  bool dragged = false;

  @override
  Widget build(BuildContext context) {
    final Node node = NodeListModel.of(context, widget.nodeKey);
    final MainScaleOffset mainScaleOffset =
        MainScaleOffset.of(context, MainScaleOffsetAspect.static);

    final Size renderSize = _getSelfSize(node);
    final Widget content = _NodePreviewContent(
      title: node.title,
      description: node.description,
      color: node.color,
      renderSize: renderSize,
      scale: mainScaleOffset.staticScale,
    );
    final Widget shadow = _NodePreviewShadow(
        renderSize: renderSize, scale: mainScaleOffset.staticScale);

    return Positioned(
      left: (node.pos.dx - mainScaleOffset.staticOffset.dx) *
          mainScaleOffset.staticScale,
      top: (node.pos.dy - mainScaleOffset.staticOffset.dy) *
          mainScaleOffset.staticScale,
      child: Stack(
        children: [
          if (!dragged)
            IgnorePointer(
              ignoring: true,
              child: shadow,
            ),
          LongPressDraggable(
            child: Stack(
              children: [
                SizedBox(
                  height: renderSize.height * mainScaleOffset.staticScale,
                  width: renderSize.width * mainScaleOffset.staticScale,
                ),
                content,
              ],
            ),
            childWhenDragging: Opacity(
              opacity: 0.35,
              child: content,
            ),
            feedback: Material(
              color: Colors.transparent,
              child: Stack(
                children: [
                  shadow,
                  Transform(
                    transform: Matrix4.identity()
                      ..scale(mainScaleOffset.staticScale),
                    child: Container(
                      height: renderSize.height,
                      width: renderSize.width,
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black38,
                            offset: Offset(sqrt(3) * 2, 4),
                            blurRadius: 4,
                            spreadRadius: 0
                          ),
                        ],
                      ),
                    ),
                  ),
                  content,
                ],
              ),
            ),
            onDragStarted: () {
              setState(() {
                dragged = true;
              });
            },
            onDragEnd: (DraggableDetails details) {
              setState(() {
                dragged = false;
              });
              node.update(
                  position: node.pos +
                      (context.findRenderObject() as RenderBox)
                              .globalToLocal(details.offset) /
                          mainScaleOffset.overallScale);
            },
          ),
        ],
      ),
    );
  }

  Size _getSelfSize(Node node) {
    final Size titleSize =
        getTextSize(node.title, nodeTitleStyle, minWidth: 28);
    final Size descSize = getTextSize(node.description, nodeDescStyle);

    if (node.description.isNotEmpty) {
      return Size(8 + titleSize.width + 8 + 8 + descSize.width + 12,
          24 + max(titleSize.height, descSize.height) + 24);
    } else {
      return Size(8 + titleSize.width + 8, 24 + titleSize.height + 24);
    }
  }
}
