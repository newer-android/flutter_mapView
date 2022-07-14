import 'package:flutter/cupertino.dart';

///手势相关的回调方法

///手势、鼠标缩放
enum ScaleType{
  startScale, //放缩开始前
  updateScale,//放缩开始后
  endScale //放缩结束
}

enum ScaleChange{
  scaleChange,//连续变化，缩小到放大或者放大到缩小，重新赋值，手指使用
  scaleNormal //正常放缩
}

typedef OnZoomListener = void Function(double scale, ScaleType scaleType,ScaleChange scaleChange);

///手势、鼠标移动
typedef OnMoved = void Function(Offset offset);

///手势、鼠标中心坐标,放缩的
typedef CenterOffset = void Function(Offset centerOffset);

///手势、鼠标的移动速度
typedef VelocitySpeed = void Function(double speedX,double speedY);