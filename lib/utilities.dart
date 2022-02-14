import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'styles.dart';
import 'refreshable_draggable_scrollable_sheet.dart';

Size getTextSize(final String text, final TextStyle style,
    {double minWidth = 0.0, double maxWidth = double.infinity}) {
  final TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: 1,
      textDirection: TextDirection.ltr)
    ..layout(minWidth: minWidth, maxWidth: maxWidth);
  return textPainter.size;
}

bool isDark(Color color) {
  return color.red * 0.21 + color.green * 0.72 + color.blue * 0.07 < 128;
}

Future<T?> showPopModal<T>(
    {required BuildContext context,
    required Widget child,
    double? maxHeight,
    double? minHeight,
    double? initHeight,
    bool isDismissible=true}) {
  double screenHeight = MediaQuery.of(context).size.height;
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    isDismissible: isDismissible,
    barrierColor: Colors.transparent,
    backgroundColor: Colors.transparent,
    builder: (BuildContext context) {
      return Container(
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              boxShadow: const [
                BoxShadow(blurRadius: 16, color: Colors.black38),
              ],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: RefreshableDraggableScrollableSheet(
              minHeight: minHeight ?? screenHeight * 0.1,
              maxHeight: maxHeight ?? screenHeight,
              initHeight: initHeight ?? screenHeight * 0.2,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 12),
                    child: Container(
                      height: 8,
                      width: 48,
                      decoration: BoxDecoration(
                        color: Colors.black26,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  child,
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}

Widget _colorList(
    {required BuildContext context,
    required List<Color> colors,
    required void Function(Color) callback}) {
  return Column(
    children: colors
        .map(
          (Color color) => Padding(
            padding: const EdgeInsets.fromLTRB(4, 8, 8, 8),
            child: CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () {
                callback(color);
              },
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 8, 8, 8),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        boxShadow: const [
                          BoxShadow(blurRadius: 4, color: Colors.black38),
                        ],
                        borderRadius: BorderRadius.circular(16),
                        color: color,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        boxShadow: const [
                          BoxShadow(blurRadius: 4, color: Colors.black38),
                        ],
                        color: color,
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: Text(
                            '#' + (color.value & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase(),
                            style: Theme.of(context).textTheme.headline6?.apply(
                                color: isDark(color)
                                    ? customStyle[CustomStyle.textColorLight]
                                    : customStyle[CustomStyle.textColorDark]),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        )
        .toList(growable: false),
  );
}

Future<Color?> showColorSelector({required BuildContext context}) {
  return showPopModal<Color>(
    initHeight: 300,
    context: context,
    child: _colorList(
      context: context,
      callback: (Color color) {
        MaterialColor? materialColor = color as MaterialColor?;
        if (materialColor == null) {
          Navigator.of(context).pop();
        } else {
          showPopModal<Color>(
            maxHeight: 740,
            initHeight: 740,
            context: context,
            child: _colorList(
              context: context,
              callback: (Color color) {
                Navigator.of(context).pop(color);
              },
              colors: [
                for (int i in [50, 100, 200, 300, 400, 500, 600, 700, 800, 900])
                  materialColor[i]!
              ],
            ),
          ).then((Color? color) {
            if (color != null) Navigator.of(context).pop(color);
          });
        }
      },
      colors: [
        Colors.pink,
        Colors.red,
        Colors.deepOrange,
        Colors.orange,
        Colors.amber,
        Colors.yellow,
        Colors.lime,
        Colors.lightGreen,
        Colors.green,
        Colors.teal,
        Colors.cyan,
        Colors.lightBlue,
        Colors.blue,
        Colors.indigo,
        Colors.purple,
        Colors.deepPurple,
        Colors.blueGrey,
        Colors.brown,
        Colors.grey,
      ],
    ),
  );
}
