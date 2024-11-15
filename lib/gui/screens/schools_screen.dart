
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

class SchoolsScreen extends StatefulWidget {
  const SchoolsScreen({this.schoolID, Key? key}) : super(key: key);

  final int? schoolID;
  @override
  SchoolsScreenState createState() => SchoolsScreenState();
}

class SchoolsScreenState extends State<SchoolsScreen> {
  ThisApplicationViewModel thisAppModel =
      serviceLocator<ThisApplicationViewModel>();
  String searchValue = "";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      thisAppModel.getSchoolsEndpoint();
    });
  }

  Widget displayAllSchools() {
    return Scaffold(
      appBar: buildAppBar(context, translation(context)?.schools ??  'Schools'),
      body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Consumer<ThisApplicationViewModel>(
            builder: (context, thisApplicationViewModel, child) {
              return displaySchools(context)!;
            },
          )),
    );
  }

  Widget? displaySchools(BuildContext context) {
    if (thisAppModel.schoolsLoadingState.inLoading()) {
      // loading. display animation
      return loadingSchools();
    } else if (thisAppModel.schoolsLoadingState.loadingFinished()) {
      //network call finished.
      if (thisAppModel.schoolsLoadingState.loadError != null) {
        if (kDebugMode) {
          print("page loading error. Display the error");
        }
        // page loading error. Display the error
        return failedScreen(
            context, thisAppModel.schoolsLoadingState.failState!);
      } else {
        return Consumer<ThisApplicationViewModel>(
          builder: (context, thisApplicationViewModel, child) {
            List<DbUser> allSchools;
            Widget content;
            if(searchValue.isNotEmpty) {
              allSchools = thisAppModel.schools.where((element) =>
                  element.name!.toLowerCase().contains(
                      searchValue.toLowerCase())).toList();
            } else {
              allSchools = thisAppModel.schools;
            }
            if (allSchools.isEmpty) {
              content=emptyScreen();
            } else {
              List<Widget> a = [];
              a.addAll(schoolsListScreen(allSchools, thisApplicationViewModel));
              content=ListView(children: a);
            }
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(100.0),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        searchValue = value;
                      });
                    },
                  ),
                ),
                Expanded(child: content),
              ],
            );
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
                    translation(context)?.anySchoolsYet ??  "Oops... There aren't any schools.",
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

  List<Widget> schoolsListScreen(List<DbUser> allSchools,
      ThisApplicationViewModel thisApplicationViewModel) {
    return List.generate(allSchools.length, (i) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            elevation: 1,
            child: ListTile(
              title: Text(
                allSchools[i].name!,
                style: AppTheme.bold20Black,
              ),
              subtitle: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      allSchools[i].email ?? "",
                      style: AppTheme.coloredSubtitle,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      allSchools[i].address ?? "",
                      style: AppTheme.coloredSubSubtitle,
                    ),
                  ],
                ),
              ),
              leading: CircleAvatar(
                backgroundColor: AppTheme.primary,
                child: //image with avatar url
                CircleAvatar(
                  backgroundImage: NetworkImage("${Config.serverUrl}${allSchools[i].avatar}"),
                  backgroundColor: AppTheme.veryLightGrey,
                )
              ),
              trailing: widget.schoolID == allSchools[i].id
                  ? const Icon(Icons.check, color: AppTheme.primary)
                  : null,
              onTap: () {
                Navigator.pop(context, allSchools[i]);
              }
            ),
        ),
      );
    });
  }

  @override
  Widget build(context) {
    return displayAllSchools();
  }

  Widget loadingSchools() {
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
