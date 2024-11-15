
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../model/loading_state.dart';
import '../../services/service_locator.dart';
import '../../utils/app_theme.dart';
import '../../view_models/this_application_view_model.dart';
import '../languages/language_constants.dart';
import '../widgets/app_bar.dart';


class MyProfileScreen extends StatefulWidget {
  const MyProfileScreen({Key? key}) : super(key: key);

  @override
  MyProfileScreenState createState() => MyProfileScreenState();
}

class MyProfileScreenState extends State<MyProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  bool buttonPressed = true;

  String errorMessage = '';
  List<String> errors = [];

  ThisApplicationViewModel thisAppModel = serviceLocator<
      ThisApplicationViewModel>();

  @override
  void initState(){
    super.initState();

    errorMessage = '';
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThisApplicationViewModel>(
        builder: (context, thisAppModel, child) {
          if(thisAppModel.updateProfileLoadingState.error != null) {
            errors.clear();
            errors.add(
                thisAppModel.updateProfileLoadingState.error!);
          }
          return Scaffold(
            appBar: buildAppBar(context, translation(context)?.basicInformation ?? 'Basic information'),
            body: _drawField(thisAppModel),
          );
        });

  }

  Widget _drawField(ThisApplicationViewModel thisAppModel) {
    //print(thisAppModel.currentUser.address?.isEmpty ?? true);
    return
      Form(
        key: _formKey,
        child:
        SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const SizedBox(height: 20,),
                Text( translation(context)?.accountInformation ?? 'Account information',
                    style: AppTheme.textPrimaryLarge),
                const SizedBox(height: 30,),
                Row(
                  children: [
                    const SizedBox(width: 10,),
                    const Icon(Icons.person_outline, color: AppTheme.normalGrey,),
                    const SizedBox(width: 10,),
                    Text(thisAppModel.currentUser!.name!,
                        style: AppTheme.textGreyMedium),
                  ],
                ),
                const SizedBox(height: 30,),
                Row(
                  children: [
                    const SizedBox(width: 10,),
                    const Icon(Icons.email_outlined, color: AppTheme.normalGrey,),
                    const SizedBox(width: 10,),
                    Text(thisAppModel.currentUser!.email!,
                        style: AppTheme.textGreyMedium),
                  ],
                ),
                const SizedBox(height: 30,),
              ],
            ),
          ),
        ),
      );
  }

  @override
  void dispose() {
    thisAppModel.updateProfileLoadingState = LoadingState();
    super.dispose();
  }

  String hintMessage() {
      return 'Add or edit/remove your interests';
  }


}