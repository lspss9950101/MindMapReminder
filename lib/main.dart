import 'dart:math';
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
  static const double doubleTapScaleRatio = 0.004;

  TwoLevelScaleOffset canvasScaleOffset = TwoLevelScaleOffset();
  NodeMap nodeMap = NodeMap();

  Offset _focalPointOnScale = Offset.zero;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(onPressed: () {
            Size screenSize = MediaQuery.of(context).size;
            nodeMap.add(Node.dummy(pos: (Offset(screenSize.width, screenSize.height) / canvasScaleOffset.overallScale - const Offset(160, 76)) / 2 + canvasScaleOffset.overallOffset));
          }, icon: const Icon(Icons.add)),
        ],
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
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
        onScaleStart: (ScaleStartDetails details) {
          _focalPointOnScale =
              details.localFocalPoint / canvasScaleOffset.overallScale +
                  canvasScaleOffset.overallOffset;
        },
        onScaleUpdate: (ScaleUpdateDetails details) {
          setState(() {
            Offset newFocalPoint = canvasScaleOffset.overallOffset;
            canvasScaleOffset.scale2 = max(minScale / canvasScaleOffset.scale1,
                min(maxScale / canvasScaleOffset.scale1, details.scale));
            newFocalPoint +=
                details.localFocalPoint / canvasScaleOffset.overallScale;
            canvasScaleOffset.offset2 +=
                (_focalPointOnScale - newFocalPoint) * canvasScaleOffset.scale1;
          });
        },
        onScaleEnd: (ScaleEndDetails details) {
          setState(() {
            canvasScaleOffset.apply();
          });
        },
      ),
    );
  }
}
