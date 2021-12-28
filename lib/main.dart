import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mind_map_reminder/mesh_background.dart';
import 'package:mind_map_reminder/mind_map.dart';
import 'package:mind_map_reminder/node_preview.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
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
      home: MainPage(),
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
  Offset canvasOffset = Offset.zero;
  double canvasScale = 1.0;

  Offset _lastPanLocation = Offset.zero;
  double _lastScale = 1.0;

  final GlobalKey<MindMapState> mindMapKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () {
                mindMapKey.currentState?.addNode();
              },
              icon: const Icon(Icons.add)),
        ],
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        child: Stack(
          children: [
            MeshBackground(200, scale: canvasScale, offset: canvasOffset),
            MindMap(
              scale: canvasScale,
              offset: canvasOffset,
              key: mindMapKey,
            ),
          ],
        ),
        onScaleStart: (ScaleStartDetails details) {
          _lastPanLocation = details.focalPoint;
        },
        onScaleUpdate: (ScaleUpdateDetails details) {
          if (details.pointerCount == 1) {
            // Pan
            setState(() {
              canvasOffset -=
                  (details.focalPoint - _lastPanLocation) / canvasScale;
              _lastPanLocation = details.focalPoint;
            });
          } else if (details.pointerCount == 2) {
            // Scale
            setState(() {
              double oldScale = canvasScale;
              canvasScale = min(
                  max(canvasScale * (details.scale / _lastScale), minScale),
                  maxScale);
              canvasOffset +=
                  _lastPanLocation * (1 - oldScale / canvasScale) / oldScale;
              _lastScale = details.scale;
            });
          }
        },
        onScaleEnd: (ScaleEndDetails details) {
          if (details.pointerCount == 1) {
            _lastScale = 1.0;
          }
        },
      ),
    );
  }
}
