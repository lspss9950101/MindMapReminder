import 'dart:math';

import 'package:flutter/material.dart';
import 'consumer.dart';
import 'mind_map_configuration.dart';
import 'scale_offset.dart';
import 'mind_map.dart';
import 'styles.dart';
import 'utilities.dart';

////////////////////////////////////////////////////
// MindMapNodeDisplay
// StatefulWidget
////////////////////////////////////////////////////

class _NodeDisplayContent extends StatefulWidget {
  final String title;
  final String description;
  final Color color;
  final bool darkText;
  final Size renderSize;
  final double scale;

  const _NodeDisplayContent(
      {required this.title,
      required this.description,
      required this.color,
      required this.darkText,
      required this.renderSize,
      required this.scale,
      Key? key})
      : super(key: key);

  @override
  _NodeDisplayContentState createState() => _NodeDisplayContentState();
}

class _NodeDisplayContentState extends State<_NodeDisplayContent>
    with TickerProviderStateMixin {
  late final AnimationController _colorAnimationController;
  late final AnimationController _textAnimationController;
  late final Animation<Color?> _colorAnimation;
  late final Animation<Color?> _textAnimation;
  late final ColorTween _colorTween;
  late final ColorTween _textTween;

  @override
  void initState() {
    super.initState();
    _colorTween = ColorTween(begin: widget.color, end: widget.color);
    _colorAnimationController = AnimationController(
        duration: const Duration(milliseconds: 500), value: 0, vsync: this);
    _colorAnimation = _colorTween.animate(_colorAnimationController)
      ..addListener(() {
        setState(() {});
      });

    Color c = widget.darkText
        ? customStyle[CustomStyle.textColorDark]
        : customStyle[CustomStyle.textColorLight];
    _textTween = ColorTween(begin: c, end: c);
    _textAnimationController = AnimationController(
        duration: const Duration(milliseconds: 500), value: 0.0, vsync: this);
    _textAnimation = _textTween.animate(_textAnimationController)
      ..addListener(() {
        setState(() {});
      });
  }

  @override
  void didUpdateWidget(_NodeDisplayContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    _colorTween.begin = oldWidget.color;
    _colorTween.end = widget.color;
    _colorAnimationController.forward(from: 0);

    _textTween.begin = _textTween.end;
    _textTween.end = widget.darkText
        ? customStyle[CustomStyle.textColorDark]
        : customStyle[CustomStyle.textColorLight];
    _textAnimationController.forward(from: 0);
  }

  @override
  void dispose() {
    _colorAnimationController.dispose();
    _textAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.renderSize.width,
      height: widget.renderSize.height,
      transform: Matrix4.identity()..scale(widget.scale),
      color: _colorAnimation.value,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Container(
              alignment: Alignment.center,
              width: getTextSize(widget.title,
                      customStyle[CustomStyle.mindMapNodeDisplayTitleStyle],
                      minWidth: 28)
                  .width,
              child: Text(
                widget.title,
                style: customStyle[CustomStyle.mindMapNodeDisplayTitleStyle]
                    .apply(color: _textAnimation.value),
              ),
            ),
          ),
          if (widget.description.isNotEmpty)
            Stack(
              alignment: Alignment.centerLeft,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8, right: 12),
                  child: Text(widget.description,
                      style: customStyle[
                              CustomStyle.mindMapNodeDisplayDescriptionStyle]
                          .apply(color: _textAnimation.value)),
                ),
                Container(
                  width: 24,
                  height: widget.renderSize.height,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        Colors.black26,
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _NodeDisplayShadow extends StatelessWidget {
  final Size renderSize;
  final double scale;

  const _NodeDisplayShadow(
      {required this.renderSize, required this.scale, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double renderSizeLength = sqrt(renderSize.width * renderSize.width +
        renderSize.height * renderSize.height);
    final double shadowLength = renderSizeLength * 0.7;
    final double cos = renderSize.width / renderSizeLength;
    final double sin = renderSize.height / renderSizeLength;
    final double theta = acos(cos);

    final Size shadowSize = Size(
        renderSizeLength, shadowLength * (cos * 0.5 + sin * sqrt(3) * 0.5));

    return Transform(
      transform: Matrix4.identity()
        ..scale(scale)
        ..translate(0.0, renderSize.height)
        ..rotateZ(-theta),
      child: Container(
        transform: Matrix4.skewX(pi / 3 - theta),
        width: shadowSize.width,
        height: shadowSize.height,
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

class _NodeDisplayDraggable extends StatefulWidget {
  final MindMapNode mindMapNode;

  const _NodeDisplayDraggable(this.mindMapNode, {Key? key}) : super(key: key);

  @override
  _NodeDisplayDraggableState createState() => _NodeDisplayDraggableState();
}

class _NodeDisplayDraggableState extends State<_NodeDisplayDraggable> {
  bool dragged = false;

  @override
  Widget build(BuildContext context) {
    final CanvasScaleOffsetProvider canvasScaleOffsetProvider =
        CanvasScaleOffsetProvider.of(context, CanvasScaleOffsetAspect.static);
    /*final Widget content = _NodeDisplayContent(
      title: widget.mindMapNode.title,
      description: widget.mindMapNode.description,
      color: widget.mindMapNode.color,
      darkText: widget.mindMapNode.darkText,
      renderSize: renderSize,
      scale: canvasScaleOffsetProvider.staticScale,
    );*/
    /*final Widget shadow = _NodeDisplayShadow(
      renderSize: renderSize,
      scale: canvasScaleOffsetProvider.staticScale,
    );*/
    final Widget content = MindMapNodeCanvas(mindMapNode: widget.mindMapNode,);
    final Widget shadow =
        MindMapNodeShadowCanvas(mindMapNode: widget.mindMapNode);
    return Stack(
      children: [
        if (!dragged)
          IgnorePointer(
            ignoring: true,
            child: shadow,
          ),
        LongPressDraggable(
          data: widget.mindMapNode.id,
          child: GestureDetector(
            onTap: () {
              MindMapAuxiliary mindMapAuxiliary =
                  MindMapAuxiliaryProvider.independentOf(context);
              if (mindMapAuxiliary.operationMode == OperationMode.nodeEdition) {
                showPopModal<MindMapNode>(
                  minHeight: 112,
                  maxHeight: 484,
                  initHeight: 112,
                  context: context,
                  child: MindMapNodeConfigurationPanel(
                    mindMapNode: widget.mindMapNode,
                    onAccepted: (MindMapNode mindMapNode) {
                      Navigator.of(context).pop(mindMapNode);
                    },
                    onCancelled: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ).then((MindMapNode? mindMapNode) {
                  if (mindMapNode != null) {
                    widget.mindMapNode.update(
                      title: mindMapNode.title,
                      description: mindMapNode.description,
                      color: mindMapNode.color,
                      darkText: mindMapNode.darkText,
                    );
                  }
                });
              } else if (mindMapAuxiliary.operationMode ==
                  OperationMode.nodeSelection) {
                mindMapAuxiliary.selectNode(widget.mindMapNode.id);
              } else if (mindMapAuxiliary.operationMode ==
                  OperationMode.edgeAddition) {
                mindMapAuxiliary.selectNode(widget.mindMapNode.id, max: 2);
              }
            },
            child: Stack(
              children: [
                /*SizedBox(
                  width:
                      renderSize.width * canvasScaleOffsetProvider.staticScale,
                  height:
                      renderSize.height * canvasScaleOffsetProvider.staticScale,
                ),*/
                content,
              ],
            ),
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
                    ..scale(canvasScaleOffsetProvider.staticScale),
                  child: Container(/*
                    width: renderSize.width,
                    height: renderSize.height,*/
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black38,
                          offset: Offset(sqrt(3) * 2, 4),
                          blurRadius: 4,
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                  ),
                ),
                content
              ],
            ),
          ),
          onDragStarted: () {
            setState(() {
              dragged = true;
              MindMapAuxiliaryProvider.independentOf(context)
                  .update(operationMode: OperationMode.nodeDeletion);
            });
          },
          onDragEnd: (DraggableDetails details) {
            MindMapAuxiliary mindMapAuxiliary =
                MindMapAuxiliaryProvider.independentOf(context);
            Offset newPosition = widget.mindMapNode.position +
                (context.findRenderObject() as RenderBox)
                        .globalToLocal(details.offset) /
                    canvasScaleOffsetProvider.staticScale;
            int snapping =
                MindMapAuxiliary.snappingLabel[mindMapAuxiliary.snapping] * 30;
            if (snapping > 0) {
              newPosition = Offset(
                  (newPosition.dx / snapping).round().toDouble() * snapping,
                  (newPosition.dy / snapping).round().toDouble() * snapping);
            }
            print(newPosition);
            widget.mindMapNode.update(position: newPosition);
            dragged = false;
            MindMapAuxiliaryProvider.independentOf(context)
                .update(operationMode: OperationMode.nodeEdition);
          },
        ),
      ],
    );
  }
}

class MindMapNodeDisplay extends StatelessWidget {
  final NodeId nodeId;

  const MindMapNodeDisplay(this.nodeId) : super(key: nodeId);

  @override
  Widget build(BuildContext context) {
    final MindMapNode mindMapNode =
        MindMapGraphProvider.nodeOf(context, nodeId);

    return Consumer<MindMapNode>(
      data: mindMapNode,
      builder: (BuildContext innerContext) {
        final CanvasScaleOffsetProvider canvasScaleOffsetProvider =
            CanvasScaleOffsetProvider.of(
                innerContext, CanvasScaleOffsetAspect.static);
        return Positioned(
          left: (mindMapNode.position.dx -
                  canvasScaleOffsetProvider.staticOffset.dx) *
              canvasScaleOffsetProvider.staticScale,
          top: (mindMapNode.position.dy -
                  canvasScaleOffsetProvider.staticOffset.dy) *
              canvasScaleOffsetProvider.staticScale,
          child: _NodeDisplayDraggable(mindMapNode),
        );
      },
    );
  }
}

////////////////////////////////////////////////////
// MindMapEdgeDisplay
// StatelessWidget
////////////////////////////////////////////////////

class _MindMapEdgeDisplayPainter extends CustomPainter {
  final MindMapEdgeSet edgeSet;
  final BuildContext context;

  const _MindMapEdgeDisplayPainter(
      {required this.edgeSet, required this.context});

  List<AxisDirection> determineAnchor(
      Offset fromPosition,
      Offset toPosition,
      Size fromSize,
      Size toSize,
      Map<AxisDirection, Offset> fromAnchor,
      Map<AxisDirection, Offset> toAnchor) {
    Offset temp;
    temp = toAnchor[AxisDirection.down]! - fromAnchor[AxisDirection.up]!;
    if (temp.dx - temp.dy > 0 && temp.dx + temp.dy < 0) {
      return [AxisDirection.up, AxisDirection.down];
    }
    temp = toAnchor[AxisDirection.up]! - fromAnchor[AxisDirection.down]!;
    if (temp.dx + temp.dy > 0 && temp.dx - temp.dy < 0) {
      return [AxisDirection.down, AxisDirection.up];
    }
    temp = toAnchor[AxisDirection.right]! - fromAnchor[AxisDirection.left]!;
    if (temp.dx - temp.dy < 0 && temp.dx + temp.dy < 0) {
      return [AxisDirection.left, AxisDirection.right];
    }
    temp = toAnchor[AxisDirection.left]! - fromAnchor[AxisDirection.right]!;
    if (temp.dx + temp.dy > 0 && temp.dx - temp.dy > 0) {
      return [AxisDirection.right, AxisDirection.left];
    }

    bool insideH, insideV;

    {
      // topLeft
      insideH = toAnchor[AxisDirection.right]!.dx <=
              fromAnchor[AxisDirection.up]!.dx &&
          toAnchor[AxisDirection.right]!.dy <=
              fromAnchor[AxisDirection.left]!.dy;
      temp = toAnchor[AxisDirection.right]! - fromAnchor[AxisDirection.up]!;
      insideH &= temp.dx - temp.dy <= 0;
      temp = toAnchor[AxisDirection.right]! - fromAnchor[AxisDirection.left]!;
      insideH &= temp.dx - temp.dy >= 0;

      insideV = toAnchor[AxisDirection.down]!.dx <=
              fromAnchor[AxisDirection.up]!.dx &&
          toAnchor[AxisDirection.down]!.dy <=
              fromAnchor[AxisDirection.left]!.dy;
      temp = toAnchor[AxisDirection.down]! - fromAnchor[AxisDirection.up]!;
      insideV &= temp.dx - temp.dy <= 0;
      temp = toAnchor[AxisDirection.down]! - fromAnchor[AxisDirection.left]!;
      insideV &= temp.dx - temp.dy >= 0;
      if (insideH && !insideV) {
        return [AxisDirection.up, AxisDirection.right];
      }
      if (!insideH && insideV) {
        return [AxisDirection.left, AxisDirection.down];
      }
      if (insideH && insideH) {
        Offset delta = toPosition +
            Offset(toSize.width * 0.5, toSize.height * 0.5) -
            (fromPosition +
                Offset(fromSize.width * 0.5, fromSize.height * 0.5));
        return delta.dx.abs() > delta.dy.abs()
            ? [AxisDirection.left, AxisDirection.down]
            : [AxisDirection.up, AxisDirection.right];
      }
    }
    {
      // topRight
      insideH = toAnchor[AxisDirection.left]!.dx >=
              fromAnchor[AxisDirection.up]!.dx &&
          toAnchor[AxisDirection.left]!.dy <=
              fromAnchor[AxisDirection.right]!.dy;
      temp = toAnchor[AxisDirection.left]! - fromAnchor[AxisDirection.up]!;
      insideH &= temp.dx + temp.dy >= 0;
      temp = toAnchor[AxisDirection.left]! - fromAnchor[AxisDirection.right]!;
      insideH &= temp.dx + temp.dy <= 0;

      insideV = toAnchor[AxisDirection.down]!.dx <=
              fromAnchor[AxisDirection.up]!.dx &&
          toAnchor[AxisDirection.down]!.dy <=
              fromAnchor[AxisDirection.right]!.dy;
      temp = toAnchor[AxisDirection.down]! - fromAnchor[AxisDirection.up]!;
      insideV &= temp.dx + temp.dy >= 0;
      temp = toAnchor[AxisDirection.down]! - fromAnchor[AxisDirection.right]!;
      insideV &= temp.dx + temp.dy <= 0;
      if (insideH && !insideV) {
        return [AxisDirection.up, AxisDirection.left];
      }
      if (!insideH && insideV) {
        return [AxisDirection.right, AxisDirection.down];
      }
      if (insideH && insideH) {
        Offset delta = toPosition +
            Offset(toSize.width * 0.5, toSize.height * 0.5) -
            (fromPosition +
                Offset(fromSize.width * 0.5, fromSize.height * 0.5));
        return delta.dx.abs() > delta.dy.abs()
            ? [AxisDirection.right, AxisDirection.down]
            : [AxisDirection.up, AxisDirection.left];
      }
    }
    {
      // bottomLeft
      insideH = toAnchor[AxisDirection.right]!.dx <=
              fromAnchor[AxisDirection.down]!.dx &&
          toAnchor[AxisDirection.right]!.dy >=
              fromAnchor[AxisDirection.left]!.dy;
      temp = toAnchor[AxisDirection.right]! - fromAnchor[AxisDirection.down]!;
      insideH &= temp.dx + temp.dy <= 0;
      temp = toAnchor[AxisDirection.right]! - fromAnchor[AxisDirection.left]!;
      insideH &= temp.dx + temp.dy >= 0;

      insideV = toAnchor[AxisDirection.up]!.dx <=
              fromAnchor[AxisDirection.down]!.dx &&
          toAnchor[AxisDirection.up]!.dy >= fromAnchor[AxisDirection.left]!.dy;
      temp = toAnchor[AxisDirection.up]! - fromAnchor[AxisDirection.down]!;
      insideV &= temp.dx + temp.dy <= 0;
      temp = toAnchor[AxisDirection.up]! - fromAnchor[AxisDirection.left]!;
      insideV &= temp.dx + temp.dy >= 0;
      if (insideH && !insideV) {
        return [AxisDirection.down, AxisDirection.right];
      }
      if (!insideH && insideV) {
        return [AxisDirection.left, AxisDirection.up];
      }
      if (insideH && insideH) {
        Offset delta = toPosition +
            Offset(toSize.width * 0.5, toSize.height * 0.5) -
            (fromPosition +
                Offset(fromSize.width * 0.5, fromSize.height * 0.5));
        return delta.dx.abs() > delta.dy.abs()
            ? [AxisDirection.left, AxisDirection.up]
            : [AxisDirection.down, AxisDirection.right];
      }
    }
    {
      // bottomRight
      insideH = toAnchor[AxisDirection.left]!.dx >=
              fromAnchor[AxisDirection.down]!.dx &&
          toAnchor[AxisDirection.left]!.dy >=
              fromAnchor[AxisDirection.right]!.dy;
      temp = toAnchor[AxisDirection.left]! - fromAnchor[AxisDirection.down]!;
      insideH &= temp.dx - temp.dy >= 0;
      temp = toAnchor[AxisDirection.left]! - fromAnchor[AxisDirection.right]!;
      insideH &= temp.dx - temp.dy <= 0;

      insideV = toAnchor[AxisDirection.up]!.dx >=
              fromAnchor[AxisDirection.down]!.dx &&
          toAnchor[AxisDirection.up]!.dy >= fromAnchor[AxisDirection.right]!.dy;
      temp = toAnchor[AxisDirection.up]! - fromAnchor[AxisDirection.down]!;
      insideV &= temp.dx - temp.dy >= 0;
      temp = toAnchor[AxisDirection.up]! - fromAnchor[AxisDirection.right]!;
      insideV &= temp.dx - temp.dy <= 0;
      if (insideH && !insideV) {
        return [AxisDirection.down, AxisDirection.left];
      }
      if (!insideH && insideV) {
        return [AxisDirection.right, AxisDirection.up];
      }
      if (insideH && insideH) {
        Offset delta = toPosition +
            Offset(toSize.width * 0.5, toSize.height * 0.5) -
            (fromPosition +
                Offset(fromSize.width * 0.5, fromSize.height * 0.5));
        return delta.dx.abs() > delta.dy.abs()
            ? [AxisDirection.right, AxisDirection.up]
            : [AxisDirection.down, AxisDirection.left];
      }
    }

    if (fromPosition.dy + fromSize.height * 0.5 >
        toPosition.dy + toSize.height * 0.5) {
      if (fromPosition.dx + fromSize.width * 0.5 >
          toPosition.dx + toSize.width * 0.5) {
        return [AxisDirection.up, AxisDirection.right];
      } else {
        return [AxisDirection.up, AxisDirection.left];
      }
    } else {
      if (fromPosition.dx + fromSize.width * 0.5 >
          toPosition.dx + toSize.width * 0.5) {
        return [AxisDirection.down, AxisDirection.right];
      } else {
        return [AxisDirection.down, AxisDirection.left];
      }
    }
  }

  void paintEdge(Canvas canvas, Size size, Paint paint,
      CanvasScaleOffsetProvider canvasScaleOffsetProvider, MindMapEdge edge) {
    MindMapNode from = MindMapGraphProvider.nodeOf(context, edge.from);
    MindMapNode to = MindMapGraphProvider.nodeOf(context, edge.to);
    Size fromSize = from.totalSize;
    Size toSize = to.totalSize;
    Map<AxisDirection, Offset> fromAnchor = {
      AxisDirection.up: from.position + Offset(fromSize.width * 0.5, 0),
      AxisDirection.down:
          from.position + Offset(fromSize.width * 0.5, fromSize.height),
      AxisDirection.left: from.position + Offset(0, fromSize.height * 0.5),
      AxisDirection.right:
          from.position + Offset(fromSize.width, fromSize.height * 0.5),
    };
    Map<AxisDirection, Offset> toAnchor = {
      AxisDirection.up: to.position + Offset(toSize.width * 0.5, 0),
      AxisDirection.down:
          to.position + Offset(toSize.width * 0.5, toSize.height),
      AxisDirection.left: to.position + Offset(0, toSize.height * 0.5),
      AxisDirection.right:
          to.position + Offset(toSize.width, toSize.height * 0.5),
    };
    List<AxisDirection> direction = determineAnchor(
        from.position, to.position, fromSize, toSize, fromAnchor, toAnchor);
    Offset begin =
        (fromAnchor[direction[0]]! - canvasScaleOffsetProvider.staticOffset) *
            canvasScaleOffsetProvider.staticScale;
    Offset end =
        (toAnchor[direction[1]]! - canvasScaleOffsetProvider.staticOffset) *
            canvasScaleOffsetProvider.staticScale;
    Offset delta = end - begin;
    Offset mid = delta.dx.abs() > delta.dy.abs()
        ? Offset(delta.dx.sign * delta.dy.abs(), delta.dy)
        : Offset(delta.dx, delta.dy.sign * delta.dx.abs());
    mid += begin;
    Path path = Path()
      ..moveTo(begin.dx, begin.dy)
      ..lineTo(mid.dx, mid.dy)
      ..lineTo(end.dx, end.dy);
    canvas.drawPath(
        path,
        paint
          ..color = customStyle[CustomStyle.textColorLightGrey]
          ..style = PaintingStyle.stroke
          ..strokeJoin = StrokeJoin.round);

    paint.style = PaintingStyle.fill;
    canvas.drawCircle(begin, 4 * canvasScaleOffsetProvider.staticScale,
        paint..color = MindMapGraphProvider.nodeOf(context, edge.from).color);
    canvas.drawCircle(end, 4 * canvasScaleOffsetProvider.staticScale,
        paint..color = MindMapGraphProvider.nodeOf(context, edge.to).color);
  }

  @override
  void paint(Canvas canvas, Size size) {
    CanvasScaleOffsetProvider canvasScaleOffsetProvider =
        CanvasScaleOffsetProvider.of(context, CanvasScaleOffsetAspect.all);
    Paint paint = Paint()
      ..strokeWidth = 4 * canvasScaleOffsetProvider.staticScale;
    for (MindMapEdge edge in edgeSet.edges) {
      paintEdge(canvas, size, paint, canvasScaleOffsetProvider, edge);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }

  @override
  bool? hitTest(Offset position) => false;
}

class MindMapEdgeDisplay extends StatelessWidget {
  final MindMapEdgeSet edgeSet;

  const MindMapEdgeDisplay({required this.edgeSet, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: CustomPaint(
        painter: _MindMapEdgeDisplayPainter(context: context, edgeSet: edgeSet),
      ),
    );
  }
}

////////////////////////////////////////////////////
// MindMapNodeMainCanvas
// StatelessWidget
////////////////////////////////////////////////////

class _MindMapNodeMainCanvasPainter extends CustomPainter {
  final String title;
  final String description;
  final Color backgroundColor;
  final Size titleSize;
  final Size descriptionSize;
  final Color titleColor;
  final Color descriptionColor;

  const _MindMapNodeMainCanvasPainter({
    required this.title,
    required this.description,
    required this.backgroundColor,
    required this.titleSize,
    required this.descriptionSize,
    required this.titleColor,
    required this.descriptionColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Size totalSize = Size(titleSize.width + descriptionSize.width,
        max(titleSize.height, descriptionSize.height));

    Paint paint = Paint()..color = backgroundColor;
    canvas.drawRect(
        Rect.fromLTWH(0, 0, totalSize.width, totalSize.height), paint);
    TextPainter textPainter =
        TextPainter(maxLines: 1, textDirection: TextDirection.ltr);
    textPainter.text = TextSpan(
        text: title,
        style: customStyle[CustomStyle.mindMapNodeDisplayTitleStyle]
            ?.apply(color: titleColor));
    textPainter.layout();
    textPainter.paint(canvas, const Offset(8, 24));

    textPainter.text = TextSpan(
        text: description,
        style: customStyle[CustomStyle.mindMapNodeDisplayDescriptionStyle]
            ?.apply(color: descriptionColor));
    textPainter.layout();
    textPainter.paint(
        canvas,
        Offset(titleSize.width + 8,
            totalSize.height / 2 - textPainter.height / 2));

    Rect r = Rect.fromLTWH(titleSize.width, 0, 24, totalSize.height);
    paint.shader = const LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [
        Colors.black26,
        Colors.transparent,
      ],
    ).createShader(r);
    canvas.drawRect(r, paint);
  }

  @override
  bool shouldRepaint(_MindMapNodeMainCanvasPainter oldDelegate) => true;
}

class MindMapNodeCanvas extends StatefulWidget {
  final MindMapNode mindMapNode;

  const MindMapNodeCanvas({required this.mindMapNode, Key? key})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _MindMapNodeCanvasState();
}

class _MindMapNodeCanvasState extends State<MindMapNodeCanvas>
    with TickerProviderStateMixin {
  late String _title;
  late String _description;
  late Color _backgroundColor;
  late bool _darkText;
  late Size _titleSize;
  late Size _descriptionSize;

  late final AnimationController _backgroundColorAnimationController;
  late ColorTween _backgroundColorTween;
  late Animation<Color?> _backgroundColorAnimation;

  late final AnimationController _textColorAnimationController;
  late ColorTween _textColorTween;
  late Animation<Color?> _textColorAnimation;

  late final AnimationController _textSizeAnimationController;
  late Tween<double> _textSizeTween;
  late Animation<double?> _textSizeAnimation;

  bool _backgroundColorAnimationDone = true;
  bool _textColorAnimationDone = true;
  bool get _titleChanged =>
      _darkText != widget.mindMapNode.darkText ||
      _title != widget.mindMapNode.title;
  bool get _descriptionChanged =>
      _darkText != widget.mindMapNode.darkText ||
      _description != widget.mindMapNode.description;

  Color getTextColor(bool dark) => dark
      ? customStyle[CustomStyle.textColorDark]!
      : customStyle[CustomStyle.textColorLight]!;

  void update() {
    bool animationStarted = false;
    if (widget.mindMapNode.color != _backgroundColor) {
      _backgroundColorTween.end = widget.mindMapNode.color;
      _backgroundColorAnimationDone = false;
      _backgroundColorAnimationController.forward();
      animationStarted = true;
    }
    if (_titleChanged || _descriptionChanged) {
      _textColorAnimationController.forward();
      _textColorAnimationDone = false;
      animationStarted = true;
    }
    if(animationStarted) {
      keepUpdating();
    }
  }

  void keepUpdating() {
    setState(() {
      if(!_backgroundColorAnimationDone || !_textColorAnimationDone) {
        Future.delayed(const Duration(milliseconds: 40), keepUpdating);
      }
    });
  }

  void _setupAnimation() {
    _backgroundColorAnimationController = AnimationController(
        duration: const Duration(milliseconds: 250), vsync: this);
    _textColorAnimationController = AnimationController(
        duration: const Duration(milliseconds: 200), vsync: this);
    _textSizeAnimationController = AnimationController(
        duration: const Duration(milliseconds: 100), vsync: this);

    final Color textColor = getTextColor(_darkText);
    _backgroundColorTween =
        ColorTween(begin: _backgroundColor, end: _backgroundColor);
    _textColorTween = ColorTween(begin: textColor, end: textColor.withAlpha(0));
    _textSizeTween = Tween<double>(begin: 0, end: 1);

    _backgroundColorAnimation = _backgroundColorTween.animate(CurvedAnimation(
        parent: _backgroundColorAnimationController, curve: Curves.easeInOut));
    _textColorAnimation = _textColorTween.animate(CurvedAnimation(
        parent: _textColorAnimationController, curve: Curves.easeInOut));
    _textSizeAnimation = _textSizeTween.animate(CurvedAnimation(
        parent: _textSizeAnimationController, curve: Curves.easeInOut));

    _backgroundColorAnimationController
        .addStatusListener((AnimationStatus status) {
      if (AnimationStatus.completed == status) {
        _backgroundColor = widget.mindMapNode.color;
        _backgroundColorTween.begin = _backgroundColor;
        _backgroundColorAnimationController.reset();
        _backgroundColorAnimationDone = true;
      }
    });
    _textColorAnimationController.addStatusListener((AnimationStatus status) {
      if (AnimationStatus.completed == status) {
        _darkText = widget.mindMapNode.darkText;
        final Color textColor = getTextColor(_darkText);
        _textColorTween.begin = textColor;
        _textColorTween.end = textColor.withAlpha(0);
        if (_title == widget.mindMapNode.title &&
            _description == widget.mindMapNode.description) {
          _textColorAnimationController.reverse();
        } else {
          _textSizeAnimationController.forward(from: 0);
        }
      } else if (AnimationStatus.dismissed == status) {
        _textColorAnimationDone = true;
      }
    });
    _textSizeAnimationController.addStatusListener((AnimationStatus status) {
      if (AnimationStatus.completed == status) {
        _textColorAnimationController.reverse();
        _title = widget.mindMapNode.title;
        _titleSize = widget.mindMapNode.titleSize;
        _description = widget.mindMapNode.description;
        _descriptionSize = widget.mindMapNode.descriptionSize;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    widget.mindMapNode.addListener(update);
    _title = widget.mindMapNode.title;
    _description = widget.mindMapNode.description;
    _backgroundColor = widget.mindMapNode.color;
    _darkText = widget.mindMapNode.darkText;
    _titleSize = widget.mindMapNode.titleSize;
    _descriptionSize = widget.mindMapNode.descriptionSize;
    _setupAnimation();
  }

  @override
  void didUpdateWidget(covariant MindMapNodeCanvas oldWidget) {
    oldWidget.mindMapNode.removeListener(update);
    widget.mindMapNode.addListener(update);
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    widget.mindMapNode.removeListener(update);

    _backgroundColorAnimationController.dispose();
    _textColorAnimationController.dispose();
    _textSizeAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _MindMapNodeShadowCanvasPainter(mindMapNode: widget.mindMapNode),
      child: CustomPaint(
        size: widget.mindMapNode.totalSize,
        painter: _MindMapNodeMainCanvasPainter(
          title: _title,
          description: _description,
          backgroundColor: _backgroundColorAnimation.value!,
          titleSize: Size.lerp(_titleSize, widget.mindMapNode.titleSize,
              1-_textSizeAnimation.value!)!,
          descriptionSize: Size.lerp(_descriptionSize,
              widget.mindMapNode.descriptionSize, 1-_textSizeAnimation.value!)!,
          titleColor: _titleChanged
              ? _textColorAnimation.value!
              : getTextColor(_darkText),
          descriptionColor: _descriptionChanged
              ? _textColorAnimation.value!
              : getTextColor(_darkText),
        ),
      ),
    );
  }
}

////////////////////////////////////////////////////
// MindMapNodeShadowCanvas
// StatelessWidget
////////////////////////////////////////////////////

class _MindMapNodeShadowCanvasPainter extends CustomPainter {
  final MindMapNode mindMapNode;

  const _MindMapNodeShadowCanvasPainter({required this.mindMapNode});

  @override
  void paint(Canvas canvas, Size size) {
    final Size size = mindMapNode.totalSize;
    final double len = Offset(size.width, size.height).distance;
    final double cos = size.width / len;
    final double sin = size.height / len;
    final double theta = acos(cos);
    final Size shadowSize = Size(len, 140 * (cos * 0.5 + sin * sqrt(3) * 0.5));

    canvas.translate(0, size.height);
    canvas.rotate(-theta);
    canvas.skew(tan(pi / 3 - theta), 0);

    Paint paint = Paint()
      ..style = PaintingStyle.fill
      ..shader = const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.black12, Colors.transparent])
          .createShader(
              Rect.fromLTWH(0, 0, shadowSize.width, shadowSize.height));
    canvas.drawRect(
        Rect.fromLTWH(0, 0, shadowSize.width, shadowSize.height), paint);
  }

  @override
  bool shouldRepaint(covariant _MindMapNodeShadowCanvasPainter oldDelegate) =>
      false;
}

class MindMapNodeShadowCanvas extends StatelessWidget {
  final MindMapNode mindMapNode;

  const MindMapNodeShadowCanvas({required this.mindMapNode, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _MindMapNodeShadowCanvasPainter(mindMapNode: mindMapNode),
      size: mindMapNode.totalSize,
    );
  }
}
