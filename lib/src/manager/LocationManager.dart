import 'dart:ui';

import 'package:flutter/cupertino.dart';

import '../bean/Beans.dart';
import '../listener/MapDetailsManager.dart';

///坐标转换，缩放、平移后的坐标,手势
class LocationManager implements ChangeLocation {
  /// 单例对象
  static LocationManager? _instance;

  /// 内部构造方法，可避免外部暴露构造函数，进行实例化
  LocationManager._internal();

  /// 工厂构造方法，这里使用命名构造函数方式进行声明
  factory LocationManager.getInstance() => _getInstance();

  /// 获取单例内部方法
  static _getInstance() {
    // 只能有一个实例
    _instance ??= LocationManager._internal();
    return _instance!;
  }

  ///获取Mark坐标
  @override
  void changeMarkScaleCoordinate(
      List<MarkBean> markBeans, double scale, MapInfoBean mapInfoBean) {
    for (var element in markBeans) {
      element.x = mapInfoBean.x + mapInfoBean.currentWidth * element.scaleX;
      element.y = mapInfoBean.y + mapInfoBean.currentHeight * element.scaleY;
    }
  }

  @override
  Offset getMouseCenter() {
    // TODO: implement getMouseCenter
    throw UnimplementedError();
  }

  ///地图移动，地图信息修改
  @override
  void changeMapMoveInfo(
      MapInfoBean mapInfoBean, double distanceX, double distanceY) {
    //X轴移动
    if (distanceX > 0) {
      //右移
      if ((mapInfoBean.x + distanceX) > 0) {
        distanceX = 0 - mapInfoBean.x;
      }
    } else {
      //左移

      if ((mapInfoBean.x + distanceX) <
          (mapInfoBean.screenWidth - mapInfoBean.currentWidth)) {
        distanceX =
            mapInfoBean.screenWidth - mapInfoBean.currentWidth - mapInfoBean.x;
      }
    }

    if (mapInfoBean.currentHeight <= mapInfoBean.screenHeight) {
      double y = mapInfoBean.screenHeight / 2 - mapInfoBean.currentHeight / 2;
      distanceY = y - mapInfoBean.y;
    } else {
      //Y轴移动
      if (distanceY > 0) {
        //下移
        if ((mapInfoBean.y + distanceY) > 0) {
          distanceY = 0 - mapInfoBean.y;
        }
      } else {
        //上移
        if ((mapInfoBean.y + distanceY) <
            (mapInfoBean.screenHeight - mapInfoBean.currentHeight)) {
          distanceY = mapInfoBean.screenHeight -
              mapInfoBean.currentHeight -
              mapInfoBean.y;
        }
      }
    }

    mapInfoBean.x += distanceX;
    mapInfoBean.y += distanceY;
  }

