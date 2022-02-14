import 'package:flutter/Widgets.dart';

class TwoLevelScaleOffset {
  double scale1, scale2;
  Offset offset1, offset2;
  double get overallScale => scale1 * scale2;
  Offset get overallOffset => offset1 + offset2 / scale1;

  TwoLevelScaleOffset({
    this.scale1 = 1.0,
    this.offset1 = Offset.zero,
    this.scale2 = 1.0,
    this.offset2 = Offset.zero,
  });

  factory TwoLevelScaleOffset.from(TwoLevelScaleOffset other) =>
      TwoLevelScaleOffset(
        scale1: other.scale1,
        offset1: other.offset1,
        scale2: other.scale2,
        offset2: other.offset2,
      );

  void alignFocal(Offset oldFocal, Offset newFocal, double scale) {
    final Offset oldWorldFocal = oldFocal / scale1 + offset1;
    final Offset newWorldFocal = overallOffset + newFocal / scale1 / scale;
    scale2 = scale;
    offset2 -= (newWorldFocal - oldWorldFocal) * scale1;
  }

  void commit() {
    offset1 = overallOffset;
    offset2 = Offset.zero;
    scale1 = overallScale;
    scale2 = 1.0;
  }

  @override
  bool operator ==(Object other) =>
      other is TwoLevelScaleOffset &&
      other.scale1 == scale1 &&
      other.scale2 == scale2 &&
      other.offset1 == offset1 &&
      other.offset2 == offset2;

  @override
  int get hashCode => Object.hashAll([scale1, scale2, offset1, offset2]);
}

enum CanvasScaleOffsetAspect { dynamic, static, all }

class CanvasScaleOffsetProvider
    extends InheritedModel<CanvasScaleOffsetAspect> {
  late final TwoLevelScaleOffset scaleOffset;

  double get staticScale => scaleOffset.scale1;
  Offset get staticOffset => scaleOffset.offset1;
  double get dynamicScale => scaleOffset.scale2;
  Offset get dynamicOffset => scaleOffset.offset2;
  double get overallScale => scaleOffset.overallScale;
  Offset get overallOffset => scaleOffset.overallOffset;

  CanvasScaleOffsetProvider({
    required TwoLevelScaleOffset scaleOffset,
    required Widget child,
    Key? key,
  }) : super(key: key, child: child) {
    this.scaleOffset = TwoLevelScaleOffset.from(scaleOffset);
  }

  static CanvasScaleOffsetProvider of(
      BuildContext context, CanvasScaleOffsetAspect aspect) {
    final CanvasScaleOffsetProvider? canvasScaleOffsetProvider =
        InheritedModel.inheritFrom<CanvasScaleOffsetProvider>(context,
            aspect: aspect);
    assert(canvasScaleOffsetProvider != null);
    return canvasScaleOffsetProvider!;
  }

  @override
  bool updateShouldNotify(CanvasScaleOffsetProvider oldWidget) =>
      oldWidget.scaleOffset != scaleOffset;

  @override
  bool updateShouldNotifyDependent(CanvasScaleOffsetProvider oldWidget,
      Set<CanvasScaleOffsetAspect> dependencies) {
    bool ret = false;
    ret |= dependencies.contains(CanvasScaleOffsetAspect.all) &&
        oldWidget.scaleOffset != scaleOffset;
    ret |= dependencies.contains(CanvasScaleOffsetAspect.dynamic) &&
        (oldWidget.dynamicScale != dynamicScale ||
            oldWidget.dynamicOffset != dynamicOffset);
    ret |= dependencies.contains(CanvasScaleOffsetAspect.static) &&
        (oldWidget.staticScale != staticScale ||
            oldWidget.staticOffset != staticOffset);
    return ret;
  }
}
