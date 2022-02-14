import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'mind_map_display.dart';
import 'button.dart';
import 'utilities.dart';
import 'mind_map.dart';
import 'styles.dart';

////////////////////////////////////////////////////
// MindMapNodeConfigurationPanel
// StatefulWidget
////////////////////////////////////////////////////

class MindMapNodeConfigurationPanel extends StatefulWidget {
  final MindMapNode mindMapNode;
  final void Function() onCancelled;
  final void Function(MindMapNode) onAccepted;

  const MindMapNodeConfigurationPanel(
      {required this.mindMapNode,
      required this.onAccepted,
      required this.onCancelled,
      Key? key})
      : super(key: key);

  @override
  _MindMapNodeConfigurationPanelState createState() =>
      _MindMapNodeConfigurationPanelState();
}

class _MindMapNodeConfigurationPanelState
    extends State<MindMapNodeConfigurationPanel> with TickerProviderStateMixin {
  late MindMapNode _mindMapNode;
  late final TextEditingController _titleTextEditingController;
  late final TextEditingController _descriptionTextEditingController;
  late final AnimationController _colorAnimationController;
  late final AnimationController _textAnimationController;
  late final Animation<Color?> _colorAnimation;
  late final Animation<Color?> _textAnimation;
  late ColorTween _colorTween;
  late ColorTween _textTween;

  late final FocusNode _titleTextEditingFocusNode;
  late final FocusNode _descriptionTextEditingFocusNode;

  @override
  void initState() {
    super.initState();
    _mindMapNode = MindMapNode.from(widget.mindMapNode);
    _titleTextEditingController = TextEditingController();
    _titleTextEditingController.text = _mindMapNode.title;
    _descriptionTextEditingController = TextEditingController();
    _descriptionTextEditingController.text = _mindMapNode.description;

    _colorTween =
        ColorTween(begin: _mindMapNode.color, end: _mindMapNode.color);
    _colorAnimationController = AnimationController(
        duration: const Duration(milliseconds: 750), value: 0.0, vsync: this);
    _colorAnimation = _colorTween.animate(_colorAnimationController)
      ..addListener(() {
        setState(() {});
      });

    Color c = _mindMapNode.darkText
        ? customStyle[CustomStyle.textColorDark]
        : customStyle[CustomStyle.textColorLight];
    _textTween = ColorTween(begin: c, end: c);
    _textAnimationController = AnimationController(
        duration: const Duration(milliseconds: 500), value: 0.0, vsync: this);
    _textAnimation = _textTween.animate(_textAnimationController)
      ..addListener(() {
        setState(() {});
      });

    _mindMapNode.addListener(() {
      _colorTween.begin = _colorTween.end;
      _colorTween.end = _mindMapNode.color;
      _colorAnimationController.forward(from: 0);

      _textTween.begin = _textTween.end;
      _textTween.end = _mindMapNode.darkText
          ? customStyle[CustomStyle.textColorDark]
          : customStyle[CustomStyle.textColorLight];
      _textAnimationController.forward(from: 0);
    });

    _titleTextEditingFocusNode = FocusNode()
      ..addListener(() {
        setState(() {});
      });
    _descriptionTextEditingFocusNode = FocusNode()
      ..addListener(() {
        setState(() {});
      });
  }

  @override
  void dispose() {
    _titleTextEditingController.dispose();
    _descriptionTextEditingController.dispose();
    _colorAnimationController.dispose();
    _textAnimationController.dispose();
    _titleTextEditingFocusNode.dispose();
    _descriptionTextEditingFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: GradientCupertinoButton(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        Colors.teal.shade400,
                        Colors.lightGreen.shade400
                      ],
                    ),
                    child: Text(
                      "OK",
                      style: customStyle[
                              CustomStyle.bottomSheetButtonTextStyleLight]
                          ?.apply(color: Colors.white),
                    ),
                    onPressed: () {
                      _mindMapNode.update(
                        title: _titleTextEditingController.text,
                        description: _descriptionTextEditingController.text,
                      );
                      widget.onAccepted(_mindMapNode);
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Expanded(
                  child: TextField(
                focusNode: _titleTextEditingFocusNode,
                style: customStyle[CustomStyle.bottomSheetTextFieldStyle],
                decoration: InputDecoration(
                  labelText: "Title",
                  border: customStyle[CustomStyle.bottomSheetInputBorderStyle],
                  focusedBorder: customStyle[
                      CustomStyle.bottomSheetFocusedInputBorderStyle],
                  labelStyle: _titleTextEditingFocusNode.hasFocus
                      ? customStyle[
                          CustomStyle.bottomSheetFocusedInputLabelStyle]
                      : customStyle[CustomStyle.bottomSheetInputLabelStyle],
                ),
                controller: _titleTextEditingController,
              )),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Expanded(
                  child: TextField(
                focusNode: _descriptionTextEditingFocusNode,
                style: customStyle[CustomStyle.bottomSheetTextFieldStyle],
                decoration: InputDecoration(
                  labelText: "Description",
                  border: customStyle[CustomStyle.bottomSheetInputBorderStyle],
                  focusedBorder: customStyle[
                      CustomStyle.bottomSheetFocusedInputBorderStyle],
                  labelStyle: _descriptionTextEditingFocusNode.hasFocus
                      ? customStyle[
                          CustomStyle.bottomSheetFocusedInputLabelStyle]
                      : customStyle[CustomStyle.bottomSheetInputLabelStyle],
                ),
                controller: _descriptionTextEditingController,
              )),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: InputDecorator(
                  decoration: InputDecoration(
                      labelText: "Dark Text",
                      border:
                          customStyle[CustomStyle.bottomSheetInputBorderStyle]),
                  child: Row(
                    children: [
                      Expanded(
                        child: NeumorphismButton(
                          height: 48,
                          borderRadius: BorderRadius.circular(8),
                          padding: const EdgeInsets.only(right: 8),
                          onPressed: () {
                            _mindMapNode.update(darkText: true);
                            _titleTextEditingFocusNode.unfocus();
                            _descriptionTextEditingFocusNode.unfocus();
                          },
                          pressed: _mindMapNode.darkText,
                          color: Colors.grey.shade50,
                          child: Text(
                            "Dark",
                            style: customStyle[
                                CustomStyle.bottomSheetButtonTextStyleDark],
                          ),
                        ),
                      ),
                      Expanded(
                        child: NeumorphismButton(
                          height: 48,
                          borderRadius: BorderRadius.circular(8),
                          padding: const EdgeInsets.only(left: 8),
                          onPressed: () {
                            _mindMapNode.update(darkText: false);
                            _titleTextEditingFocusNode.unfocus();
                            _descriptionTextEditingFocusNode.unfocus();
                          },
                          pressed: !_mindMapNode.darkText,
                          color: Colors.grey.shade800,
                          child: Text(
                            "Light",
                            style: customStyle[
                                CustomStyle.bottomSheetButtonTextStyleLight],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: InputDecorator(
                  decoration: InputDecoration(
                      labelText: "Color",
                      border:
                          customStyle[CustomStyle.bottomSheetInputBorderStyle]),
                  child: CupertinoButton(
                    minSize: 0,
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      showColorSelector(context: context).then((Color? color) {
                        setState(() {
                          _mindMapNode.update(color: color);
                        });
                      });
                      _titleTextEditingFocusNode.unfocus();
                      _descriptionTextEditingFocusNode.unfocus();
                    },
                    child: AnimatedContainer(
                      height: 48,
                      decoration: BoxDecoration(
                        color: _colorAnimation.value,
                        borderRadius: BorderRadius.circular(4),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black38,
                            offset: Offset(2, 2),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                          BoxShadow(
                            color: Colors.black12,
                            offset: Offset(-2, -2),
                            blurRadius: 8,
                            spreadRadius: 1,
                          )
                        ],
                      ),
                      duration: const Duration(milliseconds: 500),
                      child: Align(
                        alignment: Alignment.center,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: Text(
                            '#' +
                                (_colorAnimation.value!.value & 0xFFFFFF)
                                    .toRadixString(16)
                                    .padLeft(6, '0')
                                    .toUpperCase(),
                            style: Theme.of(context)
                                .textTheme
                                .headline6
                                ?.apply(color: _textAnimation.value),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

////////////////////////////////////////////////////
// MindMapEdgeAdditionConfigurationPanel
// StatefulWidget
////////////////////////////////////////////////////

class MindMapEdgeAdditionConfigurationPanel extends StatefulWidget {
  final MindMapGraph mindMapGraph;
  final MindMapAuxiliary mindMapAuxiliary;
  final void Function(MindMapEdge)? onAccepted;
  final void Function()? onCancelled;

  const MindMapEdgeAdditionConfigurationPanel({
    required this.mindMapGraph,
    required this.mindMapAuxiliary,
    this.onAccepted,
    this.onCancelled,
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() =>
      _MindMapEdgeAdditionConfigurationPanelState();
}

class _MindMapEdgeAdditionConfigurationPanelState
    extends State<MindMapEdgeAdditionConfigurationPanel> {
  void update() => setState(() {});

  @override
  void initState() {
    super.initState();
    widget.mindMapAuxiliary.addListener(update);
  }

  @override
  void didUpdateWidget(
      covariant MindMapEdgeAdditionConfigurationPanel oldWidget) {
    oldWidget.mindMapAuxiliary.removeListener(update);
    widget.mindMapAuxiliary.addListener(update);
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    widget.mindMapAuxiliary.removeListener(update);
    super.dispose();
  }

  Widget mindMapNodeDisplay(MindMapNode node) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: "Title",
              labelStyle: customStyle[CustomStyle.bottomSheetInputLabelStyle],
              border: customStyle[CustomStyle.bottomSheetInputBorderStyle],
            ),
            child: Text(
              node.title,
              style: customStyle[CustomStyle.bottomSheetTextFieldStyle],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: "Description",
              labelStyle: customStyle[CustomStyle.bottomSheetInputLabelStyle],
              border: customStyle[CustomStyle.bottomSheetInputBorderStyle],
            ),
            child: Text(
              node.description,
              style: customStyle[CustomStyle.bottomSheetTextFieldStyle],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: GradientCupertinoButton(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        Colors.teal.shade400,
                        Colors.lightGreen.shade400
                      ],
                    ),
                    child: Text(
                      "OK",
                      style: customStyle[
                              CustomStyle.bottomSheetButtonTextStyleLight]
                          ?.apply(color: Colors.white),
                    ),
                    onPressed: widget.mindMapAuxiliary.selectedNodes.length == 2
                        ? () {
                            widget.onAccepted?.call(MindMapEdge(
                                from: widget.mindMapAuxiliary.selectedNodes[0],
                                to: widget.mindMapAuxiliary.selectedNodes[1]));
                          }
                        : null,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (widget.mindMapAuxiliary.selectedNodes.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                MindMapNodeCanvas(
                  mindMapNode: widget
                      .mindMapGraph[widget.mindMapAuxiliary.selectedNodes[0]]!,
                ),
              ],
            ),
          ),
        if (widget.mindMapAuxiliary.selectedNodes.length > 1)
          Column(
            children: [
              Icon(
                Icons.keyboard_arrow_up,
                size: 32,
                color: customStyle[CustomStyle.textColorGrey],
              ),
              Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Icon(
                    CupertinoIcons.circle_fill,
                    size: 4,
                    color: customStyle[CustomStyle.textColorGrey],
                  )),
              Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Icon(
                    CupertinoIcons.circle_fill,
                    size: 4,
                    color: customStyle[CustomStyle.textColorGrey],
                  )),
              Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Icon(
                    CupertinoIcons.circle_fill,
                    size: 4,
                    color: customStyle[CustomStyle.textColorGrey],
                  )),
              Icon(
                Icons.keyboard_arrow_down,
                size: 32,
                color: customStyle[CustomStyle.textColorGrey],
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    MindMapNodeCanvas(
                      mindMapNode: widget.mindMapGraph[
                          widget.mindMapAuxiliary.selectedNodes[1]]!,
                    ),
                  ],
                ),
              ),
            ],
          ),
      ],
    );
  }
}

////////////////////////////////////////////////////
// MindMapConfigurationPanel
// StatefulWidget
////////////////////////////////////////////////////

class MindMapConfigurationPanel extends StatefulWidget {
  final MindMapAuxiliary mindMapAuxiliary;

  const MindMapConfigurationPanel({
    required this.mindMapAuxiliary,
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _MindMapConfigurationPanelState();
}

class _MindMapConfigurationPanelState extends State<MindMapConfigurationPanel> {
  void update() => setState(() {});

  @override
  void initState() {
    super.initState();
    widget.mindMapAuxiliary.addListener(update);
  }

  @override
  void didUpdateWidget(covariant MindMapConfigurationPanel oldWidget) {
    oldWidget.mindMapAuxiliary.removeListener(update);
    widget.mindMapAuxiliary.addListener(update);
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    widget.mindMapAuxiliary.removeListener(update);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.white70,
        ),
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("Snapping : "),
                Slider(
                  value: widget.mindMapAuxiliary.snapping.toDouble(),
                  max: 3,
                  divisions: 3,
                  label: widget.mindMapAuxiliary.snapping > 0
                      ? MindMapAuxiliary
                          .snappingLabel[widget.mindMapAuxiliary.snapping]
                          .toString()
                      : "None",
                  onChanged: (double value) {
                    widget.mindMapAuxiliary.update(snapping: value.floor());
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
