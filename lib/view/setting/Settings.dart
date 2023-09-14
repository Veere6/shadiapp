import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shadiapp/CommonMethod/CommonColors.dart';
import 'package:shadiapp/CommonMethod/Toaster.dart';
import 'package:shadiapp/Models/age_height_range_model.dart';
import 'package:shadiapp/Models/country_list_model.dart';
import 'package:shadiapp/Models/otpsend.dart';
import 'package:shadiapp/Models/update_setting_model.dart';
import 'package:shadiapp/Models/user_delete_model.dart';
import 'package:shadiapp/Models/user_detail_model.dart';
import 'package:shadiapp/Models/user_update_model.dart';
import 'package:shadiapp/Services/Services.dart';
import 'package:shadiapp/ShadiApp.dart';
import 'package:shadiapp/commonpackage/SearchChoices.dart';
import 'package:shadiapp/view/ChooseReg/ChooseReg.dart';
import 'package:shadiapp/view/commonWeb.dart';
import 'package:shadiapp/view/setting/verifyEmailPhone.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:collection/collection.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:share/share.dart';

class Settings extends StatefulWidget {
  @override
  State<Settings> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<Settings> {
  bool ActiveConnection = false;
  String T = "";
  late UserDetailModel _userDetailModel;
  late SharedPreferences _preferences;
  late AgeHeightRangeModel _rangeModel;
  late UserDeleteModel _userDeleteModel;
  late CountryListModel _countryListModel;
  String email = "";
  String phone = "";
  String profileimage = "";
  String profilename = "";
  int? minAge;
  int? maxAge;
  int? minHeight;
  int? maxHeight;
  bool isLoad = false;
  bool clickLoad = false;
  bool deleteLoad = false;
  String country = 'Select country';
  List<DropdownMenuItem> countryitems = [];

  List<String> countryList = [
    "Select country"
  ];

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

  String youarevalue = "";

  List<File?> imagelist = List.filled(6, null);

  bool GoGlobal = false;
  bool inrange = false;
  bool showme = false;
  bool dontshowme = false;
  bool incognito = false;
  bool isonline = false;
  bool isNotification = false;
  bool isEmail = false;
  bool isPushNotification = false;
  late RangeValues _currentRangeValues;
  late RangeValues _currentheightValues;
  bool isloaddetail=true;
  bool enablePhone=false;
  bool enableEmail=false;
  String user_plan="Free";
  Future<void> userDetail() async {
    setState(() {
      isLoad = true;
      isloaddetail=true;
    });
    _preferences = await SharedPreferences.getInstance();
    _userDetailModel = await Services.UserDetailMethod(
        "${_preferences?.getString(ShadiApp.userId)}");
     if (_userDetailModel.status == 1) {

      // phone = _userDetailModel.data![0].phone.toString();
       profileimage = _userDetailModel.data![0].image ?? "";
       profilename = "${_userDetailModel.data![0].firstName} ${_userDetailModel.data![0].lastName}";
      minAge = _userDetailModel.data![0].minAge;
      maxAge = _userDetailModel.data![0].maxAge;
      minHeight = _userDetailModel.data![0].minHeight;
      maxHeight = _userDetailModel.data![0].maxHeight;
      GoGlobal = _userDetailModel.data![0].goGlobel ?? false;
      inrange = _userDetailModel.data![0].showPeopleInRange ?? false;
      showme = _userDetailModel.data![0].isShowOnCard ?? false;
      incognito = _userDetailModel.data![0].goIncognito ?? false;
      isonline = _userDetailModel.data![0].isOnline ?? false;
       // _preferences.setBool(ShadiApp.isOnline, _userDetailModel.data?[0].isOnline ?? false);
      isEmail = _userDetailModel.data![0].isEmail ?? false;
      country = _userDetailModel.data![0].savecountry ?? "Select";
      user_plan = _userDetailModel.data![0].plan ?? "Free";
      isNotification = _userDetailModel.data![0].isPush ?? false;
      _controllerusername.text = _userDetailModel.data![0].username ?? "";
      _currentRangeValues =
          RangeValues(minAge?.toDouble() ?? 18, maxAge?.toDouble() ?? 30);
      _currentheightValues =
          RangeValues(minHeight?.toDouble() ?? 0, maxHeight?.toDouble() ?? 10);

      if(_userDetailModel.data![0].email!=" " && _userDetailModel.data![0].email!="" && _userDetailModel.data![0].email!="null"){
        _controlleremail.text = _userDetailModel.data![0].email.toString();
        enableEmail=false;
      }else{
        enableEmail=true;
      }
      if(_userDetailModel.data![0].phone!=" " &&_userDetailModel.data![0].phone!="" && _userDetailModel.data![0].phone!="null"){
        enablePhone=false;
        _controllerphone.text = _userDetailModel.data![0].phone.toString();
      }else{
        enablePhone=true;
      }
    }
    isLoad = false;

    setState(() {
      isloaddetail=false;
    });
  }

  Future<void> rangeSet() async {
    clickLoad = true;
    _preferences = await SharedPreferences.getInstance();
    _rangeModel = await Services.RangeSet(

        {
          "id": _preferences.getString(ShadiApp.userId).toString(),
          "minAge": _currentRangeValues.start.round().toString(),
          "maxAge": _currentRangeValues.end.round().toString(),
          "minHeight": _currentheightValues.start.round().toString(),
          "maxHeight": _currentheightValues.end.round().toString()
        });
    if (_rangeModel.status == 1) {
      Toaster.show(context, _rangeModel.message.toString());
    } else {
      Toaster.show(context, _rangeModel.message.toString());
    }
    clickLoad = false;
    setState(() {});
  }
  Future<void> ListCountry() async {
    isLoad = true;

    _countryListModel = await Services.CountryList();
    if (_countryListModel.status == true){

      for(var i = 0; i < _countryListModel.data!.length; i++){
        countryList.add(_countryListModel.data![i].name.toString());
        countryitems.add(DropdownMenuItem(
          value: _countryListModel.data![i].name.toString(),
          child: Text(_countryListModel.data![i].name.toString()),
        ));
      }
      // if(country!=""){
      //   ListCity(country);
      // }
      // country = _userDetailModel.data?[0].country ?? "Select country";
    }
    isLoad = false;
    if(mounted)
    setState(() {
    });
  }



  @override
  void initState() {
    ListCountry();
    userDetail();
    getCurrentLocation();
    CheckUserConnection();
    super.initState();
  }

  List<String> tags = [
    'travel',
    'foodie',
    'fitness',
    'photography',
    'nature',
    'fashion',
    'beauty',
    'health',
    'motivation',
    'entrepreneur',
    'pets',
    'music',
    'art',
    'books',
    'technology',
    'education',
    'cooking',
    'gaming',
    'humor',
    'sports',
    'finance',
    'selfcare',
    'parenting',
    'politics',
    'spirituality'
  ];

  List<int> selectedIndex = [];

  bool ischeck = false;
  // double value1 = minAge as double;
  TextEditingController _controllerusername = TextEditingController();
  TextEditingController _controlleremail = TextEditingController();
  TextEditingController _controllerphone = TextEditingController();

  void navigateUser(BuildContext context) async {
    SharedPreferences _preferences = await SharedPreferences.getInstance();
    _preferences.clear();
    Navigator.pushAndRemoveUntil(context,
        MaterialPageRoute(builder: (context) => ChooseReg()), (route) => false);
  }

  late UpdateUserModel _updateUserModel;
  late UpdateSettingModel _updateSettingModel;
  void Updateuser() async {
    _preferences = await SharedPreferences.getInstance();
    _updateSettingModel = await Services.updateSetting({
      "userId": "${_preferences?.getString(ShadiApp.userId)}",
      "is_online": isonline.toString(),
      "email": _controlleremail.text,
      "phone": _controllerphone.text,
      "goGlobel": GoGlobal.toString(),
      "go_incognito": incognito.toString(),
      "show_people_in_range": inrange.toString(),
      "is_showOnCard": showme.toString(),
      "is_push": isNotification.toString(),
      "is_email": isEmail.toString(),
      "username":_controllerusername.text,
      "save_country":country
    });
    if (_updateSettingModel.status == 1) {
      userDetail();
    }
  }

  bool click=false;
  void updateEmail()async{
    setState((){
      click=true;
    });
    _preferences = await SharedPreferences.getInstance();
    OtpSend otpSend = await Services.UpdateEmail("${_preferences?.getString(ShadiApp.userId)}",_controlleremail.text);
    if(otpSend.status == 1){
      Toaster.show(context, "${otpSend.message}");
      Navigator.of(context).push(
          MaterialPageRoute(
              builder: (context) => VerifyEmailPhone(otpSend.data.toString(),_controlleremail.text,"email")
          )
      );
    }else{
      Toaster.show(context, "${otpSend.message}");
    }
    setState((){
      click=false;
    });
  }
  void updatePhone()async{
    setState((){
      click=true;
    });
    _preferences = await SharedPreferences.getInstance();
    OtpSend otpSend = await Services.UpdatePhone("${_preferences?.getString(ShadiApp.userId)}",_controllerphone.text);
    if(otpSend.status == 1){
      Toaster.show(context, "${otpSend.massege}");
      Navigator.of(context).push(
          MaterialPageRoute(
              builder: (context) => VerifyEmailPhone(otpSend.data.toString(),_controllerphone.text,"phone")
          )
      );
    }else{
      Toaster.show(context, "${otpSend.massege}");
    }
    setState((){
      click=false;
    });
  }

  int usernamecheck=0;
  void Checkuser(String username) async {
    _preferences = await SharedPreferences.getInstance();
    _updateUserModel = await Services.CheckUpdateUser2({
      "id": "${_preferences?.getString(ShadiApp.userId)}",
      "username": username,
    });
    if (_updateUserModel.status == 1) {
      // userDetail();
      Toaster.show(context, _updateUserModel.message.toString());
      usernamecheck=1;
    } else {
      usernamecheck=0;
      Toaster.show(context, _updateUserModel.message.toString());
    }
    setState(() {});
  }

  void deleteUser() async {
    setState(() {
      deleteLoad = true;
    });
    _preferences = await SharedPreferences.getInstance();
    _userDeleteModel = await Services.DeleteUser(
        "${_preferences?.getString(ShadiApp.userId)}");
    if (_userDeleteModel.status == 1) {
      Toaster.show(context, _userDeleteModel.message.toString());
      navigateUser(context);
    } else {
      Toaster.show(context, _userDeleteModel.message.toString());
    }
    setState(() {
      deleteLoad = false;
    });
  }

  // void _launchURL(String url) async {
  //   if (await canLaunch(url)) {
  //     await launch(url);
  //   } else {
  //     throw 'Could not launch $url';
  //   }
  // }

  // final Uri cookie_policy = Uri(scheme: 'https', host: 'www.cylog.org', path: 'headers/');
  // final Uri pricacy_policy = Uri(scheme: 'https', host: 'http://52.63.253.231:4000/privacy', path: 'headers/');
  // final Uri pricacy_preferences = Uri(scheme: 'https', host: 'www.cylog.org', path: 'headers/');
  // final Uri term_services = Uri(scheme: 'https', host: 'http://52.63.253.231:4000/term_and_condition', path: 'headers/');

  final String cookie_policy = 'http://52.63.253.231:4000/cookie';
  final String pricacy_policy = 'http://52.63.253.231:4000/privacy';
  final String pricacy_preferences = 'http://52.63.253.231:4000/privacy_preference';
  final String term_services = 'http://52.63.253.231:4000/term_and_condition';
  // Future<void> _launchInBrowser(Uri url) async {
  //   if (!await launchUrl(
  //     url,
  //     // mode: LaunchMode.externalApplication,
  //   )) {
  //     throw Exception('Could not launch $url');
  //   }
  // }

  void _launchInBrowser(String nonSecureUrl) async {

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CommonWeb(url: nonSecureUrl),
      ),
    );

