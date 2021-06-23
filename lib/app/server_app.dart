import 'package:flutter/material.dart';
import 'package:remove_bg/pages/qr_code_page.dart';
import 'package:remove_bg/tools/navigator.dart';
import 'package:remove_bg/tools/server.dart';
import 'package:remove_bg/widgets/fancy_plasms.dart';

String? wsAddress;

class ServerApp extends StatefulWidget {
  @override
  _ServerAppState createState() => _ServerAppState();
}

class _ServerAppState extends State<ServerApp> {
  @override
  void initState() {
    super.initState();
    _startServer();
  }

  void _startServer() async {
    if (await Server.run()) {
      router.push(QrCodePage());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FancyPlasma(color: Colors.blue.withOpacity(0.4)),
    );
  }
}
