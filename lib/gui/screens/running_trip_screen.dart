import 'dart:async';
import 'dart:math';
import 'package:school_trip_track_driver/gui/screens/students_screen.dart';
import 'package:school_trip_track_driver/gui/widgets/direction_positioned.dart';

import 'package:school_trip_track_driver/gui/screens/pick_up_screen.dart';
import 'package:school_trip_track_driver/gui/widgets/RouteWidget/route_widget.dart';
import 'package:school_trip_track_driver/gui/widgets/RouteWidget/route_widget_dashed_line.dart';
import 'package:school_trip_track_driver/gui/widgets/RouteWidget/route_widget_marker.dart';
import 'package:school_trip_track_driver/model/reservation.dart';
import 'package:school_trip_track_driver/model/route_direction.dart';
import 'package:school_trip_track_driver/model/trip.dart';
import 'package:school_trip_track_driver/services/service_locator.dart';
import 'package:school_trip_track_driver/utils/app_theme.dart';
import 'package:school_trip_track_driver/view_models/this_application_view_model.dart';
import 'package:school_trip_track_driver/widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';

import '../../connection/utils.dart';
import '../../utils/size_config.dart';
import '../../utils/tools.dart';
import 'dart:ui' as ui;

import '../languages/language_constants.dart';

enum CurrentPickUpState {
  onTrip,
  enteredSlowDownZone,
  enteredPickupZone,
  leftPickupZone,
}

enum CurrentDropOffState {
  onTrip,
  enteredSlowDownZone,
  enteredDropOffZone,
  leftDropOffZone,
}


class BannerData {
  String message;
  Color backgroundColor;
  String buttonText;
  String audioPath;
  Function? handleAction;
  DateTime? lastPlayedTime;
  bool visible = false;
  BannerData(this.message, this.backgroundColor, this.buttonText, this.audioPath, {this.handleAction});

  static AudioPlayer player = AudioPlayer();

  void playAudio()
  {

      if (lastPlayedTime == null) {
        lastPlayedTime = DateTime.now();
        playAudioFile();
      }
      else {
        DateTime now = DateTime.now();
        Duration difference = now.difference(lastPlayedTime!);
        if (difference.inSeconds > 5) {
          lastPlayedTime = DateTime.now();
          playAudioFile();
        }
      }
  }

  Future<void> playAudioFile() async {
    if(player.playing) {
      await player.stop();
    }
    await player.setAsset(audioPath);
    player.play();
  }
}

class RunningTripScreen extends StatefulWidget {
  final int? routeId;
  final Trip? trip;
  const RunningTripScreen({Key? key, this.routeId, this.trip}) : super(key: key);

  @override
  RunningTripScreenState createState() => RunningTripScreenState();
}
class RunningTripScreenState extends State<RunningTripScreen> {