  ///地图缩放，地图信息修改
  @override
  void changeMapScaleInfo(MapInfoBean mapInfoBean, double scale,
      ShowCenterBean showCenter, Offset touchCenter,MapType mapType) {
    if(mapType == MapType.finger){
      if (scale > 1) {
        //放大
        if (mapInfoBean.currentWidth <
            mapInfoBean.realWidth * mapInfoBean.maxScale) {
          if (mapInfoBean.preWidth * scale >=
              mapInfoBean.realWidth * mapInfoBean.maxScale) {
            //设置最大缩放倍数
            mapInfoBean.currentWidth =
                mapInfoBean.realWidth * mapInfoBean.maxScale;
            mapInfoBean.currentHeight =
                mapInfoBean.realHeight * mapInfoBean.maxScale;
          } else {
            //正常放大
            mapInfoBean.currentWidth = mapInfoBean.preWidth * scale;
            mapInfoBean.currentHeight = mapInfoBean.preHeight * scale;
          }
          showCenter.x = mapInfoBean.currentWidth * showCenter.scaleX;
          mapInfoBean.x = touchCenter.dx - showCenter.x;
          showCenter.y = mapInfoBean.currentHeight * showCenter.scaleY;
          mapInfoBean.y = touchCenter.dy - showCenter.y;
        }
      } else {
        //缩小
        if (mapInfoBean.currentWidth >
            mapInfoBean.realWidth * mapInfoBean.minScale) {
          if (mapInfoBean.preWidth * scale <=
              mapInfoBean.realWidth * mapInfoBean.minScale) {
            //设置最小倍数
            mapInfoBean.currentWidth =
                mapInfoBean.realWidth * mapInfoBean.minScale;
            mapInfoBean.currentHeight =
                mapInfoBean.realHeight * mapInfoBean.minScale;
          } else {
            //正常缩小
            mapInfoBean.currentWidth = mapInfoBean.preWidth * scale;
            mapInfoBean.currentHeight = mapInfoBean.preHeight * scale;
          }
        }

        showCenter.x = mapInfoBean.currentWidth * showCenter.scaleX;

        if (touchCenter.dx - showCenter.x >= 0) {
          //左侧不能进屏幕
          mapInfoBean.x = 0;
        } else if (touchCenter.dx - showCenter.x <=
            (mapInfoBean.screenWidth - mapInfoBean.currentWidth)) {
          //右侧不能进屏幕
          mapInfoBean.x = mapInfoBean.screenWidth - mapInfoBean.currentWidth;
        } else {
          mapInfoBean.x = touchCenter.dx - showCenter.x;
        }

        //缩小后高度是否小于屏幕
        if (mapInfoBean.currentHeight <= mapInfoBean.screenHeight) {
          mapInfoBean.y =
              mapInfoBean.screenHeight / 2 - mapInfoBean.currentHeight / 2;
        } else {
          showCenter.y = mapInfoBean.currentHeight * showCenter.scaleY;
          if ((touchCenter.dy - showCenter.y) >= 0) {
            //上边界不能进图屏幕
            mapInfoBean.y = 0;
          } else if ((touchCenter.dy - showCenter.y) <=
              (mapInfoBean.screenHeight - mapInfoBean.currentHeight)) {
            //下边界不能进图屏幕
            mapInfoBean.y = mapInfoBean.screenHeight - mapInfoBean.currentHeight;
          } else {
            mapInfoBean.y = touchCenter.dy - showCenter.y;
          }
        }
      }
    }else{
      var currentScale = mapInfoBean.currentWidth/mapInfoBean.realWidth;
      if(scale>0){
        //放大
        if (mapInfoBean.currentWidth <
            mapInfoBean.realWidth * mapInfoBean.maxScale) {
          if ((currentScale+scale) >= mapInfoBean.maxScale) {
            //设置最大缩放倍数
            mapInfoBean.currentWidth =
                mapInfoBean.realWidth * mapInfoBean.maxScale;
            mapInfoBean.currentHeight =
                mapInfoBean.realHeight * mapInfoBean.maxScale;
          } else {
            //正常放大
            mapInfoBean.currentWidth = mapInfoBean.realWidth * (currentScale+scale);
            mapInfoBean.currentHeight = mapInfoBean.realHeight * (currentScale+scale);
          }
          showCenter.x = mapInfoBean.currentWidth * showCenter.scaleX;
          mapInfoBean.x = touchCenter.dx - showCenter.x;
          showCenter.y = mapInfoBean.currentHeight * showCenter.scaleY;
          mapInfoBean.y = touchCenter.dy - showCenter.y;
        }
      }else{
        //缩小
        if (currentScale > mapInfoBean.minScale) {
          if ((currentScale + scale) <= mapInfoBean.minScale) {
            //设置最小倍数
            mapInfoBean.currentWidth =
                mapInfoBean.realWidth * mapInfoBean.minScale;
            mapInfoBean.currentHeight =
                mapInfoBean.realHeight * mapInfoBean.minScale;
          } else {
            //正常缩小
            mapInfoBean.currentWidth = mapInfoBean.realWidth * (scale+currentScale);
            mapInfoBean.currentHeight = mapInfoBean.realHeight * (scale+currentScale);
          }
        }

        showCenter.x = mapInfoBean.currentWidth * showCenter.scaleX;

        if (touchCenter.dx - showCenter.x >= 0) {
          //左侧不能进屏幕
          mapInfoBean.x = 0;
        } else if (touchCenter.dx - showCenter.x <=
            (mapInfoBean.screenWidth - mapInfoBean.currentWidth)) {
          //右侧不能进屏幕
          mapInfoBean.x = mapInfoBean.screenWidth - mapInfoBean.currentWidth;
        } else {
          mapInfoBean.x = touchCenter.dx - showCenter.x;
        }

        //缩小后高度是否小于屏幕
        if (mapInfoBean.currentHeight <= mapInfoBean.screenHeight) {
          mapInfoBean.y =
              mapInfoBean.screenHeight / 2 - mapInfoBean.currentHeight / 2;
        } else {
          showCenter.y = mapInfoBean.currentHeight * showCenter.scaleY;
          if ((touchCenter.dy - showCenter.y) >= 0) {
            //上边界不能进图屏幕
            mapInfoBean.y = 0;
          } else if ((touchCenter.dy - showCenter.y) <=
              (mapInfoBean.screenHeight - mapInfoBean.currentHeight)) {
            //下边界不能进图屏幕
            mapInfoBean.y = mapInfoBean.screenHeight - mapInfoBean.currentHeight;
          } else {
            mapInfoBean.y = touchCenter.dy - showCenter.y;
          }
        }
      }
    }

  }

