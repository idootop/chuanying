import 'dart:io';

import 'package:flutter_launcher_icons/utils.dart';
import 'package:image/image.dart';

const String macosDefaultIconFolder =
    'macos/Runner/Assets.xcassets/AppIcon.appiconset/';
const String macosAssetFolder = 'macos/Runner/Assets.xcassets/';
const String macosConfigFile = 'macos/Runner.xcodeproj/project.pbxproj';
const String macosDefaultIconName = 'app_icon';

// flutter pub run flutter_launcher_icons:main

void main() {
  createIcons('logo_round.png');
}

List<int> iconSizes = [
  16,
  32,
  64,
  128,
  256,
  512,
  1024,
];

void createIcons(String filePath) {
  final Image? image = decodeImage(File(filePath).readAsBytesSync());
  if (image == null) {
    return;
  }
  image.channels = Channels.rgb;
  for (int size in iconSizes) {
    overwriteDefaultIcons(size, image);
    printStatus(
        '>>> 已创建$macosDefaultIconFolder$macosDefaultIconName${'_$size'}.png');
  }
  printStatus('>>> 修改完毕！');
}

void overwriteDefaultIcons(int size, Image image) {
  final Image newFile = createResizedImage(size, image);
  File('$macosDefaultIconFolder$macosDefaultIconName${'_$size'}.png')
      .writeAsBytesSync(encodePng(newFile));
}

Image createResizedImage(int size, Image image) {
  if (image.width >= size) {
    return copyResize(image,
        width: size, height: size, interpolation: Interpolation.average);
  } else {
    return copyResize(image,
        width: size, height: size, interpolation: Interpolation.linear);
  }
}
