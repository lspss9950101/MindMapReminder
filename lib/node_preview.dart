import 'dart:math';
import 'package:intl/intl.dart' as intl;

import 'package:flutter/material.dart';

class Node {
  final String title;
  final String description;
  final Color color;
  final Key key = UniqueKey();

  late int lastModifyTime;
  Offset pos;

  Node(this.title, this.description, this.color, this.pos) {
    lastModifyTime = DateTime.now().millisecondsSinceEpoch;
  }

  Node.dummy([Offset pos=const Offset(100, 100)]) : this("Title", intl.DateFormat('yyyy/MM/dd').format(DateTime.now()), Colors.deepPurple, pos);
}

class NodePreview extends StatefulWidget {
  final Node data;

  final Offset offset;
  final double scale;
  final double maxScale;
  final Function? onModified;

  const NodePreview(this.data,
      {this.offset = Offset.zero,
      this.scale = 1.0,
      this.maxScale = 1,
      this.onModified,
      Key? key})
      : super(key: key);

  NodePreview.dummy(
      {Offset? pos, Offset offset = Offset.zero, double scale = 1.0, Key? key})
      : this(Node.dummy(), offset: offset, scale: scale, key: key);

  @override
  _NodePreviewState createState() => _NodePreviewState();
}

class _NodePreviewState extends State<NodePreview> {
  static const TextStyle _titleStyle = TextStyle(
    color: Colors.white,
    fontSize: 24,
    fontWeight: FontWeight.bold,
  );
  static const TextStyle _descStyle = TextStyle(
    color: Colors.white,
    fontSize: 14,
  );

  bool dragged = false;

  Widget _contentPart(Size renderSize) {
    return Container(
      height: renderSize.height,
      width: renderSize.width,
      transform: Matrix4.identity()
        ..scale(min(widget.scale, widget.maxScale),
            min(widget.scale, widget.maxScale), 1.0),
      color: widget.data.color,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Container(
              alignment: Alignment.center,
              width: _getTextSize(widget.data.title, _titleStyle, minWidth: 28)
                  .width,
              child: Text(
                widget.data.title,
                style: _titleStyle.apply(
                  fontSizeFactor: 1,
                ),
              ),
            ),
          ),
          if (widget.data.description.isNotEmpty) ...[
            Container(
              width: 8,
              height: double.infinity,
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
                widget.data.description,
                style: _descStyle.apply(
                  fontSizeFactor: 1,
                ),
              ),
            ),
          ]
        ],
      ),
    );
  }

  Widget _shadowPart(Size renderSize) {
    final Offset renderSizeOffset = Offset(renderSize.width, renderSize.height);
    final double shadowLength = renderSizeOffset.distance * 0.7;
    final double cos = renderSizeOffset.dx / renderSizeOffset.distance;
    final double sin = renderSizeOffset.dy / renderSizeOffset.distance;
    final double theta = acos(cos);

    final double height = shadowLength * (cos * 0.5 + sin * sqrt(3) * 0.5);
    final double width = renderSizeOffset.distance;

    return Transform(
      transform: Matrix4.identity()
        ..scale(min(widget.scale, widget.maxScale),
            min(widget.scale, widget.maxScale), 1.0),
      child: Transform(
        transform: Matrix4.identity()
          ..translate(0.0, renderSize.height)
          ..rotateZ(-theta),
        child: Container(
          transform: Matrix4.skewX(pi/3-theta),
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Size renderSize = _getSelfSize();
    Widget content = _contentPart(renderSize);
    Widget shadow = _shadowPart(renderSize);
    return Positioned(
      top: (widget.data.pos.dy - widget.offset.dy) * widget.scale,
      left: (widget.data.pos.dx - widget.offset.dx) * widget.scale,
      child: Stack(
        children: [
          if (!dragged)
            IgnorePointer(
              ignoring: true,
              child: shadow,
            ),
          LongPressDraggable(
            child: content,
            childWhenDragging: Opacity(
              opacity: 0.5,
              child: content,
            ),
            feedback: Material(
              color: Colors.transparent,
              child: Stack(
                children: [
                  shadow,
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
              widget.onModified
                  ?.call((context.findRenderObject() as RenderBox).globalToLocal(details.offset) / widget.scale + widget.data.pos);
            },
          ),
        ],
      ),
    );
  }

  static Size _getTextSize(String text, TextStyle style,
      {double minWidth = 0.0, double maxWidth = double.infinity}) {
    final TextPainter textPainter = TextPainter(
        text: TextSpan(text: text, style: style),
        maxLines: 1,
        textDirection: TextDirection.ltr)
      ..layout(minWidth: minWidth, maxWidth: maxWidth);
    return textPainter.size;
  }

  Size _getSelfSize() {
    final Size titleSize =
        _getTextSize(widget.data.title, _titleStyle, minWidth: 28);
    final Size descSize = _getTextSize(widget.data.description, _descStyle);

    if (widget.data.description.isNotEmpty) {
      return Size(8 + titleSize.width + 8 + 8 + descSize.width + 12,
          24 + max(titleSize.height, descSize.height) + 24);
    } else {
      return Size(8 + titleSize.width + 8, 24 + titleSize.height + 24);
    }
  }
}
