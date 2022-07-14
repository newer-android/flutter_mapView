import 'dart:io';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../bean/Beans.dart';
import '../listener/MapDetailsManager.dart';
import '../roads/RoadPath.dart';

///加载Url
class AddUrlWidget implements AddMapWidget {
  /// 单例对象
  static AddUrlWidget? _instance;

  /// 内部构造方法，可避免外部暴露构造函数，进行实例化
  AddUrlWidget._internal();

  /// 工厂构造方法，这里使用命名构造函数方式进行声明
  factory AddUrlWidget.getInstance() => _getInstance();

  /// 获取单例内部方法
  static _getInstance() {
    // 只能有一个实例
    _instance ??= AddUrlWidget._internal();
    return _instance!;
  }

  @override
  Positioned addBottomMap(
      MapInfoBean mapInfoBean,ImageProvider imageProvider) {
    return Positioned(
      left: mapInfoBean.x,
      top: mapInfoBean.y,
      child: Image(
              image: imageProvider,
              width: mapInfoBean.currentWidth,
              height: mapInfoBean.currentHeight,
              fit: BoxFit.fill,
            ),
    );
  }

  @override
  Positioned addMap(MapInfoBean mapInfoBean, Widget? loadWidget,
      ImageProvider mapProvider) {
    return Positioned(
      left: mapInfoBean.x,
      top: mapInfoBean.y,
      child: Image(
        loadingBuilder:(context,child,loadingProgress){
          if(loadingProgress==null){
            return child;
          }
          return Center(child: loadWidget??Text('正在加载,请稍候'),);
        },
        image: mapProvider,
        width: mapInfoBean.currentWidth,
        height: mapInfoBean.currentHeight,
        fit: BoxFit.fill,
      ),
    );
  }

  @override
  Positioned addRoad(List<List<Offset>> roads, MapInfoBean mapInfoBean) {
    return Positioned(
      left: mapInfoBean.x,
      top: mapInfoBean.y,
      child: Container(
        width: mapInfoBean.currentWidth,
        height: mapInfoBean.currentHeight,
        color: Colors.transparent,
        child: RoadPath(
            width: mapInfoBean.currentWidth,
            height: mapInfoBean.currentHeight,
            roads: roads,
            scaled: mapInfoBean.currentWidth / mapInfoBean.realWidth),
      ),
    );
  }

  @override
  Positioned addRoadImage(
      MapInfoBean mapInfoBean, ImageProvider imageProvider) {
    return Positioned(
      left: mapInfoBean.x,
      top: mapInfoBean.y,
      child: Image(
              image: imageProvider,
              width: mapInfoBean.currentWidth,
              height: mapInfoBean.currentHeight,
              fit: BoxFit.fill,
            ),
    );
  }

  @override
  List<Positioned> addMarks(List<MarkBean> markInfo) {
    List<Positioned> widgets = [];
    for (var element in markInfo) {
      Positioned positioned = Positioned(
        key: element.globalKey,
        left: element.x - element.width * element.offX,
        top: element.y - element.width * element.offY,
        child: Opacity(
          opacity: element.width == 0 ? 0 : 1,
          child: element.widget!,
        ),
      );
      widgets.add(positioned);
    }
    return widgets;
  }

  @override
  List<Positioned> addWidgets(List<Widget> widgets, MapInfoBean mapInfoBean) {
    List<Positioned> widgets = [];
    for (var element in widgets) {
      Positioned positioned = Positioned(
        left: mapInfoBean.x,
        top: mapInfoBean.y,
        child: SizedBox(
          width: mapInfoBean.currentWidth,
          height: mapInfoBean.currentHeight,
          child: element,
        ),
      );
      widgets.add(positioned);
    }
    return widgets;
  }
}
