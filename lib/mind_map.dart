import 'dart:math';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'utilities.dart';
import 'mind_map_configuration.dart';
import 'refreshable_draggable_scrollable_sheet.dart';
import 'button.dart';
import 'styles.dart';
import 'mesh_background.dart';
import 'mind_map_display.dart';
import 'scale_offset.dart';

typedef NodeId = UniqueKey;
typedef EdgeId = int;

////////////////////////////////////////////////////
// MindMapNode
// ChangeNotifier
////////////////////////////////////////////////////

class MindMapNode with ChangeNotifier {
  final NodeId _id;
  String _title;
  String _description;
  Color _color;
  bool _darkText;
  Offset _position;
  int _lastModifiedTime;

  late Size _titleSize;
  late Size _descriptionSize;
  late Size _totalSize;

  MindMapNode(
      {required String title,
      required String description,
      required Color color,
      bool darkText = false,
      Offset? position})
      : _id = NodeId(),
        _title = title,
        _description = description,
        _color = color,
        _darkText = darkText,
        _position = position ?? Offset.zero,
        _lastModifiedTime = DateTime.now().millisecondsSinceEpoch {
    _calcSize();
  }

  factory MindMapNode.from(MindMapNode other) => MindMapNode(
        title: other.title,
        description: other.description,
        color: other.color,
        darkText: other.darkText,
      );

  factory MindMapNode.dummy() => MindMapNode(
        title: "Dummy",
        description: Random().nextInt(10000).toString(),
        color: Colors.deepPurple,
      );

  NodeId get id => _id;
  String get title => _title;
  String get description => _description;
  Color get color => _color;
  bool get darkText => _darkText;
  Offset get position => _position;
  int get lastModifiedTime => _lastModifiedTime;

  Size get titleSize => _titleSize;
  Size get descriptionSize => _descriptionSize;
  Size get totalSize => _totalSize;

  void _calcSize() {
    _titleSize = getTitleSize(title);
    _descriptionSize = getDescriptionSize(description);
    _totalSize = Size(titleSize.width + descriptionSize.width,
        max(titleSize.height, descriptionSize.height));
  }

  // Normal Attributes Updates
  void update(
      {String? title,
      String? description,
      Color? color,
      bool? darkText,
      Offset? position}) {
    _title = title ?? _title;
    _description = description ?? _description;
    _color = color ?? _color;
    _darkText = darkText ?? _darkText;
    _position = position ?? _position;
    _lastModifiedTime = DateTime.now().millisecondsSinceEpoch;
    _calcSize();
    notifyListeners();
  }

  @override
  bool operator ==(covariant MindMapNode other) =>
      other.title == title &&
      other.description == description &&
      other.color == color &&
      other.darkText == darkText &&
      other.id == id;

  @override
  int get hashCode => Object.hash(
        id,
        title,
        description,
        color,
        darkText,
        lastModifiedTime,
      );

  static Size getSize(MindMapNode mindMapNode) {
    final Size titleSize = getTextSize(mindMapNode.title,
        customStyle[CustomStyle.mindMapNodeDisplayTitleStyle],
        minWidth: 28);
    final Size descriptionSize = getTextSize(mindMapNode.description,
        customStyle[CustomStyle.mindMapNodeDisplayDescriptionStyle]);

    if (mindMapNode.description.isNotEmpty) {
      return Size(8 + titleSize.width + 8 + 8 + descriptionSize.width + 12,
          24 + max(titleSize.height, descriptionSize.height) + 24);
    } else {
      return Size(8 + titleSize.width + 8, 24 + titleSize.height + 24);
    }
  }

  static Size getTitleSize(String title) {
    final Size size = getTextSize(
        title, customStyle[CustomStyle.mindMapNodeDisplayTitleStyle],
        minWidth: 28);
    return Size(8 + size.width + 8, 24 + size.height + 24);
  }

  static Size getDescriptionSize(String description) {
    final Size size = getTextSize(description,
        customStyle[CustomStyle.mindMapNodeDisplayDescriptionStyle]);
    if (description.isNotEmpty) {
      return Size(8 + size.width + 12, 24 + size.height + 24);
    } else {
      return Size(0, 24 + size.height + 24);
    }
  }
}

////////////////////////////////////////////////////
// MindMapEdge
// InheritedModel
////////////////////////////////////////////////////

class MindMapEdge {
  final EdgeId _id;
  NodeId _from;
  NodeId _to;

