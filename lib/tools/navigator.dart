import 'package:flutter/widgets.dart';

final router = NavigatorTool();

class NavigatorTool extends NavigatorObserver {
  factory NavigatorTool() => _instance;
  NavigatorTool._();
  static final NavigatorTool _instance = NavigatorTool._();

  BuildContext? get context => _instance.navigator?.context;

  void pop<T extends Object?>([T? result]) => _instance.navigator?.pop(result);

  Future<T?> push<T extends Object?>(Widget child) async =>
      await _instance.navigator?.push<T>(_page<T>(child));

  Future<T?> replace<T extends Object?>(Widget child) async =>
      await _instance.navigator?.pushReplacement(_page<T>(child));

  Future<T?> pushToBeRoot<T extends Object?>(Widget child) async =>
      await _instance.navigator?.pushAndRemoveUntil<T>(
        _page<T>(child),
        ModalRoute.withName('/'),
      );

  Route<T> _page<T extends Object?>(Widget child) {
    return PageRouteBuilder(
      opaque: false,
      transitionDuration: Duration.zero,
      pageBuilder: (_, __, ___) => child,
      transitionsBuilder: (_, __, ___, ____) => child,
    );
  }
}
