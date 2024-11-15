import 'dart:async';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:school_trip_track_driver/gui/screens/students_order_screen.dart';
import 'package:school_trip_track_driver/gui/widgets/direction_positioned.dart';

import 'package:school_trip_track_driver/gui/widgets/RouteWidget/route_widget.dart';
import 'package:school_trip_track_driver/gui/widgets/RouteWidget/route_widget_dashed_line.dart';
import 'package:school_trip_track_driver/gui/widgets/RouteWidget/route_widget_marker.dart';
import 'package:school_trip_track_driver/gui/widgets/RouteWidget/route_widget_road.dart';
import 'package:school_trip_track_driver/model/route_direction.dart';
import 'package:school_trip_track_driver/model/trip.dart';
import 'package:school_trip_track_driver/services/service_locator.dart';
import 'package:school_trip_track_driver/utils/app_theme.dart';
import 'package:school_trip_track_driver/view_models/this_application_view_model.dart';
import 'package:school_trip_track_driver/widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart' as intl;
import 'package:provider/provider.dart';

import '../../connection/utils.dart';
import '../../utils/size_config.dart';
import '../../utils/tools.dart';
import '../languages/language_constants.dart';
import '../widgets/app_bar.dart';
import 'dart:ui' as ui;

class StartTripScreen extends StatefulWidget {
  final int? routeId;
  final Trip? trip;
  const StartTripScreen({Key? key, this.routeId, this.trip}) : super(key: key);

  @override
  StartTripScreenState createState() => StartTripScreenState();
}
class StartTripScreenState extends State<StartTripScreen> {
  Completer<GoogleMapController>? mapController = Completer();
  ThisApplicationViewModel thisApplicationModel = serviceLocator<ThisApplicationViewModel>();

  List<Marker> markers = [];
  Marker? busMarker;
  BitmapDescriptor? customIcon;

