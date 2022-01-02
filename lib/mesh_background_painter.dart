import 'dart:math';

import 'package:flutter/material.dart';
import 'dart:core';

class MeshBackgroundPainter extends CustomPainter {
  late final double interval;
  final double scale;

  MeshBackgroundPainter({required double interval, required this.scale}) {
    this.interval = interval * scale;
  }

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = const Color.fromARGB(255, 220, 220, 220)
      ..strokeWidth = 1.0 * scale;
    Paint paintWhite = Paint()
      ..color = const Color.fromARGB(255, 250, 250, 250);

    Size paintSize = Size((size.width / interval + 1).ceil() * interval,
        (size.height / interval + 1).ceil() * interval);

    canvas.drawColor(const Color.fromARGB(255, 250, 250, 250), BlendMode.dst);

    for (double x = 0; x <= paintSize.width; x += interval) {
      Offset src;
      Offset dst;
      src = Offset(x, 0);
      dst = Offset(
          min(x + paintSize.height, paintSize.width), min(paintSize.width - x, paintSize.height));
      canvas.drawLine(src, dst, paint);

      dst = Offset(max(x - paintSize.height, 0), min(x, paintSize.height));
      canvas.drawLine(src, dst, paint);
    }

    for (double y = 0; y <= paintSize.height; y += interval) {
      Offset src;
      Offset dst;
      src = Offset(0, y);
      dst = Offset(
          min(paintSize.height - y, paintSize.width), min(y + paintSize.width, paintSize.height));
      canvas.drawLine(src, dst, paint);

      src = Offset(paintSize.width, y);
      dst = Offset(max(paintSize.width - paintSize.height + y, 0),
          min(y + paintSize.width, paintSize.height));
      canvas.drawLine(src, dst, paint);
    }

    for(int xIdx = 0; xIdx <= paintSize.width / interval * 2; xIdx++) {
      for(int yIdx = 0; yIdx <= paintSize.height / interval * 2; yIdx++) {
        if((xIdx + yIdx) % 2 == 1) continue;
        double x = xIdx * interval * 0.5;
        double y = yIdx * interval * 0.5;
        canvas.drawCircle(Offset(x, y), 8 * scale, paintWhite);
        canvas.drawCircle(Offset(x, y), 4 * scale, paint);
        canvas.drawCircle(Offset(x, y), 2 * scale, paintWhite);
      }
    }
  }

  @override
  bool shouldRepaint(MeshBackgroundPainter oldDelegate) {
    return oldDelegate.scale != scale;
  }
}
