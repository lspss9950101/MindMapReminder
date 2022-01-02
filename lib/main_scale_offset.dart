import 'package:flutter/widgets.dart';

enum MainScaleOffsetAspect { dynamic, static, all }

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

  TwoLevelScaleOffset.copy(TwoLevelScaleOffset other)
      : this(
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

  void apply() {
    offset1 = overallOffset;
    offset2 = Offset.zero;
    scale1 = overallScale;
    scale2 = 1.0;
  }

  @override
  bool operator ==(Object other) =>
      other is TwoLevelScaleOffset &&
      other.scale1 == scale1 &&
      other.offset1 == offset1 &&
      other.scale2 == scale2 &&
      other.offset2 == offset2;

  @override
  int get hashCode => Object.hashAll([scale1, scale2, offset1, offset2]);
}

class MainScaleOffset extends InheritedModel<MainScaleOffsetAspect> {
  late final TwoLevelScaleOffset _scaleOffset;

  double get staticScale => _scaleOffset.scale1;
  Offset get staticOffset => _scaleOffset.offset1;
  double get dynamicScale => _scaleOffset.scale2;
  Offset get dynamicOffset => _scaleOffset.offset2;
  double get overallScale => _scaleOffset.overallScale;
  Offset get overallOffset => _scaleOffset.overallOffset;

  MainScaleOffset({
    Key? key,
    required TwoLevelScaleOffset scaleOffset,
    required Widget child,
  }) : super(key: key, child: child) {
    _scaleOffset = TwoLevelScaleOffset.copy(scaleOffset);
  }

  static MainScaleOffset of(
      BuildContext context, MainScaleOffsetAspect aspect) {
    final MainScaleOffset? result =
        InheritedModel.inheritFrom<MainScaleOffset>(context, aspect: aspect);
    assert(result != null, 'No MainScaleOffset found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(MainScaleOffset oldWidget) =>
      oldWidget._scaleOffset != _scaleOffset;

  @override
  bool updateShouldNotifyDependent(
      MainScaleOffset oldWidget, Set<MainScaleOffsetAspect> dependencies) {
    bool ret = false;
    if (dependencies.contains(MainScaleOffsetAspect.all)) {
      ret |= oldWidget._scaleOffset != _scaleOffset;
    }
    if (dependencies.contains(MainScaleOffsetAspect.dynamic)) {
      ret |= dynamicScale != oldWidget.dynamicScale ||
          dynamicOffset != oldWidget.dynamicOffset;
    }
    if (dependencies.contains(MainScaleOffsetAspect.static)) {
      ret |= staticScale != oldWidget.staticScale ||
          staticOffset != oldWidget.staticOffset;
    }
    return ret;
  }
}
