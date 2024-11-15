

import 'package:school_trip_track_driver/model/stop.dart';

class StopsResponse {
  List<Stop>? items = [];

  StopsResponse({this.items});

  factory StopsResponse.fromJson(List<dynamic> list) {
    return StopsResponse(
        items: list.map((p) => Stop.fromJson(p)).toList()
    );
  }
}