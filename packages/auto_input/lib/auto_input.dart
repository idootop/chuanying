import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AutoInput {
  static const MethodChannel _channel = MethodChannel('auto_input');

  ///粘贴
  static Future<void> paste() => _channel.invokeMethod('paste');

  ///复制图片到粘贴板
  static Future<void> copy(String path) => _channel.invokeMethod('copy', path);

  ///截图保存至本地
  static Future<String> screenShot(String path) async {
    await _channel.invokeMethod('screenShot', path);
    return path;
  }

  ///在指定位置打开图片窗口
  static Future<void> openImageWindow({
    required String path,
    double srcX = 0,
    double srcY = 0,
    double width = 1,
    double height = 1,
  }) async {
    srcX = srcX.clamp(0, 1);
    srcY = srcY.clamp(0, 1);
    width = width.clamp(0, 1);
    height = height.clamp(0, 1);
    if (width + srcX > 1) {
      width = 1 - srcX;
    }
    if (height + srcY > 1) {
      height = 1 - srcY;
    }
    await _channel.invokeMethod('openImageWindow', {
      'path': path,
      'srcX': srcX,
      'srcY': srcY,
      'width': width,
      'height': height
    });
  }

  ///左键点击屏幕
  ///
  ///左上角为(0,0)，右下角(1,1)
  static Future<void> click(double x, double y) =>
      _channel.invokeMethod('click', {'x': x.clamp(0, 1), 'y': y.clamp(0, 1)});

  ///获取屏幕尺寸
  static Future<Size> get screenSize async {
    final Map? size = await _channel.invokeMethod('screenSize');
    return Size(size?['x'] ?? 0, size?['y'] ?? 0);
  }
}
