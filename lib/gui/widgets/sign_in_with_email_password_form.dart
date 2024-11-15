
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:school_trip_track_driver/gui/screens/forget_password_screen.dart';
import 'package:school_trip_track_driver/utils/keyboard.dart';
import 'package:school_trip_track_driver/utils/app_theme.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../main.dart';
import '../../model/loading_state.dart';
import '../../services/service_locator.dart';
import '../../view_models/this_application_view_model.dart';
import '../../widgets.dart';
import '../languages/language_constants.dart';
import '../screens/change_language_screen.dart';
import '../screens/sign_up_screen.dart';
import 'form_error.dart';

class SignInWithEmailPasswordForm extends StatefulWidget {
  final Widget? nextScreen;

  const SignInWithEmailPasswordForm(this.nextScreen, {super.key});

  @override
  SignInWithEmailPasswordFormState createState() => SignInWithEmailPasswordFormState();
}

class SignInWithEmailPasswordFormState extends State<SignInWithEmailPasswordForm> {
  final _formKey = GlobalKey<FormState>();
  String? email;
  String? password;
  bool remember = false;
  bool isLoading = false;
  final List<String> errors = [];

  ThisApplicationViewModel thisAppModel = serviceLocator<ThisApplicationViewModel>();

  bool rememberMe=false;

