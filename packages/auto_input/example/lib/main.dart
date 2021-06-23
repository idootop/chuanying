import 'dart:async';

import 'package:auto_input/auto_input.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    String platformVersion;
    try {
      final size = await AutoInput.screenSize;
      // await AutoInput.screenShot('/Users/wjg/APP/Flutter/personal_works/remove_bg/bin/temp/screen.jpg');
      // await AutoInput.copy('/Users/wjg/APP/Flutter/personal_works/remove_bg/bin/temp/output.jpg');
      // await AutoInput.click(0.5, 0.5);
      // await AutoInput.paste();
      platformVersion = 'width:${size.width} height:${size.height}';
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Text('Running on: $_platformVersion\n'),
        ),
      ),
    );
  }
}
