import 'dart:math';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:mind_map_reminder/main_scale_offset.dart';
import 'package:mind_map_reminder/mesh_background.dart';
import 'package:mind_map_reminder/mind_map.dart';

import 'node.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mind Map Reminder',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  static const double maxScale = 2.0;
  static const double minScale = 0.2;
  static const double backgroundInterval = 200;
  static double doubleTapMappingFunction(double dy) {
    final double rawScale = 0.01 * dy.abs();
    return dy < 0 ? 1 / (1 + rawScale) : 1 + rawScale;
  }

  static const List<double> scaleRatioStops = [0.35, 0.63, 1.12, 2.0];

  TwoLevelScaleOffset canvasScaleOffset = TwoLevelScaleOffset();
  NodeMap nodeMap = NodeMap();

  bool _scaleByDoubleTap = false;
  Offset _focalPointOnScale = Offset.zero;
  Offset? _positionOnDoubleTap = Offset.zero;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () {
                Size screenSize = MediaQuery.of(context).size;
                nodeMap.add(Node.dummy(
                    pos: (Offset(screenSize.width, screenSize.height) /
                                    canvasScaleOffset.overallScale -
                                const Offset(160, 76)) /
                            2 +
                        canvasScaleOffset.overallOffset));
              },
              icon: const Icon(Icons.add)),
        ],
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        dragStartBehavior: DragStartBehavior.down,
        child: MainScaleOffset(
          scaleOffset: canvasScaleOffset,
          child: Stack(
            children: [
              MeshBackground(
                interval: backgroundInterval,
              ),
              MindMap(nodeMap: nodeMap),
            ],
          ),
        ),
        onDoubleTap: () {
          for (double stop in scaleRatioStops) {
            if (canvasScaleOffset.overallScale < stop) {
              setState(() {
                canvasScaleOffset.alignFocal(_positionOnDoubleTap!,
                    _positionOnDoubleTap!, stop / canvasScaleOffset.scale1);
                canvasScaleOffset.apply();
              });
              break;
            }
          }
        },
        onDoubleTapDown: (TapDownDetails details) {
          _positionOnDoubleTap = details.localPosition;
        },
        onDoubleTapCancel: () {
          _scaleByDoubleTap = true;
          _positionOnDoubleTap = null;
        },
        onScaleStart: (ScaleStartDetails details) {
          _focalPointOnScale = details.localFocalPoint;
        },
        onScaleUpdate: (ScaleUpdateDetails details) {
          setState(() {
            if (_scaleByDoubleTap) {
              _positionOnDoubleTap = _positionOnDoubleTap ?? details.localFocalPoint;
              final double newScale = max(
                  minScale / canvasScaleOffset.scale1,
                  min(
                      maxScale / canvasScaleOffset.scale1,
                      doubleTapMappingFunction(
                          (details.localFocalPoint - _positionOnDoubleTap!)
                              .dy)));
              canvasScaleOffset.alignFocal(
                  _focalPointOnScale, _focalPointOnScale, newScale);
            } else {
              final double newScale = max(minScale / canvasScaleOffset.scale1,
                  min(maxScale / canvasScaleOffset.scale1, details.scale));
              canvasScaleOffset.alignFocal(
                  _focalPointOnScale, details.localFocalPoint, newScale);
            }
          });
        },
        onScaleEnd: (ScaleEndDetails details) {
          _scaleByDoubleTap = false;
          setState(() {
            canvasScaleOffset.apply();
          });
        },
      ),
    );
  }
}
