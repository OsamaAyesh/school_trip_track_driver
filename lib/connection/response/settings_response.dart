import 'package:school_trip_track_driver/model/setting.dart';

class SettingsResponse {
  Setting? item;

  SettingsResponse({this.item});

  factory SettingsResponse.fromJson(dynamic p) {
    return SettingsResponse(
        item: Setting.fromJson(p)
    );
  }
}