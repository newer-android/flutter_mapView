import 'package:flutter/material.dart';

class MyPath extends CustomPainter{

  const MyPath({Key? key,required this.roads,required this.scaled}) : super();

  final List<List<Offset>> roads;
  final double scaled;

  @override
  void paint(Canvas canvas, Size size) {
    Paint _paint = Paint()
      ..color=Colors.blue
      ..strokeWidth=2.0
      ..isAntiAlias = true
      ..style = PaintingStyle.fill;

    for (var element in roads) {
      if(element.length<2){

      }else{
        for(int i=1;i<element.length;i++){
          Offset start = Offset(element[i-1].dx*scaled,element[i-1].dy*scaled);
          Offset end = Offset(element[i].dx*scaled,element[i].dy*scaled);
          canvas.drawLine(start,end, _paint);
        }
      }
    }
  }

  //返回false会导致不会及时更新
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }

}