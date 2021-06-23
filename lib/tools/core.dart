import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:auto_input/auto_input.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image/image.dart';
import 'package:process_run/shell.dart';
import 'package:remove_bg/app/app.dart';
import 'package:remove_bg/tools/system.dart';
import 'package:remove_bg/tools/toast.dart';

var start = DateTime.now();

void consumingTime(String text) {
  final time = DateTime.now().difference(start).inMilliseconds;
  assert(() {
    print('>>> $text $time');
    return true;
  }());
  start = DateTime.now();
}

//server端处理图片流程
Future<void> handleImage(
  List<int> imgBytes,
  List<int> viewBytes, {
  bool open = true,
  bool paste = false,
}) async {
  final img = await bytes2img(imgBytes);
  consumingTime('bytes2img');
  if (await canProject()) {
    final viewPath = await saveImgBytes(viewBytes, 'temp/view.jpg');
    consumingTime('saveImgBytes');
    var info = await trimTransparent(img);
    consumingTime('trimTransparent');
    final crop = info.image;
    final cropPath = info.path;
    info.path = viewPath;
    info.image = crop;
    info.cropPath = cropPath;
    info = await projectToScreen(info);
    consumingTime('projectToScreen');
    //复制图片到粘贴板
    await AutoInput.copy(cropPath!);
    //点击center坐标
    await AutoInput.click(info.center![0], info.center![1]);
    //粘贴
    if (paste) AutoInput.paste();
    //在指定位置打开指定大小的图片窗口
    if (open) openImageWindow(info);
    consumingTime('finish image progress');
  } else {
    var info = await trimTransparent(img);
    final cropPath = info.path;
    //复制图片到粘贴板
    await AutoInput.copy(cropPath!);
    //点击center坐标
    await AutoInput.click(0.5, 0.5);
    //粘贴
    if (paste) await AutoInput.paste();
    //打开看图
    if (open) openImageFile(cropPath);
  }
}

//server端处理文字流程
Future<void> handleWords(String words, List<int> viewBytes) async {
  if (await canProject()) {
    final viewPath = await saveImgBytes(viewBytes, 'temp/view.jpg');
    consumingTime('saveImgBytes');
    final info = await projectToScreen(ImageInfo(path: viewPath));
    consumingTime('projectToScreen');
    //复制文字到粘贴板
    await Clipboard.setData(ClipboardData(text: words));
    //点击center坐标
    await AutoInput.click(info.center![0], info.center![1]);
    //粘贴
    await AutoInput.paste();
    consumingTime('finish words progress');
  } else {
    //复制文字到粘贴板
    await Clipboard.setData(ClipboardData(text: words));
    //点击center坐标
    await AutoInput.click(0.5, 0.5);
    //粘贴
    await AutoInput.paste();
  }
}

//server端处理公式流程
Future<void> handleLatex(String latex, List<int> viewBytes) async {
  final latexPath = await latex2svg(latex);
  if (latexPath == null) {
    //复制文字到粘贴板
    await Clipboard.setData(ClipboardData(text: latex));
    return;
  }
  if (await canProject()) {
    final viewPath = await saveImgBytes(viewBytes, 'temp/view.jpg');
    consumingTime('saveImgBytes');
    final info = await projectToScreen(ImageInfo(path: viewPath));
    consumingTime('projectToScreen');
    //复制图片到粘贴板
    await AutoInput.copy(latexPath);
    //点击center坐标
    await AutoInput.click(info.center![0], info.center![1]);
    //粘贴
    await AutoInput.paste();
    //复制文字到粘贴板
    Future.delayed(Duration(milliseconds: 1000), () {
      Clipboard.setData(ClipboardData(text: latex));
    });
    consumingTime('finish latex progress');
  } else {
    //复制图片到粘贴板
    await AutoInput.copy(latexPath);
    //点击center坐标
    await AutoInput.click(0.5, 0.5);
    //粘贴
    await AutoInput.paste();
    //复制文字到粘贴板
    Future.delayed(Duration(milliseconds: 1000), () {
      Clipboard.setData(ClipboardData(text: latex));
    });
  }
}

//在指定位置打开指定大小的图片窗口
void openImageWindow(ImageInfo info) async {
  return AutoInput.openImageWindow(
    path: info.path!,
    srcX: info.srcX,
    srcY: info.srcY,
    width: info.width,
    height: info.height,
  );
}

