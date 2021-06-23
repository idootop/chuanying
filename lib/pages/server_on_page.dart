import 'package:flutter/material.dart';
import 'package:remove_bg/tools/screen/screen_tool.dart';

class ServerOnPage extends StatelessWidget {
  final String? text;
  ServerOnPage({this.text});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Text(
          text ?? '😊 传影运行中',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16.px,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