  EdgeId get id => _id;
  NodeId get from => _from;
  NodeId get to => _to;

  MindMapEdge({required NodeId from, required NodeId to})
      : _id = Object.hash(from, to),
        _from = from,
        _to = to;

  @override
  bool operator ==(covariant MindMapEdge other) => other.id == id;

  @override
  int get hashCode => id;
}

class MindMapEdgeSet with ChangeNotifier {
  final Map<int, MindMapEdge> _mindMapEdgeMap = {};
  final Map<NodeId, Set<EdgeId>> _mindMapRelation = {};

  List<MindMapEdge> get edges => List.unmodifiable(_mindMapEdgeMap.values);

  MindMapEdge? getEdge({required NodeId from, required NodeId to}) =>
      _mindMapEdgeMap[Object.hash(from, to)];

  List<MindMapEdge> getEdges({required NodeId nodeId}) => List.unmodifiable(
      (_mindMapRelation[nodeId]?.toList(growable: false) ?? [])
          .map((EdgeId edgeId) => _mindMapEdgeMap[edgeId]));

  MindMapEdge? addEdge(MindMapEdge mindMapEdge) {
    if (!_mindMapEdgeMap.containsKey(mindMapEdge.id)) {
      MindMapEdge edge =
          MindMapEdge(from: mindMapEdge.from, to: mindMapEdge.to);
      _mindMapEdgeMap[mindMapEdge.id] = edge;
      if (!_mindMapRelation.containsKey(mindMapEdge.from)) {
        _mindMapRelation[mindMapEdge.from] = <EdgeId>{};
      }
      _mindMapRelation[mindMapEdge.from]?.add(mindMapEdge.id);
      if (!_mindMapRelation.containsKey(mindMapEdge.to)) {
        _mindMapRelation[mindMapEdge.to] = <EdgeId>{};
      }
      _mindMapRelation[mindMapEdge.to]?.add(mindMapEdge.id);
      notifyListeners();
      return edge;
    }
    return null;
  }

  void removeEdge(EdgeId id) {
    MindMapEdge? edge = _mindMapEdgeMap[id];
    _mindMapEdgeMap.remove(id);
    _mindMapRelation[edge?.from]?.remove(edge?.id);
    _mindMapRelation[edge?.to]?.remove(edge?.id);
    notifyListeners();
  }

  void removeRelation(NodeId nodeId) {
    if (_mindMapRelation.containsKey(nodeId)) {
      for (EdgeId edgeId in _mindMapRelation[nodeId]!) {
        MindMapEdge? edge = _mindMapEdgeMap[edgeId];
        _mindMapEdgeMap.remove(edgeId);
        if (edge?.from == nodeId) {
          _mindMapRelation[edge?.to]?.remove(edge?.id);
        } else {
          _mindMapRelation[edge?.from]?.remove(edge?.id);
        }
      }
      _mindMapRelation[nodeId]?.clear();
    }
  }
}

////////////////////////////////////////////////////
// MindMapGraph
// ChangeNotifier
////////////////////////////////////////////////////

class MindMapGraph with ChangeNotifier {
  final Map<NodeId, MindMapNode> _mindMapNodeMap = {};
  final MindMapEdgeSet mindMapEdgeSet = MindMapEdgeSet();

  MindMapGraph();

  List<NodeId> get mindMapNodeIdList {
    List<MindMapNode> ret = _mindMapNodeMap.values.toList(growable: false)
      ..sort((MindMapNode n1, MindMapNode n2) =>
          (n1.lastModifiedTime - n2.lastModifiedTime));
    return List.unmodifiable(ret.map((node) => node.id));
  }

  MindMapNode? operator [](NodeId id) => _mindMapNodeMap[id];

  void addNode(MindMapNode mindMapNode) {
    _mindMapNodeMap[mindMapNode.id] = mindMapNode;
    notifyListeners();
  }

  void removeNode(NodeId id) {
    _mindMapNodeMap.remove(id);
    mindMapEdgeSet.removeRelation(id);
    notifyListeners();
  }

  void addEdge(MindMapEdge mindMapEdge) {
    mindMapEdgeSet.addEdge(mindMapEdge);
    notifyListeners();
  }

  void removeEdge(EdgeId id) {
    mindMapEdgeSet.removeEdge(id);
    notifyListeners();
  }
}

////////////////////////////////////////////////////
// MindMapProvider
// InheritedModel
////////////////////////////////////////////////////

