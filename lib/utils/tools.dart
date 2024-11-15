
import 'dart:io';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
// import 'package:share_extend/share_extend.dart';
import 'package:shared_preferences/shared_preferences.dart';


class Tools {

  static double getScreenWidth(BuildContext context) {
    return MediaQuery
        .of(context)
        .size
        .width;
  }

  static double getScreenHeight(BuildContext context) {
    return MediaQuery
        .of(context)
        .size
        .height;
  }

  static double getActiveScreenHeight(BuildContext context) {

    var padding = MediaQuery.of(context).padding;
    double activeHeight = Tools.getScreenHeight(context) - padding.top - padding.bottom;

    return activeHeight;
  }



  static String getFormattedDate(int dateTime) {
    DateFormat newFormat = DateFormat("dd/MM/yy hh:mm");
    return newFormat.format(DateTime.fromMillisecondsSinceEpoch(dateTime));
  }

  static String getFormattedDateOnly(int dateTime) {
    DateFormat newFormat = DateFormat("dd MMM yy");
    return newFormat.format(DateTime.fromMillisecondsSinceEpoch(dateTime));
  }

  static String getFormattedDateFull(int dateTime) {
    DateFormat newFormat = DateFormat("dd MMM yyyy, hh:mm");
    return newFormat.format(DateTime.fromMillisecondsSinceEpoch(dateTime));
  }

  static String getFormattedDateSimple(int dateTime) {
    DateFormat newFormat = DateFormat("dd MMM yy hh:mm");
    return newFormat.format(DateTime.fromMillisecondsSinceEpoch(dateTime));
  }

  static int getGridSpanCount(BuildContext context) {
    double screenWidth = getScreenWidth(context);

    double cellWidth = 150;
    return (screenWidth / cellWidth).round();
  }

  static void methodShare(String filePath) async {
    File testFile = File(filePath);
    // ShareExtend.share(testFile.path, "file");
  }

  static Future<bool> getDoNotShow() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool donotShow = (prefs.getBool('donotShow') ?? false);
    return donotShow;
  }

  static double calculateDistance(lat1, lon1, lat2, lon2){
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 - c((lat2 - lat1) * p)/2 +
        c(lat1 * p) * c(lat2 * p) *
            (1 - c((lon2 - lon1) * p))/2;
    return 12742 * asin(sqrt(a));
  }

  static bool isNumeric(String? s) {
    if (s == null) {
      return false;
    }
    return double.tryParse(s) != null;
  }
  
  static String formatDouble(double? n, {int fractionDigits=1}) {
    if(n == null) return "";
    return n.toStringAsFixed(n.truncateToDouble() == n ? 0 : fractionDigits);
  }

  static LatLngBounds createBounds(List<LatLng> positions) {
    final southwestLat = positions.map((p) => p.latitude).reduce((value, element) => value < element ? value : element); // smallest
    final southwestLon = positions.map((p) => p.longitude).reduce((value, element) => value < element ? value : element);
    final northeastLat = positions.map((p) => p.latitude).reduce((value, element) => value > element ? value : element); // biggest
    final northeastLon = positions.map((p) => p.longitude).reduce((value, element) => value > element ? value : element);
    return LatLngBounds(
        southwest: LatLng(southwestLat, southwestLon),
        northeast: LatLng(northeastLat, northeastLon)
    );
  }

  static String formatTime(String? s) {
    if(s == null) return "";
    //split string based on :
    var parts = s.split(":");
    //get hours and minutes
    var hours = int.parse(parts[0]);
    var minutes = int.parse(parts[1]);
    //convert to 12 hour format in the form of HH:MM AM/PM
    var time = "${(hours > 12) ? hours - 12 : hours}:${(minutes < 10) ? '0$minutes' : minutes} ${(hours >= 12) ? 'PM' : 'AM'}";
    return time;
  }

  static String formatPrice(thisApplicationViewModel, double price) {
    String currency = (thisApplicationViewModel.settings != null ? thisApplicationViewModel.settings!.currencyCode! : "");
    return "${price.toStringAsFixed(2)} $currency";
  }
}
