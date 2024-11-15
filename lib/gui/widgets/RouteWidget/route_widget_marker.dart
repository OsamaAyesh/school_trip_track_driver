import 'package:school_trip_track_driver/gui/widgets/RouteWidget/route_widget_child.dart';
import 'package:school_trip_track_driver/utils/icomoon_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:school_trip_track_driver/gui/widgets/direction_positioned.dart';

import '../../../utils/app_theme.dart';
import '../../../utils/size_config.dart';

class RouteWidgetMarker extends RouteWidgetChild{
  final Widget leading;
  final Widget trailing;
  const RouteWidgetMarker({super.key, required this.leading, required this.trailing});
  @override
  double get height => 40;
  @override
  Widget build(BuildContext context){
    return SizedBox(
      height: 40.h,
      width: SizeConfig.screenWidth!,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          DirectionPositioned(
            left: 60.w,
            child: //circular container with icon
            Container(
              height: 40.h,
              width: 40.w,
              decoration: BoxDecoration(
                color: AppTheme.primary,
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Icon(
                Icomoon.routeWidgetMarker,
                color: Colors.white,
                size: 20.r,
              ),
            ),
          ),
          DirectionPositioned(
              top: 5.h,
              left: 24.w,
              child: leading
          ),
          DirectionPositioned(
              left: 110.w,
              top:5,
              child: trailing
          ),
        ],
      ),
    );
  }
}