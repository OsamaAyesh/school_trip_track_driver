import 'package:school_trip_track_driver/utils/config.dart';
import 'package:flutter/material.dart';
import 'package:school_trip_track_driver/model/loading_state.dart';
import 'package:school_trip_track_driver/services/service_locator.dart';
import 'package:school_trip_track_driver/utils/app_theme.dart';
import 'package:school_trip_track_driver/utils/size_config.dart';
import 'package:school_trip_track_driver/utils/tools.dart';
import 'package:school_trip_track_driver/view_models/this_application_view_model.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'connection/utils.dart';
import 'gui/languages/language_constants.dart';
import 'gui/screens/sign_in_screen.dart';
import 'gui/widgets/custom_surfix_icon.dart';
import 'package:school_trip_track_driver/gui/widgets/direction_positioned.dart';

import 'model/push_notification.dart';

Widget showFailedView(BuildContext context, String? text, String? img, {bool showLogOut = false}) {

  ThisApplicationViewModel thisAppModel = serviceLocator<ThisApplicationViewModel>();

  return Center(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Image.asset(
          'assets/images/$img.png', width: 160.0, height: 160.0,
        ),
        SizedBox(height: 20.h,),
        Text(text!, style: AppTheme.bold16DarkBlue, textAlign: TextAlign.center),
        showLogOut?Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton(
              onPressed: () {
                showAlertLogoutDialog(context, thisAppModel);
              }, child: Text(translation(context)?.signOut ?? "Sign out")),
        ):Container(),
      ],
    ),
  );
}

onFailRequest(BuildContext context, FailState? reason, {LoadingState? loadSate}) {
  if(reason == null)
    {
      return showFailedView(context, Config.noItem, "img_no_item");
    }
  if (reason == FailState.GENERAL) {
    if(loadSate != null) {
      return showFailedView(context, loadSate.error, "img_failed");
    } else {
      return showFailedView(context, Config.failedText, "img_failed");
    }
  }
  else if (reason == FailState.UNAUTHENTICATED){
    return showFailedView(
        context, Config.notAuthenticatedText, "lock", showLogOut: true);
  }
  else {
    return showFailedView(
        context, Config.noInternetText, "img_no_internet");
  }
}

Widget displayDivider() {
  return const Divider(
    height: 2,
    color: Colors.grey,
  );
}

Widget loadMoreWidget() {
  return const Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: <Widget>[
      SizedBox(
        width: 30,
        height: 30,
        child: CircularProgressIndicator(
          backgroundColor: Colors.transparent,
          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
        ),
      ),
    ],
  );
}

Widget failedScreen(BuildContext context, FailState? failState, {LoadingState? loadState}) {
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
              child: onFailRequest(context, failState, loadSate: loadState),
            ),
          )
        ]
    );
}

void showNotificationDialog(BuildContext context, PushNotification notification) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(notification.title!),
        content: SingleChildScrollView(
          child: Column(
            //crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 70.0.w,
                child: Image.asset("assets/images/notification.png",
                    alignment: Alignment.center),
              ),
              SizedBox(height: 15.h),
              Text(notification.body!)
            ],
          ),
        ),
      );
    },
  );
}

Widget loadingScreen() {
  return
    Scaffold(
      body: Stack(
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
                      valueColor: AlwaysStoppedAnimation<Color>(
                          AppTheme.primary),
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
      ),
    );
}