  @override
  void initState() {
    thisAppModel.signInLoadingState = LoadingState();
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
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 40.h),
              Stack(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(child: SizedBox()),
                        Align(
                          alignment: Alignment.topCenter,
                          child: Text(
                            translation(context)?.welcomeBack ?? 'Welcome back',
                            style: AppTheme.textSecondaryLarge,
                          ),
                        ),
                        Expanded(child: SizedBox()),
                        IconButton(onPressed: (){
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => ChangeLanguageScreen()),
                          );
                        }, icon: Icon(Icons.language,))
                      ],
                    )
                  ]
              ),
              SizedBox(height: 40.h),
              Padding(
                padding: EdgeInsets.only(left: 20.0.w, right: 20.0.w),
                child: buildEmailFormField(context),
              ),
              SizedBox(height: 40.h),
              Padding(
                padding: EdgeInsets.only(left: 20.0.w, right: 20.0.w),
                child: buildPasswordFormField(context),
              ),
              SizedBox(height: 40.h),
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: Padding(
                  padding: EdgeInsets.only(right: 20.0.w),
                  //forget password button
                  child: GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ForgetPasswordScreen(null),
                      ),
                    ),
                    child: Text(
                      translation(context)?.forgetOrChangePassword ?? 'Forget or Change Password',
                      style: AppTheme.textSecondarySmall,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 40.h),
              //Remember me
              Padding(
                padding: EdgeInsets.only(left: 10.0.w),
                child: Row(
                  children: [
                    Checkbox(value: rememberMe, onChanged: (value){
                      setState(() {
                        rememberMe=value!;
                      });
                    }),
                    Text(
                      translation(context)?.rememberMe ?? 'Remember me',
                      style: AppTheme.textPrimarySmall,
                    ),
                  ],
                ),
              ),
              FormError(errors: errors),
              SizedBox(height: 40.h),
              TextButton(
                onPressed: (){
                  errors.clear();
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    // if all are valid then go to success screen
                    KeyboardUtil.hideKeyboard(context);
                    setState(() {
                      isLoading = true;
                    });

                    thisAppModel.signIn(email, password).then((token) {
                      setState(() {
                        isLoading = false;
                      });
                      if (token != null) {
                        if (widget.nextScreen != null) {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (context) => const MyHomePage()),
                                (Route<dynamic> route) => false,
                          );
                        }
                        else {
                          Navigator.pop(
                              context
                          );
                        }
                      }
                      else {
                        if (thisAppModel.signInLoadingState!.loadError == 1) {
                          errors.clear();
                          addError(
                              error: thisAppModel.signInLoadingState!.error);
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
                        thisAppModel.signInLoadingState!.inLoading() == true ?
                        SizedBox(
                          height: 20.h,
                          width: 20.w,
                          child: const CircularProgressIndicator(
                            color: Colors.white,
                          ),
                        ): Container(),
                        SizedBox(width: 10.w),
                        Text(
                          translation(context)?.login ?? 'Login',
                          style: AppTheme.textSecondaryLarge,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 40.h),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: translation(context)?.dontHaveAccount ?? 'Don\'t have an account? ',
                      style: AppTheme.textPrimaryLarge,
                    ),
                    TextSpan(
                      text: translation(context)?.signUp ?? 'Sign Up',
                      style: AppTheme.textSecondaryLarge,
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SignUpScreen(widget.nextScreen)),
                          );
                        },
                    ),
                  ],
                ),
              ),
              SizedBox(height: 40.h),
            ],
          ),
        ),
      ),
    );

  }

  TextFormField buildPasswordFormField(BuildContext context) {
    return passwordFormField(context, (newValue) => password = newValue, removeError, addError);
  }

  TextFormField buildEmailFormField(BuildContext context) {
    return emailFormField(context, (newValue) => email = newValue, removeError, addError);
  }
  void signIn(String provider) {
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

    if (isLoading) return;

    setState(() {
      isLoading = true;
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
        isLoading = false;
      });
      if (token != null) {
        if (widget.nextScreen != null) {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => widget.nextScreen!));
        } else {
          Navigator.pop(context);
        }
      } else {
        if (thisAppModel.signInLoadingState?.loadError == 1) {
          errors.clear();
          addError(error: thisAppModel.signInLoadingState?.error);
        }
      }
    });
  }

}
// import 'package:flutter/gestures.dart';
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:school_trip_track_driver/gui/screens/forget_password_screen.dart';
// import 'package:school_trip_track_driver/widgets.dart';
// import 'package:school_trip_track_driver/utils/app_theme.dart';
// import 'package:school_trip_track_driver/services/service_locator.dart';
// import 'package:school_trip_track_driver/view_models/this_application_view_model.dart';
// import 'package:school_trip_track_driver/model/loading_state.dart';
//
// import '../screens/sign_up_screen.dart';
// import 'form_error.dart';
//
// class SignInWithEmailPasswordForm extends StatefulWidget {
//   final Widget? nextScreen;
//
//   const SignInWithEmailPasswordForm(this.nextScreen, {super.key});
//
//   @override
//   SignInWithEmailPasswordFormState createState() =>
//       SignInWithEmailPasswordFormState();
// }
//
// class SignInWithEmailPasswordFormState extends State<SignInWithEmailPasswordForm> {
//   final _formKey = GlobalKey<FormState>();
//   String? email;
//   String? password;
//   bool rememberMe = false;
//   bool isLoading = false;
//   final List<String> errors = [];
//
//   ThisApplicationViewModel thisAppModel = serviceLocator<ThisApplicationViewModel>();
//
//   @override
//   void initState() {
//     super.initState();
//     thisAppModel.signInLoadingState = LoadingState();
//   }
//
//   void addError({String? error}) {
//     if (!errors.contains(error)) {
//       setState(() {
//         errors.add(error!);
//       });
//     }
//   }
//
//   void removeError({String? error}) {
//     if (errors.contains(error)) {
//       setState(() {
//         errors.remove(error);
//       });
//     }
//   }
//   Future<void> signInWithEmailPassword() async {
//     if (_formKey.currentState!.validate()) {
//       _formKey.currentState!.save();
//
//       setState(() {
//         isLoading = true;
//       });
//
//       try {
//         // Firebase Authentication Login
//         final UserCredential userCredential = await FirebaseAuth.instance
//             .signInWithEmailAndPassword(
//             email: email!, password: password!);
//
//         if (userCredential.user != null) {
//           // User is signed in successfully
//           if (widget.nextScreen != null) {
//             // Use pushReplacement instead of pop for smooth transition
//             Navigator.pushAndRemoveUntil(
//               context,
//               MaterialPageRoute(builder: (context) => widget.nextScreen!),
//                   (Route<dynamic> route) => false, // Remove all previous routes
//             );
//           } else {
//             // This ensures that if nextScreen is null, you don't return to the login screen
//             Navigator.pop(context);
//           }
//         }
//       } catch (e) {
//         setState(() {
//           isLoading = false;
//         });
//         addError(error: 'Login failed: ${e.toString()}');
//       }
//     }
//   }
//
//   // Future<void> signInWithEmailPassword() async {
//   //   if (_formKey.currentState!.validate()) {
//   //     _formKey.currentState!.save();
//   //
//   //     setState(() {
//   //       isLoading = true;
//   //     });
//   //
//   //     try {
//   //       // Firebase Authentication Login
//   //       final UserCredential userCredential = await FirebaseAuth.instance
//   //           .signInWithEmailAndPassword(
//   //           email: email!, password: password!);
//   //       if (userCredential.user != null) {
//   //         // User is signed in successfully
//   //         if (widget.nextScreen != null) {
//   //           Navigator.pushAndRemoveUntil(
//   //             context,
//   //             MaterialPageRoute(builder: (context) => widget.nextScreen!),
//   //                 (Route<dynamic> route) => false,
//   //           );
//   //         } else {
//   //           Navigator.pop(context);
//   //         }
//   //       }
//   //     } catch (e) {
//   //       setState(() {
//   //         isLoading = false;
//   //       });
//   //       addError(error: 'Login failed: ${e.toString()}');
//   //     }
//   //   }
//   // }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppTheme.backgroundColor,
//       body: Form(
//         key: _formKey,
//         child: SingleChildScrollView(
//           child: Column(
//             children: [
//               SizedBox(height: 40.h),
//               Stack(
//                 children: [
//                   Align(
//                     alignment: Alignment.topCenter,
//                     child: Text(
//                       'Welcome back',
//                       style: AppTheme.textSecondaryLarge,
//                     ),
//                   ),
//                 ],
//               ),
//               SizedBox(height: 40.h),
//               Padding(
//                 padding: EdgeInsets.symmetric(horizontal: 20.0.w),
//                 child: buildEmailFormField(context),
//               ),
//               SizedBox(height: 40.h),
//               Padding(
//                 padding: EdgeInsets.symmetric(horizontal: 20.0.w),
//                 child: buildPasswordFormField(context),
//               ),
//               SizedBox(height: 40.h),
//               Align(
//                 alignment: AlignmentDirectional.centerEnd,
//                 child: Padding(
//                   padding: EdgeInsets.only(right: 20.0.w),
//                   child: GestureDetector(
//                     onTap: () => Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => const ForgetPasswordScreen(null),
//                       ),
//                     ),
//                     child: Text(
//                       'Forget or Change Password',
//                       style: AppTheme.textSecondarySmall,
//                     ),
//                   ),
//                 ),
//               ),
//               SizedBox(height: 40.h),
//               Padding(
//                 padding: EdgeInsets.only(left: 10.0.w),
//                 child: Row(
//                   children: [
//                     Checkbox(
//                       value: rememberMe,
//                       onChanged: (value) {
//                         setState(() {
//                           rememberMe = value!;
//                         });
//                       },
//                     ),
//                     Text(
//                       'Remember me',
//                       style: AppTheme.textPrimarySmall,
//                     ),
//                   ],
//                 ),
//               ),
//               FormError(errors: errors),
//               SizedBox(height: 40.h),
//               TextButton(
//                 onPressed: () {
//                   errors.clear();
//                   signInWithEmailPassword();
//                 },
//                 style: TextButton.styleFrom(
//                   backgroundColor: AppTheme.primary,
//                   elevation: 5,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(15),
//                   ),
//                 ),
//                 child: SizedBox(
//                   height: 30.h,
//                   width: 250.w,
//                   child: Align(
//                     alignment: Alignment.center,
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         isLoading
//                             ? SizedBox(
//                           height: 20.h,
//                           width: 20.w,
//                           child: const CircularProgressIndicator(
//                             color: Colors.white,
//                           ),
//                         )
//                             : Container(),
//                         SizedBox(width: 10.w),
//                         Text(
//                           'Login',
//                           style: AppTheme.textSecondaryLarge,
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//               SizedBox(height: 40.h),
//               Text.rich(
//                 TextSpan(
//                   children: [
//                     TextSpan(
//                       text: 'Don\'t have an account? ',
//                       style: AppTheme.textPrimaryLarge,
//                     ),
//                     TextSpan(
//                       text: 'Sign Up',
//                       style: AppTheme.textSecondaryLarge,
//                       recognizer: TapGestureRecognizer()
//                         ..onTap = () {
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                                 builder: (context) => SignUpScreen(widget.nextScreen)),
//                           );
//                         },
//                     ),
//                   ],
//                 ),
//               ),
//               SizedBox(height: 40.h),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   TextFormField buildPasswordFormField(BuildContext context) {
//     return passwordFormField(context, (newValue) => password = newValue, removeError, addError);
//   }
//
//   TextFormField buildEmailFormField(BuildContext context) {
//     return emailFormField(context, (newValue) => email = newValue, removeError, addError);
//   }
// }
