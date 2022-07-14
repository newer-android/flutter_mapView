import 'package:flutter/cupertino.dart';

import 'MyPath.dart';

class RoadPath extends StatelessWidget {
  const RoadPath({Key? key, required this.width, required this.height, required this.roads, required this.scaled}) : super(key: key);

  final double width;
  final double height;
  final List<List<Offset>> roads;
  final double scaled;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(width, height),
      painter: MyPath(roads: roads, scaled: scaled),
    );
  }
}
