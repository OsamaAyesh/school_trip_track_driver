
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:school_trip_track_driver/gui/widgets/form_error.dart';
import 'package:school_trip_track_driver/model/my_notification.dart';
import 'package:school_trip_track_driver/services/service_locator.dart';
import 'package:school_trip_track_driver/utils/app_theme.dart';
import 'package:school_trip_track_driver/utils/tools.dart';
import 'package:school_trip_track_driver/view_models/this_application_view_model.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../connection/utils.dart';
import '../../model/loading_state.dart';
import '../../model/push_notification.dart';
import '../../view_models/this_application_view_model.dart';
import '../../widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../languages/language_constants.dart';
import 'package:school_trip_track_driver/gui/widgets/direction_positioned.dart';

import '../widgets/animated_app_bar.dart';
import '../widgets/app_bar.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  NotificationsScreenState createState() => NotificationsScreenState();
}

class NotificationsScreenState extends State<NotificationsScreen> {
  bool isLoading = false;
  bool markAllAsRead = false;
  ThisApplicationViewModel thisAppModel = serviceLocator<ThisApplicationViewModel>();

  final notificationsScaffoldKey = GlobalKey<FormState>();

  Future<void> _refreshData() {
    return Future(
            () {
              thisAppModel.markNotificationSeenLoadingState.loadError = null;
              thisAppModel.markAllAsSeenNotificationsLoadingState.loadError = null;
              thisAppModel.deleteAllNotificationsLoadingState.loadError = null;
          thisAppModel.getNotificationsEndpoint();
        }
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      thisAppModel.markNotificationSeenLoadingState.loadError = null;
      thisAppModel.markAllAsSeenNotificationsLoadingState.loadError = null;
      thisAppModel.deleteAllNotificationsLoadingState.loadError = null;
      thisAppModel.getNotificationsEndpoint();
    });
  }


  Widget displayAllNotifications(ThisApplicationViewModel thisApplicationViewModel) {
    return Scaffold(
        appBar: AnimatedAppBar(translation(context)?.notifications ?? "Notifications", false, right: markAllButtonRead()),
        key: notificationsScaffoldKey,
        body: RefreshIndicator(
          onRefresh: _refreshData,
          child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: displayNotifications(thisApplicationViewModel)
          ),
        ),
      // floatingActionButton to delete all notifications
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showAlertDialog(context, thisApplicationViewModel, false);
        },
        backgroundColor: AppTheme.secondary,
        child: thisApplicationViewModel.deleteAllNotificationsLoadingState.inLoading() ?
        const CircularProgressIndicator(
          strokeWidth: 2,
          backgroundColor: Colors.transparent,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ) :
        const Icon(Icons.delete_forever, color: Colors.white,),
      ),
    );
  }

  Widget? displayNotifications(ThisApplicationViewModel thisApplicationViewModel) {
    if (thisApplicationViewModel.notificationsLoadingState.inLoading()) {
      // loading. display animation
      return loadingNotifications();
    }
    else if (thisApplicationViewModel.notificationsLoadingState.loadingFinished()) {
      if (kDebugMode) {
        print("network call finished");
      }
      //network call finished.
      if (thisApplicationViewModel.notificationsLoadingState.loadError != null) {
        if (kDebugMode) {
          print("page loading error. Display the error");
        }
        // page loading error. Display the error
        return failedScreen(context,
            thisApplicationViewModel.notificationsLoadingState.failState!);
      }
      else {
        List<MyNotification> allNotifications;
        allNotifications = thisApplicationViewModel.notificationsList;
        if (allNotifications.isEmpty) {
          return
            SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: Align(
                alignment: Alignment.center,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      "assets/images/img_no_notifications.png", height: MediaQuery
                        .of(context)
                        .orientation == Orientation.landscape ? 50 : 300,),
                    Padding(
                      padding: EdgeInsets.only(top: 30.h),
                      child: Column(
                        children: [
                          Text(translation(context)?.anyNotificationsYet ??
                              "Oops... There aren't any notifications yet.",
                            style: AppTheme.textSecondaryMedium,
                            textAlign: TextAlign.center,),
                          SizedBox(height: 30.h),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
        }
        else {
          List<Widget> a = [];
          a.addAll(notificationsListScreen(allNotifications, thisApplicationViewModel));
          return Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              errorSection(thisApplicationViewModel),
              Expanded(
                child: ListView(
                    children: a
                ),
              ),
            ],
          );
        }
      }
    }
    return null;
  }

  Widget markAllButtonRead() {
    return thisAppModel.unseenNotificationsCount > 0 ? markAllButton(
        thisAppModel.unseenNotificationsCount == 0
            ? translation(context)?.markAllAsRead ??
            "Mark all as read"
            :
        (translation(context)?.markAllAsRead ??
            "Mark all as read") + " (" +
            (thisAppModel.unseenNotificationsCount).toString() + ")",
        context, thisAppModel) : Container();
  }

  Widget markAllButton(String text, BuildContext context, ThisApplicationViewModel thisApplicationViewModel) {
    return InkWell(
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: AppTheme.primary,
          borderRadius: BorderRadius.circular(50),
        ),
        child: Center(
          child:
            markAllReadButton(text, thisApplicationViewModel)
        ),
      ),
      onTap: ()
      {
        showAlertDialog(context, thisApplicationViewModel, true);
      },
    );
  }

  Widget failedScreen(BuildContext context, FailState failState) {
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
            Container(
              constraints: BoxConstraints(
                minHeight: Tools.getScreenHeight(context) - 150,
              ),
              child: Center(
                child: onFailRequest(context, failState),
              ),
            )
          ]
      );
  }

  List<Widget> notificationsListScreen(List<MyNotification> allNotification, ThisApplicationViewModel thisApplicationViewModel) {
    return
      List.generate(allNotification
          .length, (i) {
        return InkWell(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              elevation: 5,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                          color: Colors.white,
                        ),
                        child: Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: DescriptionTextWidget(allNotification[i]),
                                  ),
                                ),
                              ],
                            ),
                            actionsSection(allNotification[i], i),
                          ],
                        )
                    ),
                  ),
                ],
              ),
            ),
          ),
          onTap: () {
            if (allNotification[i].seen == 0) {
              thisApplicationViewModel.markNotificationEndpoint(
                  i, allNotification[i].id!);
            }
            //show notification details
            //create PushNotification object
            PushNotification notification = PushNotification();
            notification.title = "";
            notification.body = allNotification[i].message;
            showNotificationDialog(context, notification);
          },
        );
      });
  }

  Widget actionsSection(MyNotification notification, int idx) {
    TextStyle style = AppTheme.textPrimarySmallLight;
    if(notification.seen == 0) {
      style = AppTheme.textPrimarySmall;
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(notification.createdAt!, style: style,),
        ),
        notification.seen == 0 ?
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(10),
          ),
        ): Container()
      ],
    );
  }
  
  Widget errorSection(ThisApplicationViewModel thisApplicationViewModel) {
    if (thisApplicationViewModel.markNotificationSeenLoadingState.loadError == 1) {
      return FormError(errors: [
        thisApplicationViewModel
            .markNotificationSeenLoadingState.error ?? ""
      ]);
    } else {
      return Container();
    }
  }

  void handleNotificationAction(String actionType) {
    LoadingState loadingState;
    switch (actionType) {
      case 'markNotificationSeen':
        loadingState = thisAppModel.markNotificationSeenLoadingState;
        break;
      case 'markAllAsSeen':
        loadingState = thisAppModel.markAllAsSeenNotificationsLoadingState;
        break;
      case 'deleteAll':
        loadingState = thisAppModel.deleteAllNotificationsLoadingState;
        break;
      default:
        return; // Optionally handle unknown action type
    }

    if (loadingState.loadingFinished() && loadingState.loadError != null && loadingState.error != null) {
      Fluttertoast.showToast(
          msg: loadingState.error ?? "",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: AppTheme.primary,
          textColor: Colors.white,
          fontSize: 16.0
      );
      loadingState.loadError = null;
      loadingState.error = null;
    }
  }


  @override
  Widget build(BuildContext context) {
    return Consumer<ThisApplicationViewModel>(
      builder: (context, thisApplicationViewModel, child) {

        handleNotificationAction('markNotificationSeen');
        handleNotificationAction('markAllAsSeen');
        handleNotificationAction('deleteAll');

        if (thisApplicationViewModel.isLoggedIn!) {
          return displayAllNotifications(thisApplicationViewModel);
        }
        else {
          return signInOut(context, null);
        }
      },
    );
  }

  Widget loadingNotifications() {
    return Center(
      child: SizedBox(
        width: 30.w,
        height: 30.h,
        child: const CircularProgressIndicator(
          backgroundColor: Colors.transparent,
          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
        ),
      ),
    );
  }

  Widget markAllReadButton(String text, ThisApplicationViewModel thisApplicationViewModel) {
    bool loading = false;
    if ((thisApplicationViewModel.notificationsList.isNotEmpty))
    {
      if (thisApplicationViewModel.markAllAsSeenNotificationsLoadingState.inLoading()) {
        loading = true;
      }
      return Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          loading ?
          const SizedBox(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ) :
          const Icon(Icons.playlist_add_check_rounded, size: 25, color: Colors.white,),
        ],
      );
    }
    else {
      return Container();
    }
  }

  showAlertDialog(BuildContext context,
      ThisApplicationViewModel thisApplicationViewModel,
      bool isMarkAllAsRead) {
    // set up the buttons
    Widget cancelButton = TextButton(
      child: Text(translation(context)?.cancel ?? "Cancel"),
      onPressed: () {
        Navigator.of(context, rootNavigator: true)
            .pop();
      },
    );
    Widget continueButton = TextButton(
      child: Text(translation(context)?.continueText ?? "Continue"),
      onPressed: () {
        Navigator.of(context, rootNavigator: true)
            .pop();
        //removeAllErrors();
        if (isMarkAllAsRead) {
          thisApplicationViewModel.markAllNotificationsAsReadEndpoint();
        }
        else {
          thisApplicationViewModel.deleteAllNotificationsEndpoint();
        }
      },
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: isMarkAllAsRead ? (Text(translation(context)?.markAllNotificationsAsSeen ?? "Mark all notifications as seen")) : (Text(translation(context)?.deleteAllNotifications ?? "Delete all notifications")),
      content: isMarkAllAsRead ? (Text(translation(context)?.markAllNotificationsAsSeen ?? "Mark all notifications as seen")): (Text(translation(context)?.deleteAllNotifications ?? "Delete all notifications")),
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


}

class DescriptionTextWidget extends StatefulWidget {
  final MyNotification notification;

  const DescriptionTextWidget(this.notification, {super.key});

  @override
  DescriptionTextWidgetState createState() => DescriptionTextWidgetState();
}

class DescriptionTextWidgetState extends State<DescriptionTextWidget> {
  String? firstHalf;
  String? secondHalf;

  bool flag = true;
  String text = "";

  @override
  void initState() {
    super.initState();
    text = widget.notification.message!;
    if (text.length > 50) {
      firstHalf = text.substring(0, 50);
      secondHalf = text.substring(50, text.length);
    } else {
      firstHalf = text;
      secondHalf = "";
    }
  }

  @override
  Widget build(BuildContext context) {
    TextStyle style = AppTheme.coloredSubtitle;
    if(widget.notification.seen == 0) {
      style = AppTheme.textSecondaryMedium;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 1.0, vertical: 10.0),
      child: secondHalf!.isEmpty
          ? Text(firstHalf!, style: style,)
          : Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(flag ? ("$firstHalf...") : (firstHalf! + secondHalf!),
            style: style,),
        ],
      ),
    );
  }
}