class MindMapGraphProvider extends StatelessWidget {
  final MindMapGraph mindMapGraph;
  final Widget child;

  const MindMapGraphProvider(
      {required this.mindMapGraph, required this.child, Key? key})
      : super(key: key);

  static MindMapNode nodeOf(BuildContext context, NodeId id) {
    final MindMapGraphProvider? mindMapProvider =
        context.findAncestorWidgetOfExactType<MindMapGraphProvider>();
    final MindMapNode? mindMapNode = mindMapProvider?.mindMapGraph[id];
    assert(mindMapProvider != null, "No ancestor MindMapProvider found.");
    assert(mindMapNode != null, "No corresponding MindMapNode found.");
    return mindMapNode!;
  }

  @override
  Widget build(BuildContext context) => child;
}

////////////////////////////////////////////////////
// MindMapConfigProvider
// InheritedModel
////////////////////////////////////////////////////

enum MindMapAuxiliaryAspect {
  operationMode,
  selectedNodes,
}

enum OperationMode {
  nodeEdition,
  nodeSelection,
  nodeDeletion,
  edgeEdition,
  edgeAddition,
  edgeDeletion,
}

class MindMapAuxiliary extends ChangeNotifier {
  OperationMode operationMode = OperationMode.nodeEdition;
  final List<NodeId> selectedNodes = [];
  static const List<int> snappingLabel = [0, 1, 5, 10];
  int snapping = 0;

  void selectNode(NodeId nodeId, {int max = 100000}) {
    if (selectedNodes.contains(nodeId)) {
      selectedNodes.remove(nodeId);
    } else {
      selectedNodes.add(nodeId);
    }
    if (selectedNodes.length > max) {
      selectedNodes.removeRange(0, selectedNodes.length - max);
    }

    notifyListeners();
  }

  void update({OperationMode? operationMode, int? snapping}) {
    if (operationMode != null) {
      selectedNodes.clear();
    }
    this.operationMode = operationMode ?? this.operationMode;
    this.snapping = snapping ?? this.snapping;
    notifyListeners();
  }

  @override
  bool operator ==(covariant MindMapAuxiliary other) =>
      other.operationMode == operationMode &&
      other.selectedNodes == selectedNodes;

  @override
  int get hashCode => Object.hashAll([operationMode]);
}

class MindMapAuxiliaryProvider extends InheritedModel<MindMapAuxiliaryAspect> {
  final MindMapAuxiliary mindMapConfig;

  const MindMapAuxiliaryProvider(
      {required this.mindMapConfig, required Widget child, Key? key})
      : super(child: child, key: key);

  static MindMapAuxiliary of(
      BuildContext context, MindMapAuxiliaryAspect aspect) {
    final MindMapAuxiliaryProvider? mindMapConfigProvider =
        InheritedModel.inheritFrom<MindMapAuxiliaryProvider>(context,
            aspect: aspect);
    final MindMapAuxiliary? mindMapConfig =
        mindMapConfigProvider?.mindMapConfig;
    assert(mindMapConfigProvider != null, "No MindMapConfigProvider found.");
    assert(mindMapConfig != null, "No corresponding MindMapConfig.");
    return mindMapConfig!;
  }

  static MindMapAuxiliary independentOf(BuildContext context) {
    final MindMapAuxiliaryProvider? mindMapAuxiliaryProvider =
        context.findAncestorWidgetOfExactType<MindMapAuxiliaryProvider>();
    final MindMapAuxiliary? mindMapConfig =
        mindMapAuxiliaryProvider?.mindMapConfig;
    assert(mindMapAuxiliaryProvider != null, "No MindMapConfigProvider found.");
    assert(mindMapConfig != null, "No corresponding MindMapConfig.");
    return mindMapConfig!;
  }

  @override
  bool updateShouldNotify(MindMapAuxiliaryProvider oldWidget) =>
      oldWidget.mindMapConfig == mindMapConfig;

  @override
  bool updateShouldNotifyDependent(MindMapAuxiliaryProvider oldWidget,
      Set<MindMapAuxiliaryAspect> dependencies) {
    bool ret = false;
    if (dependencies.contains(MindMapAuxiliaryAspect.operationMode) &&
        oldWidget.mindMapConfig.operationMode != mindMapConfig.operationMode) {
      ret |= true;
    }
    if (dependencies.contains(MindMapAuxiliaryAspect.selectedNodes) &&
        oldWidget.mindMapConfig.selectedNodes
                .takeWhile((NodeId nodeId) =>
                    mindMapConfig.selectedNodes.contains(nodeId))
                .length ==
            oldWidget.mindMapConfig.selectedNodes.length) {
      ret |= true;
    }
    return ret;
  }
}

