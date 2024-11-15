
class RouteInfo
{
  //id and name
  int? id;
  String? name;

  int? stopsCount;

  //constructor

  RouteInfo({
    this.id,
    this.name,
    this.stopsCount,
  });

  //toJson

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'stops_count': stopsCount,
    };
  }

  //fromJson

  static RouteInfo fromJson(json) {
    return RouteInfo(
      id: json['id'],
      name: json['name'],
      stopsCount: json['stops_count'],
    );
  }
}