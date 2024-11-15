
import 'package:school_trip_track_driver/model/reservation.dart';

class ReservationsResponse {
  List<Reservation>? items = [];

  ReservationsResponse({this.items});

  factory ReservationsResponse.fromJson(List<dynamic> list) {
    return ReservationsResponse(
        items: list.map((p) => Reservation.fromJson(p)).toList()
    );
  }
}