////////////////////////////////////////////////////
// MindMap
// StatefulWidget
////////////////////////////////////////////////////

enum MindMapAppBarAction {
  addNode,
}

class MindMapAppBar extends StatefulWidget implements PreferredSizeWidget {
  final BuildContext context;
  final MindMapAuxiliary mindMapAuxiliary;
  final void Function(MindMapAppBarAction) onAction;
  @override
  late final Size preferredSize;

  MindMapAppBar({
    required this.context,
    required this.mindMapAuxiliary,
    required this.onAction,
    Key? key,
  }) : super(key: key) {
    preferredSize =
        Size.fromHeight(MediaQuery.of(context).viewPadding.top + 50);
  }

  @override
  State<StatefulWidget> createState() => _MindMapAppBarState();
}

class _MindMapAppBarState extends State<MindMapAppBar> {
  void update() => setState(() {});

  @override
  void initState() {
    super.initState();
    widget.mindMapAuxiliary.addListener(update);
  }

  @override
  void didUpdateWidget(covariant MindMapAppBar oldWidget) {
    oldWidget.mindMapAuxiliary.removeListener(update);
    widget.mindMapAuxiliary.addListener(update);
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    widget.mindMapAuxiliary.removeListener(update);
    super.dispose();
  }

  List<Widget> getModeSelections() {
    return [
      Padding(
        padding: const EdgeInsets.all(4),
        child: NeumorphismButton(
          height: 42,
          width: 42,
          shadow1: Colors.white12,
          shadow2: Colors.black45,
          pressed: [
            OperationMode.nodeEdition,
            OperationMode.nodeSelection,
            OperationMode.nodeDeletion,
          ].contains(widget.mindMapAuxiliary.operationMode),
          onPressed: () {
            widget.mindMapAuxiliary
                .update(operationMode: OperationMode.nodeEdition);
          },
          color: customStyle[CustomStyle.textColorDark],
          child: Icon(
            CupertinoIcons.circle_fill,
            size: 12,
            color: customStyle[CustomStyle.textColorLight],
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(4),
        child: NeumorphismButton(
          height: 42,
          width: 42,
          shadow1: Colors.white12,
          shadow2: Colors.black45,
          pressed: [
            OperationMode.edgeEdition,
            OperationMode.edgeAddition,
            OperationMode.edgeDeletion,
          ].contains(widget.mindMapAuxiliary.operationMode),
          onPressed: () {
            widget.mindMapAuxiliary
                .update(operationMode: OperationMode.edgeEdition);
          },
          color: customStyle[CustomStyle.textColorDark],
          child: Icon(
            Icons.timeline,
            size: 32,
            color: customStyle[CustomStyle.textColorLight],
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Container(
          width: 1,
          height: 40,
          color: Colors.white70,
        ),
      ),
    ];
  }

  List<Widget> getActions() {
    List<Widget> ret = [];
    if ([
      OperationMode.nodeEdition,
      OperationMode.nodeSelection,
      OperationMode.nodeDeletion
    ].contains(widget.mindMapAuxiliary.operationMode)) {
      ret = [
        Padding(
          padding: const EdgeInsets.all(4),
          child: CupertinoButton(
            padding: const EdgeInsets.all(0),
            alignment: Alignment.center,
            child: SizedBox(
              width: 42,
              height: 42,
              child: Icon(
                Icons.settings,
                color: customStyle[CustomStyle.textColorLight],
              ),
            ),
            onPressed: () {
              showDialog(
                  context: context,
                  barrierDismissible: true,
                  builder: (BuildContext context) {
                    return BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                      child: SimpleDialog(
                        alignment: Alignment.center,
                        insetPadding: EdgeInsets.zero,
                        backgroundColor: Colors.transparent,
                        children: [
                          MindMapConfigurationPanel(
                              mindMapAuxiliary: widget.mindMapAuxiliary)
                        ],
                      ),
                    );
                  });
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(4),
          child: CupertinoButton(
            padding: const EdgeInsets.all(0),
            alignment: Alignment.center,
            child: SizedBox(
              width: 42,
              height: 42,
              child: Icon(
                Icons.add,
                color: customStyle[CustomStyle.textColorLight],
              ),
            ),
            onPressed: () => widget.onAction(MindMapAppBarAction.addNode),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(4),
          child: NeumorphismButton(
            padding: const EdgeInsets.all(0),
            width: 42,
            height: 42,
            shadow1: Colors.white12,
            shadow2: Colors.black45,
            color: customStyle[CustomStyle.textColorDark],
            pressed: widget.mindMapAuxiliary.operationMode ==
                OperationMode.nodeSelection,
            onPressed: () {
              if (widget.mindMapAuxiliary.operationMode !=
                  OperationMode.nodeSelection) {
                widget.mindMapAuxiliary
                    .update(operationMode: OperationMode.nodeSelection);
              } else {
                widget.mindMapAuxiliary
                    .update(operationMode: OperationMode.nodeEdition);
              }
            },
            child: Icon(
              Icons.select_all,
              color: customStyle[CustomStyle.textColorLight],
            ),
          ),
        ),
      ];
    } else if ([
      OperationMode.edgeEdition,
      OperationMode.edgeAddition,
      OperationMode.edgeDeletion
    ].contains(widget.mindMapAuxiliary.operationMode)) {
      ret = [
        Padding(
          padding: const EdgeInsets.all(4),
          child: NeumorphismButton(
            padding: const EdgeInsets.all(0),
            width: 42,
            height: 42,
            shadow1: Colors.white12,
            shadow2: Colors.black45,
            color: customStyle[CustomStyle.textColorDark],
            pressed: widget.mindMapAuxiliary.operationMode ==
                OperationMode.edgeAddition,
            onPressed: () {
              if (widget.mindMapAuxiliary.operationMode !=
                  OperationMode.edgeAddition) {
                widget.mindMapAuxiliary
                    .update(operationMode: OperationMode.edgeAddition);
              } else {
                widget.mindMapAuxiliary
                    .update(operationMode: OperationMode.edgeEdition);
              }
            },
            child: Icon(
              Icons.add,
              color: customStyle[CustomStyle.textColorLight],
            ),
          ),
        ),
      ];
    }
    return [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Container(
          width: 1,
          height: 40,
          color: Colors.white70,
        ),
      ),
      ...ret,
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.preferredSize.height,
      decoration: BoxDecoration(
        color: customStyle[CustomStyle.textColorDark],
      ),
      child: Padding(
        padding: EdgeInsets.only(top: MediaQuery.of(context).viewPadding.top),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(children: getModeSelections()),
            Row(children: getActions()),
          ],
        ),
      ),
    );
  }
}

class MindMap extends StatefulWidget {
  const MindMap({Key? key}) : super(key: key);

  @override
  State<MindMap> createState() => _MindMapState();
}

class _MindMapState extends State<MindMap> {
  static const double maxScale = 2.0;
  static const double minScale = 0.2;
  static double doubleTapMappingFunction(double dy) {
    final double rawScale = 0.01 * dy.abs();
    return dy < 0 ? 1 / (1 + rawScale) : 1 + rawScale;
  }

  MindMapGraph mindMapGraph = MindMapGraph();
  TwoLevelScaleOffset scaleOffset = TwoLevelScaleOffset();
  final MindMapAuxiliary mindMapAuxiliary = MindMapAuxiliary();

  Offset _focalPointOnScale = Offset.zero;
  bool _scaleByDoubleTap = false;
  Offset? _positionOnDoubleTap = Offset.zero;

  void update() => setState(() {});

  @override
  void initState() {
    super.initState();
    mindMapAuxiliary.addListener(update);
    mindMapGraph.addListener(update);
  }

  @override
  void dispose() {
    mindMapAuxiliary.removeListener(update);
    mindMapGraph.removeListener(update);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: MindMapAppBar(
          context: context,
          mindMapAuxiliary: mindMapAuxiliary,
          onAction: (MindMapAppBarAction mindMapAppBarAction) {
            switch (mindMapAppBarAction) {
              case MindMapAppBarAction.addNode:
                Size screenSize = MediaQuery.of(context).size;
                mindMapGraph.addNode(
                  MindMapNode(
                      title: "Event",
                      description: "Description",
                      color: Colors.blueAccent,
                      position: scaleOffset.overallOffset +
                          Offset(screenSize.width, screenSize.height) /
                              scaleOffset.overallScale /
                              2 -
                          const Offset(80, 38)),
                );
                break;
            }
          },
        ),
        body: MindMapAuxiliaryProvider(
          mindMapConfig: mindMapAuxiliary,
          child: Stack(
            children: [
              GestureDetector(
                behavior: HitTestBehavior.translucent,
                dragStartBehavior: DragStartBehavior.down,
                onDoubleTap: () {},
                onDoubleTapDown: (TapDownDetails details) {
                  _positionOnDoubleTap = details.localPosition;
                },
                onDoubleTapCancel: () {
                  _scaleByDoubleTap = true;
                  _positionOnDoubleTap = null;
                },
                onScaleStart: (ScaleStartDetails details) {
                  _focalPointOnScale = details.localFocalPoint;
                },
                onScaleUpdate: (ScaleUpdateDetails details) {
                  setState(() {
                    if (_scaleByDoubleTap) {
                      _positionOnDoubleTap =
                          _positionOnDoubleTap ?? details.localFocalPoint;
                      final double newScale = max(
                          minScale / scaleOffset.scale1,
                          min(
                              maxScale / scaleOffset.scale1,
                              doubleTapMappingFunction(
                                  (details.localFocalPoint -
                                          _positionOnDoubleTap!)
                                      .dy)));
                      scaleOffset.alignFocal(
                          _focalPointOnScale, _focalPointOnScale, newScale);
                    } else {
                      final double newScale = max(minScale / scaleOffset.scale1,
                          min(maxScale / scaleOffset.scale1, details.scale));
                      scaleOffset.alignFocal(_focalPointOnScale,
                          details.localFocalPoint, newScale);
                    }
                  });
                },
                onScaleEnd: (ScaleEndDetails details) {
                  setState(() {
                    _scaleByDoubleTap = false;
                    scaleOffset.commit();
                  });
                },
                child: CanvasScaleOffsetProvider(
                  scaleOffset: scaleOffset,
                  child: Stack(
                    children: [
                      MeshBackground(),
                      MindMapGraphProvider(
                        mindMapGraph: mindMapGraph,
                        child: Builder(
                          builder: (BuildContext innerContext) {
                            final CanvasScaleOffsetProvider
                                canvasScaleOffsetProvider =
                                CanvasScaleOffsetProvider.of(innerContext,
                                    CanvasScaleOffsetAspect.dynamic);
                            return Transform(
                              transform: Matrix4.identity()
                                ..scale(canvasScaleOffsetProvider.dynamicScale)
                                ..translate(
                                    -canvasScaleOffsetProvider.dynamicOffset.dx,
                                    -canvasScaleOffsetProvider
                                        .dynamicOffset.dy),
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  MindMapEdgeDisplay(
                                      edgeSet: mindMapGraph.mindMapEdgeSet),
                                  ...mindMapGraph.mindMapNodeIdList
                                      .map((id) => MindMapNodeDisplay(id))
                                      .toList(),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (mindMapAuxiliary.operationMode == OperationMode.nodeDeletion)
                Positioned(
                  left: 0,
                  right: 0,
                  top: MediaQuery.of(context).size.height * 0.7,
                  bottom: 0,
                  child: DragTarget<NodeId>(
                    onWillAccept: (NodeId? id) => true,
                    onAccept: (NodeId id) {
                      mindMapGraph.removeNode(id);
                    },
                    builder: (BuildContext context, List<Object?> candidateData,
                            List<dynamic> rejectedData) =>
                        Container(
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black38,
                          ],
                        ),
                      ),
                      child: Icon(
                        Icons.delete,
                        size: 48,
                        color: candidateData.isNotEmpty
                            ? Colors.grey.shade600
                            : Colors.grey.shade500,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        bottomSheet: mindMapAuxiliary.operationMode ==
                OperationMode.edgeAddition
            ? Container(
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
                      minHeight: 120,
                      maxHeight: mindMapAuxiliary.selectedNodes.isNotEmpty
                          ? mindMapAuxiliary.selectedNodes.length >= 2
                              ? 430
                              : 250
                          : 138,
                      initHeight: 138,
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
                          MindMapEdgeAdditionConfigurationPanel(
                            mindMapGraph: mindMapGraph,
                            mindMapAuxiliary: mindMapAuxiliary,
                            onAccepted: (MindMapEdge mindMapEdge) {
                              mindMapGraph.addEdge(mindMapEdge);
                              mindMapAuxiliary.update(
                                  operationMode: OperationMode.edgeEdition);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )
            : null,
      );
}
