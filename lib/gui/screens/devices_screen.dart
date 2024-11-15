
import 'package:school_trip_track_driver/gui/widgets/direction_positioned.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:school_trip_track_driver/gui/widgets/form_error.dart';
import 'package:school_trip_track_driver/gui/widgets/app_bar.dart';
import 'package:school_trip_track_driver/model/device.dart';
import 'package:school_trip_track_driver/services/service_locator.dart';
import 'package:school_trip_track_driver/utils/tools.dart';
import 'package:school_trip_track_driver/utils/app_theme.dart';
import 'package:school_trip_track_driver/view_models/this_application_view_model.dart';
import 'package:provider/provider.dart';

import '../../connection/utils.dart';
import '../../widgets.dart';
import '../languages/language_constants.dart';

class DevicesScreen extends StatefulWidget {
  const DevicesScreen({Key? key}) : super(key: key);

  @override
  DevicesScreenState createState() => DevicesScreenState();
}

class DevicesScreenState extends State<DevicesScreen> {
  ThisApplicationViewModel thisAppModel =
      serviceLocator<ThisApplicationViewModel>();

  final List<String> errors = [];

  void removeAllErrors() {
    setState(() {
      errors.clear();
    });
  }

  @override
  void initState() {
    super.initState();
  }

  Widget displayAllDevices() {
    return Scaffold(
      appBar: buildAppBar(context, translation(context)?.devices ??  'Devices'),
      body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Consumer<ThisApplicationViewModel>(
            builder: (context, thisApplicationViewModel, child) {
              return displayDevices(context)!;
            },
          )),
    );
  }

  Widget? displayDevices(BuildContext context) {
    if (thisAppModel.devicesLoadingState.inLoading()) {
      // loading. display animation
      return loadingDevices();
    } else if (thisAppModel.devicesLoadingState.loadingFinished()) {
      //network call finished.
      if (thisAppModel.devicesLoadingState.loadError != null) {
        if (kDebugMode) {
          print("page loading error. Display the error");
        }
        // page loading error. Display the error
        return failedScreen(
            context, thisAppModel.devicesLoadingState.failState!);
      } else {
        return Consumer<ThisApplicationViewModel>(
          builder: (context, thisApplicationViewModel, child) {
            List<Device> allDevices;
            allDevices = thisAppModel.devices;
            if (allDevices.isEmpty) {
              return emptyScreen();
            } else {
              for (int i = 0;
                  i < thisApplicationViewModel.deviceDeletingStates.length;
                  i++) {
                if (thisApplicationViewModel
                        .deviceDeletingStates[i].loadError ==
                    1) {
                  errors.add(
                      thisApplicationViewModel.deviceDeletingStates[i].error!);
                }
              }

              List<Widget> a = [];
              a.add(FormError(errors: errors));
              a.addAll(devicesListScreen(allDevices, thisApplicationViewModel));
              return ListView(children: a);
            }
          },
        );
      }
    }
    return null;
  }

  Widget failedScreen(BuildContext context, FailState failState) {
    return Stack(children: [
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
      Container(
        constraints: BoxConstraints(
          minHeight: Tools.getScreenHeight(context) - 150,
        ),
        child: Center(
          child: onFailRequest(context, failState),
        ),
      )
    ]);
  }

  Widget emptyScreen() {
    return Stack(children: [
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
            Image.asset(
              "assets/images/img_no_connected_dev.png",
              height:
                  MediaQuery.of(context).orientation == Orientation.landscape
                      ? 50
                      : 150,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 30),
              child: Column(
                children: [
                  Text(
                    translation(context)?.anyDevicesYet ??  "Oops... There aren't any devices yet.",
                    style: AppTheme.caption,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    ]);
  }

  List<Widget> devicesListScreen(List<Device> allDevices,
      ThisApplicationViewModel thisApplicationViewModel) {
    return List.generate(allDevices.length, (i) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            elevation: 1,
            child: ListTile(
                title: Text(
                  allDevices[i].name,
                  style: AppTheme.bold20Black,
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        (translation(context)?.lastActive ?? "Last active  ") + allDevices[i].lastUsedAt,
                        style: AppTheme.coloredSubtitle,
                      ),
                      allDevices[i].name == thisAppModel.deviceData["model"]
                          ? Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                translation(context)?.currentDevice ?? 'Current device',
                                style: const TextStyle(color: Colors.green),
                              ),
                            )
                          : Container(),
                    ],
                  ),
                ),
                leading: allDevices[i].name.toLowerCase().contains('iphone') ||
                        allDevices[i].name.toLowerCase().contains('ipad') ||
                        allDevices[i].name.toLowerCase().contains('ios')
                    ? const Icon(
                        Icons.phone_iphone,
                        size: 50,
                        color: AppTheme.normalGrey,
                      )
                    : const Icon(
                        Icons.android,
                        size: 50,
                        color: AppTheme.normalGrey,
                      ),
                trailing: allDevices[i].name == thisAppModel.deviceData["model"]
                    ? Container(
                        width: 1,
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          thisApplicationViewModel.deviceDeletingStates[i]
                                  .inLoading()
                              ? const CircularProgressIndicator(
                                strokeWidth: 2,
                                backgroundColor: Colors.transparent,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.red),
                              )
                              : IconButton(
                                  icon: const Icon(
                                    Icons.delete_outlined,
                                    color: AppTheme.colorError,
                                  ),
                                  onPressed: () {
                                    showAlertDialog(
                                        context,
                                        thisApplicationViewModel,
                                        i,
                                        allDevices[i].id.toString(),
                                        allDevices[i].name);
                                  },
                                )
                        ],
                      ))),
      );
    });
  }

  showAlertDialog(
      BuildContext context,
      ThisApplicationViewModel thisApplicationViewModel,
      int i,
      String id,
      String name) {
    // set up the buttons
    Widget cancelButton = TextButton(
      child: Text(translation(context)?.cancel ?? "Cancel"),
      onPressed: () {
        Navigator.of(context, rootNavigator: true).pop();
      },
    );
    Widget continueButton = TextButton(
      child: Text(translation(context)?.continueText ?? "Continue"),
      onPressed: () {
        Navigator.of(context, rootNavigator: true).pop();

        removeAllErrors();
        thisApplicationViewModel.deleteDeviceEndpoint(i, id, name);
      },
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(translation(context)?.warning ?? "Warning"),
      content: Text(translation(context)?.areYouSureDeleteDevice ?? "Are you sure you want to delete this device?"),
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

  @override
  Widget build(context) {
    return displayAllDevices();
  }

  Widget loadingDevices() {
    return const Center(
      child: SizedBox(
        width: 30,
        height: 30,
        child: CircularProgressIndicator(
          backgroundColor: Colors.transparent,
          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
        ),
      ),
    );
  }
}
