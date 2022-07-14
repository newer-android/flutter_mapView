import 'package:flutter/widgets.dart';

import '../bean/Beans.dart';

enum MapType{
  finger, //手指
  mouse,//鼠标
}

///地图相关操作
abstract class MapDetails {
  ///基本信息相关
  void setMapSize(double width, double height);

  void addBaseMap(String url);

  void addMap(String url);

  void setScaleLimits({double minScale = 0.0, double maxScale = 2.0});

  ///Mark相关
  void addMark(Widget widget, double x, double y, double offX, double offY,
      {double width = 0.0, double height = 0.0, bool isScale = false}); //添加mark
  void removeMark(Widget widget); //删除Mark
  void removeAllMark(); //删除全部Mark

  ///路线相关
  void drawPath(List<Offset> roads); //绘制路线
  void removeAllPath(); //清除路线
  void removePath(List<Offset> roads);

  void addPath(String url);

  void removeAllWidget();

  ///移动位置
  void moveToCenter(double x, double y);

  void addZoomBegin(
      OnZoomBegin onZoomBegin, OnZoomUpdate onZoomUpdate, OnZoomEnd onZoomEnd);
}

///缩放监听
typedef OnZoomBegin = Function(double scaleBegin);

typedef OnZoomUpdate = void Function(double scaleUpdate);

typedef OnZoomEnd = void Function(double scaleEnd);

///动画监听
// ignore: camel_case_types  平移动画
typedef TranslateLocation = Function(double scale);

//缩放动画
typedef ScaleWidget = Function(Size size);

///坐标统一实现
abstract class ChangeLocation {

  void changeMarkScaleCoordinate(List<MarkBean> markBean, double scale,
      MapInfoBean mapInfoBean); //Mark坐标变化，缩放

  //地图信息变化,缩放showCenter显示坐标，touchCenter手势中心
  void changeMapScaleInfo(MapInfoBean mapInfoBean, double scale,
      ShowCenterBean showCenter, Offset touchCenter,MapType mapType);

  void changeMapMoveInfo(
      MapInfoBean mapInfoBean, double distanceX, double distanceY); //地图信息变化,移动

  Offset getMouseCenter(); //获取屏幕中心，鼠标放大，放大中心

  void moveToCenter(double x,double y,MapInfoBean mapInfoBean,List<MarkBean> markBean);
}

///用到的所有动画效果
abstract class AnimationView {
  ///位置平移动画
  ///time:动画时长
  void translateWidget(TranslateLocation translateLocation, double time,TickerProvider tickerProvider);

  ///缩放动画  begin:初始化大小，end:最终大小  time:动画时长
  void scaleWidget(
      ScaleWidget scaleWidget, Widget widget,double begin, double end, double time);
}

///添加地图各种组件
abstract class AddMapWidget {
  //添加底图
  Positioned addBottomMap(MapInfoBean mapInfoBean,ImageProvider imageProvider);
  //添加地图
  Positioned addMap(MapInfoBean mapInfoBean,Widget? loadWidget,ImageProvider mapProvider);

  Positioned addRoad(List<List<Offset>> roads,MapInfoBean mapInfoBean); //添加路线
  Positioned addRoadImage(MapInfoBean mapInfoBean,ImageProvider imageProvider); //添加路线图片

  List<Positioned> addMarks(List<MarkBean> markInfo); //添加Mark

  List<Positioned> addWidgets(List<Widget> widgets,MapInfoBean mapInfoBean); //添加图层
}