    // if (await canLaunch(nonSecureUrl)) {
    //   await launch(nonSecureUrl, forceSafariVC: false);
    // } else {
    //   throw 'Could not launch $nonSecureUrl';
    // }
  }


  void deleteDailog() {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => Dialog(
        child: Container(
          height: 300,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            SizedBox(height: 20,),
              Align(
                alignment: Alignment.center,
                child: SizedBox(
                  // alignment: Alignment.center,
                  width: 70,
                  height: 70,
                  // decoration: BoxDecoration(
                  //     color: Colors.black26
                  // ),
                  child: Icon(CupertinoIcons.delete,color: CommonColors.buttonorg,size: 70,)
                ),
              ),
              Align(
                alignment: Alignment.center,
                child: Container(
                  alignment: Alignment.center,
                  child: Text("Are you sure want to\ndelete this profile ?",style: TextStyle(color:CommonColors.buttonorg,fontSize: 18,fontWeight: FontWeight.w600),textAlign: TextAlign.center,),
                ),
              ),
              SizedBox(height: 20,),
              InkWell(
                onTap: (){
                  deleteUser();
                  Navigator.pop(context);
                },
                child: Container(
                  height: 50,
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: CommonColors.buttonorg,
                    borderRadius:
                    const BorderRadius.all(Radius.circular(25)),
                  ),
                  child: Center(
                    child: Text(
                      "YES",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10,),
              InkWell(
                onTap: (){
                  Navigator.pop(context);
                },
                child: Container(
                  height: 50,
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: CommonColors.buttonorg,
                    borderRadius:
                    const BorderRadius.all(Radius.circular(25)),
                  ),
                  child: Center(
                    child: Text(
                      "NO",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      )
    );
  }

  String placeName = "";

  void getCurrentLocation() async{
    Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.best,
    ).then((Position position) async {
      // Retrieve the latitude and longitude from the 'position' object.
      double latitude = position.latitude;
      double longitude = position.longitude;
      // Use geocoding to get the place name from the coordinates.
      List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
      Placemark placemark = placemarks.first;
      // Retrieve the place name from the 'placemark' object.
      placeName = placemark.country.toString();
      // print("ashfkjdgsdhf $placeName");
    }).catchError((e) {
      // print("objectjhgfdgsfxfcvgb $e");
      // Handle any errors that occur during location fetching or geocoding.
    });
  }



  void openEmailMessage() async {
    final Uri _emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'shaadiapp23@gmail.com', // Replace with the recipient's email address
      queryParameters: {
        'subject': 'Subject', // Replace with the desired email subject
        'body': '', // Replace with the email body
      },
    );
    if (!await launchUrl(
      _emailLaunchUri,
      mode: LaunchMode.externalApplication,
    )){
      throw Exception('Could not launch $_emailLaunchUri');
    }
  }

  // Future<void> _launchInBrowser(Uri url) async {
  //   if (!await launchUrl(
  //     url,
  //     // mode: LaunchMode.externalApplication,
  //   )) {
  //     throw Exception('Could not launch $url');
  //   }
  // }



  void shareApp() {

    String androidAppLink = "https://play.google.com/store/apps/details?id=com.shaadi.app"; // Replace with your Android app link.
    String iosAppLink = "https://apps.apple.com/us/app/your-app-name/id1234567890"; // Replace with your iOS app link.

    String message = "Check out our app:\n";

    if (Theme.of(context).platform == TargetPlatform.android) {
      message += androidAppLink;
    } else if (Theme.of(context).platform == TargetPlatform.iOS) {
      message += iosAppLink;
    } else {
      // For other platforms, just include a generic message.
      message += "Download on your app store!";
    }

    Share.share(message);
  }


  Future<void> _launchSocialMediaAppIfInstalled({
    required String url,
  }) async {
    try {
      bool launched = await launch(url, forceSafariVC: false); // Launch the app if installed!

      if (!launched) {
        launch(url); // Launch web view if app is not installed!
      }
    } catch (e) {
      launch(url); // Launch web view if app is not installed!
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CommonColors.themeblack,
      body: isLoad
          ? Center(
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 3.0,
              ),
            )
          : SingleChildScrollView(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  // crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    new SizedBox(
                      height: MediaQuery.of(context).padding.top + 10,
                    ),
                    Row(
                      children: [
                        Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 0),
                          alignment: Alignment.centerLeft,
                          child: InkWell(
                            onTap: () {
                              Navigator.of(context).pop();
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Image.asset(
                                'assets/back_icon.png',
                              ),
                            ),
                          ),
                        ),
                        new Spacer(),
                        new Text(
                          "Settings",
                          style: new TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white),
                        ),
                        new Spacer(),
                        Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 0),
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                          ),
                        ),
                      ],
                    ),
                    new SizedBox(
                      height: 40,
                    ),
                    // Container(
                    //   alignment: Alignment.centerLeft,
                    //   margin: const EdgeInsets.only(left: 20, right: 20),
                    //   decoration: BoxDecoration(
                    //       color: CommonColors.settingblue,
                    //       borderRadius: BorderRadius.all(Radius.circular(5))),
                    //   padding: const EdgeInsets.only(top: 10, bottom: 15),
                    //   child: Column(
                    //     children: [
                    //       new Row(
                    //         mainAxisAlignment: MainAxisAlignment.center,
                    //         crossAxisAlignment: CrossAxisAlignment.center,
                    //         children: [
                    //           new Container(
                    //             child: new Text(
                    //               "Shaadi-App",
                    //               style: new TextStyle(
                    //                   fontSize: 16,
                    //                   fontWeight: FontWeight.w600,
                    //                   color: Colors.white),
                    //             ),
                    //           ),
                    //           new SizedBox(
                    //             width: 13,
                    //           ),
                    //           Container(
                    //               decoration: BoxDecoration(
                    //                 color: CommonColors.themeblack,
                    //                 borderRadius: BorderRadius.circular(65),
                    //               ),
                    //               // padding: const EdgeInsets.symmetric(horizontal: 23,vertical: 4),
                    //               alignment: Alignment.center,
                    //               width: 69,
                    //               height: 26,
                    //               child: Row(
                    //                 mainAxisSize: MainAxisSize.min,
                    //                 children: [
                    //                   Text(
                    //                     "Free",
                    //                     style: new TextStyle(
                    //                         fontSize: 11,
                    //                         fontWeight: FontWeight.w600,
                    //                         color: Colors.white),
                    //                   ),
                    //                 ],
                    //               )),
                    //         ],
                    //       ),
                    //       new SizedBox(
                    //         height: 12,
                    //       ),
                    //       new Container(
                    //         child: new Text(
                    //           "Priority Likes, see who likes you and more",
                    //           style: new TextStyle(
                    //               fontSize: 14,
                    //               fontWeight: FontWeight.w400,
                    //               color: Colors.white),
                    //         ),
                    //       ),
                    //     ],
                    //   ),
                    // ),
                    // Container(
                    //   alignment: Alignment.centerLeft,
                    //   margin: const EdgeInsets.only(left: 20, right: 20),
                    //   decoration: BoxDecoration(
                    //       color: CommonColors.bluepro,
                    //       borderRadius: BorderRadius.all(Radius.circular(5))),
                    //   padding: const EdgeInsets.only(top: 10, bottom: 15),
                    //   child: Column(
                    //     children: [
                    //       new Row(
                    //         mainAxisAlignment: MainAxisAlignment.center,
                    //         crossAxisAlignment: CrossAxisAlignment.center,
                    //         children: [
                    //           new Container(
                    //             child: new Text(
                    //               "Shaadi-App",
                    //               style: new TextStyle(
                    //                   fontSize: 16,
                    //                   fontWeight: FontWeight.w600,
                    //                   color: Colors.white),
                    //             ),
                    //           ),
                    //           new SizedBox(
                    //             width: 13,
                    //           ),
                    //           Container(
                    //               decoration: BoxDecoration(
                    //                 color: CommonColors.white,
                    //                 borderRadius: BorderRadius.circular(65),
                    //               ),
                    //               // padding: const EdgeInsets.symmetric(horizontal: 23,vertical: 4),
                    //               alignment: Alignment.center,
                    //               width: 69,
                    //               height: 26,
                    //               child: Row(
                    //                 mainAxisSize: MainAxisSize.min,
                    //                 children: [
                    //                   Text(
                    //                     "Premium",
                    //                     style: new TextStyle(
                    //                         fontSize: 11,
                    //                         fontWeight: FontWeight.w600,
                    //                         color: CommonColors.bluepro),
                    //                   ),
                    //                 ],
                    //               )),
                    //         ],
                    //       ),
                    //       new SizedBox(
                    //         height: 12,
                    //       ),
                    //       new Container(
                    //         child: new Text(
                    //           "Priority Likes, see who likes you and more",
                    //           style: new TextStyle(
                    //               fontSize: 14,
                    //               fontWeight: FontWeight.w400,
                    //               color: Colors.white.withOpacity(0.6)),
                    //         ),
                    //       ),
                    //     ],
                    //   ),
                    // ),
                    // Container(
                    //   alignment: Alignment.centerLeft,
                    //   margin: const EdgeInsets.only(left: 20, right: 20),
                    //   decoration: BoxDecoration(
                    //       color: CommonColors.yellow,
                    //       borderRadius: BorderRadius.all(Radius.circular(5))),
                    //   padding: const EdgeInsets.only(top: 10, bottom: 15),
                    //   child: Column(
                    //     children: [
                    //       new Row(
                    //         mainAxisAlignment: MainAxisAlignment.center,
                    //         crossAxisAlignment: CrossAxisAlignment.center,
                    //         children: [
                    //           new Container(
                    //             child: new Text(
                    //               "Shaadi-App",
                    //               style: new TextStyle(
                    //                   fontSize: 16,
                    //                   fontWeight: FontWeight.w600,
                    //                   color: Colors.black),
                    //             ),
                    //           ),
                    //           new SizedBox(
                    //             width: 13,
                    //           ),
                    //           Container(
                    //               decoration: BoxDecoration(
                    //                 color: CommonColors.white,
                    //                 borderRadius: BorderRadius.circular(65),
                    //               ),
                    //               // padding: const EdgeInsets.symmetric(horizontal: 23,vertical: 4),
                    //               alignment: Alignment.center,
                    //               width: 69,
                    //               height: 26,
                    //               child: Row(
                    //                 mainAxisSize: MainAxisSize.min,
                    //                 children: [
                    //                   Text(
                    //                     "Gold",
                    //                     style: new TextStyle(
                    //                         fontSize: 11,
                    //                         fontWeight: FontWeight.w600,
                    //                         color: Colors.black),
                    //                   ),
                    //                 ],
                    //               )),
                    //         ],
                    //       ),
                    //       new SizedBox(
                    //         height: 12,
                    //       ),
                    //       new Container(
                    //         child: new Text(
                    //           "Priority Likes, see who likes you and more",
                    //           style: new TextStyle(
                    //               fontSize: 14,
                    //               fontWeight: FontWeight.w400,
                    //               color: Colors.black.withOpacity(0.6)),
                    //         ),
                    //       ),
                    //     ],
                    //   ),
                    // ),
                    // Container(
                    //   alignment: Alignment.centerLeft,
                    //   margin: const EdgeInsets.only(left: 20, right: 20),
                    //   decoration: BoxDecoration(
                    //       color: CommonColors.buttonorg,
                    //       borderRadius: BorderRadius.all(Radius.circular(5))),
                    //   padding: const EdgeInsets.only(top: 10, bottom: 15),
                    //   child: Column(
                    //     children: [
                    //       new Row(
                    //         mainAxisAlignment: MainAxisAlignment.center,
                    //         crossAxisAlignment: CrossAxisAlignment.center,
                    //         children: [
                    //           new Container(
                    //             child: new Text(
                    //               "Shaadi-App",
                    //               style: new TextStyle(
                    //                   fontSize: 16,
                    //                   fontWeight: FontWeight.w600,
                    //                   color: Colors.white),
                    //             ),
                    //           ),
                    //           new SizedBox(
                    //             width: 13,
                    //           ),
                    //           Container(
                    //               decoration: BoxDecoration(
                    //                 color: CommonColors.white,
                    //                 borderRadius: BorderRadius.circular(65),
                    //               ),
                    //               // padding: const EdgeInsets.symmetric(horizontal: 23,vertical: 0),
                    //               alignment: Alignment.center,
                    //               width: 69,
                    //               height: 26,
                    //               child: Row(
                    //                 mainAxisSize: MainAxisSize.min,
                    //                 children: [
                    //                   Text(
                    //                     "VIP",
                    //                     style: new TextStyle(
                    //                         fontSize: 11,
                    //                         fontWeight: FontWeight.w600,
                    //                         color: Colors.black),
                    //                   ),
                    //                 ],
                    //               )),
                    //         ],
                    //       ),
                    //       new SizedBox(
                    //         height: 12,
                    //       ),
                    //       new Container(
                    //         child: new Text(
                    //           "Priority Likes, see who likes you and more",
                    //           style: new TextStyle(
                    //               fontSize: 14,
                    //               fontWeight: FontWeight.w400,
                    //               color: Colors.white.withOpacity(0.6)),
                    //         ),
                    //       ),
                    //     ],
                    //   ),
                    // ),
                    // new SizedBox(
                    //   height: 100,
                    // ),
                    new Container(
                      margin: const EdgeInsets.only(left: 20, right: 20),
                      alignment: Alignment.centerLeft,
                      child: new Text(
                        "Account Settings",
                        style: new TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white),
                      ),
                    ),
                    new SizedBox(
                      height: 25,
                    ),
                    new Container(height:50,
                      margin: const EdgeInsets.only(left: 20, right: 20),
                      decoration: BoxDecoration(
                          color: CommonColors.editblack,
                          borderRadius: BorderRadius.circular(37)),
                      padding: const EdgeInsets.symmetric(
                          vertical: 5, horizontal: 20),
                      child: Row(
                        children: [
                          // new SizedBox(width: 20,),
                          new Container(
                            child: new Text(
                              "Phone Number",
                              style: new TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: CommonColors.edittextblack),
                            ),
                          ),
                          // Spacer(),
                          new SizedBox(width: 20,),
                          new Expanded(
                            child: Container(
                              // margin: const EdgeInsets.only(top: 10),
                              // height: 30,
                              // width:600,
                              alignment:Alignment.bottomCenter,
                              child: TextFormField(
                                enabled: enablePhone,
                                textAlign: TextAlign.end,
                                // textAlignVertical: TextAlignVertical.bottom,
                                keyboardType: TextInputType.name,
                                textInputAction: TextInputAction.done,
                                controller: _controllerphone,
                                decoration: InputDecoration(
                                  hintText: 'Phone',
                                  border: InputBorder.none,
                                  hintStyle: new TextStyle(
                                      color: Colors.white.withOpacity(0.6),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400),
                                ),
                                onChanged: (text){
                                  setState(() {
                                  });
                                },
                                style: new TextStyle(color: Colors.white, fontSize: 14),
                              ),
                            ),
                          ),
                         if(_controllerphone.text.isEmpty || enablePhone==true) InkWell(
                            onTap: (){
                              if(!click) {
                                updatePhone();
                              }
                            },
                              child: Icon(Icons.done)
                          )
                        ],
                      ),
                    ),
                    new SizedBox(
                      height: 20,
                    ),
                    new Container(
                      height:50,
                      width: MediaQuery.of(context).size.width,
                      margin: const EdgeInsets.only(left: 20, right: 20),
                      decoration: BoxDecoration(
                          color: CommonColors.editblack,
                          borderRadius: BorderRadius.circular(37)),
                      padding: const EdgeInsets.symmetric(
                          vertical: 5, horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // new SizedBox(width: 20,),
                          new Container(
                            child: new Text(
                              "Email",
                              style: new TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: CommonColors.edittextblack),
                            ),
                          ),
                          // Spacer(),
                          SizedBox(width:20),
                          new Expanded(
                            child: Container(
                              // margin: const EdgeInsets.only(top: 10),
                              // height: 30,
                              // width:600,
                              alignment:Alignment.bottomCenter,
                              child: TextFormField(
                                enabled: enableEmail,
                                textAlign: TextAlign.end,
                                // textAlignVertical: TextAlignVertical.bottom,
                                keyboardType: TextInputType.name,
                                textInputAction: TextInputAction.done,
                                controller: _controlleremail,
                                decoration: InputDecoration(
                                  hintText: 'Email',
                                  border: InputBorder.none,
                                  hintStyle: new TextStyle(
                                      color: Colors.white.withOpacity(0.6),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400),
                                ),
                                style: new TextStyle(color: Colors.white, fontSize: 14),
                                onChanged: (text){
                                  setState((){});
                                },
                              ),
                            ),
                          ),

                          if(_controlleremail.text.isEmpty || enableEmail==true)
                            InkWell(
                              onTap: (){
                                if(!click) {
                                  updateEmail();
                                }
                              },
                              child: Icon(Icons.done)
                            )
                          // new SizedBox(width: 20,),
                        ],
                      ),
                    ),
                    // new SizedBox(
                    //   height: 20,
                    // ),
                    // new Container(
                    //   height:50,
                    //   width: MediaQuery.of(context).size.width,
                    //   margin: const EdgeInsets.only(left: 20, right: 20),
                    //   decoration: BoxDecoration(
                    //       color: CommonColors.editblack,
                    //       borderRadius: BorderRadius.circular(37)),
                    //   padding: const EdgeInsets.symmetric(
                    //       vertical: 5, horizontal: 20),
                    //   child: Row(
                    //     mainAxisAlignment: MainAxisAlignment.center,
                    //     crossAxisAlignment: CrossAxisAlignment.center,
                    //     children: [
                    //       // new SizedBox(width: 20,),
                    //       new Container(
                    //         child: new Text(
                    //           "Email",
                    //           style: new TextStyle(
                    //               fontSize: 14,
                    //               fontWeight: FontWeight.w400,
                    //               color: CommonColors.edittextblack),
                    //         ),
                    //       ),
                    //       Spacer(),
                    //       // SizedBox(width:20),
                    //       new Expanded(
                    //         child: Container(
                    //           margin: const EdgeInsets.only(top: 10),
                    //           height: 30,
                    //           // width:600,
                    //           alignment:Alignment.bottomCenter,
                    //           child: TextFormField(
                    //             enabled: enableEmail,
                    //             textAlign: TextAlign.end,
                    //             textAlignVertical: TextAlignVertical.bottom,
                    //             keyboardType: TextInputType.name,
                    //             textInputAction: TextInputAction.done,
                    //             controller: _controlleremail,
                    //             decoration: InputDecoration(
                    //               hintText: 'Email',
                    //               border: InputBorder.none,
                    //               hintStyle: new TextStyle(
                    //                   color: Colors.white.withOpacity(0.6),
                    //                   fontSize: 14,
                    //                   fontWeight: FontWeight.w400),
                    //             ),
                    //             style: new TextStyle(color: Colors.white, fontSize: 14),
                    //             onChanged: (text){
                    //               setState((){});
                    //             },
                    //           ),
                    //         ),
                    //       ),
                    //
                    //       if(_controlleremail.text.isEmpty || enableEmail==true)  InkWell(
                    //           onTap: (){
                    //             updateEmail();
                    //           },
                    //           child: Icon(Icons.done)
                    //       )
                    //       // new SizedBox(width: 20,),
                    //     ],
                    //   ),
                    // ),
                    new Container(
                      margin:
                          const EdgeInsets.only(left: 30, right: 30, top: 10),
                      alignment: Alignment.centerLeft,
                      child: new Text(
                        "Verify your phone number and email to help secure your account.",
                        style: new TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Colors.white.withOpacity(0.6)),
                      ),
                    ),
                    // new SizedBox(
                    //   height: 50,
                    // ),
                    // new Container(
                    //   margin: const EdgeInsets.only(left: 20, right: 20),
                    //   decoration: BoxDecoration(
                    //       color: CommonColors.editblack,
                    //       borderRadius: BorderRadius.circular(37)),
                    //   padding: const EdgeInsets.symmetric(
                    //       vertical: 15, horizontal: 20),
                    //   child: Row(
                    //     children: [
                    //       // new SizedBox(width: 20,),
                    //       new Container(
                    //         child: new Text(
                    //           "Restore Account",
                    //           style: new TextStyle(
                    //               fontSize: 14,
                    //               fontWeight: FontWeight.w400,
                    //               color: CommonColors.edittextblack),
                    //         ),
                    //       ),
                    //       Spacer(),
                    //       new Container(
                    //           child: Icon(
                    //         Icons.arrow_forward_ios,
                    //         color: CommonColors.edittextblack,
                    //         size: 20,
                    //       )),
                    //       // new SizedBox(width: 20,),
                    //     ],
                    //   ),
                    // ),
                    new SizedBox(
                      height: 50,
                    ),
                    new Container(
                      margin: const EdgeInsets.only(left: 20, right: 20),
                      alignment: Alignment.centerLeft,
                      child: new Text(
                        "Search Settings",
                        style: new TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white),
                      ),
                    ),
                    new SizedBox(
                      height: 40,
                    ),
                    new Container(
                      margin: const EdgeInsets.only(left: 20, right: 20),
                      decoration: BoxDecoration(
                          color: CommonColors.blueloc,
                          borderRadius: BorderRadius.circular(17)),
                      padding: const EdgeInsets.symmetric(
                          vertical: 24, horizontal: 30),
                      child: Column(
                        children: [
                          // new SizedBox(width: 20,),
                          new Container(
                            alignment: Alignment.centerLeft,
                            child: new Text(
                              "Location",
                              style: new TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: CommonColors.edittextblack),
                            ),
                          ),
                          new SizedBox(
                            height: 20,
                          ),
                          Row(
                            children: [
                              new Container(
                                  child: SizedBox(
                                height: 24,
                                width: 24,
                                child: Image.asset("assets/s_location.png"),
                              )),
                              new SizedBox(
                                width: 10,
                              ),
                              new Container(
                                      child: new Text(
                                        placeName,
                                        style: new TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w400,
                                            color: CommonColors.edittextblack),
                                      ),
                                    ),
                            ],
                          ),
                          // new SizedBox(width: 20,),
                        ],
                      ),
                    ),
                    new SizedBox(
                      height: 25,
                    ),
                    new Container(
                      margin: const EdgeInsets.only(left: 20, right: 20),
                      decoration: BoxDecoration(
                          color: CommonColors.editblack,
                          borderRadius: BorderRadius.circular(37)),
                      padding: const EdgeInsets.symmetric(
                          vertical: 0, horizontal: 20),
                      child: SearchChoices.single(
                        items: countryitems,
                        value: country,
                        hint: "Select",
                        // disabledHint: "Disabled",
                        searchHint: "Select country",
                        style: TextStyle(color: Colors.white),
                        underline: Container(),
                        onChanged: (value) {
                          setState(() {
                            country = value;
                          });
                        },
                        displayClearIcon: false,
                        isExpanded: true,
                      ),
                      // Row(
                      //   children: [
                      //     // new SizedBox(width: 20,),
                      //
                      //     // new Container(
                      //     //   child: new Text(
                      //     //     "Select",
                      //     //     style: new TextStyle(
                      //     //         fontSize: 14,
                      //     //         fontWeight: FontWeight.w400,
                      //     //         color: CommonColors.edittextblack),
                      //     //   ),
                      //     // ),
                      //     Spacer(),
                      //     new Container(
                      //         child: Icon(
                      //       Icons.arrow_forward_ios,
                      //       color: CommonColors.edittextblack,
                      //       size: 20,
                      //     )),
                      //     // new SizedBox(width: 20,),
                      //   ],
                      // ),
                    ),
                    new Container(
                      margin:
                          const EdgeInsets.only(left: 30, right: 30, top: 10),
                      alignment: Alignment.centerLeft,
                      child: new Text(
                        "Change your location to see matches worldwide",
                        style: new TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w400,
                            color: Colors.white.withOpacity(0.6)),
                      ),
                    ),
                    new SizedBox(
                      height: 21,
                    ),
                    Container(
                      height: 50.0,
                      margin: const EdgeInsets.only(left: 20, right: 20),
                      decoration: BoxDecoration(
                          color: CommonColors.editblack,
                          borderRadius: BorderRadius.circular(37)),
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 20),
                      child: Row(
                        children: [
                          // new SizedBox(width: 20,),
                          new Container(
                            child: new Text(
                              "GoGlobal",
                              style: new TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                  color: CommonColors.edittextblack),
                            ),
                          ),
                          Spacer(),
                          Transform.scale(
                            scale: 0.8,
                            child: CupertinoSwitch(
                              value: GoGlobal,
                              onChanged: (value) {
                                GoGlobal = value;
                                setState(() {});

                              },
                              thumbColor: GoGlobal ? CommonColors.buttonorg:CupertinoColors.black,
                              activeColor: CupertinoColors.white,
                              trackColor: CupertinoColors.white,
                            ),
                          ),
                          // new SizedBox(width: 20,),
                        ],
                      ),
                    ),
                    new Container(
                      margin:
                          const EdgeInsets.only(left: 30, right: 30, top: 10),
                      alignment: Alignment.centerLeft,
                      child: new Text(
                        "Going global will allow you to see matches from around the world.",
                        style: new TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w400,
                            color: Colors.white.withOpacity(0.6)),
                      ),
                    ),
                    new SizedBox(
                      height: 15,
                    ),
                    Container(
                      margin: const EdgeInsets.only(left: 20, right: 20),
                      decoration: BoxDecoration(
                          color: CommonColors.editblack,
                          borderRadius: BorderRadius.circular(17)),
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 20),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              // new SizedBox(width: 20,),
                              new Container(
                                child: new Text(
                                  "Age range",
                                  style: new TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400,
                                      color: CommonColors.edittextblack),
                                ),
                              ),
                              Spacer(),
                              new Container(
                                child: new Text(
                                  isloaddetail ? "0 - 0":"${_currentRangeValues.start.round().toString()} - ${_currentRangeValues.end.round().toString()}",
                                  style: new TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400,
                                      color: CommonColors.edittextblack),
                                ),
                              ),
                              // new SizedBox(width: 20,),
                            ],
                          ),
                          if(isloaddetail==false)  Row(
                            children: [
                              Expanded(
                                child: RangeSlider(
                                  values: _currentRangeValues,
                                  max: 100,
                                  min: 18,
                                  divisions: 100,
                                  inactiveColor: CommonColors.white,
                                  activeColor: CommonColors.blueloc,
                                  labels: RangeLabels(
                                    _currentRangeValues.start
                                        .round()
                                        .toString(),
                                    _currentRangeValues.end.round().toString(),
                                  ),
                                  onChanged: (RangeValues values) {
                                    setState(() {
                                      _currentRangeValues = values;
                                    });
                                  },
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                    new SizedBox(
                      height: 28,
                    ),
                    Container(
                      height: 50.0,
                      margin: const EdgeInsets.only(left: 20, right: 20),
                      decoration: BoxDecoration(
                          color: CommonColors.editblack,
                          borderRadius: BorderRadius.circular(37)),
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 20),
                      child: Row(
                        children: [
                          // new SizedBox(width: 20,),
                          new Expanded(
                            child: new Text(
                              "Only show people in this range",
                              style: new TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                  color: CommonColors.edittextblack),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Transform.scale(
                            scale: 0.8,
                            child: CupertinoSwitch(
                              value: inrange,
                              onChanged: (value) {
                                inrange = value;
                                setState(() {});
                              },
                              thumbColor:  inrange ? CommonColors.buttonorg:CupertinoColors.black,
                              activeColor: CupertinoColors.white,
                              trackColor: CupertinoColors.white,
                            ),
                          ),
                          // new SizedBox(width: 20,),
                        ],
                      ),
                    ),
                    new SizedBox(
                      height: 15,
                    ),
                    Container(
                      margin: const EdgeInsets.only(left: 20, right: 20),
                      decoration: BoxDecoration(
                          color: CommonColors.editblack,
                          borderRadius: BorderRadius.circular(17)),
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 20),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              // new SizedBox(width: 20,),
                              new Container(
                                child: new Text(
                                  "Height range",
                                  style: new TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400,
                                      color: CommonColors.edittextblack),
                                ),
                              ),
                              Spacer(),
                              new Container(
                                child: new Text(
                               isloaddetail ? "0-0" :"${_currentheightValues.start.toString().replaceAll(".", "'")} - ${_currentheightValues.end.toString().replaceAll(".", "'")}",
                                  style: new TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400,
                                      color: CommonColors.edittextblack),
                                ),
                              ),
                              // new SizedBox(width: 20,),
                            ],
                          ),
                          if(isloaddetail==false) Row(
                            children: [
                              Expanded(
                                child: RangeSlider(
                                  values: _currentheightValues,
                                  max: 10,
                                  min: 0,
                                  divisions: 10,
                                  inactiveColor: CommonColors.white,
                                  activeColor: CommonColors.blueloc,
                                  labels: RangeLabels(
                                    _currentheightValues.start
                                        .toString()
                                        .replaceAll(".", "'"),
                                    _currentheightValues.end
                                        .toString()
                                        .replaceAll(".", "'"),
                                  ),
                                  onChanged: (RangeValues values) {
                                    setState(() {
                                      _currentheightValues = values;
                                    });
                                  },
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                    new SizedBox(
                      height: 32,
                    ),
                    new Container(
                      margin: const EdgeInsets.only(left: 20, right: 20),
                      alignment: Alignment.centerLeft,
                      child: new Text(
                        "My visibility",
                        style: new TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white),
                      ),
                    ),
                    new SizedBox(
                      height: 22,
                    ),
                    new Container(
                      margin: const EdgeInsets.only(left: 37, right: 37),
                      // decoration: BoxDecoration(
                      //     color: CommonColors.editblack,
                      //     borderRadius: BorderRadius.circular(37)
                      // ),
                      // padding: const EdgeInsets.symmetric(vertical: 15,horizontal: 20),
                      child: Row(
                        children: [
                          // new SizedBox(width: 20,),
                          new Container(
                            child: new Text(
                              "Show me on Shaadi-App",
                              style: new TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: CommonColors.edittextblack),
                            ),
                          ),
                          Spacer(),
                          showme
                              ? InkWell(
                                  onTap: () {
                                    setState(() {
                                      showme = false;
                                    });
                                  },
                                  child: new Container(
                                    height: 20,
                                    width: 20,
                                    decoration: BoxDecoration(
                                        color: CommonColors.blueloc,
                                        borderRadius: BorderRadius.circular(3)),
                                    child: Icon(
                                      Icons.check,
                                      size: 20,
                                      color: Colors.white,
                                    ),
                                  ),
                                )
                              : InkWell(
                                  onTap: () {
                                    setState(() {
                                      showme = true;
                                    });
                                  },
                                  child: new Container(
                                    height: 20,
                                    width: 20,
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(3)),
                                  ),
                                )
                          // new SizedBox(width: 20,),
                        ],
                      ),
                    ),
                    new Container(
                      margin:
                          const EdgeInsets.only(left: 37, right: 37, top: 10),
                      alignment: Alignment.centerLeft,
                      child: new Text(
                        "Your profile will be seen in the card stack",
                        style: new TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Colors.white.withOpacity(0.6)),
                      ),
                    ),
                    new Container(
                      height: 1,
                      color: Colors.white,
                      width: MediaQuery.of(context).size.width,
                      margin:
                          const EdgeInsets.only(left: 37, right: 37, top: 15),
                    ),
                    new Container(
                      margin:
                          const EdgeInsets.only(left: 37, right: 37, top: 20),
                      // decoration: BoxDecoration(
                      //     color: CommonColors.editblack,
                      //     borderRadius: BorderRadius.circular(37)
                      // ),
                      // padding: const EdgeInsets.symmetric(vertical: 15,horizontal: 20),
                      child: Row(
                        children: [
                          // new SizedBox(width: 20,),
                          new Container(
                            child: new Text(
                              "Go Incognito",
                              style: new TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: CommonColors.edittextblack),
                            ),
                          ),
                          Spacer(),
                          incognito
                              ? InkWell(
                                  onTap: () {

                                    setState(() {
                                      incognito = false;
                                    });
                                  },
                                  child: new Container(
                                    height: 20,
                                    width: 20,
                                    decoration: BoxDecoration(
                                        color: CommonColors.blueloc,
                                        borderRadius: BorderRadius.circular(3)),
                                    child: Icon(
                                      Icons.check,
                                      size: 20,
                                      color: Colors.white,
                                    ),
                                  ),
                                )
                              : InkWell(
                                  onTap: () {
                                    setState(() {
                                      incognito = true;
                                    });
                                  },
                                  child: new Container(
                                    height: 20,
                                    width: 20,
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(3)),
                                  ),
                                )
                          // new SizedBox(width: 20,),
                        ],
                      ),
                    ),
                    new Container(
                      margin:
                          const EdgeInsets.only(left: 37, right: 37, top: 10),
                      alignment: Alignment.centerLeft,
                      child: new Text(
                        "You will only be seen by people you like",
                        style: new TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Colors.white.withOpacity(0.6)),
                      ),
                    ),
                    Container(
                      margin:
                          const EdgeInsets.only(left: 37, right: 37, top: 20),
                      alignment: Alignment.centerLeft,
                      child: new SizedBox(
                        height: 24,
                        width: 27,
                        child: Image.asset("assets/not_eye.png",
                            height: 24, width: 27),
                      ),
                    ),
                    new Container(
                      margin:
                          const EdgeInsets.only(left: 37, right: 37, top: 20),
                      // decoration: BoxDecoration(
                      //     color: CommonColors.editblack,
                      //     borderRadius: BorderRadius.circular(37)
                      // ),
                      // padding: const EdgeInsets.symmetric(vertical: 15,horizontal: 20),
                      child: Row(
                        children: [
                          // new SizedBox(width: 20,),
                          new Container(
                            child: new Text(
                              "Don’t show me on Shaadi-App",
                              style: new TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: CommonColors.edittextblack),
                            ),
                          ),
                          Spacer(),
                          showme == false
                              ? InkWell(
                                  onTap: () {
                                    setState(() {
                                      showme = true;
                                    });
                                  },
                                  child: new Container(
                                    height: 20,
                                    width: 20,
                                    decoration: BoxDecoration(
                                        color: CommonColors.blueloc,
                                        borderRadius: BorderRadius.circular(3)),
                                    child: Icon(
                                      Icons.check,
                                      size: 20,
                                      color: Colors.white,
                                    ),
                                  ),
                                )
                              : InkWell(
                                  onTap: () {
                                    setState(() {
                                      showme = false;
                                    });
                                  },
                                  child: new Container(
                                    height: 20,
                                    width: 20,
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(3)),
                                  ),
                                )
                          // new SizedBox(width: 20,),
                        ],
                      ),
                    ),
                    new Container(
                      margin:
                          const EdgeInsets.only(left: 37, right: 37, top: 10),
                      alignment: Alignment.centerLeft,
                      child: new Text(
                        "Your profile won’t be shown in the card stack. You can still be seen by your matches",
                        style: new TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Colors.white.withOpacity(0.6)),
                      ),
                    ),
                    new SizedBox(
                      height: 40,
                    ),
                    Container(
                      height: 50.0,
                      margin: const EdgeInsets.only(left: 20, right: 20),
                      // decoration: BoxDecoration(
                      //     color: CommonColors.editblack,
                      //     borderRadius: BorderRadius.circular(37)
                      // ),
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 20),
                      child: Row(
                        children: [
                          // new SizedBox(width: 20,),
                          new Container(
                            child: new Text(
                              "Show me online",
                              style: new TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: CommonColors.edittextblack),
                            ),
                          ),
                          Spacer(),
                          Transform.scale(
                            scale: 0.8,
                            child: CupertinoSwitch(
                              value: isonline,
                              onChanged: (value) {
                                isonline = value;
                                setState(() {});
                              },
                              thumbColor: isonline ? CommonColors.buttonorg:CupertinoColors.black,
                              activeColor: CupertinoColors.white,
                              trackColor: CupertinoColors.white,
                            ),
                          ),
                          // new SizedBox(width: 20,),
                        ],
                      ),
                    ),
                    new SizedBox(
                      height: 15,
                    ),
                    new Container(
                      margin: const EdgeInsets.only(left: 20, right: 30),
                      // decoration: BoxDecoration(
                      //     color: CommonColors.editblack,
                      //     borderRadius: BorderRadius.circular(37)
                      // ),
                      padding: const EdgeInsets.symmetric(
                          vertical: 15, horizontal: 20),
                      child: Row(
                        children: [
                          // new SizedBox(width: 20,),
                          new Container(
                            child: new Text(
                              "Select your username",
                              style: new TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: CommonColors.edittextblack),
                            ),
                          ),
                          Spacer(),
                          new Container(
                              child: Icon(
                            Icons.arrow_forward_ios,
                            color: CommonColors.edittextblack,
                            size: 20,
                          )),
                          // new SizedBox(width: 20,),
                        ],
                      ),
                    ),
                    new SizedBox(
                      height: 20,
                    ),
                    Container(
                      height: 50,
                      margin: const EdgeInsets.symmetric(horizontal: 30),
                      padding: const EdgeInsets.only(right: 5,left:15),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.white),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(25)),
                      ),
                      child: TextFormField(
                        readOnly: user_plan=="Free" ? true:false,
                        keyboardType: TextInputType.name,
                        textInputAction: TextInputAction.done,
                        controller: _controllerusername,
                        decoration: InputDecoration(
                          suffixIcon: /*usernamecheck==1 ?*/ Icon(Icons.check_circle,color: Colors.blue,)/*:null*/,
                          hintText: 'username',
                          border: InputBorder.none,
                          hintStyle: new TextStyle(
                              color: Colors.black.withOpacity(0.6),
                              fontSize: 14,
                              fontWeight: FontWeight.w400),
                        ),
                        style: new TextStyle(color: Colors.black, fontSize: 14),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter your name';
                          }
                          return null;
                        },
                      ),
                    ),
                    new SizedBox(
                      height: 40,
                    ),
                    Container(
                      height: 50,
                      margin: const EdgeInsets.symmetric(horizontal: 100),
                      decoration: BoxDecoration(
                        color: CommonColors.buttonorg,
                        borderRadius:
                            const BorderRadius.all(Radius.circular(25)),
                      ),
                      child: Stack(
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Expanded(
                                  child: Center(
                                child: Text(
                                  "Check availability",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400),
                                ),
                              )),
                            ],
                          ),
                          SizedBox.expand(
                            child: Material(
                              type: MaterialType.transparency,
                              child: InkWell(
                                onTap: () {
                                  if(user_plan=="Free"){
                                    Toaster.show(context, "Please Purchase Any Package First");
                                  }else {
                                    Checkuser(_controllerusername.text);
                                  }
                                },
                                splashColor: Colors.blue.withOpacity(0.2),
                                customBorder: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    new Container(
                      margin:
                          const EdgeInsets.only(left: 37, right: 37, top: 12),
                      alignment: Alignment.centerLeft,
                      child: new Text(
                        "Create a unique username. Use your username instead of your fullname.",
                        style: new TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: Colors.white.withOpacity(0.6)),
                      ),
                    ),
                    new SizedBox(
                      height: 30,
                    ),
                    new Container(
                      margin: const EdgeInsets.only(left: 23, right: 23),
                      alignment: Alignment.centerLeft,
                      child: new Text(
                        "App settings",
                        style: new TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white),
                      ),
                    ),
                    new SizedBox(
                      height: 30,
                    ),
                    new Container(
                      margin: const EdgeInsets.only(left: 20, right: 30),
                      // decoration: BoxDecoration(
                      //     color: CommonColors.editblack,
                      //     borderRadius: BorderRadius.circular(37)
                      // ),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          // new SizedBox(width: 20,),
                          new Container(
                            child: new Text(
                              "Notifications",
                              style: new TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: CommonColors.edittextblack),
                            ),
                          ),
                          Spacer(),
                          Transform.scale(
                            scale: 0.8,
                            child: CupertinoSwitch(
                              value: isNotification,
                              onChanged: (value) {
                                isNotification = value;

                                setState(() {});
                              },
                              thumbColor: isNotification ? CommonColors.buttonorg:CupertinoColors.black,
                              activeColor: CupertinoColors.white,
                              trackColor: CupertinoColors.white,
                            ),
                          ),
                          // new SizedBox(width: 20,),
                        ],
                      ),
                    ),
                    new SizedBox(
                      height: 15,
                    ),
                    new Container(
                      margin: const EdgeInsets.only(left: 20, right: 30),
                      // decoration: BoxDecoration(
                      //     color: CommonColors.editblack,
                      //     borderRadius: BorderRadius.circular(37)
                      // ),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          // new SizedBox(width: 20,),
                          new Container(
                            child: new Text(
                              "Email",
                              style: new TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: CommonColors.edittextblack),
                            ),
                          ),
                          Spacer(),
                          Transform.scale(
                            scale: 0.8,
                            child: CupertinoSwitch(
                              value: isEmail,
                              onChanged: (value) {
                                isEmail = value;

                                setState(() {});
                              },
                              thumbColor: isEmail ? CommonColors.buttonorg:CupertinoColors.black,
                              activeColor: CupertinoColors.white,
                              trackColor: CupertinoColors.white,
                            ),
                          ),
                          // new SizedBox(width: 20,),
                        ],
                      ),
                    ),
                    new SizedBox(
                      height: 15,
                    ),
                    // new Container(
                    //   margin: const EdgeInsets.only(left: 20, right: 30),
                    //   // decoration: BoxDecoration(
                    //   //     color: CommonColors.editblack,
                    //   //     borderRadius: BorderRadius.circular(37)
                    //   // ),
                    //   padding: const EdgeInsets.symmetric(horizontal: 20),
                    //   child: Row(
                    //     children: [
                    //       // new SizedBox(width: 20,),
                    //       new Container(
                    //         child: new Text(
                    //           "Push notifications",
                    //           style: new TextStyle(
                    //               fontSize: 16,
                    //               fontWeight: FontWeight.w600,
                    //               color: CommonColors.edittextblack),
                    //         ),
                    //       ),
                    //       Spacer(),
                    //       new Container(
                    //           child: Icon(
                    //         Icons.arrow_forward_ios,
                    //         color: CommonColors.edittextblack,
                    //         size: 20,
                    //       )),
                    //       // new SizedBox(width: 20,),
                    //     ],
                    //   ),
                    // ),
                    new SizedBox(
                      height: 40,
                    ),
                    Container(
                      height: 50,
                      margin: const EdgeInsets.symmetric(horizontal: 25),
                      decoration: BoxDecoration(
                        color: CommonColors.buttonorg,
                        borderRadius:
                            const BorderRadius.all(Radius.circular(25)),
                      ),
                      child: Stack(
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Expanded(
                                  child: Center(
                                child: Text(
                                  "Share Shaadi-App",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600),
                                ),
                              )),
                            ],
                          ),
                          SizedBox.expand(
                            child: Material(
                              type: MaterialType.transparency,
                              child: InkWell(
                                onTap: () {
                                  shareApp();
                                },
                                splashColor: Colors.blue.withOpacity(0.2),
                                customBorder: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    new SizedBox(
                      height: 30,
                    ),
                    new Container(
                      margin: const EdgeInsets.only(left: 23, right: 23),
                      alignment: Alignment.centerLeft,
                      child: new Text(
                        "Privacy",
                        style: new TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white),
                      ),
                    ),
                    new SizedBox(
                      height: 30,
                    ),
                    InkWell(
                      onTap: (){
                        // _launchURL("https://www.google.com/");
                        _launchInBrowser(cookie_policy);
                      },
                      child: new Container(
                        margin: const EdgeInsets.only(left: 20, right: 30),
                        // decoration: BoxDecoration(
                        //     color: CommonColors.editblack,
                        //     borderRadius: BorderRadius.circular(37)
                        // ),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          children: [
                            // new SizedBox(width: 20,),
                            new Container(
                              child: new Text(
                                "Cookie Policy",
                                style: new TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: CommonColors.edittextblack),
                              ),
                            ),
                            Spacer(),
                            new Container(
                                child: Icon(
                              Icons.arrow_forward_ios,
                              color: CommonColors.edittextblack,
                              size: 20,
                            )),
                            // new SizedBox(width: 20,),
                          ],
                        ),
                      ),
                    ),
                    new SizedBox(
                      height: 15,
                    ),
                    InkWell(
                      onTap: (){
                        _launchInBrowser(pricacy_policy);
                      },
                      child: new Container(
                        margin: const EdgeInsets.only(left: 20, right: 30),
                        // decoration: BoxDecoration(
                        //     color: CommonColors.editblack,
                        //     borderRadius: BorderRadius.circular(37)
                        // ),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          children: [
                            // new SizedBox(width: 20,),
                            new Container(
                              child: new Text(
                                "Privacy Policy",
                                style: new TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: CommonColors.edittextblack),
                              ),
                            ),
                            Spacer(),
                            new Container(
                                child: Icon(
                              Icons.arrow_forward_ios,
                              color: CommonColors.edittextblack,
                              size: 20,
                            )),
                            // new SizedBox(width: 20,),
                          ],
                        ),
                      ),
                    ),
                    new SizedBox(
                      height: 15,
                    ),
                    InkWell(
                      onTap: (){
                        _launchInBrowser(pricacy_preferences);
                      },
                      child: new Container(
                        margin: const EdgeInsets.only(left: 20, right: 30),
                        // decoration: BoxDecoration(
                        //     color: CommonColors.editblack,
                        //     borderRadius: BorderRadius.circular(37)
                        // ),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          children: [
                            // new SizedBox(width: 20,),
                            new Container(
                              child: new Text(
                                "Privacy preferences",
                                style: new TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: CommonColors.edittextblack),
                              ),
                            ),
                            Spacer(),
                            new Container(
                                child: Icon(
                              Icons.arrow_forward_ios,
                              color: CommonColors.edittextblack,
                              size: 20,
                            )),
                            // new SizedBox(width: 20,),
                          ],
                        ),
                      ),
                    ),
                    new SizedBox(
                      height: 30,
                    ),
                    new Container(
                      margin: const EdgeInsets.only(left: 23, right: 23),
                      alignment: Alignment.centerLeft,
                      child: new Text(
                        "Privacy",
                        style: new TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white),
                      ),
                    ),
                    new SizedBox(
                      height: 25,
                    ),
                    InkWell(
                      onTap: (){
                        _launchInBrowser(term_services);
                      },
                      child: Container(
                          height: 50,
                          width: double.infinity,
                          margin: const EdgeInsets.symmetric(horizontal: 20),
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          decoration: BoxDecoration(
                            color: CommonColors.editblack,
                            // border: Border.all(color: Colors.white),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(25)),
                          ),
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Terms of Services",
                            style: new TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: CommonColors.editblackgrey),
                            textAlign: TextAlign.left,
                          )),
                    ),
                    new SizedBox(
                      height: 30,
                    ),
                    new Container(
                      margin: const EdgeInsets.only(left: 23, right: 23),
                      alignment: Alignment.centerLeft,
                      child: new Text(
                        "Contact us",
                        style: new TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white),
                      ),
                    ),
                    new SizedBox(
                      height: 25,
                    ),
                    InkWell(
                      onTap: (){
                        openEmailMessage();
                      },
                      child: Container(
                          height: 50,
                          width: double.infinity,
                          margin: const EdgeInsets.symmetric(horizontal: 20),
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          decoration: BoxDecoration(
                            color: CommonColors.editblack,
                            // border: Border.all(color: Colors.white),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(25)),
                          ),
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Support",
                            style: new TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: CommonColors.editblackgrey),
                            textAlign: TextAlign.left,
                          )),
                    ),
                    new SizedBox(
                      height: 140,
                    ),
                    Container(
                      height: 50,
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        color: CommonColors.buttonorg,
                        borderRadius:
                            const BorderRadius.all(Radius.circular(25)),
                      ),
                      child: Stack(
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              clickLoad
                                  ? Expanded(
                                      child: Center(
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 3.0,
                                      ),
                                    ))
                                  : Expanded(
                                      child: Center(
                                      child: Text(
                                        "Update Setting".toUpperCase(),
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 20,
                                            fontWeight: FontWeight.w900),
                                      ),
                                    )),
                            ],
                          ),
                          SizedBox.expand(
                            child: Material(
                              type: MaterialType.transparency,
                              child: InkWell(
                                onTap: () {
                                  Updateuser();
                                  rangeSet();
                                },
                                splashColor: Colors.blue.withOpacity(0.2),
                                customBorder: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // new SizedBox(
                    //   height: 20,
                    // ),
                    // Container(
                    //   height: 50,
                    //   margin: const EdgeInsets.symmetric(horizontal: 20),
                    //   decoration: BoxDecoration(
                    //     color: CommonColors.buttonorg,
                    //     borderRadius:
                    //         const BorderRadius.all(Radius.circular(25)),
                    //   ),
                    //   child: Stack(
                    //     children: <Widget>[
                    //       Row(
                    //         children: <Widget>[
                    //           Expanded(
                    //               child: Center(
                    //             child: Text(
                    //               "RESTORE PURCHASE",
                    //               style: TextStyle(
                    //                   color: Colors.white,
                    //                   fontSize: 20,
                    //                   fontWeight: FontWeight.w900),
                    //             ),
                    //           )),
                    //         ],
                    //       ),
                    //       SizedBox.expand(
                    //         child: Material(
                    //           type: MaterialType.transparency,
                    //           child: InkWell(
                    //             onTap: () {
                    //               Navigator.of(context)
                    //                   .pushNamed("EnableLocation");
                    //             },
                    //             splashColor: Colors.blue.withOpacity(0.2),
                    //             customBorder: RoundedRectangleBorder(
                    //               borderRadius: BorderRadius.circular(25),
                    //             ),
                    //           ),
                    //         ),
                    //       ),
                    //     ],
                    //   ),
                    // ),
                    new SizedBox(
                      height: 20,
                    ),
                    Container(
                      height: 50,
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        color: CommonColors.buttonorg,
                        borderRadius:
                            const BorderRadius.all(Radius.circular(25)),
                      ),
                      child: Stack(
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Expanded(
                                  child: Center(
                                child: Text(
                                  "LOGOUT",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w900),
                                ),
                              )),
                            ],
                          ),
                          SizedBox.expand(
                            child: Material(
                              type: MaterialType.transparency,
                              child: InkWell(
                                onTap: () {
                                  navigateUser(context);
                                },
                                splashColor: Colors.blue.withOpacity(0.2),
                                customBorder: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    new SizedBox(
                      height: 20,
                    ),
                    Container(
                      height: 50,
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        color: CommonColors.buttonorg,
                        borderRadius:
                            const BorderRadius.all(Radius.circular(25)),
                      ),
                      child: Stack(
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              deleteLoad
                                  ? Expanded(
                                      child: Center(
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 3.0,
                                      ),
                                    ))
                                  : Expanded(
                                      child: Center(
                                      child: Text(
                                        "DELETE PROFILE",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 20,
                                            fontWeight: FontWeight.w900),
                                      ),
                                    )),
                            ],
                          ),
                          SizedBox.expand(
                            child: Material(
                              type: MaterialType.transparency,
                              child: InkWell(
                                onTap: () {
                                  deleteDailog();
                                },
                                splashColor: Colors.blue.withOpacity(0.2),
                                customBorder: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    new SizedBox(
                      height: 100,
                    ),
                    new Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        new SizedBox(
                            height: 40,
                            width: 40,
                            child: InkWell(
                              onTap: () {
                                _launchSocialMediaAppIfInstalled(
                                  url: 'https://www.facebook.com/', // Facebook
                                );
                              },
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20.0),
                                child: Image.asset("assets/facebook.png"),
                              ),
                              splashColor: Colors.blue.withOpacity(0.2),
                              customBorder: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            )),
                        new SizedBox(
                          width: 35,
                        ),
                        new SizedBox(
                            height: 40,
                            width: 40,
                            child: InkWell(
                              onTap: () {
                                _launchSocialMediaAppIfInstalled(
                                  url: 'https://twitter.com/', // Twitter
                                );
                              },
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20.0),
                                child: Image.asset("assets/twitter.png"),
                              ),
                              splashColor: Colors.blue.withOpacity(0.2),
                              customBorder: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            )),
                        new SizedBox(
                          width: 35,
                        ),
                        new SizedBox(
                            height: 40,
                            width: 40,
                            child: InkWell(
                              onTap: () {
                                _launchSocialMediaAppIfInstalled(
                                  url: 'https://www.instagram.com/', //Instagram
                                );
                              },
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20.0),
                                child: Image.asset("assets/instagram.png"),
                              ),
                              splashColor: Colors.blue.withOpacity(0.2),
                              customBorder: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            )),
                      ],
                    ),
                    new SizedBox(
                      height: 100,
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
