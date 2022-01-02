import 'package:flutter/cupertino.dart';

typedef ChildShouldRebuildFunction<T> = bool Function(T oldChild);

class ShouldRebuild<T extends Widget> extends StatefulWidget {
  final T child;
  final ChildShouldRebuildFunction<T> childShouldRebuild;
  const ShouldRebuild(
      {required this.childShouldRebuild, required this.child,  Key? key})
      : super(key: key);

  @override
  _ShouldRebuildState createState() => _ShouldRebuildState<T>();
}

class _ShouldRebuildState<T extends Widget> extends State<ShouldRebuild> {
  late T oldChild;
  @override
  ShouldRebuild<T> get widget => super.widget as ShouldRebuild<T>;

  @override
  void initState() {
    oldChild = widget.child;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if(widget.childShouldRebuild(oldChild)) {
      oldChild = widget.child;
    }
    return oldChild;
  }
}