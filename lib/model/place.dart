
import 'package:intl/intl.dart';

class Place{

    int? id;
    String? name, lastUsedAt, address;
    double? latitude, longitude;
    int type = 0; //o custom, 1 home, 2 work
    int favorite = 0; // 0 no, 1 yes
    Place(
        {this.id,
            this.name,
            this.lastUsedAt,
            this.address,
            this.latitude,
            this.longitude,
            this.type = 0,
            this.favorite = 0}
        );

    Map<String, dynamic> toJson() {
        return {
            'id': id,
            'name': name,
            'last_used_at': lastUsedAt,
            'address': address,
            'latitude': latitude,
            'longitude': longitude,
            'type': type,
            'favorite': favorite,
        };
    }

    static Place fromJson(json) {
        return Place(
            id: json['id'],
            name: json['name'],
            lastUsedAt: json['last_used_at']!=null? DateFormat('yyyy-MM-dd hh:mm aa').format(DateTime.parse(json['last_used_at']).toLocal()).toString():"",
            address: json['address'],
            latitude: json['latitude'],
            longitude: json['longitude'],
            type: json['type'],
            favorite: json['favorite'],
        );
    }

}