//在指定位置打开指定大小窗口的Chrome
void openImageInChrome(ImageInfo info) async {
  const chrome = '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome';
  final size = await AutoInput.screenSize;
  final width = (size.width * info.width).floor();
  final height = (size.height * info.height).floor();
  final srcX = (size.width * info.srcX).floor();
  final srcY = (size.height * info.srcY).floor();
  Shell().runExecutableArguments(chrome, [
    '--window-position=$srcX,$srcY',
    '--window-size=$width,$height',
    '--new-window',
    info.path!,
  ]);
}

//使用open打开图片文件
Future<void> openImageFile(String path) async {
  await Shell().run('open $path');
}

///转换view坐标至screen坐标
///当前视图：view path
///裁剪图片：image cropPath
Future<ImageInfo> projectToScreen(ImageInfo view) async {
  final path = await getTempPath();
  final screenShotPath = '$path/temp/screen.jpg';
  await AutoInput.screenShot(screenShotPath);
  final result = await Shell(workingDirectory: '$path/screenpoint').run(
      '/usr/local/bin/python3 index.py ${view.path} $screenShotPath ${view.srcX} ${view.srcY} ${view.width} ${view.height}');
  final i = jsonDecode(result.outText);
  return ImageInfo(
    image: view.image,
    path: view.cropPath,
    srcX: i['topLeft'][0],
    srcY: i['topLeft'][1],
    width: i['bottomRight'][0] - i['topLeft'][0],
    height: i['bottomRight'][1] - i['topLeft'][1],
    center: i['center'],
  );
}

Future<List<int>?> removeBg(List<int> bytes) async {
  var data = FormData.fromMap({
    'size': 'auto',
    'image_file': MultipartFile.fromBytes(bytes),
  });
  final options = Options(
    responseType: ResponseType.bytes,
    headers: {
      'X-Api-Key': removeBgKey,
    },
  );
  var response = await Dio()
      .post(
    'https://api.remove.bg/v1.0/removebg',
    data: data,
    options: options,
  )
      .onError((error, stackTrace) {
    return Response(
      requestOptions: RequestOptions(path: ''),
      data: null,
    );
  });
  ;
  return await response.data;
}

Future<String?> latex2svg(String latex,
    {String output = 'temp/latex.svg'}) async {
  final url =
      'https://latex.vimsky.com/test.image.latex.php?fmt=svg&val=$latex';
  final options = Options(responseType: ResponseType.bytes);
  var response = await Dio().get(url, options: options).onError(
    (error, stackTrace) {
      return Response(
        requestOptions: RequestOptions(path: ''),
        data: null,
      );
    },
  );
  final imgData = response.data;
  if (imgData == null) return null;
  String dir = await getTempPath();
  final path = '$dir/$output';
  if (imgData is List<int>) {
    await File(path).writeAsBytes(imgData, flush: true);
  }
  return path;
}

String? token;
Future<String?> img2words(Uint8List imgBytes) async {
  var result;
  final base64 = imgBytes.toBase64();
  if (token == null) {
    const ak = baiduAk;
    const sk = baiduSk;
    result = await Dio()
        .get(
      'https://aip.baidubce.com/oauth/2.0/token?grant_type=client_credentials&client_id=$ak&client_secret=$sk',
    )
        .onError((error, stackTrace) {
      ToastTool.toast('识别失败:(');
      return Response(
        requestOptions: RequestOptions(path: ''),
        data: {},
      );
    });
    token = result?.data['access_token'];
  }
  result = await Dio()
      .post(
    'https://aip.baidubce.com/rest/2.0/ocr/v1/accurate_basic?access_token=$token',
    data: {'image': base64},
    options: Options(contentType: 'application/x-www-form-urlencoded'),
  )
      .onError((error, stackTrace) {
    ToastTool.toast('识别失败:(');
    return Response(
      requestOptions: RequestOptions(path: ''),
      data: {},
    );
  });
  return result?.data['words_result']
      ?.map((e) => e['words'])
      .toList()
      .join('\n');
}

Future<String?> img2latex(Uint8List imgBytes) async {
  final base64 = imgBytes.toBase64();
  final result = await Dio()
      .post('https://api.mathpix.com/v3/latex',
          data: jsonEncode({
            'src': "data:image/jpg;base64," + base64,
            'formats': ['latex_simplified'],
          }),
          options: Options(
            contentType: ContentType.json.toString(),
            headers: {
              "app_id": mathpixId,
              "app_key": mathpixKey,
            },
          ))
      .onError((error, stackTrace) {
    ToastTool.toast('识别失败:(');
    return Response(
      requestOptions: RequestOptions(path: ''),
      data: {},
    );
  });
  return result.data['latex_simplified'];
}

