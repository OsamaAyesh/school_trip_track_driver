
import 'package:flutter/material.dart';
import 'package:school_trip_track_driver/gui/widgets/app_bar.dart';
import 'package:school_trip_track_driver/services/service_locator.dart';
import 'package:school_trip_track_driver/utils/app_theme.dart';
import 'package:school_trip_track_driver/view_models/this_application_view_model.dart';

import '../widgets/sign_up_with_email_password_form.dart';

class SignUpScreen extends StatefulWidget {
  static String routeName = "/sign_up";

  final Widget? nextScreen;

  const SignUpScreen(this.nextScreen, {super.key});

  @override
  SignUpScreenState createState() => SignUpScreenState();
}

class SignUpScreenState extends State<SignUpScreen> {
  ThisApplicationViewModel thisAppModel =
  serviceLocator<ThisApplicationViewModel>();

  List<bool> isLoading = [false, false, false, false];

  final List<String> errors = [];

  SignUpScreenState();

  void addError({String? error}) {
    if (!errors.contains(error)) {
      setState(() {
        errors.add(error!);
      });
    }
  }

  void removeError({String? error}) {
    if (errors.contains(error)) {
      setState(() {
        errors.remove(error);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        appBar: buildAppBar(context, ''),
        body: SignUpWithEmailPasswordForm(widget.nextScreen)
      //bodyContent(widget.nextScreen),
    );
  }


  void signUp(String provider) {
    setState(() {
      errors.clear();
    });

    Future<String?>? result;

    int idx = 0;

    switch (provider) {
      case "Google":
        idx = 0;
        break;
      case "Facebook":
        idx = 1;
        break;
      case "Twitter":
        idx = 2;
        break;
      case "Apple":
        idx = 3;
        break;
    }

    if (isLoading[idx]) return;

    setState(() {
      isLoading[idx] = true;
    });

    switch (provider) {
      case "Google":
        result = thisAppModel.authWithGoogle(false);
        break;
      case "Facebook":
        result = thisAppModel.authWithFacebook(false);
        break;
      case "Twitter":
        result = thisAppModel.authWithTwitter(false);
        break;
      case "Apple":
        result = thisAppModel.authWithApple(false);
        break;
    }

    if (result == null) return;

    result.then((token) {
      setState(() {
        isLoading[idx] = false;
      });
      if (token != null) {
        if (widget.nextScreen != null) {
          //Navigator.pop(context);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => widget.nextScreen!),
          );
        } else {
          Navigator.pop(context);
        }
      } else {
        if (thisAppModel.signUpLoadingState?.loadError == 1) {
          errors.clear();
          addError(error: thisAppModel.signUpLoadingState?.error);
        }
      }
    });
  }
}