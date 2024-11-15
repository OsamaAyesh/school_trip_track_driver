import 'package:school_trip_track_driver/gui/widgets/RouteWidget/route_widget_child.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:school_trip_track_driver/gui/widgets/direction_positioned.dart';

class RouteWidget extends StatelessWidget{
  final List<RouteWidgetChild> children;
  const RouteWidget({superKey, required this.children}) : super(key: superKey);

  @override
  Widget build(BuildContext context){
    double distanceFromTop = 0;
    return SizedBox(
      height: 300.h,
      width: 300.w,
      child: Stack(
          children: List.generate(
            children.length,
            (i){
              distanceFromTop += i==0 ? 10:children[i-1].height;
              return DirectionPositioned(
                top: distanceFromTop.h,
                child: children[i]
              );
            }
      ),),
    );
  }
}