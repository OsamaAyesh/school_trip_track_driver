

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:intl/intl.dart';
import 'package:school_trip_track_driver/model/driver_data.dart';
import 'package:school_trip_track_driver/model/driver_document.dart';
import 'package:school_trip_track_driver/model/route_details.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:school_trip_track_driver/connection/all_apis.dart';
import 'package:school_trip_track_driver/connection/response/auth_response.dart';
import 'package:school_trip_track_driver/connection/utils.dart';
import 'package:school_trip_track_driver/model/device.dart';
import 'package:school_trip_track_driver/model/loading_state.dart';
import 'package:school_trip_track_driver/model/my_notification.dart';
import 'package:school_trip_track_driver/model/push_notification.dart';
import 'package:school_trip_track_driver/model/setting.dart';
import 'package:school_trip_track_driver/model/trip.dart';
import 'package:school_trip_track_driver/model/user.dart';
import 'package:school_trip_track_driver/services/service_locator.dart';
import 'package:school_trip_track_driver/utils/app_theme.dart';
import 'package:school_trip_track_driver/utils/auth.dart';
import 'package:school_trip_track_driver/utils/twitter_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../connection/response/update_bus_location_response.dart';
import '../gui/languages/language_constants.dart';
import '../model/stop.dart';
import '../utils/config.dart';

class MapData{
  LatLng? _latLng;
  String? _address;

  LatLng? get currentLatLng => _latLng;
  String? get currentAddress => _address;


  set currentLatLng(LatLng? latLng) {
    _latLng = latLng;
  }

  set currentAddress(String? address) {
    _address = address;
  }

  void clear() {
    _latLng = null;
    _address = null;
  }
}

class ThisApplicationViewModel extends ChangeNotifier {
  final AllApis _apiService = serviceLocator<AllApis>();
  late String firebaseToken;

  MapData? mapData;

  void setCurrentMapAddress(String? address) {
    mapData?.currentAddress = address;
    notifyListeners();
  }

  void setCurrentMapLatLng(LatLng? latLng) {
    mapData?.currentLatLng = latLng;
    notifyListeners();
  }

  void clearMapData() {
    mapData?.clear();
    notifyListeners();
  }

  /////////////////////////////UserPublicProfile///////////////////////////////

  //uploadAvatar
  LoadingState uploadAvatarLoadingState = LoadingState();
  void uploadAvatarEndpoint(String? imagePath) { // Upload avatar
    if (apiToken == null) return;

    callEndpoint(_apiService.uploadAvatar(apiToken!, imagePath),
        uploadAvatarLoadingState, this, (resp) {
          currentUser!.avatar = resp;
          uploadAvatarLoadingState.setError(null);
        });
  }

  ////////////////////////////////////Airports/////////////////////////////////

  GoogleMapController? mapController;

  bool isValidAirport(String from, String to) {
    if (from != to) {
      return true;
    } else {
      return false;
    }
  }
  /////////////////////////////////////////////Auth///////////////////////////

  Auth auth = serviceLocator<Auth>();
  bool? isLoggedIn;
  String? apiToken;
  DbUser? currentUser;

  LoadingState? signInLoadingState = LoadingState();
  LoadingState? signOutLoadingState = LoadingState();
  LoadingState? signUpLoadingState = LoadingState();

  Future<void> initPlatformState() async {
    final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();

    try {
      if (Platform.isAndroid) {
        deviceData = _readAndroidBuildData(await deviceInfoPlugin.androidInfo);
      } else if (Platform.isIOS) {
        deviceData = _readIosDeviceInfo(await deviceInfoPlugin.iosInfo);
      }
    } on PlatformException {
      deviceData = <String, dynamic>{
        'Error:': 'Failed to get platform version.'
      };
    }
  }

  Map<String, dynamic> _readAndroidBuildData(AndroidDeviceInfo build) {
    return <String, dynamic>{
      'version.securityPatch': build.version.securityPatch,
      'version.sdkInt': build.version.sdkInt,
      'version.release': build.version.release,
      'version.previewSdkInt': build.version.previewSdkInt,
      'version.incremental': build.version.incremental,
      'version.codename': build.version.codename,
      'version.baseOS': build.version.baseOS,
      'board': build.board,
      'bootloader': build.bootloader,
      'brand': build.brand,
      'device': build.device,
      'display': build.display,
      'fingerprint': build.fingerprint,
      'hardware': build.hardware,
      'host': build.host,
      'id': build.id,
      'manufacturer': build.manufacturer,
      'model': build.model,
      'product': build.product,
      'supported32BitAbis': build.supported32BitAbis,
      'supported64BitAbis': build.supported64BitAbis,
      'supportedAbis': build.supportedAbis,
      'tags': build.tags,
      'type': build.type,
      'isPhysicalDevice': build.isPhysicalDevice,
      'androidId': build.id,
      'systemFeatures': build.systemFeatures,
    };
  }

