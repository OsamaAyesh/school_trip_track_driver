import 'package:school_trip_track_driver/gui/widgets/animated_back_button.dart';
import 'package:flutter/material.dart';
import 'package:school_trip_track_driver/utils/app_theme.dart';

AppBar buildAppBar(BuildContext context, String title, {Widget? left, Widget? right}) {
  return AppBar(
    centerTitle: true,
    toolbarHeight: 85,
    leadingWidth: 85,
    backgroundColor: AppTheme.backgroundColor,
    iconTheme: const IconThemeData(
      color: AppTheme.secondary,
    ),
    actions: [
      right ?? Container(),
    ],
    leading: const AnimatedBackButton(),
    elevation: 0,
    title:
    Text(
      title,
      style: AppTheme.title,
    ),
  );
}