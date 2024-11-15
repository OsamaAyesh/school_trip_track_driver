

import 'package:intl/intl.dart';

import '../utils/config.dart';

class MyNotification {

  int? id;
  int? seen;
  String? message;
  String? createdAt;

  MyNotification({
    this.id,
    this.seen,
    this.message,
    this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'seen': seen,
      'message': message,
      'created_at': createdAt,
    };
  }

  static MyNotification fromJson(json) {
    return MyNotification(
      id: json['id'],
      seen: json['seen'],
      message: json['message'].toString(),
      createdAt: DateFormat('yyyy-MM-dd hh:mm aa').format(
          DateTime.parse(json['created_at']).toLocal()).toString(),
    );
  }

}