  Map<String, dynamic> _readIosDeviceInfo(IosDeviceInfo data) {
    return <String, dynamic>{
      'name': data.name,
      'systemName': data.systemName,
      'systemVersion': data.systemVersion,
      'model': data.model,
      'localizedModel': data.localizedModel,
      'identifierForVendor': data.identifierForVendor,
      'isPhysicalDevice': data.isPhysicalDevice,
      'utsname.sysname:': data.utsname.sysname,
      'utsname.nodename:': data.utsname.nodename,
      'utsname.release:': data.utsname.release,
      'utsname.version:': data.utsname.version,
      'utsname.machine:': data.utsname.machine,
    };
  }

  Future<void> isUserLoggedIn() async {
    await getCurrentUser();
    String? t = await getApiToken();
    isLoggedIn = (t != null);
    if(isLoggedIn == true) {
      try {
        AuthResponse? resp = await _apiService.verifyUser(
            apiToken!, deviceData["model"]);
        if (resp == null) {
          signOut();
        }
        else {
          currentUser = resp.user;
          settings ??= Setting();
          settings = resp.settings;
          if (currentUser?.role != 3) {
            signOut();
          }
        }
      }
      catch (e) {
        if (kDebugMode) {
          print(e);
        }
        signOut();
      }
    }
    notifyListeners();
  }

  Future<String?> getApiToken() async {
    if (apiToken == null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      apiToken = prefs.getString('apiToken');
    }
    if (kDebugMode) {
      print(apiToken);
    }
    return apiToken;
  }

  Future<DbUser?> getCurrentUser() async {
    if (currentUser == null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? currentUserString = prefs.getString('currentUser');

      if (currentUserString == null) return null;

      dynamic currentUserDynamic = jsonDecode(currentUserString);
      currentUser = DbUser.fromJson(currentUserDynamic);
    }
    return currentUser;
  }


  //getCurrentUserFromServer
  LoadingState getCurrentUserLoadingState = LoadingState();

  Future<void> getDriverDataFromServer() async {
    if (apiToken == null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      apiToken = prefs.getString('apiToken');
    }
    if (apiToken != null) {
      callEndpoint(_apiService.getDriverData(apiToken!),
          getCurrentUserLoadingState, this, (resp) async {
            currentUser = resp.user;
            driverData = resp.driverData;
            if(resp.settings != null) {
              settings = resp.settings;
            }
            if (currentUser != null) {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.setString('currentUser', jsonEncode(currentUser));
            }
            getCurrentUserLoadingState.setError(null);
          });
    }
  }


  Future<String?> signOut() async {
    signOutLoadingState?.setLoadingStatus(ScreenState.LOADING, this);
    await auth.signOut().catchError((e) async {
      await onError(e, signOutLoadingState!);
    });
    clearAllUserData();

    apiToken = null;
    currentUser = null;
    driverData = DriverData();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('apiToken');
    await prefs.remove('currentUser');
    await isUserLoggedIn();
    notifyListeners();
    return null;
  }

  Future<void> authWithOurServer(String? name, String token, bool signIn) async {
    AuthResponse? authResponse;
    driverData = DriverData();
    if (signIn) {
      signInLoadingState?.setError(null);
      authResponse = await _apiService
          .loginViaToken(token, deviceData["model"], firebaseToken)
          .catchError((e) async {
        await onError(e, signInLoadingState!); return null;
      });
      if (authResponse != null) {
        currentUser = authResponse.user;
        if(authResponse.driverData != null) {
          driverData = authResponse.driverData!;
        }
        if (currentUser?.role != 3) {
          await signOut();
          signInLoadingState?.setError(1);
          signInLoadingState?.error = "You are not a driver";
          signInLoadingState?.setLoadingStatus(ScreenState.FINISH, this);
          return;
        }
        apiToken = authResponse.token;
        settings = authResponse.settings;
      }
    } else {
      //sign up
      signUpLoadingState?.setError(null);
      authResponse = await _apiService
          .createUser(name!, token, deviceData["model"], firebaseToken)
          .catchError((e) async {
        await onError(e, signUpLoadingState!);
        return null;
      });
      if (authResponse != null) {
        currentUser = authResponse.user;
        apiToken = authResponse.token;
        settings = authResponse.settings;
      }
    }

    if (apiToken != null && currentUser != null) {
      //save to shared pref here
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('apiToken', apiToken!);
      String currentUserString = jsonEncode(currentUser?.toJson());
      await prefs.setString('currentUser', currentUserString);
      signInLoadingState?.setError(null);
    }

    if (authResponse != null &&
        authResponse.userNotifications != null &&
        authResponse.userNotifications!.isNotEmpty) {
      notificationsList.clear();
      notificationsList.addAll(authResponse.userNotifications as Iterable<MyNotification>);
      notifyListeners();
    }
  }


