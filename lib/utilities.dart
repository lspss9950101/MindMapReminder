import 'package:flutter/material.dart';

class Pair<S, T> {
  S first;
  T second;
  Pair(this.first, this.second);
}

Size getTextSize(String text, TextStyle style,
    {double minWidth = 0.0, double maxWidth = double.infinity}) {
  final TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: 1,
      textDirection: TextDirection.ltr)
    ..layout(minWidth: minWidth, maxWidth: maxWidth);
  return textPainter.size;
}
