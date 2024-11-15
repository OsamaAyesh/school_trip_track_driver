
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:school_trip_track_driver/model/route_direction.dart';
import 'package:school_trip_track_driver/model/stop.dart';

class RouteDetails{
  //id and name
  int? id;
  String? name;
  //stops
  List<dynamic>? stops;

  //distance
  double? distance;

  List<RouteDirection>? routeDirections;
  List<LatLng>? routePoints;
  //constructor
  RouteDetails({
    this.id,
    this.name,
    this.stops,
    this.routeDirections,
    this.distance,
  });
  //toJson
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'stops': stops,
      'route_directions': routeDirections,
      'distance': distance,
    };
  }
  //fromJson
  static RouteDetails fromJson(json) {
    List<RouteDirection> routeDirections = [];
    for (var i = 0; i < json['directions'].length; i++) {
      for (var j = 0; j < json['directions'][i].length; j++) {
        if(json['directions'][i][j]["current"] == 1) {
          routeDirections.add(RouteDirection.fromJson(json['directions'][i][j]));
        }
      }
    }
    return RouteDetails(
      id: json['id'],
      name: json['name'],
      stops: json['stops'] ?? json['stops'].map((p) => Stop.fromJson(p)).toList(),
      routeDirections: routeDirections,
      distance: json['distance'],
    );
  }

}