///裁剪透明背景并保存到本地，返回子图在原图中的相对位置
Future<ImageInfo> trimTransparent(Image src) async {
  final crop = findTrim(src, mode: TrimMode.transparent, sides: Trim.all);
  final dst = Image(crop[2], crop[3], exif: src.exif, iccp: src.iccProfile);
  copyInto(dst, src,
      srcX: crop[0], srcY: crop[1], srcW: crop[2], srcH: crop[3], blend: false);
  final savePath = await saveImg(dst, 'temp/crop.jpg');
  return ImageInfo(
    image: dst,
    path: savePath,
    srcX: crop[0] / src.width,
    srcY: crop[1] / src.height,
    width: crop[2] / src.width,
    height: crop[3] / src.height,
  );
}

///当前python环境是否可用
Future<bool> canProject() async {
  var error = false;
  String dir = await getTempPath();
  var file = File('$dir/screenpoint.zip');
  if (!file.existsSync()) {
    await copyAsset2Document('assets/screenpoint.zip', file.path);
    await Shell(workingDirectory: dir).run('unzip screenpoint.zip');
  }
  final result = await Shell(workingDirectory: '$dir/screenpoint')
      .run('/usr/local/bin/python3 index.py ok')
      .onError((error, stackTrace) {
    error = true;
    return [];
  });
  return error ? false : result.outText.contains('ok');
}

///复制安装包中的资源文件到本地目标路径
Future<void> copyAsset2Document(String assetPath, String documentPath) async {
  var data = await rootBundle.load(assetPath);
  final bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
  var file = File(documentPath);
  if (!file.existsSync()) {
    file = await file.create(recursive: true);
  }
  await file.writeAsBytes(bytes, flush: true);
}

///压缩图片
Future<Uint8List?> zipImg(String path, {int quality = 85}) async =>
    FlutterImageCompress.compressWithFile(
      path,
      minWidth: 128,
      minHeight: 128,
      quality: quality,
    );

Future<String> saveImg(Image img, String path) async {
  String dir = await getTempPath();
  var file = File('$dir/$path');
  if (!file.existsSync()) {
    file = await file.create(recursive: true);
  }
  await file.writeAsBytes(await img2bytes(img), flush: true);
  return '$dir/$path';
}

Future<String> saveImgBytes(List<int> bytes, String path) async {
  String dir = await getTempPath();
  var file = File('$dir/$path');
  if (!file.existsSync()) {
    file = await file.create(recursive: true);
  }
  await file.writeAsBytes(bytes, flush: true);
  return '$dir/$path';
}

Image $bytes2img(List<int> data) => decodeImage(data)!;

Future<Image> bytes2img(List<int> data) async =>
    await compute($bytes2img, data);

List<int> $img2bytes(Image img) => encodePng(img);

Future<List<int>> img2bytes(Image img) async => await compute($img2bytes, img);

Future<String> img2base64(Image img) async => (await img2bytes(img)).toBase64();

Future<Image> base642img(String str) async => bytes2img(str.toBytes());

extension Base64ToBytes on String {
  List<int> toBytes() => base64Decode(this);
}

extension BytesToBase64 on List<int> {
  String toBase64() => base64Encode(this);
}

class ImageInfo {
  Image? image;
  String? path;
  String? cropPath;
  double srcX;
  double srcY;
  double width;
  double height;
  List? center;
  ImageInfo({
    this.image,
    this.path,
    this.cropPath,
    this.center,
    this.srcX = 0,
    this.srcY = 0,
    this.width = 1,
    this.height = 1,
  });
}

enum TransformDataType { img, view, words, latex }

class TransformData {
  late int type;
  late int uid;
  late List<int> data;

  ///获取原始数据，字符串或图片二进制
  dynamic get originData {
    if ([TransformDataType.img.index, TransformDataType.view.index]
        .contains(type)) {
      return Uint8List.fromList(data);
    } else if ([TransformDataType.words.index, TransformDataType.latex.index]
        .contains(type)) {
      return utf8.decode(data);
    }
  }

  List<int> toList() => <int>[type, uid, ...data];

  TransformData.fromList(List<int> data) {
    type = data[0];
    uid = data[1];
    this.data = data.sublist(2);
  }

  TransformData.fromImg(int uid, Uint8List img) {
    type = TransformDataType.img.index;
    this.uid = uid;
    this.data = img;
  }

  TransformData.fromView(int uid, Uint8List view) {
    type = TransformDataType.view.index;
    this.uid = uid;
    this.data = view;
  }

  TransformData.fromWord(int uid, String words) {
    type = TransformDataType.words.index;
    this.uid = uid;
    this.data = utf8.encode(words);
  }

  TransformData.fromLatex(int uid, String latex) {
    type = TransformDataType.latex.index;
    this.uid = uid;
    this.data = utf8.encode(latex);
  }
}
