import 'package:flutter/animation.dart';
import 'package:flutter/src/scheduler/ticker.dart';
import 'package:flutter/src/widgets/framework.dart';
import '../listener/MapDetailsManager.dart';
class AnimationManager implements AnimationView{

  /// 单例对象
  static AnimationManager? _instance;

  /// 内部构造方法，可避免外部暴露构造函数，进行实例化
  AnimationManager._internal();

  /// 工厂构造方法，这里使用命名构造函数方式进行声明
  factory AnimationManager.getInstance() => _getInstance();

  /// 获取单例内部方法
  static _getInstance() {
    // 只能有一个实例
    _instance ??= AnimationManager._internal();
    return _instance!;
  }

  @override
  void scaleWidget(ScaleWidget scaleWidget, Widget widget, double begin, double end, double time) {

  }

  @override
  void translateWidget(TranslateLocation translateLocation, double time, TickerProvider tickerProvider) {
    AnimationController controller = AnimationController(
      duration:  Duration(seconds: time.toInt()),
      vsync: tickerProvider,
    );
    CurvedAnimation decelerate = CurvedAnimation(parent: controller, curve: Curves.ease);
    decelerate.addListener(() {
      translateLocation(1-decelerate.value);
    });
    controller.forward();
  }
}