import 'package:flutter/material.dart';
import 'package:mind_map_reminder/main_scale_offset.dart';
import 'package:mind_map_reminder/mesh_background_painter.dart';

class MeshBackground extends StatelessWidget {
  final double interval;

  static double _doubleMod(double a, double b) {
    return a - (a / b).floor() * b;
  }

  MeshBackground({this.interval = 200, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final MainScaleOffset mainScaleOffset =
        MainScaleOffset.of(context, MainScaleOffsetAspect.all);
    final Offset offset = Offset(
        _doubleMod(mainScaleOffset.overallOffset.dx, interval),
        _doubleMod(mainScaleOffset.overallOffset.dy, interval));
    final double scale = mainScaleOffset.overallScale;
    return Positioned.fill(
      child: Transform(
        transform: Matrix4.translationValues(
            -offset.dx * scale, -offset.dy * scale, 0.0),
        child: CustomPaint(
          painter: MeshBackgroundPainter(
            interval: interval,
            scale: scale,
          ),
        ),
      ),
    );
  }
}
