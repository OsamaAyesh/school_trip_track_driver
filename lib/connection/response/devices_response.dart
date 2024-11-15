

import 'package:school_trip_track_driver/model/device.dart';

class DevicesResponse {
  List<Device>? items = [];

  DevicesResponse({this.items});

  factory DevicesResponse.fromJson(List<dynamic> list) {
    return DevicesResponse(
        items: list.map((p) => Device.fromJson(p)).toList()
    );
  }
}