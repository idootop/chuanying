import 'package:get/get.dart';

enum ClientStates {
  ///准备好开始新的action
  ready,

  ///获取图片识别结果中
  fetching,

  ///已获取识别结果
  fetched,

  ///发送并等待pc端执行完毕
  sending,
}

class ClientState extends GetxController {
  static ClientState get to => Get.find();

  static void init() {
    Get.put(ClientState());
    ClientState.to.initState();
  }

  List<int>? img;
  String? latex;
  String? words;

  ClientStates _where = ClientStates.ready;

  ClientStates get where => _where;

  set where(ClientStates v) {
    if (v != _where) {
      _where = v;
      update();
    }
  }

  void initState() {
    _where = ClientStates.ready;
    img = null;
    latex = null;
    words = null;
    update();
  }
}
