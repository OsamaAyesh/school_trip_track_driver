import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
// import 'package:flutter_twitter_login/flutter_twitter_login.dart';
// import 'package:twitter_login/twitter_login.dart';

Future<UserCredential?> signInWithTwitter() async {
  // Create a TwitterLogin instance

  // final TwitterLogin twitterLogin = TwitterLogin(
  //   apiKey: 'CSDaRDAFs4Uoen3Zc0OYfH671',
  //   apiSecretKey: 'M8mxcXqPWK3SBfv1Ck246lwPwVAHJjeR8fzX4N8Hr3sAiADIkc',
  //   redirectURI: 'liveshoppers://',
  // );

  // Trigger the sign-in flow
  // final authResult = await twitterLogin.login();

  // Create a credential from the access token
  // final twitterAuthCredential = TwitterAuthProvider.credential(
  //   accessToken: authResult.authToken!,
  //   secret: authResult.authTokenSecret!,
  // );
  //
  // if (authResult.user != null) {
  //   // Get the Logged In session
  //   if (authResult.authToken != null && authResult.authTokenSecret != null) {
  //     // Once signed in, return the UserCredential
  //     return await FirebaseAuth.instance
  //         .signInWithCredential(twitterAuthCredential);
  //   } else {
  //     return null;
  //   }
  // } else {
  //   return null;
  // }
}
