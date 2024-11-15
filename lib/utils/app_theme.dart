import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

//App colors and theme
class AppTheme {

  AppTheme._();

  static const Color backgroundColor = Color(0xFFFFFFFF);
  
  static const Color primary = Color(0xfff9a21b);
  static const Color primaryDark = Color(0xffd7893b);
  static const Color secondary = Color(0xff1f4168);
  static const Color secondaryLight = Color(0x85435b97);
  static const Color textColorOnDarkBackground = Color(0xFFfefefd);

  
  // static const Color accent = Color(0xFFC0C0C0);
  // static const Color bg_200 = Color(0xfff7F7F7);
  // static const Color bg_300 = Color(0xffc4c4c4);
  // static const Color primary_200 = Color(0xFFddb900);
  // static const Color primary_300 = Color(0xFF917800);
  // static const Color accent_200 = Color(0xFF626262);
  // static const Color text_300 = Color(0xFF5c5c5c);


  static const Color lightPrimary = Color(0x7F435b97);

  static const Color darkPrimary = Color(0xFF1A0F91);


  static const Color darkColorSecondary = Color(0xFFf00000);
  static const Color colorError = Color(0xFFFE7C71);



  static const Color veryLightGrey = Color(0xFFf7f7f7);
  static const Color lightGrey = Color(0xFFe6e6e6);
  static const Color normalGrey= Color(0xFF8E8E8E);
  static const Color darkGrey = Color(0xFF263238);

  static const String fontName = "Kreon";

  static TextStyle textPrimarySmallLight = const TextStyle(
    color: AppTheme.primary,
    fontSize: 14,
    fontFamily: 'Open Sans',
    fontWeight: FontWeight.w400,
  );

  static TextStyle headlineBig = const TextStyle(
    color: secondary,
    fontSize: 30,
    fontFamily: 'Open Sans',
    fontWeight: FontWeight.w700,
  );
  static TextStyle textGreySmall = const TextStyle(
    color: AppTheme.normalGrey,
    fontSize: 14,
    fontFamily: 'Open Sans',
    fontWeight: FontWeight.w400,
  );
  static TextStyle textGreyMedium = const TextStyle(
    color: AppTheme.normalGrey,
    fontSize: 16,
    fontFamily: 'Open Sans',
    fontWeight: FontWeight.w700,
  );
  static TextStyle textGreyLarge = const TextStyle(
    color: AppTheme.normalGrey,
    fontSize: 20,
    fontFamily: 'Open Sans',
    fontWeight: FontWeight.w700,
  );

  static TextStyle textPrimarySmall = const TextStyle(
    color: AppTheme.primary,
    fontSize: 14,
    fontFamily: 'Open Sans',
    fontWeight: FontWeight.w700,
  );
  static TextStyle textPrimaryMedium = const TextStyle(
    color: AppTheme.primary,
    fontSize: 16,
    fontFamily: 'Open Sans',
    fontWeight: FontWeight.w700,
  );
  static TextStyle textPrimaryLarge = const TextStyle(
    color: AppTheme.primary,
    fontSize: 20,
    fontFamily: 'Open Sans',
    fontWeight: FontWeight.w700,
  );
  static TextStyle textPrimaryXL = const TextStyle(
    color: AppTheme.primary,
    fontSize: 24,
    fontFamily: 'Open Sans',
    fontWeight: FontWeight.w700,
  );

  static TextStyle textDarkPrimarySmall = const TextStyle(
    color: AppTheme.primaryDark,
    fontSize: 14,
    fontFamily: 'Open Sans',
    fontWeight: FontWeight.w700,
  );
  static TextStyle textDarkPrimaryMedium = const TextStyle(
    color: AppTheme.primaryDark,
    fontSize: 16,
    fontFamily: 'Open Sans',
    fontWeight: FontWeight.w700,
  );
  static TextStyle textDarkPrimaryLarge = const TextStyle(
    color: AppTheme.primaryDark,
    fontSize: 20,
    fontFamily: 'Open Sans',
    fontWeight: FontWeight.w700,
  );
  static TextStyle textDarkPrimaryXL = const TextStyle(
    color: AppTheme.primaryDark,
    fontSize: 24,
    fontFamily: 'Open Sans',
    fontWeight: FontWeight.w700,
  );