  BannerData enteredSlowDownZoneBannerData = BannerData(
      "You are near the next stop, please slow down",
      AppTheme.colorError, "",
      "assets/audios/near_next_stop_slow_down.mp3");
  BannerData enteredPickupZoneBannerData = BannerData(
      "You have arrived to the stop, please pick up students",
      Colors.green, "Pick up students",
      "assets/audios/arrived_at_stop_pickup_students.mp3",
      handleAction: (context, widget, currentLocation, thisAppModel) {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  PickUpScreen(
                    widget.trip!.id!,
                    currentLocation,
                  )),
        );
      });
  BannerData leftPickupZoneBannerData = BannerData(
      "You have missed the pickup at the stop, please go back",
      Colors.red, "",
      "assets/audios/missed_pickup.mp3");
  BannerData enteredDropOffSlowDownZoneBannerData = BannerData(
      "You are near the drop-off point, please slow down",
      Colors.deepOrangeAccent, "",
      "assets/audios/near_drop_off_slow_down.mp3");
  BannerData enteredDropOffZoneBannerData = BannerData(
      "You have arrived to a drop-off stop, please drop off students",
      Colors.green, "Drop off students",
      "assets/audios/arrived_at_drop_off_drop_off_students.mp3",
      handleAction: (context, widget, currentLocation, thisAppModel) {
        thisAppModel.dropOffPassengersEndpoint(
            widget.trip!.id!,
            currentLocation!.latitude,
            currentLocation.longitude,
            currentLocation.speed);
      });
  BannerData leftDropOffZoneBannerData = BannerData(
      "You have missed the drop-off at the stop, please go back",
      Colors.red, "",
      "assets/audios/missed_drop_off.mp3");

  static double maxDistance = 1000000;
  Completer<GoogleMapController>? mapController = Completer();
  ThisApplicationViewModel thisApplicationModel = serviceLocator<
      ThisApplicationViewModel>();

  StreamSubscription<Position>? positionStream;
  LocationSettings locationSettings = const LocationSettings(
    accuracy: LocationAccuracy.high, //accuracy of the location data
    // minimum distance (measured in meters), device must move horizontally before an update event is generated.
  );
  List<Marker> markers = [];
  Position? currentLocation;
  Marker? busMarker;
  bool isMapAdjusted = false;
  int boundMode = 0; //0: fit all markers, 1: fit bus marker on center
  BitmapDescriptor? customIcon;

  CurrentPickUpState currentPickUpState = CurrentPickUpState.onTrip;
  CurrentDropOffState currentDropOffState = CurrentDropOffState.onTrip;

  bool inSlowDownZone = false;
  bool inPickupZone = false;

  bool inDropOffZone = false;
  bool inDropOffSlowDownZone = false;

  int distanceToDropOff = 100; //in meters
  int distanceToSlowDown = 1000; //in meters
  int distanceToPickup = 100;

  double currentDistanceToDropOff = maxDistance;

  List<Widget> currentBanners = [];

  DateTime? lastSentLocationTime;

  List<BannerData> bannerDataList = [];

  @override
  void initState() {
    super.initState();
    bannerDataList = [
      enteredSlowDownZoneBannerData,
      enteredPickupZoneBannerData,
      leftPickupZoneBannerData,
      enteredDropOffSlowDownZoneBannerData,
      enteredDropOffZoneBannerData,
      leftDropOffZoneBannerData,
    ];
    busMarker = const Marker(
      markerId: MarkerId('bus'),
    );
    getIcons();
    thisApplicationModel.startTripLoadingState.loadError = null;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        thisApplicationModel.getRouteDetailsEndpoint(widget.routeId);
      });
    });
    positionStream = Geolocator.getPositionStream(
        locationSettings: locationSettings)
        .listen((Position position) {
      currentLocation = position;

      if (kDebugMode) {
        print("current location: ${currentLocation!.latitude}, ${currentLocation!
          .longitude}");
      }
      //update the bus location on map with the new position
      setState(() {
        updateMarkerPosition();
      });
      // updateMarkerPosition();

      bool updateLocation = true;
      //check if we sent the new location recently
      if (lastSentLocationTime != null) {
        DateTime now = DateTime.now();
        Duration difference = now
            .difference(lastSentLocationTime!);
        if (difference.inSeconds < 3) {
          updateLocation = false;
        }
      }

      if(updateLocation) {
        lastSentLocationTime = DateTime.now();
        thisApplicationModel.updateBusLocationEndpoint(
            widget.trip!.id!, currentLocation!.latitude,
            currentLocation!.longitude, currentLocation!.speed);
      }

    });

    positionStream?.onError((error) {
      if (kDebugMode) {
        print("error: $error");
      }
    });

    positionStream?.onDone(() {
      if (kDebugMode) {
        print("position stream done");
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    positionStream?.cancel();
  }

  Future<Uint8List?> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(
        data.buffer.asUint8List(), targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))?.buffer
        .asUint8List();
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
        for (var i = 0; i < stops.length; i++) {
          Marker marker = createStopMarker(stops[i]);
          markers.add(marker);
        }
        markers.add(busMarker!);
        //check if students to be dropped of
        if(thisAppModel.updateBusLocationResponse?.countPassengersToBeDroppedOff != null &&
        thisAppModel.updateBusLocationResponse?.countPassengersToBeDroppedOff != 0 &&
            thisAppModel.updateBusLocationResponse != null) {
          currentDistanceToDropOff = thisAppModel.updateBusLocationResponse!.distanceToNextStop!;
          inDropOffZone = currentDistanceToDropOff < distanceToDropOff;
          inDropOffSlowDownZone = currentDistanceToDropOff < distanceToSlowDown;
        }

        String? nextStopName, distanceToNextStop, passengerCount, passengerCountToBeDroppedOff,
            nextStopAddress, distanceToDropOffString, nextStopPlannedTime;
        if (thisAppModel.updateBusLocationResponse != null) {
          nextStopName = thisAppModel.updateBusLocationResponse?.nextStop
              ?.name ?? "";
          nextStopAddress = thisAppModel.updateBusLocationResponse
              ?.nextStop?.address ?? "";
          nextStopPlannedTime = thisAppModel.updateBusLocationResponse
              ?.nextStopPlannedTime ?? "";
          if(nextStopPlannedTime != "") {
            nextStopPlannedTime = Tools.formatTime(nextStopPlannedTime);
          }
          //format thisAppModel.routeDetails?.distance in two decimal places
          distanceToNextStop = "${(thisAppModel.updateBusLocationResponse
          !.distanceToNextStop! / 1000).toStringAsFixed(2) ?? ""} km";

          passengerCount = "${thisAppModel.updateBusLocationResponse
              ?.countPassengersToBePickedUp ?? "No student"}";

          passengerCountToBeDroppedOff = "No ";
          if(thisAppModel.updateBusLocationResponse?.countPassengersToBeDroppedOff != null &&
          thisAppModel.updateBusLocationResponse?.countPassengersToBeDroppedOff != 0) {
            passengerCountToBeDroppedOff =
                thisAppModel.updateBusLocationResponse
                    ?.countPassengersToBeDroppedOff?.toString();
          }

          distanceToDropOffString = "${(currentDistanceToDropOff / 1000)
              .toStringAsFixed(2) ?? ""} km";

          inSlowDownZone =
              thisAppModel.updateBusLocationResponse!.distanceToNextStop! <
                  distanceToSlowDown;

          inPickupZone =
              thisAppModel.updateBusLocationResponse!.distanceToNextStop! <
                  distanceToPickup;
          

          if (currentPickUpState == CurrentPickUpState.onTrip) {
            if (inSlowDownZone && !inPickupZone) {
              currentPickUpState = CurrentPickUpState.enteredSlowDownZone;
            }
          }

          if (currentPickUpState == CurrentPickUpState.onTrip) {
            if (inSlowDownZone && inPickupZone) {
              currentPickUpState = CurrentPickUpState.enteredPickupZone;
            }
          }

          if (currentPickUpState == CurrentPickUpState.enteredSlowDownZone) {
            if (inPickupZone) {
              currentPickUpState = CurrentPickUpState.enteredPickupZone;
            }
            if (!inSlowDownZone) {
              currentPickUpState = CurrentPickUpState.onTrip;
            }
          }

          if (currentPickUpState == CurrentPickUpState.enteredPickupZone) {
            if (!inPickupZone) {
              currentPickUpState = CurrentPickUpState.leftPickupZone;
            }
          }

          if (currentPickUpState == CurrentPickUpState.leftPickupZone) {
            if (thisAppModel.nextStopChanged) {
              currentPickUpState = CurrentPickUpState.onTrip;
              thisAppModel.nextStopChanged = false;
            }
            else if(inPickupZone) {
              currentPickUpState = CurrentPickUpState.enteredPickupZone;
            }
          }

          if (kDebugMode) {
            print("current PickUp State: $currentPickUpState");
          }

          if (currentDropOffState == CurrentDropOffState.onTrip) {
            if (inDropOffSlowDownZone && !inDropOffZone) {
              currentDropOffState = CurrentDropOffState.enteredSlowDownZone;
            }
          }

          if (currentDropOffState == CurrentDropOffState.enteredSlowDownZone) {
            if (inDropOffZone) {
              currentDropOffState = CurrentDropOffState.enteredDropOffZone;
            }
          }

          if (currentDropOffState == CurrentDropOffState.enteredDropOffZone) {
            if (!inDropOffZone) {
              currentDropOffState = CurrentDropOffState.leftDropOffZone;
            }
          }

          if (currentDropOffState == CurrentDropOffState.leftDropOffZone) {
            if (thisAppModel.updateBusLocationResponse?.countPassengersToBeDroppedOff == null ||
                thisAppModel.updateBusLocationResponse?.countPassengersToBeDroppedOff == 0) {
              currentDropOffState = CurrentDropOffState.onTrip;
            }
          }

          if (kDebugMode) {
            print("current DropOff State: $currentDropOffState");
          }

          playBannersAudio();

          currentBanners = getCurrentBanners(thisAppModel);

          // WidgetsBinding.instance
          //     .addPostFrameCallback((_) => ()
          // );
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
                if (!mapController!.isCompleted) {
                  mapController?.complete(controller);
                }
                // mapController?.complete(controller);
                // await adjustBounds();
              },
              onCameraIdle: () async {
                if (boundMode == 0) {
                  if (!isMapAdjusted) {
                    await adjustBounds();
                    isMapAdjusted = true;
                  }
                }
                if (boundMode == 1) {
                  await centerBusMarker();
                }
              },
            ),
            //button to adjust bound
            DirectionPositioned(
              top: 25.h,
              right: 10.w,
              child: SizedBox(
                width: 40.w,
                height: 40.w,
                child: TextButton(
                  onPressed: () async {
                    await adjustBounds();
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    shape: const CircleBorder(),
                  ),
                  child: const Center(child: Icon(Icons.fit_screen_outlined, color: AppTheme.secondary,)),
                ),
              ),
            ),
            //button to center of bus marker
            DirectionPositioned(
              top: 90.h,
              right: 10.w,
              child: SizedBox(
                width: 40.w,
                height: 40.w,
                child: TextButton(
                    onPressed: () async {
                      //Center the map to the bus marker
                      await centerBusMarker();
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      shape: const CircleBorder(),
                    ),
                    child: const Icon(FontAwesomeIcons.bus, color: AppTheme.secondary,),
                ),
              ),
            ),
            DirectionPositioned(
              bottom: 60,
              left: 10,
              right: 10,
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13),
                ),
                margin: const EdgeInsets.all(10),
                child: Column(
                  children: [
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: SizedBox(
                        width: 400.w,
                        height: 125.h,
                        child: Stack(
                          children: [
                            DirectionPositioned(
                              left: -10.w,
                              child: SizedBox(
                                width: 300.w,
                                child: Material(
                                  color: Colors.transparent,
                                  child: RouteWidget(
                                    children: [
                                      RouteWidgetDashedLine(
                                        trailing: Text(
                                          distanceToNextStop ?? "",
                                          style: AppTheme.textGreySmall,
                                        ),
                                        bus: true,
                                        heightParam: 50,
                                      ),
                                      RouteWidgetMarker(
                                        leading: Text(
                                          nextStopPlannedTime ?? "",
                                          textAlign: TextAlign.left,
                                          style: const TextStyle(
                                            color: AppTheme.secondary,
                                            fontSize: 10,
                                            fontFamily: 'Open Sans',
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        trailing: SizedBox(
                                          width: 200.w,
                                          height: 50.h,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                nextStopName?? "",
                                                style: AppTheme.textSecondaryMedium,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              SizedBox(height: 5.h,),
                                              Text(
                                                nextStopAddress ?? "",
                                                style: AppTheme.textSecondarySmall,
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
                    (thisAppModel.updateBusLocationResponse?.countPassengersToBeDroppedOff != null &&
                        thisAppModel.updateBusLocationResponse?.countPassengersToBeDroppedOff != 0) ||
                        (thisAppModel.updateBusLocationResponse?.countPassengersToBePickedUp != null &&
                        thisAppModel.updateBusLocationResponse?.countPassengersToBePickedUp != 0) ?
                    Container(
                      height: 2,
                      width: 300.w,
                      color: AppTheme.normalGrey,
                    ):Container(),
                    const SizedBox(height: 5),
                    (thisAppModel.updateBusLocationResponse?.countPassengersToBeDroppedOff != null &&
                    thisAppModel.updateBusLocationResponse?.countPassengersToBeDroppedOff != 0) ?
                    Padding(
                      padding: EdgeInsets.only(left: 10.w, right: 10.0.w, bottom: 10.h),
                      child: Row(
                        children: [
                          const Row(
                            children: [
                              Icon(
                                Icons.people,
                                color: AppTheme.secondary,
                              ),
                              Icon(
                                Icons.arrow_downward,
                                color: AppTheme.secondary,
                              )
                            ],
                          ),
                          SizedBox(width: 10.w,),
                          Text(
                            "$passengerCountToBeDroppedOff Students",
                            style: AppTheme.textSecondaryMedium,
                          ),
                        ],
                      ),
                    ):Container(),
                    passengerCount != null && passengerCount != "0" ? Padding(
                      padding: EdgeInsets.only(left: 10.w, right: 10.0.w, bottom: 10.h),
                      child: InkWell(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.people,
                                  color: AppTheme.primary,
                                ),
                                Icon(
                                  Icons.arrow_upward,
                                  color: AppTheme.secondary,
                                ),
                                SizedBox(width: 10.w,),
                                Text(
                                  "$passengerCount Students",
                                  style: AppTheme.textSecondaryMedium,
                                ),
                              ],
                            ),
                            // add a button to show the list of students to be picked up
                            const Icon(Icons.arrow_forward_ios, color: AppTheme.primary,),
                          ],
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    StudentsScreen(
                                      tripID: widget.trip!.id!,
                                    )),
                          );
                        },
                      ),
                    ):Container(),
                  ],
                ),
              ),
            ),
            DirectionPositioned(
              bottom: 10,
              left: 10,
              right: 10,
              child: Column(
                children: currentBanners,
              ),
            ),
          ],
        );
      }
    }
    return Container();
  }

  Marker createStopMarker(dynamic stop) {
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


  int getDifference(String time1, String time2) {
    DateFormat dateFormat = DateFormat("HH:mm:ss");

    DateTime a = dateFormat.parse(time1);
    DateTime b = dateFormat.parse(time2);

    //check if time 2 is less than time 1, then add 24 hours to time 2
    if (b.isBefore(a)) {
      b = b.add(const Duration(hours: 24));
    }

    return b
        .difference(a)
        .inMinutes;
  }

  Future<void> adjustBounds() async {
    boundMode = 0;
    LatLngBounds? boundss = getBoundsMarker();
    if (boundss != null) {
      mapController?.future.then((value) =>
          value.animateCamera(CameraUpdate.newLatLngBounds(boundss, 50)));
    }
  }

  LatLngBounds? getBoundsMarker() {
    if (mapController == null) {
      return null;
    }
    if (markers.isEmpty || markers.length == 1) {
      return null;
    }

    return Tools.createBounds(markers.map((m) => m.position).toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 60.h,
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          translation(context)?.onRoute ?? "On Route",
          style: AppTheme.title,
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(top: 10.w, right: 20.w, bottom: 10.w),
            child: SizedBox(
              width: 100.w,
              child: ElevatedButton(
                onPressed: () {
                  showOkCancelDialog(
                      context,
                      thisApplicationModel,
                      translation(context)?.endTrip ?? "End Trip",
                      translation(context)?.endTripConfirmation ?? "Are you sure you want to end the trip?",
                      translation(context)?.ok ?? "OK",
                      translation(context)?.cancel ?? "Cancel",
                          () async {
                        //start trip
                        Navigator.of(context, rootNavigator: true).pop();
                        thisApplicationModel.startTrip(context, widget.trip, 0, positionStream: positionStream);
                      },
                          () {
                        //cancel
                        Navigator.of(context, rootNavigator: true).pop();
                      }
                  );
                },
                style: TextButton.styleFrom(
                  shape: const StadiumBorder(),
                  backgroundColor: AppTheme.primary,
                ),
                child: thisApplicationModel.startTripLoadingState.inLoading()
                  ? const CircularProgressIndicator(color: Colors.white,)
                  : Text(translation(context)?.endTrip ?? "End Trip", style: AppTheme.textSecondarySmall,),

              ),
            ),
          )
        ],
      ),
      body: Consumer<ThisApplicationViewModel>(
          builder: (context, thisAppModel, child) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (thisAppModel.startTripLoadingState.error != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      thisAppModel.startTripLoadingState.error!,
                    ),
                  ),
                );
                thisAppModel.startTripLoadingState.error = null;
              }
            });
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (thisAppModel.dropOffPassengersLoadingState.error != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      thisAppModel.dropOffPassengersLoadingState
                          .error!,
                    ),
                  ),
                );
                thisAppModel.dropOffPassengersLoadingState.error = null;
              }
            });
            return displayRouteMap(thisAppModel);
          }),
    );
  }

  calculateCenterPoint(List<Marker> markers) {
    double x = 0;
    double y = 0;
    double z = 0;
    for (var i = 0; i < markers.length; i++) {
      double latitude = markers
          .elementAt(i)
          .position
          .latitude * pi / 180;
      double longitude = markers
          .elementAt(i)
          .position
          .longitude * pi / 180;
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

  void updateMarkerPosition() {
    if (busMarker != null) {
      //update the position
      busMarker = busMarker!.copyWith(
        positionParam: LatLng(
            currentLocation!.latitude, currentLocation!.longitude),
      );
    }
  }

  void updateMarkerIcon() {
    if (busMarker != null) {
      //update icon
      busMarker = busMarker!.copyWith(
        iconParam: customIcon,
      );
    }
  }

  centerBusMarker() {
    boundMode = 1;
    //center the map on the bus marker
    mapController?.future.then((value) =>
        value.animateCamera(CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(
                currentLocation!.latitude, currentLocation!.longitude),
            zoom: 15,
          ),
        )));
  }

  textBanner(String message, handleDismiss,
      {Color? backgroundColor, String buttonText = "Dismiss"}) {
    return MaterialBanner(
      content: Text(message),
      leading: const Icon(Icons.info),
      backgroundColor: backgroundColor ?? Colors.yellow,
      actions: [
        TextButton(
          onPressed: handleDismiss,
          child: Text(buttonText),
        ),
      ],
    );
  }

  getCurrentBanners(ThisApplicationViewModel thisAppModel) {
    setAllBannerDataInvisible();
    List<Widget> banners = [];
    if (thisAppModel.updateBusLocationLoadingState.loadError != null) {
      if (kDebugMode) {
        print("error updating bus location${thisAppModel.updateBusLocationLoadingState.loadError}");
      }
      banners.add(
        textBanner("Error updating bus location ", () {
          setState(() {
            thisAppModel.updateBusLocationLoadingState.loadError = null;
          });
        }, backgroundColor: Colors.red),
      );
    }

    if (currentPickUpState == CurrentPickUpState.enteredSlowDownZone &&
        thisAppModel.updateBusLocationResponse?.countPassengersToBePickedUp != null &&
        thisAppModel.updateBusLocationResponse?.countPassengersToBePickedUp != 0) {
      // set enteredSlowDownZoneBannerData to visible in bannerDataList
      enteredSlowDownZoneBannerData.visible = true;
    }
    if (currentPickUpState == CurrentPickUpState.enteredPickupZone &&
        thisAppModel.updateBusLocationResponse?.countPassengersToBePickedUp != null &&
        thisAppModel.updateBusLocationResponse?.countPassengersToBePickedUp != 0) {
      enteredPickupZoneBannerData.visible = true;
    }

    //check if miss the next stop
    if (currentPickUpState == CurrentPickUpState.leftPickupZone &&
        thisAppModel.updateBusLocationResponse?.countPassengersToBePickedUp != null &&
        thisAppModel.updateBusLocationResponse?.countPassengersToBePickedUp != 0) {
      leftPickupZoneBannerData.visible = true;
    }

    //enteredDropOffSlowDownZone
    if (currentDropOffState == CurrentDropOffState.enteredSlowDownZone &&
        thisAppModel.updateBusLocationResponse?.countPassengersToBeDroppedOff != null &&
        thisAppModel.updateBusLocationResponse?.countPassengersToBeDroppedOff != 0 &&
        currentDistanceToDropOff != maxDistance) {
      enteredDropOffSlowDownZoneBannerData.visible = true;
    }

    //enteredDropOffZone
    if (currentDropOffState == CurrentDropOffState.enteredDropOffZone &&
        thisAppModel.updateBusLocationResponse?.countPassengersToBeDroppedOff != null &&
        thisAppModel.updateBusLocationResponse?.countPassengersToBeDroppedOff != 0) {
      enteredDropOffZoneBannerData.visible = true;
    }

    //leftDropOffZone
    if (currentDropOffState == CurrentDropOffState.leftDropOffZone &&
        thisAppModel.updateBusLocationResponse?.countPassengersToBeDroppedOff != null &&
        thisAppModel.updateBusLocationResponse?.countPassengersToBeDroppedOff != 0) {
      leftDropOffZoneBannerData.visible = true;
    }

    for (var i = 0; i < bannerDataList.length; i++) {
      BannerData bannerData = bannerDataList[i];
      if (bannerData.visible) {
        banners.add(
          textBanner(bannerData.message, () {
            bannerData.handleAction?.call(context, widget, currentLocation, thisAppModel);
          }, backgroundColor: bannerData.backgroundColor,
              buttonText: bannerData.buttonText),
        );
      }
    }

    return banners;
  }

  Marker createDropOffMarker(dynamic reservation) {
    return Marker(
      markerId: MarkerId(reservation.id.toString()),
      position: LatLng(
          reservation.endPointLatitude, reservation.endPointLongitude),
      //purple color
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet),
      // consumeTapEvents: true,
    );
  }

  void playBannersAudio() {
    for (var i = 0; i < bannerDataList.length; i++) {
      if(bannerDataList[i].visible) {
        bannerDataList[i].playAudio();
      }
    }
  }

  void setAllBannerDataInvisible() {
    for (var i = 0; i < bannerDataList.length; i++) {
      BannerData bannerData = bannerDataList[i];
      bannerData.visible = false;
    }
  }
}
