import 'dart:async';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:get/get.dart';
import 'package:remove_bg/states/client_state.dart';
import 'package:remove_bg/tools/client.dart';
import 'package:remove_bg/tools/core.dart';
import 'package:remove_bg/tools/screen/screen_tool.dart';
import 'package:remove_bg/widgets/loading.dart';

Future<CameraController?> initeCamera() async {
  try {
    final cameras = await availableCameras();
    final camera = cameras.firstWhere(
      (e) => e.lensDirection == CameraLensDirection.back, //后置摄像头
    );
    final controller = CameraController(
      camera,
      ResolutionPreset.high,
      enableAudio: false,
    );
    await controller.initialize();
    controller.setFlashMode(FlashMode.off);
    controller.setFocusMode(FocusMode.auto);
    return controller;
  } catch (_) {
    return null;
  }
}

class CameraPage extends StatefulWidget {
  final CameraController controller;

  CameraPage(this.controller);

  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> with TickerProviderStateMixin {
  String _selected = '图片';

  @override
  void initState() {
    super.initState();
    ClientState.init();
  }

  @override
  void dispose() {
    widget.controller.dispose();
    super.dispose();
  }

  Future<Uint8List?> takePhoto() async {
    final file = await widget.controller.takePicture();
    if (_selected == '文字' && ClientState.to.where == ClientStates.ready) {
      return zipImg(file.path,quality: 60);
    }
    return file.readAsBytes();
  }

  void _onLongPressStart() async {
    ClientState.to.where = ClientStates.ready;
    final bytes = await takePhoto();
    if (bytes == null) {
      return;
    }
    if (ClientState.to.where != ClientStates.ready) {
      ClientState.to.where = ClientStates.ready;
      return;
    }
    switch (_selected) {
      case '文字':
        Client.handleWords(bytes);
        break;
      case '公式':
        Client.handleLatex(bytes);
        break;
      case '图片':
      default:
        Client.handleImg(bytes);
    }
  }

  void _onLongPressEnd() async {
    if (ClientState.to.where != ClientStates.fetched) {
      ClientState.to.where = ClientStates.ready;
      return;
    }
    final bytes = await takePhoto();
    if (bytes == null) {
      return;
    }
    Client.handleView(bytes);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.transparent,
        body: SizedBox(
          width: 100.vw,
          height: 100.vh,
          child: CameraPreview(
            widget.controller,
            child: GetBuilder<ClientState>(
              builder: (_) => _buildOverlay(),
            ),
          ),
        ));
  }

  Widget _buildOverlay() {
    return Stack(
      alignment: Alignment.center,
      fit: StackFit.expand,
      children: [
        if ([ClientStates.fetching, ClientStates.sending]
            .contains(ClientState.to.where))
          Loading(),
        if ([ClientStates.fetched].contains(ClientState.to.where))
          _selected == '图片'
              ? Image.memory(
                  Uint8List.fromList(ClientState.to.img!),
                  fit: BoxFit.cover,
                )
              : Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: 10.vw, vertical: 30.vw),
                    child: _selected == '文字'
                        ? Text(
                            ClientState.to.words ?? '空空如也',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18.px,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : ListView(
                            shrinkWrap: true,
                            physics: BouncingScrollPhysics(),
                            scrollDirection: Axis.horizontal,
                            children: [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Math.tex(
                                    ClientState.to.latex ?? '空空如也',
                                    textStyle: TextStyle(
                                      color: Colors.white,
                                      fontSize: 24.px,
                                      overflow: TextOverflow.ellipsis,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    onErrorFallback: (err) =>
                                        Text(err.messageWithType,
                                            style: TextStyle(
                                              color: Colors.red,
                                              fontSize: 18.px,
                                              fontWeight: FontWeight.bold,
                                            )),
                                  ),
                                ],
                              ),
                            ],
                          ),
                  ),
                ),
        _bottomActions(),
      ],
    );
  }

  Widget _bottomActions() => Column(
        children: [
          Expanded(
            child: GestureDetector(
              onLongPressStart: (_) => _onLongPressStart(),
              onLongPressEnd: (_) => _onLongPressEnd(),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _bottomButton('公式', icon: Icons.change_history),
              _bottomButton('图片', icon: Icons.panorama_fish_eye),
              _bottomButton('文字', icon: Icons.check_box_outline_blank),
            ],
          ),
          SizedBox(height: 10.vw),
        ],
      );

  Widget _bottomButton(String text, {IconData? icon}) => GestureDetector(
        onTap: () {
          //正在转换中禁止切换
          if (ClientState.to.where == ClientStates.ready) {
            setState(() {
              _selected = text;
            });
          }
        },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 10.px, vertical: 5.px),
          decoration: BoxDecoration(
            border: Border.all(
                color: _selected == text ? Colors.white : Colors.transparent,
                width: 2.px),
            borderRadius: BorderRadius.all(
              Radius.circular(100.vw),
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: Colors.white,
                size: 24.px,
              ),
              SizedBox(width: 2.px),
              Text(
                text,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18.px,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      );
}