  static TextStyle textSecondarySmall = const TextStyle(
    color: AppTheme.secondary,
    fontSize: 14,
    fontFamily: 'Open Sans',
    fontWeight: FontWeight.w700,
  );
  static TextStyle textSecondaryMedium = const TextStyle(
    color: AppTheme.secondary,
    fontSize: 16,
    fontFamily: 'Open Sans',
    fontWeight: FontWeight.w700,
  );
  static TextStyle textSecondaryLarge = const TextStyle(
    color: AppTheme.secondary,
    fontSize: 20,
    fontFamily: 'Open Sans',
    fontWeight: FontWeight.w700,
  );
  static TextStyle textSecondaryXL = const TextStyle(
    color: AppTheme.secondary,
    fontSize: 24,
    fontFamily: 'Open Sans',
    fontWeight: FontWeight.w700,
  );

  static TextStyle textDarkerBlueLarge = const TextStyle(
    color: AppTheme.primary,
    fontSize: 20,
    fontFamily: 'Open Sans',
    fontWeight: FontWeight.w700,
  );
  static TextStyle textDarkerBlueXL = const TextStyle(
    color: AppTheme.primary,
    fontSize: 38,
    fontFamily: 'Open Sans',
    fontWeight: FontWeight.w700,
  );
  static TextStyle textDarkestBlueMedium = const TextStyle(
    color: AppTheme.lightPrimary,
    fontSize: 16,
    fontFamily: 'Open Sans',
    fontWeight: FontWeight.w700,
  );
  static TextStyle textWhiteMedium = const TextStyle(
    color: Colors.white,
    fontSize: 16,
    fontFamily: 'Open Sans',
    fontWeight: FontWeight.w700,
  );
  static TextStyle bold24Grey90 =
  GoogleFonts.sourceSansPro(
      textStyle:const TextStyle( // h5 -> headline
        fontWeight: FontWeight.bold,
        fontSize: 24,
        color: AppTheme.darkGrey,
      ));


  static TextStyle menu =
  GoogleFonts.sourceSansPro(
      textStyle:const TextStyle( // h5 -> headline
        fontSize: 18,
        color: AppTheme.darkPrimary,
      ));

  static TextStyle bold20Black =
  GoogleFonts.sourceSansPro(
      textStyle:const TextStyle( // h5 -> headline
        fontWeight: FontWeight.bold,
        fontSize: 20,
        color: Colors.black,
      ));

  static TextStyle bold14Grey60 =
  GoogleFonts.sourceSansPro(
      textStyle:
      const TextStyle( // h5 -> headline
        fontWeight: FontWeight.bold,
        fontSize: 14,
        letterSpacing: 0.27,
        color: AppTheme.normalGrey,
      ));

  static TextStyle bold16Black =
  GoogleFonts.sourceSansPro(
      textStyle:
      const TextStyle( // h5 -> headline
        fontWeight: FontWeight.bold,
        fontSize: 16,
        letterSpacing: 0.27,
        color: Colors.black,
      ));


  static TextStyle bold14Black =
  GoogleFonts.sourceSansPro(
      textStyle:
      const TextStyle( // h5 -> headline
        fontWeight: FontWeight.bold,
        fontSize: 14,
        letterSpacing: 0.27,
        color: Colors.black,
      ));

  static TextStyle bold14DarkBlue =
  GoogleFonts.sourceSansPro(
      textStyle:
      const TextStyle( // h5 -> headline
        fontWeight: FontWeight.bold,
        fontSize: 14,
        letterSpacing: 0.27,
        color: AppTheme.primary,
      ));

  static TextStyle title =
  GoogleFonts.sourceSansPro(
    textStyle: const TextStyle(
      color: AppTheme.secondary,
      fontSize: 20,
      fontFamily: 'Open Sans',
      fontWeight: FontWeight.w700,
    ),);

  static TextStyle bold20DarkBlue =
  GoogleFonts.sourceSansPro(
      textStyle:const TextStyle( // h6 -> title
        fontWeight: FontWeight.bold,
        fontSize: 20,
        color: AppTheme.primary,
        height: 1.5,
      ));

  static TextStyle bold16DarkBlue =
  GoogleFonts.sourceSansPro(
      textStyle:const TextStyle( // h6 -> title
        fontWeight: FontWeight.bold,
        fontSize: 16,
        color: AppTheme.primary,
        height: 1.5,
      ));

