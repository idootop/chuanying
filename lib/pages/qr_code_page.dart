import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:remove_bg/app/server_app.dart';
import 'package:remove_bg/tools/screen/screen_tool.dart';
import 'package:remove_bg/tools/server.dart';

class QrCodePage extends StatefulWidget {
  @override
  _QrCodePageState createState() => _QrCodePageState();
}

class _QrCodePageState extends State<QrCodePage> {
  @override
  void initState() {
    super.initState();
    _generateCode();
  }

  void _generateCode() async {
    final ip = await Server.getLocalIpAddress();
    if (ip != null) {
      wsAddress ??= 'ws://$ip:8080';
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          Expanded(flex: 2, child: Container()),
          GestureDetector(
            onTap: () async {
              //
            },
            child: QrImage(
              data: wsAddress ?? '',
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              version: QrVersions.auto,
              size: 100.px,
            ),
          ),
          Expanded(flex: 1, child: Container()),
          Text(
            '打开传影扫一扫',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16.px,
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(flex: 2, child: Container()),
        ],
      ),
    );
  }
}
