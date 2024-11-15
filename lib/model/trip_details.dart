
import 'package:school_trip_track_driver/model/stop.dart';

class TripDetails{
   int? id;
   int? stopId;
   int? tripId;
   String? plannedTimeStamp;
   int? interTime;
   Stop? stop;
   double? distanceFromStart;
  TripDetails({
    this.id,
    this.stopId,
    this.tripId,
    this.plannedTimeStamp,
    this.interTime,
    this.stop,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'stop_id': stopId,
      'trip_id': tripId,
      'planned_timestamp': plannedTimeStamp,
      'inter_time': interTime,
      'stop': stop?.toJson(),
    };
  }

  factory TripDetails.fromJson(json) {
    return TripDetails(
      id: json['id'],
      stopId: json['stop_id'],
      tripId: json['trip_id'],
      plannedTimeStamp: json['planned_timestamp'],
      interTime: json['inter_time'],
      stop: json['stop'] != null ? Stop.fromJson(json['stop']) : null,
    );
  }
}