  static TextStyle bold20Primary =
  GoogleFonts.sourceSansPro(
      textStyle:const TextStyle( // h6 -> title
        fontWeight: FontWeight.bold,
        fontSize: 20,
        letterSpacing: 0.18,
        color: AppTheme.primary,
      ));

  static TextStyle bold18Green =
  GoogleFonts.sourceSansPro(
      textStyle:const TextStyle( // h6 -> title
        fontFamily: fontName,
        fontWeight: FontWeight.bold,
        fontSize: 18,
        letterSpacing: 0.18,
        color: Colors.green,
      ));


  static TextStyle bold14Secondary =
  GoogleFonts.sourceSansPro(
      textStyle:const TextStyle( // h6 -> title
        fontWeight: FontWeight.bold,
        fontSize: 14,
        letterSpacing: 0.18,
        color: colorError,
      ));

  static TextStyle bold16Secondary =
  GoogleFonts.sourceSansPro(
      textStyle:const TextStyle( // h6 -> title
        fontWeight: FontWeight.bold,
        fontSize: 16,
        letterSpacing: 0.18,
        color: colorError,
      ));

  static TextStyle coloredGreenSubTitle =
  GoogleFonts.sourceSansPro(
      textStyle:const TextStyle( // h6 -> title
        fontSize: 14,
        letterSpacing: 0.18,
        color: Colors.green,
      ));

  static const TextStyle coloredRedTitle = TextStyle( // h6 -> title
    fontFamily: fontName,
    fontWeight: FontWeight.bold,
    fontSize: 18,
    letterSpacing: 0.18,
    color: AppTheme.colorError,
  );

  static const TextStyle coloredRedTitle2 = TextStyle( // h6 -> title
    fontFamily: fontName,
    fontWeight: FontWeight.w500,
    fontSize: 16,
    color: AppTheme.colorError,
  );

  static TextStyle subtitle =
  GoogleFonts.sourceSansPro(
      textStyle:const TextStyle( // subtitle2 -> subtitle
        fontWeight: FontWeight.bold,
        fontSize: 13,
        color: Colors.black,
      ));

  static const TextStyle coloredSubtitle = TextStyle( // subtitle2 -> subtitle
    fontFamily: fontName,
    fontWeight: FontWeight.normal,
    fontSize: 13,
    color: Colors.black,
  );

  static const TextStyle coloredSubSubtitle = TextStyle( // subtitle2 -> subtitle
    fontFamily: fontName,
    fontWeight: FontWeight.normal,
    fontSize: 12,
    color: Colors.grey,
  );


  static const TextStyle redColoredSubtitle = TextStyle( // subtitle2 -> subtitle
    fontFamily: fontName,
    fontWeight: FontWeight.normal,
    fontSize: 13,
    color: AppTheme.colorError,
  );


  static const TextStyle paragraph = TextStyle( // body1 -> body2
    fontFamily: fontName,
    fontWeight: FontWeight.w400,
    fontSize: 14,
    letterSpacing: 0.2,
    color: Colors.black,
  );

  static TextStyle caption =
  GoogleFonts.sourceSansPro(
      textStyle:const TextStyle( // subtitle2 -> subtitle
        fontWeight: FontWeight.bold,
        fontSize: 18,
        letterSpacing: 0.2,
        color: darkGrey, // was colorAccent
      ));


  static const TextStyle subCaption2 = TextStyle( // Caption -> caption
    fontFamily: fontName,
    fontWeight: FontWeight.w500,
    fontSize: 14,
    color: darkGrey, // was colorAccent
  );

// Form Error
  static final RegExp emailValidatorRegExp =
  RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
  static final RegExp phoneNumberValidatorRegExp = RegExp(r"^(?:[+0]9)?[0-9]{10}$");
  static const String kEmailNullError = "Please enter your email";
  static const String kInvalidEmailError = "Please enter a valid Email";
  static const String kPassNullError = "Please enter your password";
  static const String kConfirmPassNullError = "Please confirm your password";
  static const String kShortPassError = "Password is too short";
  static const String kMatchPassError = "Passwords don't match";
  static const String kNameNullError = "Please enter your user name";
  static const String kPhoneNumberNullError = "Please enter your phone number";
  static const String kInvalidPhoneNumberError = "Please enter a valid phone number";
  static const String kAddressNullError = "Please enter your address";
  static const String kIterestsNullError = "Please enter your interests";

  static const String kNumberNullError = "Please enter a number";
  static const String kInvalidNumberError = "Please enter a valid number";


}