  LoadingState resetPasswordLoadingState = LoadingState();

  void resetPassword(String email, BuildContext context) {
    resetPasswordLoadingState.setError(null);
    resetPasswordLoadingState.setLoadingStatus(ScreenState.LOADING, this);
    auth.sendPasswordResetEmail(email).then((value) {
      resetPasswordLoadingState.setError(null);
      Fluttertoast.showToast(
          msg:
          'Password reset link sent to your email successfully.',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: AppTheme.normalGrey,
          textColor: Colors.white);

      Future.delayed(const Duration(milliseconds: 50), () {
        Navigator.pop(context);
      });
    }).catchError((e) async {
      await onError(e, resetPasswordLoadingState);
    }).whenComplete(() {
      resetPasswordLoadingState.setLoadingStatus(ScreenState.FINISH, this);
      notifyListeners();
    });
  }

  Future<String?> signIn(String? email, String? password) async {
    signInLoadingState?.setError(null);
    apiToken = null;
    signInLoadingState?.setLoadingStatus(ScreenState.LOADING, this);
    String? token = await auth.signIn(email!, password!).catchError((e) async {
      signInLoadingState?.setLoadingStatus(ScreenState.FINISH, this);
      await onError(e, signInLoadingState!);
      return null;
    });
    if (token != null) {
      await authWithOurServer(null, token, true);
    }
    await isUserLoggedIn();
    if (apiToken != null) {
      if (kDebugMode) {
        print("apiToken: ${apiToken!}");
      }
    }
    return apiToken;
  }

  Future<String?> signUp(String? name, String? email, String? password) async {
    signUpLoadingState?.setError(null);
    apiToken = null;
    signUpLoadingState?.setLoadingStatus(ScreenState.LOADING, this);
    String? token = await auth.createUser(email, password).catchError((e) async {
      await onError(e, signUpLoadingState!);
      return null;
    });
    if (token != null) {
      await authWithOurServer(name, token, false);
    }
    await isUserLoggedIn();
    return apiToken;
  }

  Future<String?> authWithFacebook(bool signIn) async {
    signIn
        ? signInLoadingState?.setError(null)
        : signUpLoadingState?.setError(null);
    apiToken = null;
    signIn
        ? signInLoadingState?.setLoadingStatus(ScreenState.LOADING, this)
        : signUpLoadingState?.setLoadingStatus(ScreenState.LOADING, this);

    UserCredential? userCredential =
        await auth.signInWithFacebook().catchError((e) async {
      await onError(e, signIn ? signInLoadingState! : signUpLoadingState!);
      return null;
    });
    if (userCredential != null) {
      String? token = await userCredential.user?.getIdToken(true);
      await authWithOurServer(
          userCredential.additionalUserInfo!.profile!["name"], token!, signIn);
    }
    await isUserLoggedIn();
    if (apiToken != null) {
      if (kDebugMode) {
        print("apiToken: ${apiToken!}");
      }
    }
    return apiToken;
  }

  Future<String?> authWithTwitter(bool signIn) async {
    signIn
        ? signInLoadingState?.setError(null)
        : signUpLoadingState?.setError(null);
    apiToken = null;
    signIn
        ? signInLoadingState?.setLoadingStatus(ScreenState.LOADING, this)
        : signUpLoadingState?.setLoadingStatus(ScreenState.LOADING, this);
    UserCredential? userCredential =
        await signInWithTwitter().catchError((e) async {
      await onError(e, signIn ? signInLoadingState! : signUpLoadingState!);
      return null;
    });
    if (userCredential != null) {
      String? token = await userCredential.user?.getIdToken(true);
      await authWithOurServer(
          userCredential.additionalUserInfo?.profile!["name"], token!, signIn);
    }
    await isUserLoggedIn();
    if (apiToken != null)
      {if (kDebugMode) {
        print("apiToken: ${apiToken!}");
      }}
    return apiToken;
  }

