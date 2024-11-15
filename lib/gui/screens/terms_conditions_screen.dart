import 'package:school_trip_track_driver/utils/app_theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:provider/provider.dart';

import '../../services/service_locator.dart';
import '../../view_models/this_application_view_model.dart';
import '../../widgets.dart';
import '../widgets/app_bar.dart';

class TermsConditionsScreen extends StatefulWidget {
  const TermsConditionsScreen({super.key});

  @override
  TermsConditionsScreenState createState() => TermsConditionsScreenState();
}

class TermsConditionsScreenState extends State<TermsConditionsScreen> {

  ThisApplicationViewModel thisAppModel = serviceLocator<
      ThisApplicationViewModel>();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      //load user public profile
      thisAppModel.getTermsEndpoint();
    });
  }

  Widget displayHtml(ThisApplicationViewModel thisApplicationViewModel) {
    if (thisApplicationViewModel.termsLoadingState.inLoading()) {
      // loading. display animation
      return loadingScreen();
    }
    else {
      if (kDebugMode) {
        print("network call finished");
      }
      //network call finished.
      if (thisApplicationViewModel.termsLoadingState.loadError != null) {
        if (kDebugMode) {
          print("page loading error. Display the error");
        }
        // page loading error. Display the error
        return failedScreen(context,
            thisApplicationViewModel.termsLoadingState.failState);
      }
      else {
        return SingleChildScrollView(
            child: Html(
              data: thisApplicationViewModel.terms ?? '',
            )
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThisApplicationViewModel>(
      builder: (context, thisApplicationViewModel, child) {
        return Scaffold(
          backgroundColor: AppTheme.backgroundColor,
            appBar: buildAppBar(context, ''),
            body: displayHtml(thisApplicationViewModel)
        );
      },
    );
  }
}