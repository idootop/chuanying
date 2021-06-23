import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';
import 'package:remove_bg/tools/screen/screen_tool.dart';

class ToastTool {
  static void toast(String msg) {
    Widget widget = Container(
      margin: const EdgeInsets.all(50.0),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12.px),
      ),
      padding: EdgeInsets.symmetric(horizontal: 20.px, vertical: 16.px),
      child: Text(
        msg,
        textScaleFactor: 1.0,
        style: TextStyle(
          color: Colors.black,
          fontSize: 16.px,
        ),
        textAlign: TextAlign.center,
      ),
    );
    try {
      showToastWidget(
        widget,
        duration: Duration(milliseconds: 2000),
        animationDuration: Duration(milliseconds: 200),
        position: ToastPosition.center,
      );
    } catch (_) {}
  }

  static void showWidget(
    Widget child, {
    Duration? duration,
    Duration? animationDuration,
    bool handleTouch = true,
  }) {
    showToastWidget(
      child,
      duration: duration,
      animationDuration: animationDuration,
      handleTouch: handleTouch,
    );
  }

  static void dismissAll() {
    dismissAllToast();
  }
}
