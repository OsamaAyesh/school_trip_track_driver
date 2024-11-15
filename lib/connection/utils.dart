import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:school_trip_track_driver/main.dart';
import 'package:school_trip_track_driver/model/loading_state.dart';
import 'package:school_trip_track_driver/utils/network_check.dart';
import 'package:school_trip_track_driver/view_models/this_application_view_model.dart';
import 'package:geolocator/geolocator.dart';

import '../gui/languages/language_constants.dart';
import '../utils/config.dart';


enum ScreenState {
  LOADING,
  FINISH,
}

enum FailState {
  INTERNET,
  GENERAL,
  UNAUTHENTICATED,
}

void callEndpoint(Future<dynamic> apiCall,
    LoadingState loadingState,
    ChangeNotifier changeNotifier,
    FutureOr<dynamic>? Function(dynamic value) onValue, {BuildContext? context}) {
  bool errorExist = false;
  loadingState.setLoadingStatus(ScreenState.LOADING, changeNotifier);

  apiCall.then(onValue).catchError(
          (e) async {
            errorExist = true;
        await onError(e, loadingState);
      }
  ).whenComplete(() {
    loadingState.setLoadingStatus(ScreenState.FINISH, changeNotifier);
    if (context != null && context.mounted && !errorExist) {
      Future.delayed(const Duration(milliseconds: 50), () {
        Navigator.pop(context);
      });
    }
  });
}

onError(e, LoadingState loadState) async {
  if (kDebugMode) {
    print(e.toString());
  }

  try{
    String message = e.message;
    loadState.loadError = 1;
    bool connect = await NetworkCheck.isConnect();

    if (connect) {
      //check if message contains unauthenticated or unauthorized
      if (message.contains("unauthenticated") || message.contains("unauthorized"))
      {
        loadState.failState = FailState.UNAUTHENTICATED;
        loadState.error = Config.notAuthenticatedText;
      }
      else {
        loadState.failState = FailState.GENERAL;
        loadState.error = message;
      }
    } else {
      loadState.failState = FailState.INTERNET;
      loadState.error =
      "No internet. Please check your network settings.";
    }
  }
  catch(ee) {
    if (kDebugMode) {
      print(ee.toString());
    }
    loadState.failState = FailState.GENERAL;
    loadState.error = e.toString();
    if (kDebugMode) {
      print(e.toString());
    }
  }
  loadState.setError(1);
  loadState.loadState = ScreenState.FINISH;
}


showAlertLogoutDialog(BuildContext context, ThisApplicationViewModel thisApplicationViewModel) {
  // set up the buttons
  Widget cancelButton = TextButton(
    child: Text(translation(context)?.cancel ?? 'Cancel'),
    onPressed: () {
      Navigator.of(context, rootNavigator: true)
          .pop();
    },
  );
  Widget continueButton = TextButton(
    child: Text(translation(context)?.continueText ?? 'Continue'),
    onPressed: () async {
      Navigator.of(context, rootNavigator: true).pop();
      await thisApplicationViewModel.signOut();
      if (context.mounted)
      {
        Future.delayed(const Duration(milliseconds: 50), () {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const MyHomePage()),
                (Route<dynamic> route) => false,
          );
        });
      }
    },
  );
  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    title: Text(translation(context)?.logout ?? 'Logout'),
    content: Text(translation(context)?.logoutWarning ?? 'Are you sure you want to logout?'),
    actions: [
      cancelButton,
      continueButton,
    ],
  );

  // show the dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}

enum LocationServicesStatus{
  disabled,
  enabled,
  denied,
  deniedForever
}

Future<LocationServicesStatus> checkLocationService(BuildContext context) async {
  LocationPermission permission;
  bool serviceStatus = await Geolocator.isLocationServiceEnabled();
  if (serviceStatus) {
    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (kDebugMode) {
          print('Location permissions are denied');
        }
      } else if (permission == LocationPermission.deniedForever) {
        if (kDebugMode) {
          print("'Location permissions are permanently denied");
        }
      } else {
        return LocationServicesStatus.enabled;
      }
      return LocationServicesStatus.denied;
    } else {
      return LocationServicesStatus.enabled;
    }
  } else {
    //display dialog to turn on location
    if (kDebugMode) {
      print('Location services are disabled.');
    }
    if(context.mounted) {
      showTurnOnLocationDialog(context);
    }
    return LocationServicesStatus.disabled;
  }
}
Future<Position> getLocation() async {
  Position currentGPSLocation =
  await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  return currentGPSLocation;
}

void showTurnOnLocationDialog(BuildContext context) {
  showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Turn on location'),
          content: const Text('Please turn on location to continue'),
          actions: [
            TextButton(
              child: const Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop();
                //open location settings
                Geolocator.openLocationSettings();
              },
            ),
          ],
        );
      });
}