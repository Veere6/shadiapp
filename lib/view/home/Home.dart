import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shadiapp/CommonMethod/CommonColors.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shadiapp/CommonMethod/Toaster.dart';
import 'package:shadiapp/view/addphotos/AddPhotos.dart';
import 'package:shadiapp/view/enablelocation/EnableLocation.dart';
import 'package:shadiapp/view/forgotpassword/ForgotPassword.dart';
import 'package:shadiapp/view/heightweight/HeightWeight.dart';
import 'package:shadiapp/view/home/fragment/homesearch/HomeSearch.dart';
import 'package:shadiapp/view/home/fragment/likes/LikesSent.dart';
import 'package:shadiapp/view/home/fragment/live/Live.dart';
import 'package:shadiapp/view/home/fragment/profile/Profile.dart';
import 'package:shadiapp/view/otpverify/OTPVerify.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:collection/collection.dart';

import 'fragment/chats/chat.dart';


class Home extends StatefulWidget {
  @override
  State<Home> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<Home> {

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
  String youarevalue="";

  List<File?> imagelist = List.filled(6, null);
  // List<File?> imagelist=[null,null,null,null,null,null];

  @override
  void initState() {
    CheckUserConnection();
    super.initState();
  }

  int pageIndex = 0;

  final pages = [
    HomeSearch(),
    Live(),
    LikesSent(),
    Chat(),
    Profile()
  ];


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: CommonColors.themeblack,
      bottomNavigationBar: Container(
        height: 60,
        decoration: BoxDecoration(
          color: CommonColors.themeblack,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(0),
            topRight: Radius.circular(0),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            InkWell(
              // enableFeedback: false,
              onTap: () {
                setState(() {
                  pageIndex = 0;
                });
              },
              child: Container(
                height: 34,width: 20,
                alignment: Alignment.topCenter,
                child: pageIndex == 0
                    ? Image.asset("assets/home_search.png",color: CommonColors.buttonorg,height: 34,width: 20,)
                    : Image.asset("assets/home_search.png",color: CommonColors.bottomgrey,height: 34,width: 20,),
              )
            ),
            InkWell(
              // enableFeedback: false,
                onTap: () {
                setState(() {
                  pageIndex = 1;
                });
              },
                child: Container(
                  height: 34,width: 21,
                  alignment: Alignment.topCenter,
                  child: pageIndex == 1
                    ? Image.asset("assets/home_live.png",height: 34,width: 21,)
                    : Image.asset("assets/home_live.png",height: 34,width: 21,),
                )
            ),
            InkWell(
              // enableFeedback: false,
                onTap: () {
                setState(() {
                  pageIndex = 2;
                });
              },
                child: Container(
                height: 34,width: 23,
                  alignment: Alignment.topCenter,
                  child: pageIndex == 2
                    ? Image.asset("assets/home_fav.png",color: CommonColors.buttonorg,height: 34,width: 23,)
                    : Image.asset("assets/home_fav.png",color: CommonColors.bottomgrey,height: 34,width: 23,),
                )
            ),
            InkWell(
              // enableFeedback: false,
                onTap: () {
                setState(() {
                  pageIndex = 3;
                });
              },
                child: Container(
                  height: 34,width: 21,
                  alignment: Alignment.topCenter,
                  child: pageIndex == 3
                    ? Image.asset("assets/home_chat.png",color: CommonColors.buttonorg,height: 34,width: 21,)
                    : Image.asset("assets/home_chat.png",color: CommonColors.bottomgrey,height: 34,width: 21,),
                )
            ),
            InkWell(
              // enableFeedback: false,
                onTap: () {
                setState(() {
                  pageIndex = 4;
                });
              },
                child: Container(
                  height: 34,width: 18,
                  alignment: Alignment.topCenter,
                  child: pageIndex == 4
                    ? Image.asset("assets/home_profile.png",color: CommonColors.buttonorg,height: 34,width: 18,)
                    : Image.asset("assets/home_profile.png",color: CommonColors.bottomgrey,height: 34,width: 18,),
                )
            ),
          ],
        ),
      ),
      body: pages[pageIndex],
    );
  }
}

