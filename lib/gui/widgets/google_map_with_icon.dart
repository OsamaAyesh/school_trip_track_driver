import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../services/service_locator.dart';
import '../../view_models/this_application_view_model.dart';

class GoogleMapWithIcon extends StatefulWidget {

  final LatLng? currentLatLng;
  final String? currentAddress;

  const GoogleMapWithIcon({Key? key, this.currentLatLng, this.currentAddress}) : super(key: key);

  @override
  GoogleMapWithIconState createState() => GoogleMapWithIconState();

}

class GoogleMapWithIconState extends State<GoogleMapWithIcon> {

  CameraPosition? cameraPosition;

  ThisApplicationViewModel? appModel = serviceLocator<ThisApplicationViewModel>();

  @override
  void initState() {
    appModel?.mapData = MapData();
    appModel?.mapData?.currentLatLng = widget.currentLatLng;
    appModel?.mapData?.currentAddress = widget.currentAddress;
    super.initState();
  }

  @override
  void dispose() {
    appModel?.mapData?.clear();
    super.dispose();
  }

  //create getter for map
  Widget getMap() {
    return Column(
      children: [
        Expanded(
          child: Stack(
            children: [
              GoogleMap( //Map widget from google_maps_flutter package
                zoomGesturesEnabled: true,
                //enable Zoom in, out on map
                initialCameraPosition: CameraPosition( //initial position in map
                  target: appModel!.mapData!.currentLatLng ?? const LatLng(37.42796133580664, -122.085749655962),
                  zoom: 14.0, //initial zoom level
                ),
                mapType: MapType.normal,
                //map type
                onMapCreated: (controller) { //method called when map is created
                  setState(() {
                    appModel?.mapController = controller;
                  });
                },
                onCameraMove: (CameraPosition cameraPositiona) {
                  setState(() {
                    cameraPosition = cameraPositiona;
                  });
                },
                onCameraIdle: () async {
                  if (cameraPosition == null) return;
                  List<
                      Placemark> placeMarks = await placemarkFromCoordinates(
                      cameraPosition!.target.latitude,
                      cameraPosition!.target.longitude);

                  appModel?.setCurrentMapAddress(
                      getAddressFromPlaceMark(placeMarks.first));

                  if (kDebugMode) {
                    print(appModel?.mapData?.currentAddress);
                  }

                  appModel?.setCurrentMapLatLng(
                      LatLng(cameraPosition!.target.latitude,
                          cameraPosition!.target.longitude));
                },
              ),
              Center( //picker image on google map
                child: appModel?.mapData?.currentAddress != null || appModel?.mapData?.currentLatLng  != null ? Image.asset(
                  "assets/icons/location.png", width: 80,): const SizedBox(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return getMap();
  }

  String? getAddressFromPlaceMark(Placemark first) {
    if (kDebugMode) {
      print(' ${first.locality}, ${first.administrativeArea},${first.subLocality}, ${first.subAdministrativeArea},${first.thoroughfare}, ${first.subThoroughfare}');
    }

    return "${first.administrativeArea}, ${first.street!}, ${first.country!}";
  }
}

// class GoogleMapWithIcon extends StatefulWidget {
//   LatLng? startLocation;
//   String? location = "Search location";
//   LatLng? newLatLng;
//   GoogleMapController? mapController;
//
//   CameraPosition? cameraPosition;
//
//   GoogleMapWithIcon({Key? key, this.startLocation});
//
//
//
//   @override
//   Widget build(BuildContext context) {
//     return getMap();
//   }
//
// }
