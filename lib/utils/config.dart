class Config {

  static bool localTest = false;
  /// -------------------- EDIT THIS WITH YOURS -------------------------------------------------

  // Edit WEB_URL with your url. Example: yourdomain.com
  static String webUrl = "153.92.211.150/backend";
  static String serverUrl = "http://$webUrl";


  // static String webUrl = "10.0.2.2/backend";
  // static String serverUrl = "http://$webUrl";

  static String googleApikey = "AIzaSyBViS6aBy6Nx-C_wBx5ARgDnwoO_-Y9Tlg";
  static String systemName = "BTA Driver";
  static String systemVersion = "1.0.0";
  static String systemCompany = "BTA Bus";
  static String developerInfo = "Developed by $systemCompany";

  static String shareText = "Check $systemName, the best app for school bus tracking! It's simple, easy and secure app.";

  static var failedText = "Data failure. Please try again later";

  static var noInternetText = "No internet connection";

  static var notAuthenticatedText = "Your account is either disabled or deleted. Please logout and log in again!";

  static var noItem = "No item found";

  static int timeOut = 15;

  static String credits = "Icons and several images are made by Genko Mono from www.vecteezy.com. See more at https://www.vecteezy.com/members/genkomono";


  static String androidInterstitialAdUnitId = "ca-app-pub-3940256099942544/1033173712";
  static String iosInterstitialAdUnitId = "ca-app-pub-3940256099942544/4411468910";
}
