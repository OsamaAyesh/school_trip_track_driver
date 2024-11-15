

import 'package:school_trip_track_driver/model/user.dart';

class UsersResponse {
  List<DbUser>? items = [];

  UsersResponse({this.items});

  factory UsersResponse.fromJson(List<dynamic> list) {
    return UsersResponse(
        items: list.map((p) => DbUser.fromJson(p)).toList()
    );
  }
}