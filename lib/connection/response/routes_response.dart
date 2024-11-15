

import '../../model/route_info.dart';

class RoutesResponse {
  List<RouteInfo>? items = [];

  RoutesResponse({this.items});

  factory RoutesResponse.fromJson(List<dynamic> list) {
    return RoutesResponse(
        items: list.map((p) => RouteInfo.fromJson(p)).toList()
    );
  }
}