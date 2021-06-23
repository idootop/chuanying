import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';
import 'package:remove_bg/app/app.dart';
import 'package:remove_bg/tools/screen/screen_tool.dart';
import 'package:remove_bg/tools/system.dart';

import 'tools/navigator.dart';

void main() {
  runApp(MyApp());
  keepPortrait();
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return OKToast(
      child: ScreenConfig(
        builder: () => MaterialApp(
          title: '传影',
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
          home: app(),
          navigatorObservers: [router],
        ),
      ),
    );
  }
}
