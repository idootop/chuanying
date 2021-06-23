import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

Future<String> getTempPath() async {
  final dir = await getTemporaryDirectory();
  return dir.path;
}

void keepPortrait() {
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
}

void vibrate({
  bool? medium = false,
  bool? vibrate = true,
  bool? select = false,
}) {
  if (medium!) {
    HapticFeedback.mediumImpact();
  } else if (select!) {
    HapticFeedback.selectionClick();
  } else {
    HapticFeedback.vibrate();
  }
}
