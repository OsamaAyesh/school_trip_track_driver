import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:timeline_tile/timeline_tile.dart';

import '../../utils/tools.dart';

class TripTimeLine extends StatelessWidget {
  const TripTimeLine({
    Key? key,
    required this.plannedTripDetails, this.showTimes,
  }) : super(key: key);
  final List<dynamic> plannedTripDetails;
  final bool? showTimes;
  @override
  Widget build(BuildContext context) {
    double spacingMax = 100;
    double spacingMin = 50;
    return Expanded(
      child: ListView.builder(
        itemCount: plannedTripDetails.length,
        itemBuilder: (context, index) {
          return TimelineTile(
            alignment: TimelineAlign.manual,
            lineXY: 0.3,
            isFirst: index == 0,
            isLast: index == plannedTripDetails.length-1,
            indicatorStyle:
            IndicatorStyle(
              width: 40,
              height: 40,
              indicatorXY: 0.15,
              indicator: Container(
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    showTimes! ? (index).toString() : "",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            beforeLineStyle: const LineStyle(
              color: Colors.green,
              thickness: 6,
            ),
            startChild: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    showTimes! ? Tools.formatTime(plannedTripDetails[index].plannedTimeStamp) : "",
                    textDirection: TextDirection.ltr,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                Container(
                  height: spacingMax,
                ),
              ],
            ),
            endChild: Padding(
              padding: EdgeInsets.only(left: 8.w, right: 8.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      plannedTripDetails[index].stop?.name ?? "",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  //address
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      plannedTripDetails[index].stop?.address ?? "",
                      style: const TextStyle(
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Container(
                    height: spacingMax,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
