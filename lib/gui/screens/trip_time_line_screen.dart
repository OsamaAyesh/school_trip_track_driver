
import 'package:school_trip_track_driver/services/service_locator.dart';
import 'package:school_trip_track_driver/utils/app_theme.dart';
import 'package:school_trip_track_driver/view_models/this_application_view_model.dart';
import 'package:school_trip_track_driver/widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../connection/utils.dart';
import '../languages/language_constants.dart';
import '../widgets/app_bar.dart';
import '../widgets/trip_time_line.dart';

class TripTimelineScreen extends StatefulWidget {
  final List? tripDetails;

  const TripTimelineScreen({Key? key, this.tripDetails}) : super(key: key);

  @override
  TripTimelineScreenState createState() => TripTimelineScreenState();
}
class TripTimelineScreenState extends State<TripTimelineScreen> {
  ThisApplicationViewModel thisAppModel = serviceLocator<ThisApplicationViewModel>();


  List<dynamic>? plannedTripDetails;
  @override
  void initState() {
    plannedTripDetails = widget.tripDetails;
    super.initState();
  }
  Widget displayTripTimeline() {
    if (plannedTripDetails == null) {
      return failedScreen(context, FailState.GENERAL);
    }
    return Container(
      color: AppTheme.backgroundColor,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: //stops
        [
          thisAppModel.settings?.simpleMode == true ?
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.info, color: AppTheme.primary,),
              const SizedBox(width: 10,),
              Text(
                translation(context)?.orderOfStopsNotGuaranteed ?? "Order of stops not guaranteed",
                style: AppTheme.textGreySmall,
                maxLines: 4,
                textAlign: TextAlign.center,
              ),
            ],
          ) : Container(),
          SizedBox(height: 40.h,),
          TripTimeLine(plannedTripDetails: widget.tripDetails!,
              showTimes: thisAppModel.settings?.simpleMode == false),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context, translation(context)?.tripTimeline ?? "Trip Timeline"),
      body: Consumer<ThisApplicationViewModel>(
          builder: (context, thisAppModel, child) {
            return displayTripTimeline();
          }),
    );
  }

}