Widget noItemFound(BuildContext context, String content)
{
  return Container(
    constraints: BoxConstraints(
      minHeight: MediaQuery.of(context).size.height / 1.5,
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset("assets/img_no_post.png", height: MediaQuery
            .of(context)
            .orientation == Orientation.landscape ? 50 : getProportionateScreenWidth(200),),
        Padding(
          padding: const EdgeInsets.only(top: 30),
          child: Column(
            children: [
              Text("Oops... There aren’t any $content yet.",
                style: AppTheme.caption,
                textAlign: TextAlign.center,),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ],
    ),
  );
}


Widget signInOut(BuildContext context, Widget? widget) {
  return Center(
    child: Column(
      children: [
        SizedBox(height: 50.h,),
        Image.asset("assets/images/lock.png",
            height: 300.h,
            width: 250.w,
            alignment: Alignment.center),
        Text(translation(context)?.youNeedToLoginToContinue ?? "You need to login to continue.",
            style: AppTheme.textPrimaryMedium),
        SizedBox(height: 50.h,),
        TextButton(
          onPressed: (){
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SignInScreen(widget),
              ),
            );
          },
          style: TextButton.styleFrom(
            backgroundColor: AppTheme.primary,
            elevation: 20,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          child: SizedBox(
            height: 30.h,
            width: 250.w,
            child: Align(
              alignment: Alignment.center,
              child: Text(
                translation(context)?.login ?? 'Login',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

TextFormField emailFormField(BuildContext context, onSaveEmail, removeError, addError)
{
  return TextFormField(
    textInputAction: TextInputAction.next,
    keyboardType: TextInputType.emailAddress,
    onSaved: (newValue) => onSaveEmail(newValue),
    onChanged: (value) {
      if (value.isNotEmpty) {
        removeError(error: AppTheme.kEmailNullError);
      }
      if (AppTheme.emailValidatorRegExp.hasMatch(value)) {
        removeError(error: AppTheme.kInvalidEmailError);
      }
      onSaveEmail(value);
    },
    validator: (value) {
      if (value!.isEmpty) {
        addError(error: AppTheme.kEmailNullError);
        return "";
      } else if (!AppTheme.emailValidatorRegExp.hasMatch(value)) {
        addError(error: AppTheme.kInvalidEmailError);
        return "";
      }
      return null;
    },
    decoration: InputDecoration(
      labelText: translation(context)?.emailAddress ?? 'Email Address',
      labelStyle: const TextStyle(
        color: AppTheme.normalGrey,
        fontSize: 16,
        fontFamily: 'Open Sans',
        fontWeight: FontWeight.w500,
      ),
      suffixIcon: const CustomSuffixIcon(svgIcon: Icon(
        Icons.email_outlined,
        color: AppTheme.primary,
      ),
      ),
    ),
  );
}

TextFormField passwordFormField(context, onSave, removeError, addError)
{
  return TextFormField(
    textInputAction: TextInputAction.done,
    obscureText: true,
    onSaved: (newValue) => onSave(newValue),
    onChanged: (value) {
      if (value.isNotEmpty) {
        removeError(error: AppTheme.kPassNullError);
      }
      if (value.length >= 8) {
        removeError(error: AppTheme.kShortPassError);
      }
      onSave(value);
    },
    validator: (value) {
      if (value!.isEmpty) {
        addError(error: AppTheme.kPassNullError);
        return "";
      } else if (value.length < 8) {
        addError(error: AppTheme.kShortPassError);
        return "";
      }
      return null;
    },
    decoration: InputDecoration(
      labelText: translation(context)?.password ?? 'Password',
      labelStyle: const TextStyle(
        color: AppTheme.normalGrey,
        fontSize: 16,
        fontFamily: 'Open Sans',
        fontWeight: FontWeight.w500,
      ),
      suffixIcon: const CustomSuffixIcon(
        svgIcon: Icon(
          Icons.lock_outline,
          color: AppTheme.primary,
        ),
      ),
    ),
  );
}

//confirm password text field
TextFormField confirmPasswordFormField(context, password, onSave, removeError, addError)
{
  String? confirmPassword = "";
  return TextFormField(
    textInputAction: TextInputAction.done,
    obscureText: true,
    onSaved: (newValue) => {
      onSave(newValue),
      confirmPassword = newValue
    },
    onChanged: (value) {
      confirmPassword = value;
      if (value.isNotEmpty) {
        removeError(error: AppTheme.kConfirmPassNullError);
      }
      if (value.isNotEmpty && password == confirmPassword) {
        removeError(error: AppTheme.kMatchPassError);
      }
      onSave(value);
    },
    validator: (value) {
      if (value!.isEmpty) {
        addError(error: AppTheme.kConfirmPassNullError);
        return "";
      } else if ((password != value)) {
        addError(error: AppTheme.kMatchPassError);
        return "";
      }
      return null;
    },
    decoration: InputDecoration(
      labelText: translation(context)?.confirmPassword ?? 'Confirm Password',
      labelStyle: TextStyle(
        color: AppTheme.normalGrey,
        fontSize: 16,
        fontFamily: 'Open Sans',
        fontWeight: FontWeight.w500,
      ),
      suffixIcon: CustomSuffixIcon(
        svgIcon: Icon(
          Icons.lock_outline,
          color: AppTheme.primary,
        ),
      ),
    ),
  );
}
TextFormField userNameFormField(context, onSave, removeError, addError)
{
  return TextFormField(
    textInputAction: TextInputAction.next,
    keyboardType: TextInputType.name,
    onSaved: (newValue) => onSave(newValue),
    onChanged: (value) {
      if (value.isNotEmpty) {
        removeError(error: AppTheme.kNameNullError);
      }
      return;
    },
    validator: (value) {
      if (value!.isEmpty) {
        addError(error: AppTheme.kNameNullError);
        return "";
      }
      return null;
    },
    decoration: InputDecoration(
      labelText: translation(context)?.userName ?? 'User Name',
      labelStyle: const TextStyle(
        color: AppTheme.normalGrey,
        fontSize: 16,
        fontFamily: 'Open Sans',
        fontWeight: FontWeight.w500,
      ),
      suffixIcon: const CustomSuffixIcon(
        svgIcon: Icon(
          Icons.person,
          color: AppTheme.primary,
        ),
      ),
    ),
  );
}

void showLoginDialog(BuildContext context, StatefulWidget nextScreen,
    {int? popCount}) {

  BuildContext backContext = context;

  showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Login"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset("assets/images/lock.png",
                  height: 200.h,
                  width: 200.w,
                  alignment: Alignment.center),
              const SizedBox(height: 30),
              Text("You need to login to continue.",
                  style: AppTheme.textPrimaryMedium),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                if (popCount != null) {
                  for (int i = 0; i < popCount; i++) {
                    Navigator.pop(backContext);
                  }
                }
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SignInScreen(nextScreen),
                  ),
                );
              },
              child: const Text("Login"),
            ),
          ],
        );
      });
}

Widget getSplashScreen() {
  //screen with logo and spinner below it
  return Scaffold(
    backgroundColor: Colors.white,
    body: Stack(
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: SizeConfig.screenHeight! * 0.35,
              child: Image.asset(
                'assets/images/splash.png',
              ),
            ),
            SizedBox(
              height: SizeConfig.screenHeight! * 0.05,
            ),
            Text(
              Config.systemName,
              textAlign: TextAlign.center,
              style: AppTheme.headlineBig,
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 30.0),
          child: Container(
            alignment: Alignment.bottomCenter,
            child: const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.colorError),
            ),
          ),
        )
      ],
    ),
  );
}

showOkCancelDialog(
    BuildContext context,
    ThisApplicationViewModel thisApplicationViewModel,
    String title,
    String body,
    String okButtonText,
    String cancelButtonText,
    Function() okButtonCallback,
    Function() cancelButtonCallback,
    )
{
  // set up the buttons
  Widget cancelButton = TextButton(
    onPressed: cancelButtonCallback,
    child: Text(cancelButtonText),
  );
  Widget continueButton = TextButton(
    onPressed: okButtonCallback,
    child: Text(okButtonText),
  );

  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    title: Text(title),
    content: Text(body),
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
    barrierDismissible: false,
  );
}
