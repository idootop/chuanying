import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:remove_bg/tools/screen/screen_tool.dart';

class Loading extends StatefulWidget {
  const Loading({Key? key}) : super(key: key);

  @override
  _LoadingState createState() => _LoadingState();
}

class _LoadingState extends State<Loading> with SingleTickerProviderStateMixin {
  //动画控制器
  late AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  double value(double begin, double end, bool reverse) => controller
      .drive(CurveTween(curve: Curves.easeInOut))
      .drive(Tween(
        begin: reverse ? end : begin,
        end: reverse ? begin : end,
      ))
      .value;

  Widget cricle(bool reverse) {
    double beginSize = 6.vw * 0.618;
    double endSize = 6.vw;
    double beginOpacity = .9;
    double endOpacity = .3;
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) => Container(
        width: value(beginSize, endSize, reverse),
        height: value(beginSize, endSize, reverse),
        decoration: BoxDecoration(
            color: Colors.white
                .withOpacity(value(beginOpacity, endOpacity, reverse)),
            borderRadius:
                BorderRadius.circular(value(beginSize, endSize, reverse) / 2)),
      ),
    );
  }

  List<int> range(int n) {
    List<int> list = [];
    for (var i = 0; i < n; i++) {
      list.add(i + 1);
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GridView.count(
        shrinkWrap: true,
        crossAxisCount: 3,
        children: range(9)
            .map<Widget>((e) => Center(child: cricle(e.isOdd)))
            .toList(),
      ),
    );
  }
}