  /// Generates a cryptographically secure random nonce, to be included in a
  /// credential request.
  String generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)])
        .join();
  }

  /// Returns the sha256 hash of [input] in hex notation.
  String sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<UserCredential?> signInWithApple() async {
    // To prevent replay attacks with the credential returned from Apple, we
    // include a nonce in the credential request. When signing in with
    // Firebase, the nonce in the id token returned by Apple, is expected to
    // match the sha256 hash of `rawNonce`.
    final rawNonce = generateNonce();
    final nonce = sha256ofString(rawNonce);

    // Request credential for the currently signed in Apple account.
    final appleCredential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
      nonce: nonce,
    );

    // Create an `OAuthCredential` from the credential returned by Apple.
    final oauthCredential = OAuthProvider("apple.com").credential(
      idToken: appleCredential.identityToken,
      rawNonce: rawNonce,
    );

    // Sign in the user with Firebase. If the nonce we generated earlier does
    // not match the nonce in `appleCredential.identityToken`, sign in will fail.
    return await FirebaseAuth.instance.signInWithCredential(oauthCredential);
  }

  Future<String?> authWithApple(bool signIn) async {
    signIn
        ? signInLoadingState?.setError(null)
        : signUpLoadingState?.setError(null);
    apiToken = null;
    signIn
        ? signInLoadingState?.setLoadingStatus(ScreenState.LOADING, this)
        : signUpLoadingState?.setLoadingStatus(ScreenState.LOADING, this);
    UserCredential? userCredential =
        await signInWithApple().catchError((e) async {
      await onError(e, signIn ? signInLoadingState! : signUpLoadingState!);
      return null;
    });
    if(userCredential != null) {
      String? token = await userCredential.user?.getIdToken(true);
      String name = "";
      if (userCredential.additionalUserInfo?.profile!["name"] != null) {
        name = userCredential.additionalUserInfo?.profile!["name"];
      } else {
        String email = userCredential.additionalUserInfo?.profile!["email"];
        final startIndex = email.indexOf('@');
        name = email.substring(0, startIndex);
      }
      await authWithOurServer(name, token!, signIn);
      await isUserLoggedIn();
      if (apiToken != null) {
        if (kDebugMode) {
          print("apiToken: ${apiToken!}");
        }
      }
      return apiToken;
    }
    else {
      return null;
    }

  }

  Future<String?> authWithGoogle(bool signIn) async {
    signIn
        ? signInLoadingState?.setError(null)
        : signUpLoadingState?.setError(null);
    apiToken = null;
    signIn
        ? signInLoadingState?.setLoadingStatus(ScreenState.LOADING, this)
        : signUpLoadingState?.setLoadingStatus(ScreenState.LOADING, this);
    UserCredential? userCredential =
        await auth.signInWithGoogle().catchError((e) async {
      await onError(e, signIn ? signInLoadingState! : signUpLoadingState!);
      return null;
    });
    if (userCredential != null) {
      String? token = await userCredential.user?.getIdToken(true);
      await authWithOurServer(
          userCredential.additionalUserInfo?.profile!["name"], token!, signIn);
    }
    await isUserLoggedIn();
    if (apiToken != null) {if (kDebugMode) {
      print("apiToken: ${apiToken!}");
      print("api new:${apiToken!}");
    }}
    return apiToken;
  }

  ////////////////////////////////////students to be picked up//////////////////
  List<DbUser> studentsToBePickedUp = [];
  LoadingState studentsToBePickedUpLoadingState = LoadingState();
  void getStudentsToBePickedUpEndpoint(int tripID) {
    if (apiToken == null) return;
    callEndpoint(_apiService.getStudentsToBePickedUp(apiToken!, tripID),
        studentsToBePickedUpLoadingState, this,
        (resp) {
      studentsToBePickedUp = resp.items;
      studentsToBePickedUpLoadingState.setError(null);
    });
  }

  /////////////////////////////////////schools/////////////////////////////////
  List<DbUser> schools = [];
  LoadingState schoolsLoadingState = LoadingState();

  void getSchoolsEndpoint() {
    if (apiToken == null) return;
    callEndpoint(_apiService.getAllSchools(apiToken!), schoolsLoadingState, this,
        (resp) {
      schools = resp.items;
      schoolsLoadingState.setError(null);
    });
  }

  //requestDeleteAccount
  LoadingState requestDeleteAccountLoadingState = LoadingState();
  void requestDeleteAccountEndpoint() { // Requests to delete the account
    if (apiToken == null) return;
    callEndpoint(_apiService.requestDeleteAccount(apiToken!),
        requestDeleteAccountLoadingState, this, (_) {
          requestDeleteAccountLoadingState.setError(null);
          Fluttertoast.showToast(
              msg: 'Request sent successfully.',
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.BOTTOM,
              backgroundColor: AppTheme.normalGrey,
              textColor: Colors.white);
          signOut();
        });
  }

  ///////////////////////Notifications//////////////////////////////////
  MyNotification myNotifications = MyNotification();

  List<MyNotification> notificationsList = [];

  LoadingState notificationsLoadingState = LoadingState();
  int unseenNotificationsCount = 0;
  void getNotificationsEndpoint() { // Gets unread notifications
    if (apiToken == null) return;

    callEndpoint(_apiService.getNotifications(apiToken!),
        notificationsLoadingState, this, (resp) {
          notificationsList = resp.items;
          //update unseenNotificationsCount
          unseenNotificationsCount = 0;
          for (int i = 0; i < notificationsList.length; i++) {
            if (notificationsList[i].seen == 0) {
              unseenNotificationsCount++;
            }
          }
          notificationsLoadingState.setError(null);
          notifyListeners();
        });
  }

  void addNewUnseenNotification(PushNotification notification) { //Add unseen notifications
    MyNotification n = MyNotification(
        message: notification.body,
        createdAt: DateFormat("yyyy-MM-dd hh:mm aa").format(DateTime.now()),
        seen: 0,
        id: notification.id != null ? int.parse(notification.id!) : null);
    List<MyNotification> tmp = [];
    tmp.addAll(notificationsList);
    notificationsList.clear();
    unseenNotificationsCount++;
    notifyListeners();
    //wait for 1 second
    Future.delayed(const Duration(milliseconds: 100), () {
      //add new notification
      notificationsList.add(n);
      notificationsList.addAll(tmp);
      notifyListeners();
    });
  }

  LoadingState markAllAsSeenNotificationsLoadingState = LoadingState();

  void markAllNotificationsAsReadEndpoint() { //Mark all notifications as read
    if (apiToken == null) return;

    callEndpoint(_apiService.markAllNotificationAsSeen(apiToken!),
        markAllAsSeenNotificationsLoadingState, this, (_) {
          markAllAsSeenNotificationsLoadingState.setError(null);
          for (int i = 0; i < notificationsList.length; i++) {
            notificationsList[i].seen = 1;
          }
          unseenNotificationsCount = 0;
          notifyListeners();
        });
  }

  LoadingState markNotificationSeenLoadingState = LoadingState();
  void markNotificationEndpoint(int notificationIdx, int id) {
    // Mark notification as read
    if (apiToken == null) return;
    callEndpoint(_apiService.markNotificationAsSeen(apiToken!, id),
        markNotificationSeenLoadingState,
        this, (_) {
          markNotificationSeenLoadingState.setError(null);
          notificationsList[notificationIdx].seen = 1;
          unseenNotificationsCount--;
          notifyListeners();
        });
  }

  //deleteAllNotificationsEndpoint
  LoadingState deleteAllNotificationsLoadingState = LoadingState();
  void deleteAllNotificationsEndpoint() { // Deletes all notifications
    if (apiToken == null) return;

    callEndpoint(_apiService.deleteAllNotifications(apiToken!),
        deleteAllNotificationsLoadingState, this, (_) {
          deleteAllNotificationsLoadingState.setError(null);
          notificationsList.clear();
          unseenNotificationsCount = 0;
          notifyListeners();
        });
  }

  /////////////////////////////////////////////Devices///////////////////////////

  Map<String, dynamic> deviceData = <String, dynamic>{};

  List<Device> devices = [];
  LoadingState devicesLoadingState = LoadingState();

  List<LoadingState> deviceDeletingStates = [];

  void getDevicesEndpoint() {
    if (apiToken == null) return;
    callEndpoint(_apiService.getAllDevices(apiToken!), devicesLoadingState, this,
        (resp) {
      devices = resp.items;
      deviceDeletingStates = List.filled(devices.length, LoadingState());
      for (int i = 0; i < devices.length; i++) {
        if (devices[i].name == deviceData["model"]) {
          Device tmp = devices[0];
          devices[0] = devices[i];
          devices[i] = tmp;
          break;
        }
      }
      devicesLoadingState.setError(null);
    });
  }

  void deleteDeviceEndpoint(int idx, String id, String deviceName) {
    if (apiToken == null) return;
    deviceDeletingStates.length = devices.length;
    for (int i = 0; i < deviceDeletingStates.length; i++) {
      deviceDeletingStates[i] = LoadingState();
    }

    callEndpoint(_apiService.deleteDevices(apiToken!, id, deviceName),
        deviceDeletingStates[idx], this, (_) {
      deviceDeletingStates[idx].setError(null);
      devices.removeAt(idx);
      notifyListeners();
    });
  }

  ////////////////////////Route Details////////////////////////////////////////
  LoadingState routeDetailsLoadingState = LoadingState();
  RouteDetails? routeDetails;
  LatLng? busLocation;
  void getRouteDetailsEndpoint(int? routeId, {Trip? trip}) {
    if (apiToken == null) return;
    if (settings?.simpleMode == true && trip != null) {
      routeDetailsLoadingState.setLoadingStatus(ScreenState.LOADING, this);
      double? startLat, startLng;
      getCurrentLocation().then((value) {
        startLat = value.latitude;
        startLng = value.longitude;
        busLocation = LatLng(startLat!, startLng!);

        if (startLat == null || startLng == null) {
          routeDetailsLoadingState.setError(1);
          routeDetailsLoadingState.setLoadingStatus(ScreenState.FINISH, this);
          return;
        }
        double endLat = double.parse(
            trip.plannedTripDetail?.last.stop!.lat ?? 0);
        double endLng = double.parse(
            trip.plannedTripDetail?.last.stop!.lng ?? 0);
        PointLatLng start = PointLatLng(startLat!, startLng!);
        PointLatLng end = PointLatLng(endLat, endLng);
        List<PolylineWayPoint> wayPoints = [];
        for (int i = 0; i < trip.plannedTripDetail!.length - 1; i++) {
          Stop stop = trip.plannedTripDetail![i].stop!;
          wayPoints.add(PolylineWayPoint(location: "${stop.lat},${stop.lng}"));
        }
        //getRouteBetweenCoordinates
        PolylinePoints polylinePoints = PolylinePoints();
        polylinePoints.getRouteBetweenCoordinates(
            Config.googleApikey,
            start,
            end,
            travelMode: TravelMode.driving,
            optimizeWaypoints: (trip.autoOrder == null || trip.autoOrder == false)? false : true,
            wayPoints: wayPoints)
            .then((PolylineResult value) {
          callEndpoint(_apiService.getRouteDetails(apiToken!, routeId),
              routeDetailsLoadingState, this,
                  (resp) {
                routeDetails = resp;
                routeDetails?.routePoints =
                    value.points.map((e) => LatLng(e.latitude, e.longitude)).toList();
                routeDetailsLoadingState.setError(null);
              });
        }).catchError((e) {
          routeDetailsLoadingState.setError(1);
          routeDetailsLoadingState.setLoadingStatus(ScreenState.FINISH, this);
        });
      });
    }
    else {
      callEndpoint(_apiService.getRouteDetails(apiToken!, routeId),
          routeDetailsLoadingState, this,
              (resp) {
            routeDetails = resp;
            routeDetailsLoadingState.setError(null);
          });
    }
  }

  ////////////////////////////preferred payment method//////////////////////////
  LoadingState preferredPaymentMethodLoadingState = LoadingState();
  LoadingState updatePreferredPaymentMethodLoadingState = LoadingState();

  void updatePreferredPaymentMethodEndpoint(int? preferredMethod, String? accountNumber,
      String? routingNumber,
      String? accountHolderName, String? bankName, String? paypalEmail,
      String? instantTransferMobileNo, String? instantTransferMobileNetwork,
      BuildContext context) {
    if (apiToken == null) return;
    callEndpoint(_apiService.updatePreferredPaymentMethod(apiToken!, preferredMethod,
        accountNumber, routingNumber,
        accountHolderName, bankName,
        paypalEmail, instantTransferMobileNo,
        instantTransferMobileNetwork),
        updatePreferredPaymentMethodLoadingState, this, (resp) {
          currentUser = resp;
      updatePreferredPaymentMethodLoadingState.setError(null);
    }, context: context);
  }

  //get preferred payment method
  void getPreferredPaymentMethodEndpoint() {
    if (apiToken == null) return;
    callEndpoint(_apiService.getPreferredPaymentMethod(apiToken!),
        preferredPaymentMethodLoadingState, this,
        (resp) {
      currentUser = resp;
      preferredPaymentMethodLoadingState.setError(null);
    });
  }

  /////////////////////////////Trips/////////////////////////////////
  List<Trip> myTrips = [];
  LoadingState tripsLoadingState = LoadingState();
  LoadingState tripSearchLoadingState = LoadingState();

  bool nextStopChanged = false;
  Stop? previousReportedNextStop;
  //updateBusLocationEndpoint
  LoadingState updateBusLocationLoadingState = LoadingState();
  UpdateBusLocationResponse? updateBusLocationResponse;
  void updateBusLocationEndpoint(int? tripId, double? lat, double? lng, double? speed) {
    if (apiToken == null) return;
    callEndpoint(_apiService.updateBusLocation(apiToken!, tripId, lat, lng, speed), updateBusLocationLoadingState, this,
        (resp) {
      updateBusLocationResponse = resp;
      if(resp.nextStop == null) {
        nextStopChanged = false;
      }
      else {
        if (previousReportedNextStop != null &&
            previousReportedNextStop!.id != resp.nextStop.id) {
          nextStopChanged = true;
        }
        previousReportedNextStop = resp.nextStop;
      }
      updateBusLocationLoadingState.setError(null);
    });
  }

  //pickupPassengerEndpoint
  LoadingState pickupPassengerLoadingState = LoadingState();
  void pickupPassengerEndpoint(String? ticketNumber, int? tripId,
      double? lat, double? lng, double? speed) {
    if (apiToken == null) return;
    callEndpoint(_apiService.pickupPassenger(
        apiToken!,
        ticketNumber,
        tripId,
        lat,
        lng,
        speed), pickupPassengerLoadingState, this,
            (resp) {
          updateBusLocationResponse = resp;
          pickupPassengerLoadingState.setError(null);
        });
  }


  //dropOffPassengersEndpoint
  LoadingState dropOffPassengersLoadingState = LoadingState();
  void dropOffPassengersEndpoint(int? tripId,
      double? lat, double? lng, double? speed) {
    if (apiToken == null) return;
    callEndpoint(_apiService.dropOffPassengers(
        apiToken!,
        tripId,
        lat,
        lng,
        speed), dropOffPassengersLoadingState, this,
            (resp) {
          updateBusLocationResponse = resp;
          dropOffPassengersLoadingState.setError(null);
        });
  }

  void getDriverTripsEndpoint() {
    if (apiToken == null) return;
    callEndpoint(_apiService.getDriverTrips(apiToken!), tripsLoadingState, this,
        (resp) {
      myTrips = resp.items;
      tripsLoadingState.setError(null);
    });
  }

  //getTripDetailsEndpoint
  LoadingState plannedTripDetailsLoadingState = LoadingState();
  Trip? plannedTrip;
  void getPlannedTripDetailsEndpoint(int? tripId) {
    if (apiToken == null) return;
    callEndpoint(_apiService.getPlannedTripDetails(apiToken!, tripId),
        plannedTripDetailsLoadingState, this,
            (resp) {
          plannedTrip = resp;
          plannedTripDetailsLoadingState.setError(null);
        });
  }

  //getCurrentLocation
  Future<Position> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }

  //calculateDistance
  double calculateDistance(double lat1, double lng1, double lat2, double lng2) {
    double distanceInMeters = Geolocator.distanceBetween(lat1, lng1, lat2, lng2);
    return distanceInMeters;
  }

  //start a trip
  LoadingState startTripLoadingState = LoadingState();
  void startTrip(BuildContext context, Trip? trip, int mode, {StreamSubscription<Position>? positionStream}) {
    if (apiToken == null) return;
    startTripLoadingState.loadError = null;
    startTripLoadingState.setLoadingStatus(ScreenState.LOADING, this);
    //get current location+
    getCurrentLocation().then((value) {
      //check if the current location is close to the first stop
      if (trip != null) {
        if (Config.localTest) {
          //start the trip
          callEndpoint(_apiService.startEndTrip(apiToken!, trip.id, mode),
              startTripLoadingState, this,
                  (resp) async {
                if (mode == 1) {
                  //pop context
                  Navigator.pop(context);
                }
                if (mode == 0) {
                  if (positionStream != null) {
                    await positionStream.cancel();
                  }
                }
                //update the trip status
                for (int i = 0; i < myTrips.length; i++) {
                  if (myTrips[i].id == trip.id) {
                    if (mode == 1) {
                      myTrips[i].startedAt = DateTime.now();
                      break;
                    }
                    else {
                      myTrips[i].endedAt = DateTime.now();
                      break;
                    }
                  }
                }
                startTripLoadingState.setError(null);
              });
        }
        else {
          if (mode == 1) {
            String stopLat = trip.plannedTripDetail?[0].stop?.lat;
            String stopLng = trip.plannedTripDetail?[0].stop?.lng;
            double distance = calculateDistance(
                value.latitude, value.longitude,
                double.parse(stopLat), double.parse(stopLng));
            if (distance < 50 || settings?.simpleMode == true)
            {
              //check if the start date of the trip is today
              String tripStartTime = trip.plannedTripDetail?[0]
                  .plannedTimeStamp ??
                  "";
              DateTime tripStartDate = DateTime.parse(trip.plannedDate!);
              DateTime tripStartDateTime = DateTime(
                  tripStartDate.year, tripStartDate.month, tripStartDate.day,
                  int.parse(tripStartTime.split(":")[0]),
                  int.parse(tripStartTime.split(":")[1]));
              DateTime now = DateTime.now();
              //get time difference
              Duration diff = tripStartDateTime.difference(now);

              if (diff.inDays == 0) {
                //start the trip
                callEndpoint(_apiService.startEndTrip(apiToken!, trip.id, mode),
                    startTripLoadingState, this,
                        (resp) async {
                      startTripLoadingState.setError(null);
                      if (mode == 1) {
                        //pop context
                        Navigator.pop(context);
                      }
                      if (mode == 0) {
                        if (positionStream != null) {
                          await positionStream.cancel();
                        }
                      }
                      //update the trip status
                      for (int i = 0; i < myTrips.length; i++) {
                        if (myTrips[i].id == trip.id) {
                          if (mode == 1) {
                            myTrips[i].startedAt = DateTime.now();
                            break;
                          }
                          else {
                            myTrips[i].endedAt = DateTime.now();
                            break;
                          }
                        }
                      }
                    });
              }
              else {
                //set the loading state to error
                startTripLoadingState.failState = FailState.GENERAL;
                startTripLoadingState.error =
                translation(context)?.tripNotTodayMessage;
                startTripLoadingState.setError(1);
                startTripLoadingState.setLoadingStatus(
                    ScreenState.FINISH, this);
              }
            }
            else {
              //set the loading state to error
              startTripLoadingState.failState = FailState.GENERAL;
              startTripLoadingState.error =
              translation(context)?.currentLocationFarMessage;
              startTripLoadingState.setError(1);
              startTripLoadingState.setLoadingStatus(ScreenState.FINISH, this);
            }
          }
          else {
            //end the trip
            callEndpoint(_apiService.startEndTrip(apiToken!, trip.id, mode),
                startTripLoadingState, this,
                    (resp) async {
                  startTripLoadingState.setError(null);
                  if(positionStream != null) {
                    await positionStream.cancel();
                  }
                  //update the trip status
                  for (int i = 0; i < myTrips.length; i++) {
                    if (myTrips[i].id == trip.id) {
                      if (mode == 1) {
                        myTrips[i].startedAt = DateTime.now();
                        break;
                      }
                      else {
                        myTrips[i].endedAt = DateTime.now();
                        break;
                      }
                    }
                  }
                  startTripLoadingState.setError(null);
                });
          }
        }
      }
    }).catchError((error) {
      //set the loading state to error
      if (kDebugMode) {
        print(error);
      }
      startTripLoadingState.failState = FailState.GENERAL;
      startTripLoadingState.error = error.toString();
      startTripLoadingState.setError(1);
      startTripLoadingState.setLoadingStatus(ScreenState.FINISH, this);
    });
  }

  ///////////////////////Driver data//////////////////////////////////

  DriverData driverData = DriverData();
  LoadingState driverDataLoadingState = LoadingState();

  //save driver data
  LoadingState saveDriverDataLoadingState = LoadingState();
  void saveDriverDataEndpoint(int submit) {
    if (apiToken == null) return;
    saveDriverDataLoadingState = LoadingState();
    callEndpoint(_apiService.saveDriverData(apiToken!, driverData, currentUser?.schoolID, submit),
        saveDriverDataLoadingState, this, (resp) async {
      saveDriverDataLoadingState.setError(null);
      await getDriverDataFromServer();
    });
  }

  LoadingState getSchoolByCodeLoadingState = LoadingState();
  void getSchoolByCodeEndpoint(String? code) { //Get school by code
    if (apiToken == null) return;
    callEndpoint(_apiService.getSchoolByCode(apiToken!, code), getSchoolByCodeLoadingState, this, (resp) {
      getSchoolByCodeLoadingState.setError(null);
      currentUser?.school = resp;
      currentUser?.schoolID = resp.id;
      notifyListeners();
    });
  }

  /////////////////////////////FAQ, Terms and conditions///////////////////////////////
  String? terms;
  LoadingState termsLoadingState = LoadingState();

  void getTermsEndpoint() { // Terms URL

    callEndpoint(_apiService.getTerms(), termsLoadingState, this,
            (resp) {
          terms = resp;
          termsLoadingState.setError(null);
        });
  }

  /////////////////////// Settings //////////////////////////////////
  Setting? settings;

  LoadingState settingsLoadingState = LoadingState();

  void getSettingsEndpoint() {
    if (apiToken == null) return;

    callEndpoint(_apiService.getSettings(apiToken!), settingsLoadingState, this,
        (resp) {
      settings = resp.item;
      settingsLoadingState.setError(null);
    });
  }

  void clearAllUserData() {
    notificationsList.clear();
    unseenNotificationsCount = 0;
  }

  /////////////////////////////UserPublicProfile///////////////////////////////

  LoadingState updateProfileLoadingState = LoadingState();

  void updateProfileEndpoint(BuildContext context,
      String? telNumber, String? address,
      ) { //Update profile
    if (apiToken == null) return;

    callEndpoint(
        _apiService.updateProfile(
            apiToken!,
            address,
            telNumber),
        updateProfileLoadingState,
        this, (resp) {
      currentUser!.address = resp.address;
      currentUser!.telNumber = resp.telNumber;
      updateProfileLoadingState.setError(null);
    }, context: context);
  }
  ///////////////////////////////////////////////////////////////

  int nameTextFieldMaxLength = 30;

  void saveEditDriverDocument(DriverDocument driverDocument, int? documentIndex) {
    if (documentIndex == null) {
      driverData.documents ??= [];
      driverData.documents?.add(driverDocument);
    } else {
      driverData.documents?[documentIndex] = driverDocument;
    }
    notifyListeners();
  }

  // delete driver document
  void deleteDriverDocument(int? documentIndex) {
    if (documentIndex == null) return;
    driverData.documents?.removeAt(documentIndex);
    notifyListeners();
  }

  ////////////////////////////////////////////////////////////////////////////
}
