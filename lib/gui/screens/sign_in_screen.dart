
import 'package:flutter/material.dart';
import 'package:school_trip_track_driver/utils/app_theme.dart';

import '../widgets/sign_in_with_email_password_form.dart';

class SignInScreen extends StatefulWidget {
  static String routeName = "/sign_in";

  final Widget? nextScreen;

  const SignInScreen(this.nextScreen, {super.key});

  @override
  SignInScreenState createState() => SignInScreenState();
}

class SignInScreenState extends State<SignInScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SignInWithEmailPasswordForm(widget.nextScreen),
    );
  }
}
