import 'package:flutter/material.dart';
import 'package:school_trip_track_driver/gui/widgets/custom_surfix_icon.dart';
import 'package:school_trip_track_driver/gui/widgets/form_error.dart';
import 'package:school_trip_track_driver/model/loading_state.dart';
import 'package:school_trip_track_driver/services/service_locator.dart';
import 'package:school_trip_track_driver/utils/keyboard.dart';
import 'package:school_trip_track_driver/utils/app_theme.dart';
import 'package:school_trip_track_driver/view_models/this_application_view_model.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../languages/language_constants.dart';

class ForgetPasswordWidget extends StatefulWidget {
  final Widget? nextScreen;

  const ForgetPasswordWidget(this.nextScreen, {super.key});

  @override
  ForgetPasswordWidgetState createState() => ForgetPasswordWidgetState();
}

class ForgetPasswordWidgetState extends State<ForgetPasswordWidget> {
  final _formKey = GlobalKey<FormState>();
  String? email;
  final List<String> errors = [];

  ThisApplicationViewModel thisAppModel = serviceLocator<ThisApplicationViewModel>();

  @override
  void initState() {
    thisAppModel.resetPasswordLoadingState = LoadingState();
    super.initState();
  }

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
    return Consumer<ThisApplicationViewModel>(
        builder: (context, thisAppModel, child) {
          return Form(
            key: _formKey,
            child: Column(
              children: [
                buildEmailFormField(),
                SizedBox(height: 10.h),
                FormError(errors: errors),

                SizedBox(height: 20.h),
                TextButton(
                  onPressed: (){
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      // if all are valid then go to success screen
                      KeyboardUtil.hideKeyboard(context);
                      thisAppModel.resetPassword(email!, context);
                    }
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
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          //spinner
                          thisAppModel.resetPasswordLoadingState.inLoading() == true ?
                          SizedBox(
                            height: 20.h,
                            width: 20.w,
                            child: const CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          ): Container(),
                          SizedBox(width: 10.w),
                          Text(
                            translation(context)?.resetPassword ?? 'Reset Password',
                            style: AppTheme.textSecondaryMedium,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                thisAppModel.resetPasswordLoadingState.loadError == 1 ?
                FormError(errors: [thisAppModel.resetPasswordLoadingState.error]) : Container()

              ],
            ),
          );
        });
  }

  TextFormField buildEmailFormField() {
    return TextFormField(
      textInputAction: TextInputAction.next,
      keyboardType: TextInputType.emailAddress,
      onSaved: (newValue) => email = newValue,
      onChanged: (value) {
        if (value.isNotEmpty) {
          removeError(error: AppTheme.kEmailNullError);
        } else if (AppTheme.emailValidatorRegExp.hasMatch(value)) {
          removeError(error: AppTheme.kInvalidEmailError);
        }
        return;
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
        labelText: translation(context)?.email ?? "Email",
        hintText: translation(context)?.enterYourEmail ?? "Enter your email",
        // If  you are using latest version of flutter then lable text and hint text shown like this
        // if you r using flutter less then 1.20.* then maybe this is not working properly
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        suffixIcon: CustomSuffixIcon(svgIcon:
        Icon(
          Icons.email_outlined,
          color: AppTheme.darkGrey,
        ),
        ),
      ),
    );
  }
}