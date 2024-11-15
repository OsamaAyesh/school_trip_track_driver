
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:school_trip_track_driver/gui/widgets/direction_positioned.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:school_trip_track_driver/gui/widgets/form_error.dart';
import 'package:school_trip_track_driver/gui/widgets/app_bar.dart';
import 'package:school_trip_track_driver/model/device.dart';
import 'package:school_trip_track_driver/model/user.dart';
import 'package:school_trip_track_driver/services/service_locator.dart';
import 'package:school_trip_track_driver/utils/tools.dart';
import 'package:school_trip_track_driver/utils/app_theme.dart';
import 'package:school_trip_track_driver/view_models/this_application_view_model.dart';
import 'package:provider/provider.dart';

import '../../connection/utils.dart';
import '../../utils/config.dart';
import '../../widgets.dart';
import '../languages/language_constants.dart';

class StudentsScreen extends StatefulWidget {
  const StudentsScreen({this.tripID, Key? key}) : super(key: key);

  final int? tripID;
  @override
  StudentsScreenState createState() => StudentsScreenState();
}

class StudentsScreenState extends State<StudentsScreen> {
  ThisApplicationViewModel thisAppModel =
      serviceLocator<ThisApplicationViewModel>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      thisAppModel.getStudentsToBePickedUpEndpoint(widget.tripID!);
    });
  }

  Widget displayAllStudents() {
    return Scaffold(
      appBar: buildAppBar(context, translation(context)?.students ??  'Students'),
      body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Consumer<ThisApplicationViewModel>(
            builder: (context, thisApplicationViewModel, child) {
              return displayStudents(context)!;
            },
          )),
    );
  }

  Widget? displayStudents(BuildContext context) {
    if (thisAppModel.studentsToBePickedUpLoadingState.inLoading()) {
      // loading. display animation
      return loadingStudents();
    } else if (thisAppModel.studentsToBePickedUpLoadingState.loadingFinished()) {
      //network call finished.
      if (thisAppModel.studentsToBePickedUpLoadingState.loadError != null) {
        if (kDebugMode) {
          print("page loading error. Display the error");
        }
        // page loading error. Display the error
        return failedScreen(
            context, thisAppModel.studentsToBePickedUpLoadingState.failState!);
      } else {
        return Consumer<ThisApplicationViewModel>(
          builder: (context, thisApplicationViewModel, child) {
            List<DbUser> allStudents;
            allStudents = thisAppModel.studentsToBePickedUp;
            if (allStudents.isEmpty) {
              return emptyScreen();
            } else {
              List<Widget> a = [];
              a.addAll(studentsListScreen(allStudents, thisApplicationViewModel));
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
                    translation(context)?.anyStudentsYet ??  "Oops... There aren't any students yet.",
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

  List<Widget> studentsListScreen(List<DbUser> allStudents,
      ThisApplicationViewModel thisApplicationViewModel) {
    return List.generate(allStudents.length, (i) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            elevation: 1,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage("${Config.serverUrl}${allStudents[i].avatar}"),
                  backgroundColor: AppTheme.veryLightGrey,
                  radius: 80.w,
                ),
                SizedBox(height: 15.h),
                Text(
                  allStudents[i].name!,
                  style: AppTheme.textSecondaryLarge,
                ),
                SizedBox(height: 15.h),
                Text(
                  allStudents[i].notes ?? "",
                  style: AppTheme.textPrimarySmall,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 15.h),
              ],
            ),
        ),
      );
    });
  }

  @override
  Widget build(context) {
    return displayAllStudents();
  }

  Widget loadingStudents() {
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
