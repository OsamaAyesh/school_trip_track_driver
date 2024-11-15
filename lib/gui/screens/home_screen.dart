import 'dart:async';
import 'package:school_trip_track_driver/gui/screens/start_trip_screen.dart';
import 'package:school_trip_track_driver/gui/screens/students_order_screen.dart';
import 'package:school_trip_track_driver/gui/screens/trip_time_line_screen.dart';
import 'package:school_trip_track_driver/gui/widgets/RouteWidget/route_widget.dart';
import 'package:school_trip_track_driver/gui/widgets/RouteWidget/route_widget_dashed_line.dart';
import 'package:school_trip_track_driver/gui/widgets/RouteWidget/route_widget_marker.dart';
import 'package:school_trip_track_driver/gui/widgets/RouteWidget/route_widget_road.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:school_trip_track_driver/services/service_locator.dart';
import 'package:school_trip_track_driver/utils/app_theme.dart';
import 'package:school_trip_track_driver/utils/size_config.dart';
import 'package:school_trip_track_driver/view_models/this_application_view_model.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../connection/utils.dart';
import '../../model/trip.dart';
import '../../utils/tools.dart';
import '../../widgets.dart';
import '../languages/language_constants.dart';
import '../widgets/shimmers.dart';
import 'package:school_trip_track_driver/gui/widgets/direction_positioned.dart';

class HomeTab extends StatefulWidget {
  HomeTab(this.isMorning, {Key? key}) : super(key: key);

  bool? isMorning;

  @override
  HomeTabState createState() => HomeTabState();
}

class HomeTabState extends State<HomeTab> {
  final _refreshKey = GlobalKey<RefreshIndicatorState>();
  ThisApplicationViewModel thisApplicationModel = serviceLocator<ThisApplicationViewModel>();
  bool isLoading = false;
  bool activePostsFound = false;

  bool serviceStatus = false;
  bool hasPermission = false;

  Position? currentGPSLocation;
  bool? locationServiceStatus;

  final searchController = TextEditingController();
  final searchFocusNode = FocusNode();

  Locale _locale = const Locale('en', '');

