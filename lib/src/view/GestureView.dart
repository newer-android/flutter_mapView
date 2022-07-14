import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';

import '../bean/Beans.dart';
import '../listener/GestureListener.dart';
import '../listener/MapDetailsManager.dart';

class GestureView extends StatefulWidget {
  const GestureView(
      {Key? key,
      this.mapType,
      this.onZoomListener,
      this.onMoved,
      this.showCenterOffset,
      this.velocity,
      required this.child,
      this.mouseScale})
      : super(key: key);

  final MapType? mapType;
  final double? mouseScale;
  final OnZoomListener? onZoomListener;
  final OnMoved? onMoved;
  final CenterOffset? showCenterOffset;
  final VelocitySpeed? velocity;
  final Widget child;

  @override
  State<GestureView> createState() => _GestureViewState();
}

class _GestureViewState extends State<GestureView> {
  late Offset lastOffset;
  double scale = 1;

  List<TouchBean> touchPoint = []; //存储手势的点位
  Offset centerOffset = const Offset(0, 0); //屏幕中心坐标

  //鼠标
  int startTime = 0;
  int endTime = 0;
  Offset startLocation = const Offset(0, 0); //按下坐标
  Offset endLocation = const Offset(0, 0); //松开坐标


  @override
  Widget build(BuildContext context) {
    return checkMapType()
        ? GestureDetector(
            onScaleStart: (ScaleStartDetails details) {
              lastOffset = details.focalPoint;
              if (widget.onZoomListener != null) {
                widget.onZoomListener!(
                    1, ScaleType.startScale, ScaleChange.scaleNormal);
              }
            },
            onScaleEnd: (ScaleEndDetails details) {
              if (details.velocity.pixelsPerSecond.distanceSquared >
                  120 * 120) {
                double speedX = details.velocity.pixelsPerSecond.dx / 100;
                double speedY = details.velocity.pixelsPerSecond.dy / 100;
                if (widget.velocity != null) {
                  widget.velocity!(speedX.toDouble(), speedY.toDouble());
                }
              }
              if (details.pointerCount == 1) {
                scale = 1;
                if (widget.onZoomListener != null) {
                  widget.onZoomListener!(
                      1, ScaleType.endScale, ScaleChange.scaleNormal);
                }
              }
            },
            onScaleUpdate: (ScaleUpdateDetails details) {
              if (details.scale != 1) {
                if (scale != details.scale) {
                  if ((scale < 1 && details.scale > 1) ||
                      (scale > 1 && details.scale < 1)) {
                    ///缩放发生放大、缩小的变化重新初始化宽、高
                    if (widget.onZoomListener != null) {
                      widget.onZoomListener!(details.scale,
                          ScaleType.updateScale, ScaleChange.scaleChange);
                    }
                  } else {
                    if (widget.onZoomListener != null) {
                      widget.onZoomListener!(details.scale,
                          ScaleType.updateScale, ScaleChange.scaleNormal);
                    }
                  }
                  scale = details.scale;
                }
                lastOffset = details.focalPoint;
              } else {
                if (widget.onMoved != null) {
                  widget.onMoved!(Offset(details.focalPoint.dx - lastOffset.dx,
                      details.focalPoint.dy - lastOffset.dy));
                }
                lastOffset = details.focalPoint;
              }
            },
            child: Listener(
              onPointerDown: (PointerDownEvent event) {
                if (touchPoint.length < 2) {
                  TouchBean touchBean = TouchBean();
                  touchBean.pointId = event.pointer;
                  touchBean.x = event.position.dx;
                  touchBean.y = event.position.dy;
                  touchPoint.add(touchBean);
                  if (touchPoint.length == 2) {
                    centerOffset = Offset(
                        (touchPoint[1].x + touchPoint[0].x) / 2,
                        (touchPoint[1].y + touchPoint[0].y) / 2);
                    if (widget.showCenterOffset != null) {
                      widget.showCenterOffset!(centerOffset);
                    }
                  }
                }
              },
              onPointerUp: (PointerUpEvent event) {
                for (int i = 0; i < touchPoint.length; i++) {
                  if (touchPoint[i].pointId == event.pointer) {
                    touchPoint.removeAt(i);
                  }
                }

                if (touchPoint.length < 2) {
                  if (widget.showCenterOffset != null) {
                    widget.showCenterOffset!(const Offset(0, 0));
                  }
                }
              },
              child: widget.child,
            ),
          )
        : MouseRegion(
            cursor: SystemMouseCursors.click,
            child: Listener(
                child: widget.child,
                onPointerHover: (PointerHoverEvent event) {
                  lastOffset = event.position;
                },
                onPointerMove: (PointerMoveEvent event) {
                  if (widget.onMoved != null) {
                    widget.onMoved!(Offset(event.position.dx - lastOffset.dx,
                        event.position.dy - lastOffset.dy));
                  }
                  if (pow(event.position.dx - lastOffset.dx, 2) < 4 &&
                      pow(event.position.dy - lastOffset.dy, 2) < 4) {
                    startLocation = event.position;
                    startTime = event.timeStamp.inMilliseconds;
                  }
                  lastOffset = event.position;
                },
                onPointerUp: (PointerUpEvent event) {
                  endTime = event.timeStamp.inMilliseconds;
                  endLocation = event.position;
                  double speedX = endLocation.dx - startLocation.dx;
                  double speedY = endLocation.dy - startLocation.dy;
                  if (pow(speedX, 2) >= 100 || pow(speedY, 2) >= 100) {
                    if (widget.velocity != null) {
                      widget.velocity!(speedX / 10, speedY / 10);
                    }
                  }
                },
                onPointerDown: (PointerDownEvent event) {
                  startTime = event.timeStamp.inMilliseconds;
                  startLocation = event.position;
                },
                onPointerSignal: (PointerSignalEvent event) {
                  if (widget.showCenterOffset != null) {
                    widget.showCenterOffset!(event.position);
                  }
                  if (event is PointerScrollEvent) {
                    if ((event).scrollDelta.dy > 0) {
                      if (widget.onZoomListener != null) {
                        widget.onZoomListener!(0-(widget.mouseScale??0.2), ScaleType.updateScale,
                            ScaleChange.scaleNormal);
                      }
                    } else {
                      widget.onZoomListener!(
                          widget.mouseScale??0.2, ScaleType.updateScale, ScaleChange.scaleNormal);
                    }
                  }
                }),
          );
  }

  bool checkMapType() {
    return (widget.mapType ?? MapType.finger) == MapType.finger;
  }
}
