import 'package:flutter/widgets.dart';

class Consumer<T extends ChangeNotifier> extends StatefulWidget {
  final T data;
  final Widget Function(BuildContext) builder;

  const Consumer({required this.data, required this.builder, Key? key})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _ConsumerState();
}

class _ConsumerState extends State<Consumer> {
  late Widget cache;
  late bool shouldUpdate;

  void update() {
    setState(() {
      shouldUpdate = true;
    });
  }

  @override
  void initState() {
    super.initState();
    shouldUpdate = true;
    widget.data.addListener(update);
  }

  @override
  void didUpdateWidget(Consumer oldWidget) {
    super.didUpdateWidget(oldWidget);
    shouldUpdate = true;
    oldWidget.data.removeListener(update);
    widget.data.addListener(update);
  }

  @override
  void dispose() {
    widget.data.removeListener(update);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (shouldUpdate) {
      shouldUpdate = false;
      cache = widget.builder(context);
    }
    return cache;
  }
}
