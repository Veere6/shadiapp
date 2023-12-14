import 'dart:io';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:shadiapp/CommonMethod/CommonColors.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shadiapp/CommonMethod/Toaster.dart';
import 'package:shadiapp/Models/otp_verify_model.dart';
import 'package:shadiapp/Models/phone_login_Model.dart';
import 'package:shadiapp/Services/Services.dart';
import 'package:shadiapp/ShadiApp.dart';
import 'package:shadiapp/view/commonWeb.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_login_facebook/flutter_login_facebook.dart';

class ChooseReg extends StatefulWidget {
  @override
  State<ChooseReg> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<ChooseReg> {

  bool ActiveConnection = false;
  String T = "";
  Future CheckUserConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        setState(() {
          ActiveConnection = true;
          T = "Turn off the data and repress again";
        });
      }
    } catch (Error) {
      // setState(() {
      ActiveConnection = false;
      T = "Turn On the data and repress again";
      // });
    }
  }

  @override
  void initState() {
    CheckUserConnection();
    getAsync();
    super.initState();
    // Future.delayed(Duration(seconds: 4), () {
    //   navigateUser(context);
    // });
  }


  Future<Null> faceBookLogin() async {
    setState(() {
      isload=false;
    });
    // Create an instance of FacebookLogin
    final fb = FacebookLogin();

// Log in
    final res = await fb.logIn(permissions: [
      FacebookPermission.publicProfile,
      FacebookPermission.email,
    ]);

// Check result status
    switch (res.status) {
      case FacebookLoginStatus.success:
      // Logged in
      // Send access token to server for validation and auth
        final FacebookAccessToken? accessToken = res.accessToken;
        print('Access token: ${accessToken?.token}');
        if(accessToken?.token?.isNotEmpty ?? false){
          FaceBookLoginMethod("${accessToken?.token}");
        }
        // Get profile data
        // final profile = await fb.getUserProfile();
        // print('Hello, ${profile?.name}! You ID: ${profile?.userId}');
        // // Get user profile image url
        // final imageUrl = await fb.getProfileImageUrl(width: 100);
        // print('Your profile image: $imageUrl');
        // // Get email (since we request email permission)
        // final email = await fb.getUserEmail();
        // // But user can decline permission
        // if (email != null)
        //   print('And your email is $email');
        //


        break;
      case FacebookLoginStatus.cancel:
      // User cancel log in
        break;
      case FacebookLoginStatus.error:
      // Log in failed
        print('Error while log in: ${res.error}');
        break;
    }
    setState(() {
      isload=true;
    });
  }



  final GoogleSignIn _googleSignIn = GoogleSignIn();

  bool isload=true;
  Future<void> _handleSignIn() async {
    setState(() {
      isload=false;
    });
    try {
      await _googleSignIn.signOut();
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if(googleUser != null) {
        // Successful sign-in
        // You can access the user's information through the `googleUser` object
        googleUser.authentication.then((googleKey){
          GoogleLoginMethod("${googleKey.idToken}");
          // print('accessToken: ${googleKey.accessToken}');
          // print('idToken: ${googleKey.idToken}');
          // print('displayName: ${_googleSignIn.currentUser?.displayName}');
        });
      }else {
        // Sign-in process canceled by the user
        print('Sign-in canceled');
      }
    }catch(error) {
      // Error occurred during sign-in
      print('Error signing in with Google: $error');
    }
    setState(() {
      isload=true;
    });
  }
  getAsync() async {
    try{
      _preferences = await SharedPreferences.getInstance();
      setState(() {

      });
    }catch (e) {
      print(e);
    }
  }
  SharedPreferences? _preferences;
  bool clickLoad=false;
  late OtpVerifyModel otpVerifyModel;
  Future<void> GoogleLoginMethod(String token) async {
    setState(() {
      clickLoad = true;
    });
    otpVerifyModel = await Services.GoogleCrdentials(token);
    if(otpVerifyModel.status == 1){
      _preferences?.setString(ShadiApp.userId,otpVerifyModel.data?.id ?? "");
      _preferences?.setBool(ShadiApp.status, true);
      // Toaster.show(context, otpVerifyModel.massege.toString());
      print("${otpVerifyModel.data!.profilePercentage}????");
      if(otpVerifyModel.data!.profilePercentage! >= 70){
        Navigator.of(context).pushNamed('Home');
      }else{
        Navigator.of(context).pushNamed('CountryCity');
      }
    }else{
      Toaster.show(context, otpVerifyModel.massege.toString());
    }
    setState(() {
      clickLoad = false;
    });
  }

  Future<void> FaceBookLoginMethod(String token) async {
    setState(() {
      clickLoad = true;
    });
    otpVerifyModel = await Services.FaceBookCrdentials(token);
    if(otpVerifyModel.status == 1){
      _preferences?.setString(ShadiApp.userId,otpVerifyModel.data?.id ?? "");
      _preferences?.setBool(ShadiApp.status, true);
      // Toaster.show(context, otpVerifyModel.massege.toString());
      print("${otpVerifyModel.data!.profilePercentage}????");
      if(otpVerifyModel.data!.profilePercentage! >= 70){
        Navigator.of(context).pushNamed('Home');
      }else{
        Navigator.of(context).pushNamed('CountryCity');
      }
    }else{
      Toaster.show(context, otpVerifyModel.massege.toString());
    }
    setState(() {
      clickLoad = false;
    });
  }



  final String cookie_policy = 'http://52.63.253.231:4000/cookie';
  final String pricacy_policy = 'http://52.63.253.231:4000/privacy';

  void _launchInBrowser(String nonSecureUrl) async {

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CommonWeb(url: nonSecureUrl),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CommonColors.themeblack,
      body: Center(

        child:  Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              alignment: Alignment.center,
              child: Image.asset(
                'assets/logo_name.png',
                height: 62,
                width: 215,
                fit: BoxFit.cover,
              ),
            ),
            new SizedBox(height: 110,),
            Column(
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 35),
                  child: ListTile(
                    visualDensity: VisualDensity(horizontal:0),
                    contentPadding: EdgeInsets.zero,
                    title: Transform.translate(
                      offset: const Offset(-18, 0),
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          children: <TextSpan>[
                            TextSpan(
                              text: "Before you login please read our privacy policy\nand find out how we handle your data.\nBy logging in you agree to our terms.",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                              ),),
                            TextSpan(
                              text: "\n",
                            ),
                            TextSpan(
                                text: "Privacy Policy",
                                style: TextStyle(
                                    color: Colors.blue,
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.w600),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    _launchInBrowser(pricacy_policy);
                                  }),
                            TextSpan(
                              text: " and ",
                            ),
                            TextSpan(
                                text: "Cookie Policy.",
                                style: TextStyle(
                                    color: Colors.blue,
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.w600),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    _launchInBrowser(cookie_policy);
                                  }),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                new Container(margin: const EdgeInsets.only(left: 70,right: 70,top: 5,bottom: 25),height: 1,color: Colors.white,)
              ],
            ),


            Container(
              height: 50,
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                const BorderRadius.all(Radius.circular(25)),
              ),
              child:
              Stack(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Container(
                          width: 27.0,
                          height: 27.0,
                          margin: const EdgeInsets.only(left: 20),
                          alignment: Alignment.centerLeft,
                          // decoration: BoxDecoration(
                          //   color: Colors.deepPurple,
                          //   borderRadius: BorderRadius.all(
                          //     Radius.circular(8.0),
                          //   ),
                          // ),
                          child: Align(
                              alignment: Alignment.center,
                              child: Image.asset("assets/google_ref.png"))),
                      Expanded(
                          child: Center(
                            child: Text("Sign in through Google", style: TextStyle(
                                color: CommonColors.themeblack, fontSize: 12,fontWeight: FontWeight.w600),),
                          )),
                      Container(
                        width: 27.0,
                        height: 27.0,
                        margin: const EdgeInsets.only(right: 20),
                        alignment: Alignment.centerLeft,
                      ),

                    ],
                  ),
                  SizedBox.expand(
                    child: Material(
                      type: MaterialType.transparency,
                      child: InkWell(onTap: () {
                        if(isload) {
                          _handleSignIn();
                        }
                      },splashColor: Colors.blue.withOpacity(0.2),
                        customBorder: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: 50,
              margin: const EdgeInsets.symmetric(horizontal: 20,vertical: 17),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                const BorderRadius.all(Radius.circular(25)),
              ),
              child: Stack(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Container(
                          width: 27.0,
                          height: 27.0,
                          margin: const EdgeInsets.only(left: 20),
                          alignment: Alignment.centerLeft,
                          // decoration: BoxDecoration(
                          //   color: Colors.deepPurple,
                          //   borderRadius: BorderRadius.all(
                          //     Radius.circular(8.0),
                          //   ),
                          // ),
                          child: Align(
                              alignment: Alignment.center,
                              child: Image.asset("assets/facebook_ref.png"))),
                      Expanded(
                          child: Center(
                            child: Text("Sign in through Facebook", style: TextStyle(
                                color: CommonColors.themeblack, fontSize: 12,fontWeight: FontWeight.w600),),
                          )),
                      Container(
                        width: 27.0,
                        height: 27.0,
                        margin: const EdgeInsets.only(right: 20),
                        alignment: Alignment.centerLeft,
                      ),

                    ],
                  ),
                  SizedBox.expand(
                    child: Material(
                      type: MaterialType.transparency,
                      child: InkWell(onTap: () {
                        if(isload) {
                          faceBookLogin();
                        }
                      },splashColor: Colors.blue.withOpacity(0.2),
                        customBorder: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                    ),
                  ),

                ],
              ),
            ),
            Container(
              height: 50,
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                const BorderRadius.all(Radius.circular(25)),
              ),
              child: Stack(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Container(
                          width: 27.0,
                          height: 27.0,
                          margin: const EdgeInsets.only(left: 20),
                          alignment: Alignment.centerLeft,
                          // decoration: BoxDecoration(
                          //   color: Colors.deepPurple,
                          //   borderRadius: BorderRadius.all(
                          //     Radius.circular(8.0),
                          //   ),
                          // ),
                          child: Align(
                              alignment: Alignment.center,
                              child: Image.asset("assets/phone_ref.png"))),
                      Expanded(
                          child: Center(
                            child: Text("Log in by phone number", style: TextStyle(
                                color: CommonColors.themeblack, fontSize: 12,fontWeight: FontWeight.w600),),
                          )),
                      Container(
                        width: 27.0,
                        height: 27.0,
                        margin: const EdgeInsets.only(right: 20),
                        alignment: Alignment.centerLeft,
                      ),

                    ],
                  ),
                  SizedBox.expand(
                    child: Material(
                      type: MaterialType.transparency,
                      child: InkWell(onTap: () {
                        Navigator.of(context).pushNamed('PhoneLogin');
                      },splashColor: Colors.blue.withOpacity(0.2),
                        customBorder: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        // InkWell(
        //   onTap: (){
        //     Navigator.of(context).pushNamed('ProblemAuth');
        //   },
        //   splashColor: CommonColors.themeblack,
        //   highlightColor: CommonColors.themeblack,
        //    child:
               Container(
              margin: const EdgeInsets.only(top: 20,bottom: 25),
              // child: Text(
              //   'Authorization problems?',
              //   style: TextStyle(
              //     color: Colors.white,
              //     fontSize: 15,
              //     fontWeight: FontWeight.w600,
              //   ),
              //   textAlign: TextAlign.center,
              // ),
            ),
        // )
          ],
        ),
      ),
    );
  }
}

