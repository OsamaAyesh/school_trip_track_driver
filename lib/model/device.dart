
import 'package:intl/intl.dart';

class Device{

    int id;
    String name;
    String lastUsedAt;

    Device(
        {required this.id,
            required this.name,
            required this.lastUsedAt}
        );

    Map<String, dynamic> toJson() {
        return {
            'id': id,
            'name': name,
            'last_used_at': lastUsedAt,
        };
    }

    static Device fromJson(json) {
        return Device(
            id: json['id'],
            name: json['name'],
            lastUsedAt: json['last_used_at']!=null? DateFormat('yyyy-MM-dd hh:mm aa').format(DateTime.parse(json['last_used_at']).toLocal()).toString():"",
        );
    }

}
