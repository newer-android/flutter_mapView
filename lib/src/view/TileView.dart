import 'package:flutter/cupertino.dart';


import '../../flutter_map_view.dart';

class TileView extends StatefulWidget {
  const TileView(
      {Key? key,
      required this.width,
      required this.height,
      required this.mapProvider,
      this.baseMapProvider,
      this.roadProvider,
      this.onZoomBegin,
      this.onZoomUpdate,
      this.onZoomEnd,
      this.minScale,
      this.maxScale,
      this.mapType, //地图类型 手指和鼠标
      this.startScale, //初始化缩放倍数
      this.centerX, //初始化中心
      this.centerY, //初始化中心
      this.mouseScale, //鼠标滚轮每次缩放的倍数
      this.fitWidth, //默认宽度自适应，地图
      this.loadWidget, //等待加载的视图
      this.widgets,   //添加的图层
      this.markBeans, //Mark
      })
      : super(key: key);
  final double width;
  final double height;
  final ImageProvider mapProvider; //地图
  final ImageProvider? baseMapProvider;//底图
  final ImageProvider? roadProvider;//路线图
  final Widget? loadWidget;
  final List<Widget>?  widgets;
  final MapType? mapType; //地图类型，手势还是鼠标
  final double? minScale; //最小
  final double? maxScale; //最大
  final double? startScale; //起始
  final bool? fitWidth; //默认适配宽度
  final double? mouseScale; //每次滚轮缩放的倍数
  final double? centerX; //起始中心X
  final double? centerY; //起始中心Y
  final OnZoomBegin? onZoomBegin;
  final OnZoomUpdate? onZoomUpdate;
  final OnZoomEnd? onZoomEnd;
  final List<MarkBean>? markBeans;

  @override
  State<TileView> createState() => _TileViewState();

  void addMark(Widget widget, double x, double y, double offX, double offY) {
    _TileViewState.state?.addMark(widget, x, y, offX, offY);
  }

  void removeMark(Widget widget) {
    _TileViewState.state?.removeMark(widget);
  }

  void removeAllMark() {
    _TileViewState.state?.removeAllMark();
  }

  void drawPath(List<Offset> roads) {
    _TileViewState.state?.drawRoad(roads);
  }

  void removeAllPath() {
    _TileViewState.state?.removeAllPath();
  }

  void removePath(List<Offset> road) {
    _TileViewState.state?.removePath(road);
  }

  void moveToCenter(double x, double y) {
    _TileViewState.state?.moveToCenter(x, y);
  }

  void setScale(double scale){

  }
}

class _TileViewState extends State<TileView> with TickerProviderStateMixin {
  static _TileViewState? state;

  _TileViewState() {
    state = this;
  }

  List<List<Offset>> roads = []; //路线

  List<MarkBean> markBeans = []; //Mark
  List<GlobalKey> globalKeys = []; //获取Mark的大小

  Offset centerOffset = const Offset(0, 0);
  ShowCenterBean showCenterBean = ShowCenterBean(); //中心位置

  late WidgetsBinding widgetsBinding;

  var mapInfoBean = MapInfoBean();



  LocationManager locationManager = LocationManager.getInstance();
  AddUrlWidget addWidget = AddUrlWidget.getInstance();
  AnimationManager animationManager = AnimationManager.getInstance();



