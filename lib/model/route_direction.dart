import 'dart:convert';

import 'package:google_maps_flutter/google_maps_flutter.dart';

class RouteDirection{
  String? summary;
  //overview_path
  List<dynamic>? overviewPath;
  List<LatLng> get pathPoints => overviewPath!.map((e) => LatLng(
      double.parse(e['lat'].toString()),
      double.parse(e['lng'].toString()),
  )).toList();
  //Constructor
  RouteDirection({
    this.summary,
    this.overviewPath,
  });
  //toJson
  Map<String, dynamic> toJson() {
    return {
      'summary': summary,
      'overview_path': overviewPath,
    };
  }
  //fromJson
  factory RouteDirection.fromJson(Map<String, dynamic> json) {
    return RouteDirection(
      summary: json['summary'],
      overviewPath: getOverviewPath(json['overview_path']),
    );
  }

   static getOverviewPath(p) {
     if (p is String) {
       p = jsonDecode(p);
     }
     else if (p is List) {
       p = p;
     }
     else {
       p = null;
     }

     return p;
   }
}