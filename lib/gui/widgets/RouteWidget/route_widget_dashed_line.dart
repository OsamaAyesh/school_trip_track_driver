import 'package:dotted_line/dotted_line.dart';
import 'package:school_trip_track_driver/gui/widgets/RouteWidget/route_widget_child.dart';
import 'package:school_trip_track_driver/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class RouteWidgetDashedLine extends RouteWidgetChild{
  final bool walking;
  final bool bus;
  final Widget trailing;
  final double heightParam;
  const RouteWidgetDashedLine({Key? key, required this.trailing, this.walking = false, this.heightParam=50, this.bus = false}) : super(key: key);
  @override
  double get height => heightParam;
  @override
  Widget build(BuildContext context){
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        walking || bus ? SizedBox(
          width: 80.w,
          child: Align(
            alignment: Alignment.center,
            child: Icon(
              walking? FontAwesomeIcons.walking:FontAwesomeIcons.bus,
              color: walking ?
              AppTheme.normalGrey:
              AppTheme.primary,
            ),
          ),
        ) : SizedBox(width: 80.w,),
        DottedLine(
          direction: Axis.vertical,
          lineLength: heightParam,
          lineThickness: 1.0,
          dashLength: 2.0,
          dashColor: AppTheme.normalGrey,
          dashRadius: 0.0,
          dashGapLength: 2.0,
          dashGapColor: Colors.transparent,
          dashGapRadius: 0.0,
        ),
        SizedBox(width: 10.w,),
        SizedBox(
          width: 70.w,
          child: trailing
        ),
      ],
    );
  }
}