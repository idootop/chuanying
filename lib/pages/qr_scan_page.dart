import 'package:flutter/material.dart';
import 'package:remove_bg/app/client_app.dart';
import 'package:remove_bg/pages/camera_page.dart';
import 'package:remove_bg/states/client_state.dart';
import 'package:remove_bg/tools/client.dart';
import 'package:remove_bg/tools/navigator.dart';
import 'package:remove_bg/tools/toast.dart';
import 'package:scan/scan.dart';
import 'package:remove_bg/tools/screen/screen_tool.dart';

class QrScanPage extends StatelessWidget {
  void _runClient(String server) async {
    if (!server.startsWith('ws://')) {
      ToastTool.toast('无效的地址');
      router.pushToBeRoot(ClientApp());
      return;
    }
    Client.run(
      server,
      onData: (data) {
        if (data == 'done') {
          ClientState.to.where = ClientStates.ready;
        }
      },
      onConnect: () async {
        final controller = await initeCamera();
        if (controller != null) {
          ToastTool.toast('已连接');
          router.push(CameraPage(controller));
        } else {
          ToastTool.toast('未知错误');
          router.pushToBeRoot(ClientApp());
        }
      },
      onDisconnect: () {
        ToastTool.toast('连接已关闭');
        router.pushToBeRoot(ClientApp());
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        width: 100.vw,
        height: 100.vh,
        child: ScanView(
          scanAreaScale: .7,
          scanLineColor: Colors.blue.shade400,
          onCapture: _runClient,
        ),
      ),
    );
  }
}
