import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:remove_bg/app/client_app.dart';
import 'package:remove_bg/app/server_app.dart';

bool isPhone() => Platform.isAndroid || Platform.isIOS;

Widget app() => isPhone() ? ClientApp() : ServerApp();

//https://www.remove.bg
const String removeBgKey = '';

//https://mathpix.com
const String mathpixId = '';
const String mathpixKey = '';

//http://ai.baidu.com
const String baiduAk = '';
const String baiduSk = '';
