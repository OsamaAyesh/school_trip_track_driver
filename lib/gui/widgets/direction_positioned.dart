import 'package:school_trip_track_driver/main.dart';
import 'package:flutter/material.dart';

class DirectionPositioned extends StatelessWidget {
  const DirectionPositioned({
    Key? key,
    required this.child,
    this.top,
    this.bottom,
    this.left,
    this.right,
  }) : super(key: key);

  final Widget child;
  final double? top;
  final double? bottom;
  final double? left;
  final double? right;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: MainApp.isRtl(context)?right:left,
      right: MainApp.isRtl(context)?left:right,
      child: child,
    );
  }
}