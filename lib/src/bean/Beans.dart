import 'package:flutter/cupertino.dart';

import '../listener/MapDetailsManager.dart';

class MapInfoBean {
  double realWidth = 0; //原始宽度
  double realHeight = 0; //原始高度
  double currentWidth = 0; //当前实际宽度
  double currentHeight = 0; //当前实际高度
  double preWidth = 0; //变化前宽度
  double preHeight = 0; //变化前高度
  double minScale = 0; //最小缩放因子
  double maxScale = 2; //最大缩放因子
  double startScale = 0;
  double startCenterX = 0;
  double startCenterY = 0;
  double screenWidth = 0; //控件所占屏幕宽度
  double screenHeight = 0; //控件所占屏幕高度
  double x = 0; //实际左上角X坐标
  double y = 0; //实际左上角Y坐标
  MapType mapType = MapType.finger;
}

class MarkBean {
  Widget? widget;
  double x = 0;
  double y = 0;
  double offX = 0;
  double offY = 0;
  double width = 0; //组件宽和组件高
  double height = 0;
  GlobalKey? globalKey;
  double scaleX = 0; //宽度比例
  double scaleY = 0; //高度比例

  MarkBean(this.widget,this.x,this.y,this.globalKey,{double? offX,double? offY,double? width,double? height,double? scaleX,double? scaleY}){
    this.offX = offX??0;
    this.offY = offY??0;
    this.width = width??0;
    this.height = height??0;
    this.scaleX = scaleX??0;
    this.scaleY = scaleY??0;
  }

}

class TouchBean {
  int pointId = 0; //触点，区分手指
  double x = 0; //屏幕X坐标
  double y = 0; //屏幕Y坐标
}

//触摸屏幕的中心点
class ShowCenterBean {
  double x = 0;
  double y = 0;
  double scaleX = 0; //X轴相对百分比
  double scaleY = 0; //y轴相对百分比
}
