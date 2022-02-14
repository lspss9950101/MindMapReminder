import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

const EdgeInsets _kButtonPadding = EdgeInsets.all(16.0);
const EdgeInsets _kBackgroundButtonPadding = EdgeInsets.symmetric(
  vertical: 14.0,
  horizontal: 64.0,
);

class GradientCupertinoButton extends StatefulWidget {
  final double? minSize;
  final BorderRadius? borderRadius;
  final Gradient? gradient;
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onPressed;
  final double? pressedOpacity;
  final AlignmentGeometry alignment;
  final Color disabledColor;

  const GradientCupertinoButton({
    Key? key,
    required this.child,
    this.padding,
    this.gradient,
    this.disabledColor = CupertinoColors.quaternarySystemFill,
    this.minSize = kMinInteractiveDimensionCupertino,
    this.pressedOpacity = 0.4,
    this.borderRadius = const BorderRadius.all(Radius.circular(8.0)),
    this.alignment = Alignment.center,
    required this.onPressed,
  })  : assert(pressedOpacity == null ||
            (pressedOpacity >= 0.0 && pressedOpacity <= 1.0)),
        assert(disabledColor != null),
        assert(alignment != null),
        super(key: key);

  bool get enabled => onPressed != null;

  @override
  _GradientCupertinoButton createState() => _GradientCupertinoButton();
}

class _GradientCupertinoButton extends State<GradientCupertinoButton>
    with SingleTickerProviderStateMixin {
  static const Duration kFadeOutDuration = Duration(milliseconds: 120);
  static const Duration kFadeInDuration = Duration(milliseconds: 180);
  final Tween<double> _opacityTween = Tween<double>(begin: 1.0);

  late AnimationController _animationController;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
        duration: const Duration(milliseconds: 200), value: 0.0, vsync: this);
    _opacityAnimation = _animationController
        .drive(CurveTween(curve: Curves.decelerate))
        .drive(_opacityTween);
    _setTween();
  }

  @override
  void didUpdateWidget(GradientCupertinoButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    _setTween();
  }

  void _setTween() {
    _opacityTween.end = widget.pressedOpacity ?? 1.0;
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  bool _buttonHeldDown = false;

  void _handleTapDown(TapDownDetails event) {
    if (!_buttonHeldDown) {
      _buttonHeldDown = true;
      _animate();
    }
  }

  void _handleTapUp(TapUpDetails event) {
    if (_buttonHeldDown) {
      _buttonHeldDown = false;
      _animate();
    }
  }

  void _handleTapCancel() {
    if (_buttonHeldDown) {
      _buttonHeldDown = false;
      _animate();
    }
  }

  void _animate() {
    if (_animationController.isAnimating) return;
    final bool wasHeldDown = _buttonHeldDown;
    final TickerFuture ticker = _buttonHeldDown
        ? _animationController.animateTo(1.0,
            duration: kFadeOutDuration, curve: Curves.easeInOutCubicEmphasized)
        : _animationController.animateTo(0.0,
            duration: kFadeInDuration, curve: Curves.easeOutCubic);
    ticker.then<void>((void value) {
      if (mounted && wasHeldDown != _buttonHeldDown) _animate();
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool enabled = widget.enabled;
    final CupertinoThemeData themeData = CupertinoTheme.of(context);
    final Color primaryColor = themeData.primaryColor;
    final Color foregroundColor = enabled
        ? primaryColor
        : CupertinoDynamicColor.resolve(
            CupertinoColors.placeholderText, context);
    final TextStyle textStyle =
        themeData.textTheme.textStyle.copyWith(color: foregroundColor);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: widget.onPressed,
      child: Semantics(
        button: true,
        child: ConstrainedBox(
          constraints: widget.minSize == null
              ? const BoxConstraints()
              : BoxConstraints(
                  minWidth: widget.minSize!, maxHeight: widget.minSize!),
          child: FadeTransition(
            opacity: _opacityAnimation,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: widget.borderRadius,
                gradient: enabled ? widget.gradient : null,
                color: enabled ? null : widget.disabledColor,
              ),
              child: Padding(
                padding: widget.padding ??
                    (widget.gradient == null
                        ? _kBackgroundButtonPadding
                        : _kButtonPadding),
                child: Align(
                  alignment: widget.alignment,
                  widthFactor: 1.0,
                  heightFactor: 1.0,
                  child: DefaultTextStyle(
                    style: textStyle,
                    child: IconTheme(
                      data: IconThemeData(color: foregroundColor),
                      child: widget.child,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class NeumorphismButton extends StatefulWidget {
  final Color? color;
  final BorderRadius? borderRadius;
  final bool pressed;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onPressed;
  final double? width;
  final double? height;
  final Widget? child;
  final Color? shadow1;
  final Color? shadow2;

  const NeumorphismButton(
      {this.onPressed,
      this.borderRadius,
      this.pressed = false,
      this.padding,
      this.width,
      this.height,
      this.color,
      this.shadow1,
      this.shadow2,
      this.child,
      Key? key})
      : super(key: key);

  @override
  _NeumorphismButtonState createState() => _NeumorphismButtonState();
}

class _NeumorphismButtonState extends State<NeumorphismButton> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.padding ?? EdgeInsets.zero,
      child: GestureDetector(
        onTap: () {
          widget.onPressed?.call();
        },
        child: AnimatedContainer(
          width: widget.width,
          height: widget.height,
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: widget.color ?? Colors.grey[300],
            borderRadius: widget.borderRadius ?? BorderRadius.circular(16),
            boxShadow: widget.pressed
                ? [
                    BoxShadow(
                      color: widget.shadow1 ?? Colors.black12,
                      offset: const Offset(-2, -2),
                      blurRadius: 4,
                      spreadRadius: 0.5,
                    ),
                    BoxShadow(
                      color: widget.shadow2 ?? Colors.black38,
                      offset: const Offset(2, 2),
                      blurRadius: 4,
                      spreadRadius: 0.5,
                    ),
                  ]
                : null,
          ),
          child: Align(
            alignment: Alignment.center,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
