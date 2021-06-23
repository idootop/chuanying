import 'dart:io';

import 'package:get_server/get_server.dart';
import 'package:remove_bg/pages/qr_code_page.dart';
import 'package:remove_bg/pages/server_on_page.dart';
import 'package:remove_bg/tools/core.dart';
import 'package:remove_bg/tools/navigator.dart';
import 'package:remove_bg/tools/toast.dart';

class Server {
  ///上一次收到的数据
  static TransformData? lastData;

  ///开始服务
  static Future<bool> run() async {
    final localIp = await getLocalIpAddress();
    if (localIp == null) return false;
    //创建本地Server
    final app = GetServer(
      host: localIp,
      port: 8080,
      cors: true,
    );
    //socket
    app.ws(
      '/',
      (ctx) => Socket(builder: (socket) {
        //连接成功
        socket.onOpen((ws) {
          ws.send('connected');
          router.replace(ServerOnPage());
        });
        //收到消息
        socket.onMessage((data) {
          if (data is List<int>) {
            final oldData = lastData;
            final newData = TransformData.fromList(data);
            if (oldData != null && oldData.uid == newData.uid) {
              if (oldData.type == TransformDataType.img.index) {
                handleImage(oldData.originData, newData.originData)
                    .then((_) => socket.send('done'));
              } else if (oldData.type == TransformDataType.words.index) {
                handleWords(oldData.originData, newData.originData)
                    .then((_) => socket.send('done'));
              } else if (oldData.type == TransformDataType.latex.index) {
                handleLatex(oldData.originData, newData.originData)
                    .then((_) => socket.send('done'));
              }
            }
            lastData = newData;
          }
          if (data is String) {
            ToastTool.toast(data);
            socket.send(data);
          }
        });
        //连接关闭
        socket.onClose((close) {
          router.replace(QrCodePage());
        });
      }),
    );
    app.controller.start();
    return true;
  }

  /// 获取内网IP地址
  static Future<String?> getLocalIpAddress() async {
    final interfaces = await NetworkInterface.list(
        type: InternetAddressType.IPv4, includeLinkLocal: true);

    try {
      // Try VPN connection first
      NetworkInterface vpnInterface =
          interfaces.firstWhere((element) => element.name == "tun0");
      return vpnInterface.addresses.first.address;
    } on StateError {
      try {
        // Try wlan connection next
        NetworkInterface interface =
            interfaces.firstWhere((element) => element.name == "wlan0");
        return interface.addresses.first.address;
      } catch (e) {
        // Try any other connection next
        try {
          NetworkInterface interface = interfaces.firstWhere((element) =>
              !(element.name == "tun0" || element.name == "wlan0"));
          return interface.addresses.first.address;
        } catch (e) {
          return null;
        }
      }
    }
  }
}