  @override
  void moveToCenter(
      double x, double y, MapInfoBean mapInfoBean, List<MarkBean> markBean) {

    var realX = x * (mapInfoBean.currentWidth / mapInfoBean.realWidth);
    var realY = y * (mapInfoBean.currentHeight / mapInfoBean.realHeight);

    if(realX<mapInfoBean.screenWidth/2){
      //判断左侧进入屏幕
      mapInfoBean.x = 0;
    }else if(mapInfoBean.currentWidth-realX<mapInfoBean.screenWidth/2){
      //判断右侧进入屏幕
      mapInfoBean.x = mapInfoBean.screenWidth-mapInfoBean.currentWidth;
    }else{
      mapInfoBean.x = mapInfoBean.screenWidth/2-realX;
    }

    if(mapInfoBean.currentHeight<mapInfoBean.screenHeight){
      //高度小于屏幕
      mapInfoBean.y = mapInfoBean.screenHeight/2-mapInfoBean.currentHeight/2;
    }else{
      if(realY<mapInfoBean.screenHeight/2){
        mapInfoBean.y=0;
      }else if(mapInfoBean.currentHeight-realY<mapInfoBean.screenHeight/2){
        mapInfoBean.y = mapInfoBean.screenHeight-mapInfoBean.currentHeight;
      }else{
        mapInfoBean.y = mapInfoBean.screenHeight/2-realY;
      }
    }

    for (var element in markBean) {
      element.x = mapInfoBean.x + mapInfoBean.currentWidth * element.scaleX;
      element.y = mapInfoBean.y + mapInfoBean.currentHeight * element.scaleY;
    }

  }
}



///坐标转换，鼠标缩放、平移后的坐标
class MouseLocationManager implements ChangeLocation{

  /// 单例对象
  static MouseLocationManager? _instance;

  /// 内部构造方法，可避免外部暴露构造函数，进行实例化
  MouseLocationManager._internal();

  /// 工厂构造方法，这里使用命名构造函数方式进行声明
  factory MouseLocationManager.getInstance() => _getInstance();

  /// 获取单例内部方法
  static _getInstance() {
    // 只能有一个实例
    _instance ??= MouseLocationManager._internal();
    return _instance!;
  }

  @override
  void changeMapMoveInfo(MapInfoBean mapInfoBean, double distanceX, double distanceY) {
    //X轴移动
    if (distanceX > 0) {
      //右移
      if ((mapInfoBean.x + distanceX) > 0) {
        distanceX = 0 - mapInfoBean.x;
      }
    } else {
      //左移

      if ((mapInfoBean.x + distanceX) <
          (mapInfoBean.screenWidth - mapInfoBean.currentWidth)) {
        distanceX =
            mapInfoBean.screenWidth - mapInfoBean.currentWidth - mapInfoBean.x;
      }
    }

    if (mapInfoBean.currentHeight <= mapInfoBean.screenHeight) {
      double y = mapInfoBean.screenHeight / 2 - mapInfoBean.currentHeight / 2;
      distanceY = y - mapInfoBean.y;
    } else {
      //Y轴移动
      if (distanceY > 0) {
        //下移
        if ((mapInfoBean.y + distanceY) > 0) {
          distanceY = 0 - mapInfoBean.y;
        }
      } else {
        //上移
        if ((mapInfoBean.y + distanceY) <
            (mapInfoBean.screenHeight - mapInfoBean.currentHeight)) {
          distanceY = mapInfoBean.screenHeight -
              mapInfoBean.currentHeight -
              mapInfoBean.y;
        }
      }
    }

    mapInfoBean.x += distanceX;
    mapInfoBean.y += distanceY;
  }

  @override
  void changeMapScaleInfo(MapInfoBean mapInfoBean, double scale, ShowCenterBean showCenter, Offset touchCenter,MapType mapType) {


  }

  @override
  void changeMarkScaleCoordinate(List<MarkBean> markBean, double scale, MapInfoBean mapInfoBean) {
    for (var element in markBean) {
      element.x = mapInfoBean.x + mapInfoBean.currentWidth * element.scaleX;
      element.y = mapInfoBean.y + mapInfoBean.currentHeight * element.scaleY;
    }
  }

  @override
  Offset getMouseCenter() {
    // TODO: implement getMouseCenter
    throw UnimplementedError();
  }

  @override
  void moveToCenter(double x, double y, MapInfoBean mapInfoBean, List<MarkBean> markBean) {
    // TODO: implement moveToCenter
  }

}
