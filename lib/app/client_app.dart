import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:remove_bg/pages/qr_scan_page.dart';
import 'package:remove_bg/tools/navigator.dart';
import 'package:remove_bg/tools/screen/screen_tool.dart';
import 'package:remove_bg/widgets/fancy_plasms.dart';

class ClientApp extends StatelessWidget {
  void _onTapButton() async {
    if (await Permission.camera.request() == PermissionStatus.granted) {
      router.replace(QrScanPage());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          FancyPlasma(color: Colors.blue.withOpacity(0.4)),
          Column(
            children: [
              Expanded(flex: 1, child: Container()),
              Text(
                '😊 欢迎来到传影',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32.px,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Expanded(flex: 1, child: Container()),
              _bottomButton(),
              SizedBox(height: 20.vh),
            ],
          ),
        ],
      ),
    );
  }

  Widget _bottomButton() => GestureDetector(
        onTap: _onTapButton,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 10.vw, vertical: 2.vw),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.all(
              Radius.circular(100.vw),
            ),
          ),
          child: Text(
            '开始使用',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24.px,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
}
