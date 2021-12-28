import 'package:flutter/material.dart';
import 'package:mind_map_reminder/mesh_background_painter.dart';

class MeshBackground extends StatelessWidget {
  final double scale;
  late final Offset offset;
  late final double interval;

  static double _doubleMod(double a, double b) {
    return a - (a / b).floor() * b;
  }

  MeshBackground(double interval, {this.scale=1.0, Offset offset = Offset.zero, Key? key})
      : super(key: key) {
    this.interval = interval * scale;
    this.offset = Offset(
        _doubleMod(offset.dx * scale, this.interval), _doubleMod(offset.dy * scale, this.interval));
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Transform(
        transform: Matrix4.translationValues(-offset.dx, -offset.dy, 0.0),
        child: CustomPaint(
          painter: MeshBackgroundPainter(interval, scale),
        ),
      ),
    );
  }
}
