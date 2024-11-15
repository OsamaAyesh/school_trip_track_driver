import 'package:school_trip_track_driver/main.dart';
import 'package:flutter/material.dart';

class DirectionRow extends StatelessWidget {
  const DirectionRow({
    Key? key,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.mainAxisSize = MainAxisSize.max,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.textDirection,
    this.verticalDirection = VerticalDirection.down,
    required this.children,
  }) : super(key: key);

  final List<Widget> children;
  final MainAxisAlignment? mainAxisAlignment;
  final MainAxisSize? mainAxisSize;
  final CrossAxisAlignment? crossAxisAlignment;
  final TextDirection? textDirection;
  final VerticalDirection? verticalDirection;
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: mainAxisAlignment!,
      mainAxisSize: mainAxisSize!,
      crossAxisAlignment: crossAxisAlignment!,
      textDirection: textDirection,
      verticalDirection: verticalDirection!,
      textBaseline: TextBaseline.alphabetic,
      children: MainApp.isRtl(context)?children.reversed.toList():children,
    );
  }
}