  @override
  void initState() {
    getLocale().then((locale) {
      setState(() {
        _locale = locale;
      });
    });
    checkLocationService(context).then((LocationServicesStatus value) {
      locationServiceStatus = value == LocationServicesStatus.enabled;
      if(locationServiceStatus!= null && locationServiceStatus!) {
        getLocation().then((value) {
        currentGPSLocation = value;
      });
      }
    });
    searchFocusNode.addListener(() async {
      if (searchFocusNode.hasFocus) {
        searchFocusNode.unfocus();
        //await startSearch();
      }
    });
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {

    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _setData(ThisApplicationViewModel thisAppModel) {
    thisAppModel.getDriverTripsEndpoint();
  }

  Future<void> _refreshData(ThisApplicationViewModel thisAppModel) {
    return Future(
            () {
          _setData(thisAppModel);
        }
    );
  }

  Widget _displayTrips(ThisApplicationViewModel thisAppModel) {
    if (thisAppModel.tripsLoadingState.inLoading()) {
      // loading. display animation
      Shimmers shimmer = Shimmers(
        options: ShimmerOptions().vListOptions(4),
      );
      return Container(
          margin: const EdgeInsets.symmetric(vertical: 16),
          height: Tools.getScreenHeight(context) * 0.65,
          child:shimmer
      );
    }
    else if (thisAppModel.tripsLoadingState.loadingFinished()) {
      if (thisAppModel.tripsLoadingState.loadError != null) {
        return
          Text(translation(context)?.networkError ?? "Network error");
      }
      else {

        if(thisAppModel.myTrips.isEmpty)
        {
          return notAssignedTrips();
        }
        else {
          //filter trips without start and end time
          List<Trip> activeTrips = [];
          for (int i = 0; i < thisAppModel.myTrips.length; i++) {
            if (thisAppModel.myTrips[i].startedAt == null && thisAppModel.myTrips[i].isMorning == widget.isMorning) {
              activeTrips.add(thisAppModel.myTrips[i]);
            }
          }

          if(activeTrips.isNotEmpty) {
            return Container(
                margin: const EdgeInsets.symmetric(vertical: 16),
                height: Tools.getScreenHeight(context) * 0.72,
                child:
                ListView.builder(
                    itemCount: activeTrips.length,
                    itemBuilder: (context, i) {
                      return Padding(
                          padding: const EdgeInsets.all(3),
                          child: tripCard(activeTrips[i])
                      );
                    })
            );
          }
          else {
            return notAssignedTrips();
            //return Text(translation(context)?.noTripsAssignedToYou ?? "No trips assigned to you yet.");
          }
        }
      }
    }
    return Container();
  }

  Widget _displayAllSections(ThisApplicationViewModel thisAppModel) {
    var items = <Widget>[];
    items.add(_displayTripsSection(thisAppModel));
    return RefreshIndicator(
      onRefresh: ()=>_refreshData(thisAppModel),
      child: ListView(
          children: items
      ),
    );
  }

  Widget _displayTripsSection(ThisApplicationViewModel thisAppModel) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: getProportionateScreenHeight(10)),
          _displayTrips(thisAppModel)
        ],
      ),
    );
  }

  Widget _buildHomeTab(BuildContext context, ThisApplicationViewModel thisAppModel) {
    return _displayAllSections(thisAppModel);
  }

  @override
  Widget build(context) {
    return Consumer<ThisApplicationViewModel>(
        builder: (context, thisAppModel,  child) {
          return _buildHomeTab(context, thisAppModel);
        });
  }

  Widget loadingScreen() {
    return
      Stack(
          children: [
            Positioned.fill(
              child: Align(
                alignment: Alignment.topCenter,
                child: Column(
                  children: [
                    Container(),
                  ],
                ),
              ),
            ),
            DirectionPositioned(
              top: 20,
              left: 10,
              right: 10,
              bottom: 10,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    height: 60,
                    width: 60,
                    child: CircularProgressIndicator(
                      strokeWidth: 8,
                      backgroundColor: Colors.transparent,
                      valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 30),
                    child: Column(
                      children: [
                        Text("Loading ...",
                          style: AppTheme.caption,
                          textAlign: TextAlign.center,),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ]
      );
  }

  tripCard(Trip trip) {
    String startStopName = trip.plannedTripDetail?[0].stop!.name!;
    String startStopAddress = trip.plannedTripDetail?[0].stop!.address!;
    String endStopName = trip.plannedTripDetail?[trip.plannedTripDetail!.length - 1].stop!.name!;
    String endStopAddress = trip.plannedTripDetail?[trip.plannedTripDetail!.length - 1].stop!.address!;
    if(thisApplicationModel.settings?.simpleMode == true)
    {
      if (trip.isMorning == true) {
        startStopName = translation(context)?.currentLocation ?? "Current Location";
        startStopAddress = "";
      }
      // else {
      //   endStopName = "End Stop";
      //   endStopAddress = "";
      // }
    }
    return Column(
      children: [
        SizedBox(height: 1.h,),
        Text(
          DateFormat('EEEE, dd MMMM', _locale.languageCode).format(DateTime.parse(trip.plannedDate!)),
          style: const TextStyle(
            color: AppTheme.secondaryLight,
            fontSize: 16,
            fontFamily: 'Open Sans',
            fontWeight: FontWeight.w700,
            height: 0,
          ),
        ),
        SizedBox(height: 10.h,),
        Card(
          elevation: 7,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(13.0),
          ),
          color: AppTheme.backgroundColor,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Column(
                      children: [
                        Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: SizedBox(
                            width: SizeConfig.screenWidth!-100.w,
                            height: 180.h,
                            child: Stack(
                              children: [
                                DirectionPositioned(
                                  left: -60.w,
                                  child: SizedBox(
                                    width: SizeConfig.screenWidth! - 10.w,
                                    child: Material(
                                      color: Colors.transparent,
                                      child: RouteWidget(
                                        children: [
                                          RouteWidgetMarker(
                                            leading: const SizedBox(),
                                            trailing: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  startStopName,
                                                  style: AppTheme.textSecondaryMedium,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                                SizedBox(height: 5.h,),
                                                Text(
                                                  startStopAddress,
                                                  style: AppTheme.textSecondarySmall,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ],
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
                                              padding: EdgeInsets.only(top: 1.h),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Text(trip.route!=null? trip.route!.name! : "",
                                                    style: AppTheme.textPrimarySmall,
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                          RouteWidgetDashedLine(
                                            trailing: const SizedBox(),
                                            walking: false,
                                            heightParam: 24.h,
                                          ),
                                          RouteWidgetMarker(
                                            leading: const SizedBox(),
                                            trailing: SizedBox(
                                              width: 200.w,
                                              height: 50.h,
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    endStopName,
                                                    style: AppTheme.textSecondaryMedium,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                  SizedBox(height: 5.h,),
                                                  Text(
                                                    endStopAddress,
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
                      ],
                    ),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: (trip.reservationsCount != null && trip.reservationsCount != 0) ? AppTheme.primary : AppTheme.colorError,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Text(
                              trip.reservationsCount != null ? trip.reservationsCount.toString() : "0",
                              style: AppTheme.textSecondarySmall,
                            ),
                            Icon(
                              Icons.person,
                              color: AppTheme.secondary,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10.h,),
                const Divider(
                  color: AppTheme.lightGrey,
                  thickness: 1,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TripTimelineScreen(
                              tripDetails: trip.plannedTripDetail,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.timeline, color: AppTheme.secondary),
                    ),
                    thisApplicationModel.settings?.simpleMode == true ?
                    IconButton(
                      onPressed: () async {
                        //navigate to students order screen
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => StudentsOrderScreen(
                              trip: trip,
                              isMorning: trip.isMorning,
                            ),
                          ),
                        );
                        setState(() {
                          thisApplicationModel.myTrips = thisApplicationModel.myTrips;
                        });
                      },
                      icon: const Icon(Icons.settings, color: AppTheme.secondary),
                    ) : const SizedBox(),
                    //start a trip icon button
                    IconButton(
                      onPressed: () {
                        if(trip.route!=null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  StartTripScreen(
                                      routeId: trip.route!.id!, trip: trip),
                            ),
                          ).then((value) {
                            setState(() {
                              thisApplicationModel.myTrips = thisApplicationModel.myTrips;
                            });
                          });
                        }
                      },
                      icon: const Icon(Icons.play_arrow, color: AppTheme.secondary),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget notAssignedTrips() {
    //image img_no_assigned_trips.png with text "No trips assigned to you yet."
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 30.h,),
          Image.asset("assets/images/img_no_assigned_trips.png"
            , width: 250.w, height: 250.h,),
          SizedBox(height: 20.h,),
          Text(translation(context)?.noTripsAssignedToYou ?? "No trips assigned to you yet.",
            style: AppTheme.textSecondaryMedium,
          ),
        ]
      ),
    );
  }
}
