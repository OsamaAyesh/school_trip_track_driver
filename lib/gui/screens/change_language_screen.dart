import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../main.dart';
import '../../utils/app_theme.dart';
import '../../utils/config.dart';
import '../languages/language.dart';
import '../languages/language_constants.dart';
import '../widgets/app_bar.dart';

class ChangeLanguageScreen extends StatefulWidget {
  const ChangeLanguageScreen({super.key});

  @override
  ChangeLanguageScreenState createState() => ChangeLanguageScreenState();
}

class ChangeLanguageScreenState extends State<ChangeLanguageScreen> {
  int chosenLanguage = 0;
  @override
  void initState() {
    getLocale().then((value) {
      for (int i = 0; i < Language.languageList().length; i++) {
        if (Language.languageList()[i].languageCode == value.languageCode) {
          chosenLanguage = i;
          MainApp.setLocale(context, value);
          break;
        }
      }
      setState(() {});
    });
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: buildAppBar(context, translation(context)?.changeLanguage ?? "Change Language"),
      body: Center(
        child: ListView.builder(itemBuilder: (context, index) {
          return ListTile(
            leading: Text(
              Language.languageList()[index].flag,
              style: TextStyle(
                fontSize: 25.sp,
              ),
            ),
            title: Text(
              Language.languageList()[index].name,
              style: TextStyle(
                fontSize: 16.sp,
              ),
            ),
            trailing: chosenLanguage == index ? const Icon(
              Icons.check,
              color: Colors.blue,
            ):Container(width: 0,),
            onTap: () async {
              setState(() {
                chosenLanguage = index;
              });
              Locale locale = await setLocale(Language.languageList()[index].languageCode);
              MainApp.setLocale(context, locale);
            },
          );
        }, itemCount: Language.languageList().length,),
      ),
    );
  }
}