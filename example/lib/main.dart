import 'dart:async';

import 'package:flutter/material.dart';
import 'package:systray/systray.dart';

void main() async {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      color: Colors.white,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Flutter systray example app'),
        ),
        body: Center(
          child: Text(
              'There should be a menu with a Hover icon in the systray.\n\n Number of times that the counter was triggered:  '),
        ),
      ),
    );
  }

  String iconPath = "/Users/jackstefansky/Desktop/current_time.png";
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
      ]);
    });

    Timer.periodic(Duration(seconds: 2), (timer) {
      if (iconPath == "/Users/jackstefansky/Desktop/current_time.png") {
        iconPath = "/Users/jackstefansky/Desktop/test.png";
      } else {
        iconPath = "/Users/jackstefansky/Desktop/current_time.png";
      }

      Systray.updateStatusItemIcon(MainEntry(
        title: "title",
        iconPath: iconPath,
      ));
    });
  }
}