  Future<Uint8List?> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(
        data.buffer.asUint8List(), targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))?.buffer
        .asUint8List();
  }

  void updateMarkerIcon() {
    if (busMarker != null) {
      //update icon
      busMarker = busMarker!.copyWith(
        iconParam: customIcon,
      );
    }
  }

  getIcons() async {
    int iconSize = (SizeConfig.screenWidth! * SizeConfig.devicePixelRatio! / 10)
        .round();
    final Uint8List? markerIcon = await getBytesFromAsset(
        'assets/images/school_bus.png', iconSize);
    // make sure to initialize before map loading
    customIcon = BitmapDescriptor.fromBytes(markerIcon!);
    setState(() {
      updateMarkerIcon();
    });
  }

  @override
  void initState() {
    super.initState();
    busMarker = const Marker(
      markerId: MarkerId('bus'),
    );
    getIcons();
    thisApplicationModel.startTripLoadingState.loadError = null;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        thisApplicationModel.getRouteDetailsEndpoint(widget.routeId, trip: widget.trip);
      });
    });
  }
  Widget displayRouteMap(ThisApplicationViewModel thisAppModel) {
    if (thisAppModel.routeDetailsLoadingState.inLoading()) {
      // loading. display animation
      return loadingScreen();
    }
    else if (thisAppModel.routeDetailsLoadingState.loadingFinished()) {
      if (kDebugMode) {
        print("network call finished");
      }
      //network call finished.
      if (thisAppModel.routeDetailsLoadingState.loadError != null) {
        if (kDebugMode) {
          print("page loading error. Display the error");
        }
        // page loading error. Display the error
        return failedScreen(context,
            thisAppModel.routeDetailsLoadingState.failState);
      }
      else {
        Set<Polyline> polyLines = {};
        List<RouteDirection>? routeDirections = thisAppModel.routeDetails
            ?.routeDirections!;
        List<dynamic>? stops = thisAppModel.routeDetails?.stops;
        if (routeDirections == null || stops == null) {
          return failedScreen(context, FailState.GENERAL);
        }
        markers = [];
        //Change colors for polyline randomly
        if(thisAppModel.settings?.simpleMode == false) {
          for (var i = 0; i < routeDirections.length; i++) {
            Color color = Color((Random().nextDouble() * 0xFFFFFF).toInt())
                .withOpacity(1.0);
            Polyline polyline = Polyline(
              polylineId: const PolylineId('route'),
              color: color, //Random color
              width: 5,
              points: routeDirections[i].pathPoints,
            );
            polyLines.add(polyline);
          }
        }
        else {
          if (thisAppModel.routeDetails?.routePoints != null) {
            Polyline polyline = Polyline(
              polylineId: const PolylineId('route'),
              color: Colors.red,
              width: 5,
              points: thisAppModel.routeDetails!.routePoints!,
            );
            polyLines.add(polyline);
          }
        }
        //add bus location to markers
        if (thisAppModel.busLocation != null) {
          busMarker = busMarker!.copyWith(
            positionParam: LatLng(
                thisAppModel.busLocation!.latitude, thisAppModel.busLocation!.longitude),
          );
          markers.add(busMarker!);
        }
        for (var i = 0; i < stops.length; i++) {
          Marker marker = createMarker(stops[i]);
          markers.add(marker);
        }
        bool isMapAdjusted = false;
        String startStopName = widget.trip?.plannedTripDetail?[0].stop.name ??
            "";
        String startStopAddress = widget.trip?.plannedTripDetail?[0].stop.address ??
            "";
        String startStopTime = widget.trip?.plannedTripDetail?[0]
            .plannedTimeStamp ?? "";
        String endStopName = "";
        String endStopAddress = "";
        String endStopTime = "";
        if (widget.trip != null && widget.trip!.plannedTripDetail != null &&
            widget.trip!.plannedTripDetail!.isNotEmpty) {
          endStopName =
              widget.trip!.plannedTripDetail![widget.trip!.plannedTripDetail!
                  .length - 1].stop.name ?? "";
          endStopTime =
              widget.trip!.plannedTripDetail![widget.trip!.plannedTripDetail!
                  .length - 1].plannedTimeStamp ?? "";
          endStopAddress =
              widget.trip!.plannedTripDetail![widget.trip!.plannedTripDetail!
                  .length - 1].stop.address ?? "";
        }
        if(thisApplicationModel.settings?.simpleMode == true)
        {
          if (widget.trip!.isMorning == true) {
            startStopName = translation(context)?.currentLocation ?? "Current Location";
            startStopAddress = "";
          }
          // else {
          //   endStopName = "End Stop";
          //   endStopAddress = "";
          // }
        }
        //parse as time and get the difference
        int totalTripTimeInMin = getDifference(startStopTime, endStopTime);
        //check totalTripTimeInMin, if it is large, then show in hours and minutes
        String totalTripTime = "";
        if (totalTripTimeInMin > 60) {
          int hours = totalTripTimeInMin ~/ 60;
          int minutes = totalTripTimeInMin % 60;
          totalTripTime = "$hours hours $minutes minutes";
        }
        else {
          totalTripTime = "$totalTripTimeInMin minutes";
        }
        String totalTripDistance = "${thisAppModel.routeDetails?.distance
            ?.toStringAsFixed(2) ?? ""} km in $totalTripTime";
        if(thisAppModel.settings?.simpleMode == true) {
          totalTripDistance = thisAppModel.routeDetails?.name ?? "";
        }

        //Get the bounds from markers
        return Stack(
          children: [
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: calculateCenterPoint(markers),
              ),
              polylines: polyLines,
              markers: getMarkers(),
              onMapCreated: (GoogleMapController controller) async {
                mapController?.complete(controller);
                await adjustBounds();
              },
              onCameraIdle: () async {
                if (!isMapAdjusted) {
                  await adjustBounds();
                  isMapAdjusted = true;
                }
              },
            ),
            DirectionPositioned(
              bottom: 10,
              left: 10,
              right: 10,
              child: Card(
                margin: const EdgeInsets.all(10),
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                //start stop, end stop, total time
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox(
                      width: 400.w,
                      height: 180.h,
                      child: Stack(
                        children: [
                          DirectionPositioned(
                            left: -60.w,
                            child: SizedBox(
                              width: 300.w,
                              child: Material(
                                color: Colors.transparent,
                                child: RouteWidget(
                                  children: [
                                    RouteWidgetMarker(
                                      leading: const SizedBox(),
                                      trailing: SizedBox(
                                        width: 200.w,
                                        height: 50.h,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment
                                              .start,
                                          children: [
                                            Text(
                                              startStopName,
                                              style: AppTheme
                                                  .textSecondaryMedium,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            SizedBox(height: 5.h,),
                                            Text(
                                              startStopAddress,
                                              style: AppTheme
                                                  .textSecondarySmall,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    RouteWidgetDashedLine(
                                      trailing: const SizedBox(),
                                      walking: false,
                                      heightParam: 20.h,
                                    ),
                                    RouteWidgetRoad(
                                      leading: const SizedBox(),
                                      trailing: Padding(
                                        padding: const EdgeInsets.only(
                                            top: 5.0),
                                        child: Text(
                                          totalTripDistance,
                                          textDirection: TextDirection.ltr,
                                          style: const TextStyle(
                                            color: AppTheme.primary,
                                            fontSize: 16,
                                            fontFamily: 'Open Sans',
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ),
                                    RouteWidgetDashedLine(
                                      trailing: const SizedBox(),
                                      walking: false,
                                      heightParam: 20.h,
                                    ),
                                    RouteWidgetMarker(
                                      leading: const SizedBox(),
                                      trailing: SizedBox(
                                        width: 200.w,
                                        height: 50.h,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment
                                              .start,
                                          children: [
                                            Text(
                                              endStopName,
                                              style: AppTheme
                                                  .textSecondaryMedium,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            SizedBox(height: 5.h,),
                                            Text(
                                              endStopAddress,
                                              style: AppTheme
                                                  .textSecondarySmall,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Align(
                      alignment: AlignmentDirectional.centerEnd,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          ElevatedButton(
                            // style: ElevatedButton.styleFrom(
                            //   backgroundColor: AppTheme.primary,
                            //   shape: RoundedRectangleBorder(
                            //     borderRadius: BorderRadius.circular(10),
                            //   ),
                            //   side: const BorderSide(color: AppTheme.primary, width: 2),
                            //   padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 10),
                            // ),
                            onPressed: () {
                              showOkCancelDialog(
                                  context,
                                  thisAppModel,
                                  translation(context)?.startTrip ??
                                      "Start Trip",
                                  translation(context)
                                      ?.areYouSureYouWantToStartTrip ??
                                      "Are you sure you want to start trip?",
                                  translation(context)?.ok ?? "OK",
                                  translation(context)?.cancel ?? "Cancel",
                                      () {
                                    //start trip
                                    Navigator.of(
                                        context, rootNavigator: true).pop();
                                    thisAppModel.startTrip(
                                        context, widget.trip, 1);
                                  },
                                      () {
                                    //cancel
                                    Navigator.of(
                                        context, rootNavigator: true).pop();
                                  }
                              );
                            },
                            child: thisAppModel.startTripLoadingState
                                .inLoading()
                                ? const CircularProgressIndicator(
                              color: Colors.white,)
                                : Text(
                              translation(context)?.startTrip ??
                                  "Start Trip",
                              style: AppTheme.textSecondarySmall,),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
                  ),
              ),
            ),
            thisAppModel.startTripLoadingState.loadError != null ?
            DirectionPositioned(
              bottom: 10,
              left: 10,
              right: 10,
              child: MaterialBanner(
                backgroundColor: AppTheme.colorError,
                content: Text(thisAppModel.startTripLoadingState.error ?? ""
                  , style: const TextStyle(color: Colors.white),),
                leading: const CircleAvatar(child: Icon(Icons.error)),
                actions: [
                  TextButton(
                    child: const Text(
                      'DISMISS', style: TextStyle(color: Colors.white),),
                    onPressed: () {
                      setState(() {
                        thisAppModel.startTripLoadingState.loadError = null;
                      });
                    },
                  ),
                ],
              ),
            ) : Container(),
          ],
        );
      }
    }
    return Container();
  }
  
  Marker createMarker(dynamic stop) {
    return Marker(
      markerId: MarkerId(stop["name"]),
      position: LatLng(
          double.parse(stop["lat"]), double.parse(stop["lng"])),
      infoWindow: InfoWindow(
        title: stop["name"],
        snippet: stop["address"],
      ),
      icon: BitmapDescriptor.defaultMarker,
      // consumeTapEvents: true,
    );
  }

  Set<Marker> getMarkers() {
    //convert _markers to set
    Set<Marker> markers_ = {};
    for (var i = 0; i < markers.length; i++) {
      markers_.add(markers[i]);
    }
    return markers_;
  }


  int getDifference(String time1, String time2)
  {
    intl.DateFormat dateFormat = intl.DateFormat("HH:mm:ss");

    DateTime a = dateFormat.parse(time1);
    DateTime b = dateFormat.parse(time2);

    //check if time 2 is less than time 1, then add 24 hours to time 2
    if(b.isBefore(a)) {
      b = b.add(const Duration(hours: 24));
    }

    return b.difference(a).inMinutes;
  }

  Future<void> adjustBounds() async {

    // if(mapController == null) {
    //   await Future.delayed(const Duration(milliseconds: 1000));
    //   if(mapController == null) {
    //     return;
    //   }
    // }

    LatLngBounds? boundss = getBoundsMarker();
    if(boundss != null) {
      mapController?.future.then((value) => value.animateCamera(CameraUpdate.newLatLngBounds(boundss, 50)));
    }

    // setState(() {
    //
    // });
  }

  LatLngBounds? getBoundsMarker(){
    if(mapController==null) {
      return null;
    }
    if(markers.isEmpty || markers.length==1){
      return null;
    }

    return Tools.createBounds(markers.map((m) => m.position).toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context, translation(context)?.tripDetails ?? "Trip Details"),
      body: Consumer<ThisApplicationViewModel>(
          builder: (context, thisAppModel, child) {
            return displayRouteMap(thisAppModel);
          }),
    );
  }

  calculateCenterPoint(List<Marker> markers) {
    double x = 0;
    double y = 0;
    double z = 0;
    for (var i = 0; i < markers.length; i++) {
      double latitude = markers.elementAt(i).position.latitude * pi / 180;
      double longitude = markers.elementAt(i).position.longitude * pi / 180;
      x += cos(latitude) * cos(longitude);
      y += cos(latitude) * sin(longitude);
      z += sin(latitude);
    }
    double total = markers.length.toDouble();
    x = x / total;
    y = y / total;
    z = z / total;
    double centralLongitude = atan2(y, x);
    double centralSquareRoot = sqrt(x * x + y * y);
    double centralLatitude = atan2(z, centralSquareRoot);
    return LatLng(centralLatitude * 180 / pi, centralLongitude * 180 / pi);
  }
}
