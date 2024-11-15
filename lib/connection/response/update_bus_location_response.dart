

// ignore: unused_import
import 'package:school_trip_track_driver/model/device.dart';

import '../../model/reservation.dart';
import '../../model/stop.dart';

class UpdateBusLocationResponse {
  Stop? nextStop;
  bool? success;
  double? distanceToNextStop;
  int? countPassengersToBePickedUp;
  int? countPassengersToBeDroppedOff;
  String? nextStopPlannedTime;
  //visited_stop_ids
  List<dynamic>? visitedStopIds;
  UpdateBusLocationResponse({this.nextStop, this.success, this.distanceToNextStop,
    this.countPassengersToBePickedUp,
    this.countPassengersToBeDroppedOff,
    this.nextStopPlannedTime, this.visitedStopIds});

  factory UpdateBusLocationResponse.fromJson(Map<String, dynamic> json) {
    return UpdateBusLocationResponse(
        nextStop: json['next_stop'] != null ? Stop.fromJson(json['next_stop']) : null,
        success: json['success'],
        distanceToNextStop: double.parse(json['distance_to_next_stop'].toString()),
        nextStopPlannedTime: json['next_stop_planned_time'],
        countPassengersToBePickedUp: json['count_passengers_to_be_picked_up'],
        countPassengersToBeDroppedOff: json['count_passengers_to_be_dropped_off'],
        visitedStopIds: json['visited_stops_ids']
    );
  }
}