import 'dart:math';
import 'dart:typed_data';

import 'package:remove_bg/states/client_state.dart';
import 'package:remove_bg/tools/core.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/status.dart' as status;

class Client {
  static IOWebSocketChannel? _channel;

  static late int _uid;

  static void run(
    String server, {
    Function(String)? onData,
    Function? onConnect,
    Function? onDisconnect,
  }) {
    _channel = IOWebSocketChannel.connect(Uri.parse(server));

    _channel?.stream.listen(
      (data) {
        if (data == null) return;
        if (data == 'connected') {
          onConnect?.call();
        } else {
          onData?.call(data);
        }
      },
      onDone: () {
        onDisconnect?.call();
      },
    );
  }

  static void send(dynamic data) {
    _channel?.sink.add(data);
  }

  static close() {
    _channel?.sink.close(status.goingAway);
  }

  static void sendView(Uint8List view) {
    send(TransformData.fromView(_uid, view).toList());
  }

  static void sendImg(Uint8List img) {
    _uid = Random().nextInt(255);
    send(TransformData.fromImg(_uid, img).toList());
  }

  static void sendWord(String words) {
    _uid = Random().nextInt(255);
    send(TransformData.fromWord(_uid, words).toList());
  }

  static void sendLatex(String latex) {
    _uid = Random().nextInt(255);
    send(TransformData.fromLatex(_uid, latex).toList());
  }

  static void handleView(Uint8List img) async {
    ClientState.to.where = ClientStates.sending;
    Client.sendView(img);
  }

  static void handleImg(Uint8List img) async {
    ClientState.to.where = ClientStates.fetching;
    var newImg = await removeBg(img);
    if (newImg == null) {
      ClientState.to.where = ClientStates.ready;
      return;
    }
    if (ClientState.to.where != ClientStates.fetching) {
      ClientState.to.where = ClientStates.ready;
      return;
    }
    ClientState.to.img = newImg;
    ClientState.to.where = ClientStates.fetched;
    Client.sendImg(Uint8List.fromList(newImg));
  }

  static void handleWords(Uint8List img) async {
    ClientState.to.where = ClientStates.fetching;
    final words = await img2words(img);
    if (words != null) {
      if (ClientState.to.where != ClientStates.fetching) {
        ClientState.to.where = ClientStates.ready;
        return;
      }
      ClientState.to.words = words;
      ClientState.to.where = ClientStates.fetched;
      Client.sendWord(words);
    } else {
      ClientState.to.where = ClientStates.ready;
    }
  }

  static void handleLatex(Uint8List img) async {
    ClientState.to.where = ClientStates.fetching;
    final latex = await img2latex(img);
    if (latex != null) {
      if (ClientState.to.where != ClientStates.fetching) {
        ClientState.to.where = ClientStates.ready;
        return;
      }
      ClientState.to.latex = latex;
      ClientState.to.where = ClientStates.fetched;
      Client.sendLatex(latex);
    } else {
      ClientState.to.where = ClientStates.ready;
    }
  }
}
