import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

Color get randomColor {
  return Color.fromARGB(
    255,
    Random().nextInt(255),
    Random().nextInt(255),
    Random().nextInt(255),
  );
}

class EditConfig {
  const EditConfig({
    required this.size,
    required this.offset,
    required this.isEditing,
    required this.color,
    required this.colors,
  });

  const EditConfig.init({
    this.size = const Size(300, 300),
    this.offset = Offset.zero,
    this.isEditing = false,
    this.color = Colors.white,
    this.colors = const [
      Color.fromARGB(255, 255, 0, 0),
      Color.fromARGB(255, 0, 255, 0),
      Color.fromARGB(255, 0, 0, 255),
    ],
  });

  final Size size;
  final Offset offset;
  final bool isEditing;
  final Color color;
  final List<Color> colors;

  EditConfig copyWith({
    Size? size,
    Offset? offset,
    bool? isEditing,
    Color? color,
    List<Color>? colors,
  }) {
    return EditConfig(
      size: size ?? this.size,
      offset: offset ?? this.offset,
      isEditing: isEditing ?? this.isEditing,
      color: color ?? this.color,
      colors: colors ?? this.colors,
    );
  }
}

class EditState extends ValueNotifier<EditConfig> {
  EditState(EditConfig value) : super(value);

  void onDrag(DragUpdateDetails d) {
    value = value.copyWith(
      offset: value.offset.translate(d.delta.dx, d.delta.dy),
      isEditing: false,
    );
    notifyListeners();
  }

  void onScale(DragUpdateDetails d) {
    final Offset delta = d.delta;
    Size s = Size(value.size.width + delta.dx, value.size.height + delta.dy);
    if (s.width < 20) {
      s = Size(20, s.height);
    }
    if (s.height < 20) {
      s = Size(s.width, 20);
    }
    value = value.copyWith(
      size: s,
      isEditing: false,
    );
    notifyListeners();
  }

  void tapEdit({bool? edit}) {
    if (edit == value.isEditing) return;

    value = value.copyWith(isEditing: edit ?? !value.isEditing);
    notifyListeners();
  }

  void addColor() {
    final List<Color> colors = List.from(value.colors);
    colors.add(randomColor);
    value = value.copyWith(colors: colors);
    notifyListeners();
  }

  void onColorChanged(Color color) {
    final List<Color> colors = List.from(value.colors);
    colors.remove(color);
    value = value.copyWith(color: color, colors: colors);

    notifyListeners();
  }
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final EditState _editState = EditState(const EditConfig.init());

  @override
  void dispose() {
    _editState.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      backgroundColor: Colors.grey,
      body: Stack(
        children: [_box],
      ),
      bottomNavigationBar: _colorList,
    );
  }

  Widget get _box {
    return ValueListenableBuilder(
      valueListenable: _editState,
      builder: (_, EditConfig ec, Widget? child) {
        return Positioned(
          left: ec.offset.dx,
          top: ec.offset.dy,
          child: GestureDetector(
            onPanUpdate: _editState.onDrag,
            child: SizedBox(
              width: ec.size.width + 20,
              height: ec.size.height + 20,
              child: child,
            ),
          ),
        );
      },
      child: Stack(
        fit: StackFit.expand,
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: <Widget>[
          Container(
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.transparent,
              border: Border.all(),
            ),
            child: _view,
          ),
          Positioned(
            left: 0,
            bottom: 0,
            child: Container(
              width: 20,
              height: 20,
              alignment: Alignment.center,
              decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
              child: ValueListenableBuilder(
                valueListenable: _editState,
                builder: (_, EditConfig ec, __) {
                  return GestureDetector(
                    onTap: () => _editState.tapEdit(),
                    child: Icon(ec.isEditing ? Icons.check : Icons.edit, size: 10),
                  );
                },
              ),
            ),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: GestureDetector(
              onPanUpdate: _editState.onScale,
              child: Container(
                width: 20,
                height: 20,
                alignment: Alignment.center,
                decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
                child: Transform.rotate(
                  angle: pi * 0.5,
                  child: const Icon(Icons.open_in_full, size: 10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget get _view {
    return ValueListenableBuilder(
      valueListenable: _editState,
      builder: (_, EditConfig ec, Widget? child) {
        return IgnorePointer(
          ignoring: !ec.isEditing,
          child: child,
        );
      },
      child: FittedBox(
        child: InteractiveViewer(
          clipBehavior: Clip.none,
          boundaryMargin: const EdgeInsets.all(double.infinity),
          minScale: 0.1,
          child: Container(
            width: 300,
            height: 300,
            color: Colors.white,
            child: Stack(
              alignment: Alignment.center,
              children: [
                const FlutterLogo(size: 250),
                Align(
                  alignment: Alignment.bottomRight,
                  child: ClipRect(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: DragTarget<Color>(
                        onAccept: _editState.onColorChanged,
                        builder: (_, List<Color?> colors, __) {
                          return ValueListenableBuilder(
                            valueListenable: _editState,
                            builder: (_, EditConfig ec, __) {
                              final Color color =
                                  colors.isEmpty ? ec.color : (colors.single ?? ec.color);

                              return Container(
                                width: 160,
                                height: 160,
                                color: color.withOpacity(0.5),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget get _colorList {
    return Align(
      heightFactor: 1,
      alignment: Alignment.center,
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minHeight: 160,
          maxHeight: 320,
          maxWidth: 160 * 4,
        ),
        child: SingleChildScrollView(
          child: ValueListenableBuilder(
            valueListenable: _editState,
            builder: (_, EditConfig ec, __) {
              return Wrap(
                children: <Widget>[
                  for (int i = 0; i <= ec.colors.length; i++)
                    i == ec.colors.length ? _addColorBtn : _colorItem(ec.colors[i]),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _colorItem(Color color) {
    final Widget child = Container(
      width: 160,
      height: 160,
      color: color,
    );

    return Draggable(
      data: color,
      feedback: child,
      child: child,
      childWhenDragging: const SizedBox(width: 160, height: 160),
    );
  }

  Widget get _addColorBtn {
    return GestureDetector(
      onTap: _editState.addColor,
      child: Container(
        width: 160,
        height: 160,
        color: Colors.white,
        alignment: Alignment.center,
        child: const Icon(Icons.add),
      ),
    );
  }
}
