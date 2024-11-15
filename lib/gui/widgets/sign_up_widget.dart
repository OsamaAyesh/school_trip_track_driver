
import 'package:flutter/material.dart';
import 'package:school_trip_track_driver/gui/widgets/custom_surfix_icon.dart';
import 'package:school_trip_track_driver/gui/widgets/form_error.dart';
import 'package:school_trip_track_driver/services/service_locator.dart';
import 'package:school_trip_track_driver/utils/app_theme.dart';
import 'package:school_trip_track_driver/utils/keyboard.dart';
import 'package:school_trip_track_driver/view_models/this_application_view_model.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../model/loading_state.dart';
import '../../widgets.dart';
import '../languages/language_constants.dart';

class SignUpForm extends StatefulWidget {

  final Widget? nextScreen;

  const SignUpForm(this.nextScreen, {super.key});

  @override
  SignUpFormState createState() => SignUpFormState();
}

class SignUpFormState extends State<SignUpForm> {
  final _formKey = GlobalKey<FormState>();
  String? email, userName;
  String? password;
  String? confirmPassword;
  String? phoneNumber;
  bool remember = false;
  final List<String> errors = [];

  ThisApplicationViewModel thisAppModel = serviceLocator<ThisApplicationViewModel>();

  bool isLoading = false;

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
  void initState() {
    thisAppModel.signUpLoadingState = LoadingState();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
                children: [
                  Align(
                    alignment: Alignment.topCenter,
                    child: Text(
                      translation(context)?.signUp ?? 'Sign Up',
                      style: const TextStyle(
                        color: AppTheme.primary,
                        fontSize: 24,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ]
            ),
            SizedBox(height: 20.h),
            Text(
              translation(context)?.signUpText ?? 'Please fill in the form below to create a new account.',
              style: TextStyle(
                color: AppTheme.normalGrey,
                fontSize: 15,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w400,
              ),
            ),
            SizedBox(height: 40.h),
            buildUserNameFormField(context),
            SizedBox(height: 15.h),
            buildEmailFormField(context),
            SizedBox(height: 15.h),
            buildPasswordFormField(context),
            SizedBox(height: 15.h),
            buildConfirmPassFormField(context),
            FormError(errors: errors),
            SizedBox(height: 40.h),
            TextButton(
              onPressed: () {
                errors.clear();
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  // if all are valid then go to success screen
                  KeyboardUtil.hideKeyboard(context);
                  setState(() {
                    isLoading = true;
                  });

                  thisAppModel.signUp(userName, email, password).then((token) {
                    setState(() {
                      isLoading = false;
                    });
                    if (token != null) {
                      if (widget.nextScreen != null) {
                        Navigator.popUntil(context, (route) => route.isFirst);
                      }
                      else {
                        Navigator.pop(
                            context
                        );
                      }
                    }
                    else {
                      if (thisAppModel.signUpLoadingState!.loadError == 1) {
                        errors.clear();
                        addError(error: thisAppModel.signUpLoadingState!.error);
                      }
                    }
                  });
                }
              },
              style: TextButton.styleFrom(
                backgroundColor: AppTheme.primary,
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: SizedBox(
                height: 30.h,
                width: 250.w,
                child: Align(
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      //spinner
                      thisAppModel.signUpLoadingState!.inLoading() == true ?
                      SizedBox(
                        height: 20.h,
                        width: 20.w,
                        child: const CircularProgressIndicator(
                          color: Colors.white,
                        ),
                      ): Container(),
                      SizedBox(width: 10.w),
                      Text(
                        translation(context)?.signUp ?? 'Sign Up',
                        style: AppTheme.textSecondaryMedium,
                      ),
                    ],
                  ),
                ),
              ),
              // child: isLoading
              //     ? const CircularProgressIndicator(
              //   strokeWidth: 2,
              //   backgroundColor: Colors.transparent,
              //   valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              // )
              //     : const Text("Sign Up"),
              // onPressed: () {
              //   if (_formKey.currentState!.validate()) {
              //     _formKey.currentState!.save();
              //     // if all are valid then go to success screen
              //     KeyboardUtil.hideKeyboard(context);
              //     setState(() {
              //       isLoading = true;
              //     });
              //
              //     thisAppModel.signUp(userName, email, password).then((token) {
              //       setState(() {
              //         isLoading = false;
              //       });
              //       if (token != null) {
              //         if (widget.nextScreen != null) {
              //           Navigator.pushReplacement(
              //             context,
              //             MaterialPageRoute(
              //                 builder: (context) => widget.nextScreen!),
              //           );
              //         }
              //         else {
              //           Navigator.pop(
              //               context
              //           );
              //         }
              //       }
              //       else {
              //         if (thisAppModel.signUpLoadingState!.loadError == 1) {
              //           errors.clear();
              //           addError(error: thisAppModel.signUpLoadingState!.error);
              //         }
              //       }
              //     });
              //   }
              // },
            ),
          ],
        ),
      ),
    );
  }

  TextFormField buildConfirmPassFormField(BuildContext context) {
    return confirmPasswordFormField(context, password, (newValue) => setState(() {confirmPassword = newValue;}), removeError, addError);
  }

  TextFormField buildPasswordFormField(BuildContext context) {
    return passwordFormField(context, (newValue) => setState(() {password = newValue;}), removeError, addError);
  }

  TextFormField buildEmailFormField(BuildContext context) {
    return emailFormField(context, (newValue) => setState(() {email = newValue;}), removeError, addError);
  }

  TextFormField buildUserNameFormField(BuildContext context) {
    return userNameFormField(context, (newValue) => setState(() {userName = newValue;}), removeError, addError);
  }

  TextFormField buildPhoneNumberFormField() {
    return TextFormField(
      textInputAction: TextInputAction.next,
      keyboardType: TextInputType.phone,
      onSaved: (newValue) => phoneNumber = newValue,
      onChanged: (value) {
        if (value.isNotEmpty) {
          removeError(error: AppTheme.kPhoneNumberNullError);
        } else if (AppTheme.phoneNumberValidatorRegExp.hasMatch(value)) {
          removeError(error: AppTheme.kInvalidPhoneNumberError);
        }
        return;
      },
      validator: (value) {
        if (value!.isEmpty) {
          addError(error: AppTheme.kPhoneNumberNullError);
          return "";
        } else if (!AppTheme.phoneNumberValidatorRegExp.hasMatch(value)) {
          addError(error: AppTheme.kInvalidPhoneNumberError);
          return "";
        }
        return null;
      },
      decoration: const InputDecoration(
        labelText: "Phone Number",
        hintText: "Enter your phone number",
        // If  you are using latest version of flutter then lable text and hint text shown like this
        // if you r using flutter less then 1.20.* then maybe this is not working properly
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        suffixIcon: CustomSuffixIcon(svgIcon: Icon(
          Icons.phone_iphone,
          color: AppTheme.darkGrey,
        ),
        ),
      ),
    );
  }
}
