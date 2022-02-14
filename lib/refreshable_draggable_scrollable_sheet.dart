import 'dart:math';

import 'package:flutter/material.dart';

class RefreshableDraggableScrollableSheet extends StatefulWidget {
  final Widget child;
  final double maxHeight;
  final double minHeight;
  final double initHeight;
  final bool expand;
  final Decoration? decoration;
  final bool dismissOnLoseFocus;

  const RefreshableDraggableScrollableSheet(
      {required this.child,
      this.maxHeight = 500,
      this.minHeight = 100,
      this.initHeight = 250,
      this.expand = false,
      this.decoration,
      this.dismissOnLoseFocus = false,
      Key? key})
      : super(key: key);

  @override
  _RefreshableDraggableScrollableSheetState createState() =>
      _RefreshableDraggableScrollableSheetState();
}

class _RefreshableDraggableScrollableSheetBehaviour extends ScrollBehavior {
  @override
  ScrollPhysics getScrollPhysics(BuildContext context) =>
      const ClampingScrollPhysics();

  @override
  Widget buildViewportChrome(
          BuildContext context, Widget child, AxisDirection axisDirection) =>
      child;
}

class _RefreshableDraggableScrollableSheetState
    extends State<RefreshableDraggableScrollableSheet> {
  ScrollController? _scrollController;

  double _screenHeight = -1;

  @override
  void didUpdateWidget(RefreshableDraggableScrollableSheet oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    _screenHeight = MediaQuery.of(context).size.height - MediaQuery.of(context).viewInsets.bottom;
    return ScrollConfiguration(
      behavior: _RefreshableDraggableScrollableSheetBehaviour(),
      child: DraggableScrollableActuator(
        child: Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: DraggableScrollableSheet(
            initialChildSize: widget.initHeight / _screenHeight,
            maxChildSize: min(widget.maxHeight / _screenHeight, 1.0),
            minChildSize: max(widget.minHeight / _screenHeight, 0.0),
            expand: widget.expand,
            builder: (BuildContext context, ScrollController scrollController) {
              _scrollController = scrollController;
              return Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
                child: Container(
                  decoration: widget.decoration,
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: widget.child,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
