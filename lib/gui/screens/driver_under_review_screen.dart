import 'package:school_trip_track_driver/view_models/this_application_view_model.dart';
import 'package:flutter/material.dart';
import 'package:school_trip_track_driver/utils/app_theme.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../connection/utils.dart';
import '../../services/service_locator.dart';
import '../languages/language_constants.dart';
import '../widgets/animated_app_bar.dart';

class DriverUnderReviewScreen extends StatefulWidget {
  const DriverUnderReviewScreen({super.key});

  @override
  DriverUnderReviewScreenState createState() => DriverUnderReviewScreenState();
}

class DriverUnderReviewScreenState extends State<DriverUnderReviewScreen> {


  ThisApplicationViewModel thisApplicationViewModel = serviceLocator<ThisApplicationViewModel>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: const AnimatedAppBar(
        '',
        false,
        addPadding: false,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        //text and logout button and exit button
        children: [
          const SizedBox(height: 20),
          Text(translation(context)?.yourAccountUnderReview ?? 'Your account is under review',
            style: AppTheme.textSecondaryMedium,
          ),
          const SizedBox(height: 80),
          Image.asset(
            'assets/images/img_account_review.png',
            height: 200.w,
            width: 200.w,
          ),
          const SizedBox(height: 20),
          Padding(
            padding: EdgeInsets.all(18.0),
            child: Text(
              translation(context)?.accountReviewMessage ?? 'Your account is under review. You will be notified once your account is approved.',
              style: AppTheme.textSecondarySmall,
            ),
          ),
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton(
                onPressed: () {
                  showAlertLogoutDialog(context, thisApplicationViewModel);
                },
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  side: const BorderSide(color: AppTheme.primary, width: 2),
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 10),
                ),
                child: Text(
                  translation(context)?.logout ?? 'Logout',
                  style: AppTheme.textSecondaryMedium,
                ),
              ),
              const SizedBox(width: 50),
              ElevatedButton(
                onPressed: () {
                  SystemNavigator.pop();
                },
                // style: ElevatedButton.styleFrom(
                //   backgroundColor: AppTheme.primary,
                //   shape: RoundedRectangleBorder(
                //     borderRadius: BorderRadius.circular(10),
                //   ),
                //   padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 10),
                // ),
                child: Text(
                  translation(context)?.exit ?? 'Exit',
                  style: AppTheme.textSecondaryMedium,
                ),
              ),
            ],
          )
        ],
      )
    );
  }
}