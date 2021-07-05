import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:systray/systray.dart';
import 'dart:ffi' as ffi;
import 'dart:io' show Directory, File, Platform;
import 'package:path/path.dart' as path;

typedef hello_world_func = ffi.Void Function();
typedef HelloWorld = void Function();

void main() async {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int seconds = 0;
  bool paused = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      color: Colors.white,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Flutter systray example app'),
        ),
        body: Center(
          child: Container(width: 500.0, height: 500.0, child: CustomPaint()),
        ),
      ),
    );
  }

  String iconPath = "/Users/jackstefansky/Desktop/tcamp.png";
  @override
  void initState() {
    super.initState();
    MainEntry main = MainEntry(title: "title", iconPath: iconPath);

    Systray.initSystray(main).then((result) {
      Systray.updateMenu([
        SystrayAction(
          name: "focus",
          label: "Focus",
          actionType: ActionType.Focus,
        ),
        SystrayAction(
          name: "toggleTimer",
          label: "Stop timer",
          actionType: ActionType.SystrayEvent,
        ),
      ]);
      Systray.registerEventHandler('toggleTimer', () {
        print('works');
        Systray.updateMenu([
          SystrayAction(
            name: "focus",
            label: "Focus",
            actionType: ActionType.Focus,
          ),
          SystrayAction(
            name: "toggleTimer",
            label: !paused ? "Start timer" : "Stop timer",
            actionType: ActionType.SystrayEvent,
          ),
        ]);
        paused = !paused;
      });
    });

    Timer.periodic(Duration(seconds: 1), (timer) {
      if (!paused) seconds++;

      generateNewIcon(_printDuration(Duration(seconds: seconds)));
      Systray.updateStatusItemIcon(MainEntry(
        title: "title",
        iconPath: '/Users/jackstefansky/Desktop/tcamp.png',
      ));
    });
  }

  String _printDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  void generateNewIcon(String text) async {
    final paint = Paint()
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.butt
      ..style = PaintingStyle.stroke;

    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: TextStyle(fontSize: 12)),
      textAlign: TextAlign.justify,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();

    final logo = await loadUiImage('assets/icon.png');
    final logoPaused = await loadUiImage('assets/icon_paused.png');

    final recorder = ui.PictureRecorder();
    final canvas = new Canvas(recorder);

    canvas.drawPaint(paint); // etc
    textPainter.paint(canvas, Offset(32, 7));
    canvas.drawImage(paused ? logoPaused : logo, Offset(8, 8), paint);

    final recordedImage = recorder.endRecording();
    final image = await recordedImage.toImage(96, 30);
    final pngBytes = await image.toByteData(format: ui.ImageByteFormat.png);

    writeToFile(pngBytes, '/Users/jackstefansky/Desktop/tcamp.png');
  }

  Future<void> writeToFile(ByteData data, String path) {
    final buffer = data.buffer;
    return new File(path).writeAsBytes(
        buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
  }

  Future<ui.Image> loadUiImage(String imageAssetPath) async {
    final ByteData data = await rootBundle.load(imageAssetPath);
    final Completer<ui.Image> completer = Completer();
    ui.decodeImageFromList(Uint8List.view(data.buffer), (ui.Image img) {
      return completer.complete(img);
    });
    return completer.future;
  }

  void systrayNew() async {
/*     final main = MainEntry(title: "title", iconPath: iconPath);

    await Systray.initSystray(main);

    Systray.updateMenu([
      SystrayAction(
        name: "focus",
        label: "Focus",
        actionType: ActionType.Focus,
      ),
    ]);

    Systray.updateStatusItemIcon(iconPath); */
  }
}
