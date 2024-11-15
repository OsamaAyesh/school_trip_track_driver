import 'package:school_trip_track_driver/model/route_info.dart';

class Stop{
   int? id;
   String? name;
   String? placeId;
   String? address;
   String? lat;
   String? lng;

   //routes
   List<dynamic>? routes;

  Stop({
    this.id,
    this.name,
    this.placeId,
    this.address,
    this.lat,
    this.lng,
    this.routes,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'place_id': placeId,
      'address': address,
      'lat': lat,
      'lng': lng,
      'routes': routes,
    };
  }

  static Stop fromJson(json) {
    return Stop(
      id: json['id'],
      name: json['name'],
      placeId: json['place_id'],
      address: json['address'],
      lat: json['lat'],
      lng: json['lng'],
      routes: json['routes']?.map((p) => RouteInfo.fromJson(p)).toList()
    );
  }
}