  @override
  void initState() {
    super.initState();
    mapInfoBean.realWidth = widget.width;
    mapInfoBean.preWidth = widget.width;
    mapInfoBean.currentWidth = widget.width;
    mapInfoBean.realHeight = widget.height;
    mapInfoBean.preHeight = widget.height;
    mapInfoBean.currentHeight = widget.height;
    mapInfoBean.mapType = widget.mapType ?? MapType.finger;
    mapInfoBean.minScale = widget.minScale ?? 0;
    mapInfoBean.maxScale = widget.maxScale ?? 2;
    mapInfoBean.startScale = widget.startScale ?? 0;
    mapInfoBean.startCenterX = widget.centerX ?? 0;
    mapInfoBean.startCenterY = widget.centerY ?? 0;

    if(widget.markBeans!=null){

    }


    widgetsBinding = WidgetsBinding.instance;
    //获取Mark的大小
    widgetsBinding.addPersistentFrameCallback((callBack) {
      for (var element in markBeans) {
        var size = element.globalKey?.currentContext
            ?.findRenderObject()
            ?.paintBounds
            .size;
        if (size != null) {
          if (element.width == 0 || element.height == 0) {
            element.width = size.width;
            element.height = size.height;
            setState(() {});
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constrains) {
      var viewWidth = constrains.maxWidth;
      var viewHeight = constrains.maxHeight;

      mapInfoBean.screenWidth = viewWidth;
      mapInfoBean.screenHeight = viewHeight;
      if (mapInfoBean.minScale == 0) {


        mapInfoBean.minScale = viewWidth / mapInfoBean.realWidth;
        // mapInfoBean.maxScale = mapInfoBean.minScale;
        ///初始化宽度适应屏幕
        mapInfoBean.currentHeight =
            mapInfoBean.realHeight * mapInfoBean.minScale;
        mapInfoBean.currentWidth = viewWidth;
        mapInfoBean.preHeight = mapInfoBean.currentHeight;
        mapInfoBean.preWidth = mapInfoBean.currentWidth;
        mapInfoBean.x = 0;
        mapInfoBean.y = viewHeight / 2 - mapInfoBean.currentHeight / 2;
      }
      return GestureView(
        mapType: widget.mapType ?? MapType.finger,
        onZoomListener: (scale, scaleType, scaleChange) {
          _zoomListener(scale, scaleType, scaleChange);
        },
        onMoved: (offset) {
          _move(offset);
        },
        velocity: (speedX, speedY) {
          _speed(speedX, speedY);
        },
        showCenterOffset: (offset) {
          _showCenterOffset(offset);
        },
        child: Stack(
          children: children(),
        ),
      );
    });
  }

  ///放缩操作
  void _zoomListener(
      double scale, ScaleType scaleType, ScaleChange scaleChange) {
    switch (scaleType) {
      case ScaleType.startScale:
        break;
      case ScaleType.updateScale:
        if (scaleChange == ScaleChange.scaleChange) {
          mapInfoBean.preWidth = mapInfoBean.currentWidth;
          mapInfoBean.preHeight = mapInfoBean.currentHeight;
        }
        locationManager.changeMapScaleInfo(mapInfoBean, scale, showCenterBean,
            centerOffset, widget.mapType ?? MapType.finger);
        locationManager.changeMarkScaleCoordinate(
            markBeans, scale, mapInfoBean);
        setState(() {});
        break;
      case ScaleType.endScale:
        mapInfoBean.preWidth = mapInfoBean.currentWidth;
        mapInfoBean.preHeight = mapInfoBean.currentHeight;
        break;
    }
  }

  ///移动操作
  void _move(Offset offset) {
    locationManager.changeMapMoveInfo(mapInfoBean, offset.dx, offset.dy);
    locationManager.changeMarkScaleCoordinate(markBeans, 1, mapInfoBean);
    setState(() {});
  }

  ///获取双指中心
  void _showCenterOffset(Offset offset) {
    centerOffset = offset;
    showCenterBean.scaleY =
        (offset.dy - mapInfoBean.y) / mapInfoBean.currentHeight;
    showCenterBean.scaleX =
        (offset.dx - mapInfoBean.x) / mapInfoBean.currentWidth;
    showCenterBean.x = offset.dx - mapInfoBean.x;
    showCenterBean.y = offset.dy - mapInfoBean.y;
  }

  ///快速移动
  void _speed(double speedX, double speedY) {
    animationManager.translateWidget((scale) {
      locationManager.changeMapMoveInfo(
          mapInfoBean, speedX * scale, speedY * scale);
      locationManager.changeMarkScaleCoordinate(markBeans, scale, mapInfoBean);
      setState(() {});
    }, 1, this);
  }

  //显示组件
  List<Positioned> children() {
    List<Positioned> children = [];
    //底图图层
    if (widget.baseMapProvider != null) {
      children.add(addWidget.addBottomMap(mapInfoBean,widget.baseMapProvider!));
    }
    //地图图层
    children.add(addWidget.addMap(mapInfoBean, widget.loadWidget,widget.mapProvider));

    //添加自定义的widget
    if(widget.widgets!=null){
      children.addAll(addWidget.addWidgets(widget.widgets!, mapInfoBean));
    }

    //路线层
    if (roads.isNotEmpty) {
      children.add(addWidget.addRoad(roads, mapInfoBean));
    }

    //路线层，路线
    if (widget.roadProvider != null) {
      children.add(addWidget.addRoadImage(mapInfoBean,widget.roadProvider!));
    }

    //添加Mark
    if (markBeans.isNotEmpty) {
      children.addAll(addWidget.addMarks(markBeans));
    }
    return children;
  }

  ///添加Mark
  void addMark(Widget widget, double x, double y, double offX, double offY) {
    MarkBean markBean = MarkBean(widget,mapInfoBean.x + x * (mapInfoBean.currentWidth / mapInfoBean.realWidth),
        mapInfoBean.y + y * (mapInfoBean.currentWidth / mapInfoBean.realWidth),
        GlobalKey(),
    offX: offX,
    offY: offY,
    width: 0,
    height: 0,
    scaleX: x / mapInfoBean.realWidth,
    scaleY: y / mapInfoBean.realHeight);
    // markBean.widget = widget;
    // markBean.x =
    //     mapInfoBean.x + x * (mapInfoBean.currentWidth / mapInfoBean.realWidth);
    // markBean.y =
    //     mapInfoBean.y + y * (mapInfoBean.currentWidth / mapInfoBean.realWidth);
    // markBean.offX = offX;
    // markBean.offY = offY;
    // markBean.width = 0;
    // markBean.height = 0;
    // markBean.scaleX = x / mapInfoBean.realWidth;
    // markBean.scaleY = y / mapInfoBean.realHeight;
    // markBean.globalKey = GlobalKey();
    markBeans.add(markBean);
    setState(() {});
  }

  ///移除全部Mark
  void removeAllMark() {
    markBeans.clear();
    setState(() {});
  }

  ///移除指定Mark
  void removeMark(Widget widget) {
    for (var element in markBeans) {
      if (element.widget == widget) {
        markBeans.remove(element);
      }
    }

    setState(() {});
  }

  ///添加路线
  void drawRoad(List<Offset> road) {
    roads.add(road);
    setState(() {});
  }

  ///移除指定路线
  void removePath(List<Offset> roads) {
    this.roads.remove(roads);
    setState(() {});
  }

  ///移除全部路线
  void removeAllPath() {
    roads.clear();
    setState(() {});
  }

  ///移到屏幕中心
  void moveToCenter(double x, double y) {
    locationManager.moveToCenter(x, y, mapInfoBean, markBeans);
    setState(() {});
  }

  ///控制缩放
  void setScale(double scale){
    //以屏幕中心点为缩放，
    centerOffset = Offset(mapInfoBean.screenWidth/2, mapInfoBean.screenHeight/2);
    showCenterBean.scaleY =
        (centerOffset.dy - mapInfoBean.y) / mapInfoBean.currentHeight;
    showCenterBean.scaleX =
        (centerOffset.dx - mapInfoBean.x) / mapInfoBean.currentWidth;
    showCenterBean.x = centerOffset.dx - mapInfoBean.x;
    showCenterBean.y = centerOffset.dy - mapInfoBean.y;
    locationManager.changeMapScaleInfo(mapInfoBean, scale, showCenterBean, centerOffset, widget.mapType!);
    mapInfoBean.currentWidth = mapInfoBean.realWidth*scale;
    mapInfoBean.currentHeight = mapInfoBean.realHeight*scale;

    setState(() {});
  }

  void setScaleWithPosition(double scale,double x,double y){

  }
}
