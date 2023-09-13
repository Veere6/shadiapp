import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shadiapp/CommonMethod/CommonColors.dart';
import 'package:shadiapp/CommonMethod/StarRating.dart';
import 'package:shadiapp/CommonMethod/Toaster.dart';
import 'package:shadiapp/Models/plan_list_model.dart';
import 'package:shadiapp/Models/update_image_model.dart';
import 'package:shadiapp/Models/view_profile_model.dart';
import 'package:shadiapp/Services/Services.dart';
import 'package:shadiapp/ShadiApp.dart';
import 'package:shadiapp/view/subscription/GoldSub.dart';
import 'package:shadiapp/view/subscription/PremiumSub.dart';
import 'package:shadiapp/view/subscription/VIPSub.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:swipe_cards/draggable_card.dart';
import 'package:swipe_cards/swipe_cards.dart';
import 'package:url_launcher/url_launcher.dart';

class Profile extends StatefulWidget {

  bool isback = false;
  Profile({super.key,required this.isback});

  @override
  State<Profile> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<Profile> {

  bool ActiveConnection = false;
  String T = "";
  late ViewProfileModel _viewProfileModel = ViewProfileModel();
  late PlanListModel _planListModel;
  late SharedPreferences _preferences;
  late UpdateImageModel _updateImageModel;
  List<planDatum> _list = [];
  bool clickLoad = false;
  bool isLoad = false;
  File? image;

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


  Future<void> viewProfile() async {
    clickLoad = true;
    _preferences = await SharedPreferences.getInstance();
    _viewProfileModel = await Services.ProfileView(_preferences.getString(ShadiApp.userId).toString());
    if(_viewProfileModel.status ==1){

    }
    clickLoad = false;
    if(mounted) {
      setState(() {});
    }
  }

  Future<void> planList() async {
    _preferences = await SharedPreferences.getInstance();
    setState(() {
      isLoad = true;
    });
    _planListModel = await Services.PlanList(_preferences.getString(ShadiApp.userId).toString());
    if(_planListModel.status ==1){
      for (var i = 0; i < _planListModel.data!.length; i++){
        _list = _planListModel.data ?? <planDatum> [];
      }
    }
    setState(() {
      isLoad = false;
    });
  }

  late double _scrollPosition;
  late ScrollController _scrollController;

  @override
  void initState() {
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    viewProfile();
    planList();
    CheckUserConnection();
    super.initState();
  }


  _scrollListener() {
    setState(() {
      _scrollPosition = _scrollController.position.pixels;
    });
  }
  int currentIndex=0;


  int parcasepackage=100;


  List<String> bottom_packageLike=["5","20","60"];
  List<String> bottom_packagediscount=["","30","50"];
  List<String> bottom_packageeach=["20,67 kr. each","15,54 kr. each","10,54 kr. each"];



  List<String> vipdialog = ["12","3","1"];
  List<String> vipdialogkr = ["kr 40.33/mo","kr 40.33/mo","kr 40.33/mo"];
  List<String> vipdialogkr2 = ["kr. 139","kr. 139","kr. 139"];

  List<Color> colorList=[CommonColors.blue,CommonColors.buttonorg,CommonColors.yellow,CommonColors.settingblue];
  List<String> packagetittle=["Basic","Premium","Gold","Vip"];
  List<String> packagedis=["0","20","25","30","30"];
  List<Color> colorList2=[CommonColors.blue,CommonColors.yellow];
  List<String> packagetittle2=["Premium","Gold"];
  List<String> packagedis2=["20","25"];

  Color getRandomColor(String packagename) {
    // Random random = Random();
    // return colorList[random.nextInt(5)];
    int goldIndex = packagetittle.indexOf(packagename);
    return colorList[goldIndex];
  }


  void _pickedImage() {
    showDialog<ImageSource>(
      context: context,
      builder: (context) => AlertDialog(
          content: Text("Choose image source"),
          actions: [
            TextButton(
                child: Text("Camera"),
                onPressed: () {
                  _getFromCamera();
                  Navigator.pop(context);
                }
            ),
            TextButton(
                child: Text("Gallery"),
                onPressed: () {
                  _getFromGallery();
                  Navigator.pop(context);
                }
            ),
          ]
      ),
    );
  }

  _getFromGallery() async {
    PickedFile? pickedFile = await ImagePicker().getImage(
      source: ImageSource.gallery,
      maxWidth: 1800,
      maxHeight: 1800,
    );
    if (pickedFile != null) {
      setState((){
        image = File(pickedFile.path);
        updateImage(image!);
      });
    }
  }
  _getFromCamera() async {
    PickedFile? pickedFile = await ImagePicker().getImage(
      source: ImageSource.camera,
      maxWidth: 1800,
      maxHeight: 1800,
    );
    if (pickedFile != null) {
      setState((){
        image = File(pickedFile.path);
        updateImage(image!);
      });

    }
  }

  void updateImage(File image) async {
    _preferences = await SharedPreferences.getInstance();
    _updateImageModel = await Services.UpdateImage(_preferences.getString(ShadiApp.userId).toString(),
        _viewProfileModel.data![0].imageId.toString(), image!);
    if(_updateImageModel.status == 1){
      Toaster.show(context, _updateImageModel.message.toString());
    }else{
      Toaster.show(context, _updateImageModel.message.toString());
    }
  }

  int selectpack=100;










  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CommonColors.themeblack,
      body: SafeArea(
        child: clickLoad ? Center(
          child: CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 3.0,
          ),
        ):SingleChildScrollView(
            child: Column(
              children: [
                new SizedBox(
                  height: 15,
                ),
                new Container(
                  child: Row(
                    children: [
                      if(widget.isback) new SizedBox(
                        width: 24,
                      ),
                      if(widget.isback) InkWell(
                        onTap:(){
                          Navigator.of(context).pop();
                        },
                        child: new SizedBox(
                          width: 20,
                          height: 24,
                          child: Image.asset("assets/back_icon.png",height:24,width: 20,),
                        ),
                      ),
                      new Spacer(),
                      InkWell(
                        onTap:(){
                          Navigator.of(context).pushNamed('MatchPro');
                        },
                        child: new SizedBox(
                          width: 20,
                          height: 24,
                          child: Image.asset("assets/shield_pro.png",height:24,width: 20,),
                        ),
                      ),
                      new SizedBox(
                        width: 15,
                      ),
                      InkWell(
                        onTap: (){
                          Navigator.of(context).pushNamed("Settings");
                        },
                        child: new SizedBox(
                          width: 22,
                          height: 24,
                          child: Image.asset("assets/setting_pro.png",height:24,width: 22,color: Colors.white,),
                        ),
                      ),
                      new SizedBox(
                        width: 24,
                      ),
                    ],
                  ),
                ),
                new SizedBox(
                  height:180,
                  width: 180,
                  child: Stack(
                    children: [
                      new Positioned(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(90.0),
                            child: image != null ? Image.file(image!,
                              fit: BoxFit.cover,height: 180,width: 180,
                            ):Image.network(_viewProfileModel.data![0].image.toString(),
                              fit: BoxFit.cover,height: 180,width: 180,),
                          )
                      ),
                      new Positioned(
                        bottom: 15,
                          right: 15,
                          child: InkWell(
                            onTap: (){
                              _pickedImage();
                              // showDialog(
                              //     context: context,
                              //     builder: (BuildContext context) {
                              //       return Dialog(
                              //         insetPadding: const EdgeInsets.all(20),
                              //         shape: RoundedRectangleBorder(
                              //             borderRadius:
                              //             BorderRadius.circular(10.0)), //this right here
                              //         child: Container(
                              //           height: 320,
                              //           width: double.infinity,
                              //
                              //           // margin: const EdgeInsets.symmetric(horizontal: 10),
                              //           child: Column(
                              //             mainAxisAlignment: MainAxisAlignment.center,
                              //             crossAxisAlignment: CrossAxisAlignment.start,
                              //             children: [
                              //               new Expanded(child: Container(
                              //                 height:double.infinity,
                              //                   decoration: BoxDecoration(
                              //                       color:Color(0xffCBF1FA),
                              //                       borderRadius: BorderRadius.only(topRight: Radius.circular(10),topLeft: Radius.circular(10))
                              //                   ),
                              //                 width: MediaQuery.of(context).size.width,
                              //                 child: Stack(
                              //                   alignment: Alignment.center,
                              //                   children: [
                              //                     new Row(
                              //                       mainAxisAlignment: MainAxisAlignment.center,
                              //                       crossAxisAlignment: CrossAxisAlignment.center,
                              //                       children: [
                              //                         Container(
                              //                             height:132,
                              //                             width:132,
                              //                             child: Stack(
                              //                               children: [
                              //                                 Container(
                              //                                   alignment: Alignment.center,
                              //                                   height:120,
                              //                                   width:120,
                              //                                   decoration: BoxDecoration(
                              //                                       borderRadius: BorderRadius.all(Radius.circular(66)),
                              //                                       border: Border.all(width: 5,color: CommonColors.upgradeblue)
                              //                                   ),
                              //                                   child: ClipRRect(
                              //                                     borderRadius: BorderRadius.circular(66.0),
                              //                                     child: Image.network(_viewProfileModel.data![0].image.toString(),
                              //                                       fit: BoxFit.cover,height: 180,width: 180,),
                              //                                   ),
                              //                                 ),
                              //                                 new Positioned(
                              //                                     bottom: 10,
                              //                                     right: 10,
                              //                                     child: InkWell(
                              //                                       onTap: (){
                              //                                       },
                              //                                       child: ClipRRect(
                              //                                           borderRadius: BorderRadius.circular(20),
                              //                                           child: Container(
                              //                                             height: 33,
                              //                                             width: 33,
                              //                                             padding: const EdgeInsets.all(5),
                              //                                             color: CommonColors.upgradeblue,
                              //                                             child: Image.asset("assets/chat_upgrade.png")
                              //                                           )
                              //                                       ),
                              //                                     )
                              //                                 )
                              //                               ],
                              //                             )
                              //                         ),
                              //                       ],
                              //                     ),
                              //                     new Positioned(
                              //                       right:0,
                              //                         top: 0,
                              //                         child: Container(
                              //                           height: 55,
                              //                           width: 56,
                              //                           decoration: BoxDecoration(
                              //                             color: Color(0xffA9EDF8),
                              //                             borderRadius: BorderRadius.only(bottomLeft: Radius.circular(28),topRight:Radius.circular(10) )
                              //                           ),
                              //                         )
                              //                     ),
                              //                     new Positioned(
                              //                         left:0,
                              //                         bottom: 0,
                              //                         child: Container(
                              //                           height: 55,
                              //                           width: 56,
                              //                           decoration: BoxDecoration(
                              //                               color: Color(0xffA9EDF8),
                              //                               borderRadius: BorderRadius.only(bottomLeft: Radius.circular(10),topRight: Radius.circular(28))
                              //                           ),
                              //                         )
                              //                     ),
                              //                     new Positioned(
                              //                       top: 10,
                              //                         left:10,
                              //                         child: Container(
                              //                           height: 38,
                              //                           width: 38,
                              //                           decoration: BoxDecoration(
                              //                               color: Color(0xffFB3357),
                              //                               borderRadius: BorderRadius.all(Radius.circular(19))
                              //                           ),
                              //                           padding: const EdgeInsets.all(8),
                              //                           child:
                              //                           new RotationTransition(
                              //                             turns: new AlwaysStoppedAnimation(-30 / 360),
                              //                             child: Image.asset("assets/bell_icon.png",color: Colors.white,),
                              //                           )
                              //
                              //
                              //                         )
                              //                     ),
                              //                   ],
                              //                 )
                              //               )),
                              //               new Expanded(child: Container(
                              //                 height:double.infinity,
                              //                   width: double.infinity,
                              //                   padding: const EdgeInsets.symmetric(horizontal: 20),
                              //                   child: Column(
                              //                     mainAxisAlignment: MainAxisAlignment.center,
                              //                     crossAxisAlignment: CrossAxisAlignment.center,
                              //                     children: [
                              //                       new Container(
                              //                         child: Text("Upgrade your like!",style: new TextStyle(fontSize: 15,fontWeight: FontWeight.w600,color: Colors.black),),
                              //                       ),
                              //                       new SizedBox(height: 13,),
                              //                       new Container(
                              //                         child: Text("Push notifications make sure you never\nmiss new comments. Turn on in settings.",style: new TextStyle(fontSize: 13,fontWeight: FontWeight.w400,color: Color(0xff656565)),textAlign: TextAlign.center,),
                              //                       ),
                              //                       new SizedBox(height: 20,),
                              //                     ],
                              //                   )
                              //               )),
                              //             ],
                              //           ),
                              //         ),
                              //       );
                              //     });
                            },
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                height: 28,
                                width: 28,
                                padding: const EdgeInsets.all(8),
                                color: Colors.white,
                                child: Image.asset("assets/camera_icon.png")
                              )
                            ),
                          )
                      )
                    ],
                  )
                ),
                new SizedBox(height: 10,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    InkWell(
                      onTap: (){
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return Dialog(
                                insetPadding: const EdgeInsets.all(20),
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                    BorderRadius.circular(10.0)), //this right here
                                child: Container(
                                  height: 480,
                                  width: double.infinity,
                                  decoration: BoxDecoration(

                                    // border: Border.all(width: 1,color: Colors.black),
                                    borderRadius: BorderRadius.all(Radius.circular(10)),
                                    gradient: LinearGradient(
                                      colors: [ Color(0xffCBF1FA),Color(0xffCBF1FA),Color(0xffFFFFFF),],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                    ),
                                  ),
                                  padding: const EdgeInsets.all(15),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      new Container(
                                        child: Text("VIP",style: new TextStyle(fontWeight: FontWeight.w600,fontSize: 15,color:Colors.black),),
                                      ),
                                      new Container(
                                        child: Text("Get 9 privileges in 1 bundle",style: new TextStyle(fontWeight: FontWeight.w400,fontSize: 12,color:Color(0xff656565)),),
                                      ),
                                      new SizedBox(height: 14,),
                                      new SizedBox(
                                        width: 89,
                                        height:82,
                                        child:Image.asset("assets/vip_dialog.png")
                                      ),
                                      new SizedBox(height: 7,),
                                      new Container(
                                        child: Text("Search for Matches",style: new TextStyle(fontWeight: FontWeight.w600,fontSize: 14,color:Colors.black),),
                                      ),
                                      new Container(
                                        child: Text("Find your matches faster",style: new TextStyle(fontWeight: FontWeight.w400,fontSize: 13,color:Color(0xff656565)),),
                                      ),
                                      new SizedBox(height: 15,),
                                      Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            for(int i = 0; i < 8; i++)
                                              Container(
                                                  height: 5, width: 5,
                                                  margin: const EdgeInsets.symmetric(horizontal: 3),
                                                  decoration: BoxDecoration(
                                                      color: i == 4 ?  CommonColors.upgradeblue:Colors.white,
                                                      borderRadius: BorderRadius.circular(5)
                                                  )
                                              )
                                          ]
                                      ),
                                      new SizedBox(height: 20,),
                                      new Container(
                                        height:120,
                                        width: MediaQuery.of(context).size.width,
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            ListView.builder(
                                              shrinkWrap: true,
                                              itemCount: vipdialog.length,
                                              scrollDirection: Axis.horizontal,
                                              controller: _scrollController,
                                              itemBuilder: (ctx,index){
                                                return  InkWell(
                                                  onTap: (){
                                                    // setState(() {
                                                    //   parcasepackage=100;
                                                    // });
                                                  },
                                                  child: new Container(
                                                    width: 90,
                                                    height: 110,
                                                    margin: const EdgeInsets.symmetric(horizontal: 5),
                                                    child: Stack(
                                                      alignment: Alignment.center,
                                                      children: [
                                                        Positioned(
                                                          top:10,
                                                        right: 0,
                                                        left:0,
                                                          bottom: 0,
                                                          child:Container(
                                                            decoration: BoxDecoration(
                                                              color: index==1 ? CommonColors.upgradeblue:null,
                                                              border: Border.all(width: index==1?3:1,color: CommonColors.upgradeblue),
                                                              borderRadius: BorderRadius.circular(10)
                                                            ),
                                                            child: Column(
                                                              children: [
                                                                new Expanded(
                                                                  flex:3,
                                                                  child: new Container(
                                                                    width: double.infinity,
                                                                    decoration: BoxDecoration(
                                                                        color:Color(0xffCBF1FA),
                                                                        borderRadius: BorderRadius.circular(10)
                                                                    ),
                                                                    child: Column(
                                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                                      crossAxisAlignment: CrossAxisAlignment.center,
                                                                      children: [
                                                                        new Container(
                                                                          child: Text("${vipdialog[index]}",style: new TextStyle(fontSize: 20,fontWeight: FontWeight.w400,color:index==1 ? CommonColors.black: CommonColors.upgradeblue),),
                                                                        ),
                                                                        new Container(
                                                                          child: Text("months",style: new TextStyle(fontSize: 10,fontWeight: FontWeight.w400,color:index==1 ? CommonColors.black: CommonColors.upgradeblue),),
                                                                        ),
                                                                        new Container(
                                                                          child: Text("${vipdialogkr[index]}",style: new TextStyle(fontSize: 10,fontWeight: FontWeight.w400,color: CommonColors.upgradeblue),),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ),
                                                                new Expanded(
                                                                  flex:1,
                                                                    child:new Container(
                                                                      alignment: Alignment.center,
                                                                      child: Text("${vipdialogkr2[index]}",style: new TextStyle(fontSize: 14,fontWeight: FontWeight.w600,color: index==1 ? CommonColors.white:CommonColors.upgradeblue),),
                                                                    ),
                                                                )

                                                              ],
                                                            ),
                                                          )
                                                        ),

                                                       if(index==1) Positioned(
                                                          top: 0,
                                                          child: Container(
                                                              decoration: BoxDecoration(
                                                                color: CommonColors.upgradeblue,
                                                                borderRadius: BorderRadius.circular(5),
                                                              ),
                                                              padding: const EdgeInsets.symmetric(horizontal: 12,vertical: 3),
                                                              child: Row(
                                                                mainAxisSize: MainAxisSize.min,
                                                                children: [
                                                                  Text("30% off",style: new TextStyle(fontSize: 11,fontWeight: FontWeight.w700,color: Colors.white),),
                                                                ],
                                                              )
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              },
                                            )
                                          ],
                                        ),
                                      ),


                                      new SizedBox(height: 20,),

                                      Container(
                                        height: 50,
                                        margin: const EdgeInsets.only(right: 30,left: 30),
                                        // margin: const EdgeInsets.symmetric(horizontal: 20),
                                        decoration: BoxDecoration(
                                          color: CommonColors.upgradeblue,
                                          borderRadius:
                                          const BorderRadius.all(Radius.circular(10)),
                                        ),
                                        child: Stack(
                                          children: <Widget>[
                                            Row(
                                              children: <Widget>[

                                                Expanded(
                                                    child: Center(
                                                      child: Text("Continue", style: TextStyle(
                                                          color: Colors.white, fontSize: 15,fontWeight: FontWeight.w600),),
                                                    )),
                                              ],
                                            ),
                                            SizedBox.expand(
                                              child: Material(
                                                type: MaterialType.transparency,
                                                child: InkWell(onTap: () {
                                                },splashColor: Colors.blue.withOpacity(0.2),
                                                  customBorder: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(10),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),


                                      new SizedBox(height: 20,),
                                    ],
                                  ),
                                ),
                              );
                            });
                      },
                      child: new Container(
                        child: Text("${_viewProfileModel.data![0].firstName![0].toUpperCase()+_viewProfileModel.data![0].firstName!.substring(1)}"
                            " ${_viewProfileModel.data![0].lastName![0].toUpperCase()+_viewProfileModel.data![0].lastName!.substring(1)}",style: new TextStyle(fontWeight: FontWeight.w600,fontSize: 20,color:Colors.white),),
                      ),
                    ),
                   if(_viewProfileModel.data![0].isVerified == 2) new SizedBox(width: 5,),
                    if(_viewProfileModel.data![0].isVerified == 2)  SizedBox(
                      height: 15,
                      width: 15,
                      child: Center(
                          child: Image.asset("assets/blue_tick.png",height: 15,width: 15)),
                    )
                  ],
                ),
                new SizedBox(height: 5,),
                new Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                     if(_viewProfileModel.data![0].city!="null") Text("${_viewProfileModel.data![0].city}, ",
                        style: new TextStyle(fontWeight: FontWeight.w400,fontSize: 14,color:Colors.white.withOpacity(0.6)),),
                     if(_viewProfileModel.data![0].state!="null") Text("${_viewProfileModel.data![0].state}, ",
                        style: new TextStyle(fontWeight: FontWeight.w400,fontSize: 14,color:Colors.white.withOpacity(0.6)),),
                     if(_viewProfileModel.data![0].country!="null") Text("${_viewProfileModel.data![0].country}",
                        style: new TextStyle(fontWeight: FontWeight.w400,fontSize: 14,color:Colors.white.withOpacity(0.6)),),
                    ],
                  ),
                ),
                new SizedBox(height: 15,),
                Container(
                  height: 50,
                  width: 130,
                  // margin: const EdgeInsets.only(top: 15),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
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
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text("Edit Profile", style: TextStyle(
                                        color: Colors.white, fontSize: 17,fontWeight: FontWeight.w800),),
                                  ],
                                ),
                              )),
                        ],
                      ),
                      SizedBox.expand(
                        child: Material(
                          type: MaterialType.transparency,
                          child: InkWell(onTap: () {
                            Navigator.of(context).pushNamed("EditProfile");
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
                new SizedBox(height: 18,),
                if(packagetittle.length >= parcasepackage) new Container(
                  child: Text("You have membership",style: new TextStyle(fontWeight: FontWeight.w400,fontSize: 15,color:Colors.white),),
                ),
                if(packagetittle.length >= parcasepackage) new Container(
                  margin: const EdgeInsets.symmetric(horizontal: 50),
                  alignment: Alignment.center,
                  child: Text("Upgrade NOW and be more succesful 3 MONTHS  PROMOTION",style: new TextStyle(fontWeight: FontWeight.w600,fontSize: 15,color:Colors.white),textAlign: TextAlign.center,),
                ),

                packagetittle.length >= parcasepackage ? new Container(
                  height: MediaQuery.of(context).size.width/2,
                  width: MediaQuery.of(context).size.width,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ListView.builder(
                        shrinkWrap: true,
                        itemCount: packagetittle2.length,
                        scrollDirection: Axis.horizontal,
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        itemBuilder: (ctx,index){
                          return  InkWell(
                            onTap: (){
                              setState(() {
                                parcasepackage=100;
                              });
                            },
                            child: new Container(
                              width: MediaQuery.of(context).size.width/3,
                              height: MediaQuery.of(context).size.width/2,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Positioned(
                                    bottom: 10,
                                    child: Container(
                                      width: MediaQuery.of(context).size.width/3.5,
                                      height: MediaQuery.of(context).size.width/2-50,
                                      decoration: BoxDecoration(
                                        color:colorList2[index],
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(17.0) //                 <--- border radius here
                                        ),
                                      ),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          new SizedBox(
                                            height: 47,
                                            width: 36,
                                            child: Image.asset("assets/drop_pro.png"),
                                          ),
                                          new SizedBox(height: 5,),
                                          new Container(
                                            child: Text("${packagetittle2[index]}",style: new TextStyle(color: Colors.white,fontSize: 20,fontWeight: FontWeight.w600),),
                                          ),
                                          new SizedBox(height: 5,),
                                          new Container(
                                            child: Text("\$ 175.00",style: new TextStyle(color: Colors.white,fontSize: 20,fontWeight: FontWeight.w600),),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      )
                    ],
                  ),
                ) :
                Container(
                  height: MediaQuery.of(context).size.width/2,
                  width: MediaQuery.of(context).size.width,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: _list.length,
                          scrollDirection: Axis.horizontal,
                          controller: _scrollController,
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          itemBuilder: (ctx,index){
                            return index!=parcasepackage ? InkWell(
                              onTap: (){
                                setState(() {
                                  selectpack=index;
                                  // parcasepackage=index;
                                  // currentIndex=index;
                                  // if(_list[index].name=="BASIC"){
                                  //   Navigator.of(context).pushNamed("FreeSub");
                                  // }else if(_list[index].name=="Premium"){
                                  //   Navigator.of(context).push(MaterialPageRoute(
                                  //       builder: (context) => PremiumSub(_list[index].name.toString(),
                                  //       _list[index].price!.toInt(), _list[index].feauture!.toList())));
                                  // }else if(_list[index].name=="Gold"){
                                  //   Navigator.of(context).push(MaterialPageRoute(
                                  //       builder: (context) => GoldSub(_list[index].name.toString(),
                                  //           _list[index].price!.toInt(), _list[index].feauture!.toList())));
                                  // }else if(_list[index].name=="Vip"){
                                  //   Navigator.of(context).push(MaterialPageRoute(
                                  //       builder: (context) => VIPSub(_list[index].name.toString(),
                                  //           _list[index].price!.toInt(), _list[index].feauture!.toList())));
                                  // }
                                });
                              },
                              child: new Container(
                                width: MediaQuery.of(context).size.width/3,
                                height: MediaQuery.of(context).size.width/2,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Positioned(
                                      bottom: 15,
                                      child: Container(
                                        width: MediaQuery.of(context).size.width/3.5,
                                        height: MediaQuery.of(context).size.width/2-50,
                                        decoration: BoxDecoration(
                                          color:getRandomColor(_list[index].name ?? ""),
                                          border: Border.all(
                                            color: Colors.white, // Border color
                                            width: selectpack==index ? 2.0:0.0,          // Border width
                                          ),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(17.0) //                 <--- border radius here
                                          ),
                                        ),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            new SizedBox(
                                              height: 47,
                                              width: 36,
                                              child: Image.network("${_list[index].icon}",fit: BoxFit.cover,),
                                            ),
                                            new SizedBox(height: 10,),
                                            new Container(
                                              child: Text("${_list[index].name}",style: new TextStyle(color: Colors.white,fontSize: 20,fontWeight: FontWeight.w600),),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 0,
                                      child: Container(
                                        height:30,
                                          // margin: const EdgeInsets.only(right: 5,top:5),
                                          decoration: BoxDecoration(
                                            color: CommonColors.red,
                                            borderRadius: BorderRadius.circular(5),
                                          ),
                                          padding: const EdgeInsets.symmetric(horizontal: 12,vertical: 6),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text("Save ${_list[index].discountePercent}%",style: new TextStyle(fontSize: 11,fontWeight: FontWeight.w700,color: Colors.white),),
                                            ],
                                          )
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ):Container();
                          },
                        ),
                      )
                    ],
                  ),
                ),
                new SizedBox(height: 20,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for(int i = 0; i < _list.length; i++)
                        Container(
                            height: 10, width: 10,
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            decoration: BoxDecoration(
                                color: i == currentIndex ?  CommonColors.buttonorg:Colors.white,
                                borderRadius: BorderRadius.circular(5)
                            )
                        )
                    ]
                ),
                // Container(
                //   padding: const EdgeInsets.symmetric(horizontal: 5),
                //   child: new Row(
                //     children: [
                //       Expanded(
                //         child: new Container(
                //           width: double.maxFinite,
                //           height: MediaQuery.of(context).size.width/2,
                //           child: Stack(
                //             alignment: Alignment.center,
                //             children: [
                //               Positioned(
                //                 bottom: 10,
                //                 child: Container(
                //                   width: MediaQuery.of(context).size.width/3.5,
                //                   height: MediaQuery.of(context).size.width/2-50,
                //                   decoration: BoxDecoration(
                //                     color:CommonColors.buttonorg,
                //                     borderRadius: BorderRadius.all(
                //                         Radius.circular(10.0) //                 <--- border radius here
                //                     ),
                //                   ),
                //                   child: Column(
                //                     mainAxisAlignment: MainAxisAlignment.center,
                //                     crossAxisAlignment: CrossAxisAlignment.center,
                //                     children: [
                //                       new SizedBox(
                //                         height: 47,
                //                         width: 36,
                //                         child: Image.asset("assets/drop_pro.png"),
                //                       ),
                //                       new SizedBox(height: 10,),
                //                       new Container(
                //                         child: Text("Premium",style: new TextStyle(color: Colors.white,fontSize: 20,fontWeight: FontWeight.w600),),
                //                       )
                //                     ],
                //                   ),
                //                 ),
                //               ),
                //               Positioned(
                //                 bottom: 0,
                //                 child: Container(
                //                     margin: const EdgeInsets.only(right: 5,top:5),
                //                     decoration: BoxDecoration(
                //                       color: CommonColors.red,
                //                       borderRadius: BorderRadius.circular(5),
                //                     ),
                //                     padding: const EdgeInsets.symmetric(horizontal: 12,vertical: 6),
                //                     child: Row(
                //                       mainAxisSize: MainAxisSize.min,
                //                       children: [
                //                         Text("Save 25%",style: new TextStyle(fontSize: 11,fontWeight: FontWeight.w700,color: Colors.white),),
                //                       ],
                //                     )
                //                 ),
                //               ),
                //             ],
                //           ),
                //         ),
                //       ),
                //       Expanded(
                //         child: new Container(
                //           width: double.maxFinite,
                //           height: MediaQuery.of(context).size.width/2,
                //           child: Stack(
                //             alignment: Alignment.center,
                //             children: [
                //               Positioned(
                //                 bottom: 10,
                //                 child: Container(
                //                   width: MediaQuery.of(context).size.width/3.5,
                //                   height: MediaQuery.of(context).size.width/2-50,
                //                   decoration: BoxDecoration(
                //                     color:CommonColors.yellow,
                //                     borderRadius: BorderRadius.all(
                //                         Radius.circular(10.0) //                 <--- border radius here
                //                     ),
                //                   ),
                //                   child: Column(
                //                     mainAxisAlignment: MainAxisAlignment.center,
                //                     crossAxisAlignment: CrossAxisAlignment.center,
                //                     children: [
                //                       new SizedBox(
                //                         height: 47,
                //                         width: 36,
                //                         child: Image.asset("assets/drop_pro.png"),
                //                       ),
                //                       new SizedBox(height: 10,),
                //                       new Container(
                //                         child: Text("Gold",style: new TextStyle(color: Colors.white,fontSize: 20,fontWeight: FontWeight.w600),),
                //                       )
                //                     ],
                //                   ),
                //                 ),
                //               ),
                //               Positioned(
                //                 bottom: 0,
                //                 child: Container(
                //                     margin: const EdgeInsets.only(right: 5,top:5),
                //                     decoration: BoxDecoration(
                //                       color: CommonColors.red,
                //                       borderRadius: BorderRadius.circular(5),
                //                     ),
                //                     padding: const EdgeInsets.symmetric(horizontal: 12,vertical: 6),
                //                     child: Row(
                //                       mainAxisSize: MainAxisSize.min,
                //                       children: [
                //                         Text("Save 25%",style: new TextStyle(fontSize: 11,fontWeight: FontWeight.w700,color: Colors.white),),
                //                       ],
                //                     )
                //                 ),
                //               ),
                //             ],
                //           ),
                //         ),
                //       ),
                //       Expanded(
                //         child: new Container(
                //           width: double.maxFinite,
                //           height: MediaQuery.of(context).size.width/2,
                //           child: Stack(
                //             alignment: Alignment.center,
                //             children: [
                //               Positioned(
                //                 bottom: 10,
                //                 child: Container(
                //                   width: MediaQuery.of(context).size.width/3.5,
                //                   height: MediaQuery.of(context).size.width/2-50,
                //                   decoration: BoxDecoration(
                //                     color:CommonColors.bluepro,
                //                     borderRadius: BorderRadius.all(
                //                         Radius.circular(10.0) //                 <--- border radius here
                //                     ),
                //                   ),
                //                   child: Column(
                //                     mainAxisAlignment: MainAxisAlignment.center,
                //                     crossAxisAlignment: CrossAxisAlignment.center,
                //                     children: [
                //                       new SizedBox(
                //                         height: 47,
                //                         width: 36,
                //                         child: Image.asset("assets/drop_pro.png"),
                //                       ),
                //                       new SizedBox(height: 10,),
                //                       new Container(
                //                         child: Text("VIP",style: new TextStyle(color: Colors.white,fontSize: 20,fontWeight: FontWeight.w600),),
                //                       )
                //                     ],
                //                   ),
                //                 ),
                //               ),
                //               Positioned(
                //                 bottom: 0,
                //                 child: Container(
                //                     margin: const EdgeInsets.only(right: 5,top:5),
                //                     decoration: BoxDecoration(
                //                       color: CommonColors.red,
                //                       borderRadius: BorderRadius.circular(5),
                //                     ),
                //                     padding: const EdgeInsets.symmetric(horizontal: 12,vertical: 6),
                //                     child: Row(
                //                       mainAxisSize: MainAxisSize.min,
                //                       children: [
                //                         Text("Save 25%",style: new TextStyle(fontSize: 11,fontWeight: FontWeight.w700,color: Colors.white),),
                //                       ],
                //                     )
                //                 ),
                //               ),
                //             ],
                //           ),
                //         ),
                //       ),
                //     ],
                //   ),
                // ),
                new SizedBox(height: 15,),
               if(_list.isNotEmpty) Container(
                  height: 50,
                  margin: const EdgeInsets.only(right: 50,left: 50),
                  // margin: const EdgeInsets.symmetric(horizontal: 20),
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
                                child: Text("Upgrade NOW", style: TextStyle(
                                    color: Colors.white, fontSize: 20),),
                              )),
                        ],
                      ),
                      SizedBox.expand(
                        child: Material(
                          type: MaterialType.transparency,
                          child: InkWell(onTap: () async {

                            // await makePayment();



                            if(selectpack!=100) {
                            //   // if (_list[selectpack].name == "BASIC") {
                            //   //   Navigator.of(context).pushNamed("FreeSub");
                            //   // } else if (_list[selectpack].name == "Premium") {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) =>
                                        PremiumSub(
                                            getRandomColor(_list[selectpack].name ?? ""),
                                            _list[selectpack].id.toString(),
                                            _list[selectpack].name.toString(),
                                            "${_preferences.getString(ShadiApp.userId).toString()}",
                                            "${_list[selectpack].name}",
                                            _list[selectpack].price!.toInt(),
                                            _list[selectpack].feauture!.toList())));
                            //   // } else if (_list[selectpack].name == "Gold") {
                            //   //   Navigator.of(context).push(MaterialPageRoute(
                            //   //       builder: (context) =>
                            //   //           GoldSub(_list[selectpack].name.toString(),
                            //   //               _list[selectpack].price!.toInt(),
                            //   //               _list[selectpack].feauture!.toList())));
                            //   // } else if (_list[selectpack].name == "Vip") {
                            //   //   Navigator.of(context).push(MaterialPageRoute(
                            //   //       builder: (context) =>
                            //   //           VIPSub(_list[selectpack].name.toString(),
                            //   //               _list[selectpack].price!.toInt(),
                            //   //               _list[selectpack].feauture!.toList())));
                            //   // }
                            }else{

                              Toaster.show(context, "Select package");
                            }

                            // showModalBottomSheet(
                            //   context: context,
                            //   elevation: 10,
                            //   backgroundColor: Colors.transparent,
                            //   builder: (BuildContext context) {
                            //     return BottomSheet(
                            //       backgroundColor: Colors.transparent,
                            //       onClosing: () {},
                            //       builder: (BuildContext context) {
                            //         int selectindex = 1;
                            //         return StatefulBuilder(
                            //           builder: (BuildContext context, setState) => Container(
                            //               height: MediaQuery.of(context).size.height/1.3,
                            //               width: MediaQuery.of(context).size.width,
                            //               color: Colors.transparent,
                            //               child: Stack(
                            //                 alignment: Alignment.topCenter,
                            //                 children: [
                            //                   Positioned(
                            //                     top:60,
                            //                     bottom: 0,
                            //                     right: 0,
                            //                     left: 0,
                            //                     child: new Container(
                            //                       decoration: BoxDecoration(
                            //                         color:Colors.white,
                            //                         // border: Border.all(width: 1,color: Colors.black),
                            //                         borderRadius: BorderRadius.only(topLeft: Radius.circular(10),topRight: Radius.circular(10)),
                            //                       ),
                            //                       padding:const EdgeInsets.all(15),
                            //                       child: Column(
                            //                         mainAxisAlignment: MainAxisAlignment.center,
                            //                         children: [
                            //                           InkWell(
                            //                             onTap:(){
                            //                               Navigator.of(context).pop();
                            //                             },
                            //                             child: new Container(
                            //                               alignment: Alignment.centerRight,
                            //                               child: SizedBox(
                            //                                 height: 32,
                            //                                 width: 32,
                            //                                 child: Container(
                            //                                     decoration: BoxDecoration(
                            //                                         color: CommonColors.blue,
                            //                                         // border: Border.all(width: 1,color: Colors.black),
                            //                                         borderRadius: BorderRadius.circular(16)
                            //                                     ),
                            //                                     padding: const EdgeInsets.all(10),
                            //                                     child: Image.asset("assets/home_close.png",color: Colors.white,)),),
                            //                             ),
                            //                           ),
                            //                           new SizedBox(height:30),
                            //                           new Container(
                            //                               height:156,
                            //                               width: MediaQuery.of(context).size.width,
                            //                               child: new Row(
                            //                                 mainAxisAlignment: MainAxisAlignment.center,
                            //                                 crossAxisAlignment: CrossAxisAlignment.center,
                            //                                 children: [
                            //                                   ListView.builder(
                            //                                     physics: const AlwaysScrollableScrollPhysics(),
                            //                                     shrinkWrap: true,
                            //                                     itemCount: bottom_packageLike.length,
                            //                                     scrollDirection: Axis.horizontal,
                            //                                     itemBuilder: (ctx,index){
                            //                                       return  InkWell(
                            //                                         onTap: (){
                            //                                           setState(() {
                            //                                             selectindex=index;
                            //                                           });
                            //                                         },
                            //                                         child: Container(
                            //                                           width:MediaQuery.of(context).size.width/3-30,
                            //                                           height: MediaQuery.of(context).size.width/3,
                            //                                           decoration: BoxDecoration(
                            //                                             color: selectindex==index ? Color(0xffC9DEFF):Colors.transparent,
                            //                                             border: Border.all(width: selectindex==index ? 0:1,color: selectindex==index ? Colors.transparent:CommonColors.blue),
                            //                                             borderRadius: BorderRadius.all(
                            //                                                 Radius.circular(10.0) //                 <--- border radius here
                            //                                             ),
                            //                                           ),
                            //                                           child: Column(
                            //                                             // mainAxisAlignment: MainAxisAlignment.center,
                            //                                             // crossAxisAlignment: CrossAxisAlignment.center,
                            //                                             children: [
                            //
                            //
                            //                                               new Expanded(
                            //                                                   flex:3,
                            //                                                   child: Container(child: Column(
                            //                                                     mainAxisAlignment: MainAxisAlignment.center,
                            //                                                     crossAxisAlignment: CrossAxisAlignment.center,
                            //                                                     children: [
                            //                                                       new Container(
                            //                                                         child: Text("${bottom_packageLike[index]}",style: new TextStyle(color: Colors.black.withOpacity(0.7),fontSize: 40,fontWeight: FontWeight.w700),),
                            //                                                       ),
                            //                                                       new Container(
                            //                                                         child: Text("Super Like",style: new TextStyle(color: Colors.black.withOpacity(0.5),fontSize: 14,fontWeight: FontWeight.w700),),
                            //                                                       ),
                            //                                                     ],
                            //                                                   ),)),
                            //                                               if(selectindex!=index) new Container(
                            //                                                 height: 1,
                            //                                                 margin: const EdgeInsets.symmetric(horizontal: 10),
                            //                                                 width: double.infinity,
                            //                                                 color: CommonColors.blue,
                            //                                               ),
                            //                                               Expanded(
                            //                                                 flex:2,
                            //                                                 child: new Container(
                            //                                                   width:double.infinity,
                            //                                                   decoration: BoxDecoration(
                            //                                                       color: selectindex==index ? CommonColors.blue:Colors.transparent,
                            //                                                       borderRadius: BorderRadius.only(bottomLeft: Radius.circular(10.0),bottomRight: Radius.circular(10.0))
                            //                                                   ),
                            //                                                   child: Column(
                            //                                                     mainAxisAlignment: MainAxisAlignment.center,
                            //                                                     crossAxisAlignment: CrossAxisAlignment.center,
                            //                                                     children: [
                            //
                            //                                                       if(bottom_packagediscount[index].isNotEmpty) new Container(
                            //                                                         child: Text("Save ${bottom_packagediscount[index]}%",style: new TextStyle(color: selectindex==index ? Colors.white:Colors.black.withOpacity(0.6),fontSize: 16,fontWeight: FontWeight.w600),),
                            //                                                       ),
                            //                                                       new Container(
                            //                                                         child: Text("${bottom_packageeach[index]}",style: new TextStyle(color:selectindex==index ? Colors.white.withOpacity(0.8): Colors.black.withOpacity(0.5),fontSize: 14,fontWeight: FontWeight.w400),),
                            //                                                       ),
                            //
                            //                                                     ],
                            //                                                   ),
                            //                                                 ),
                            //                                               )
                            //                                             ],
                            //                                           ),
                            //                                         ),
                            //                                       );
                            //                                     },
                            //                                   ),
                            //                                 ],
                            //                               )
                            //                           ),
                            //                           new SizedBox(height:30),
                            //                           new Container(
                            //                             child: Text("${bottom_packageLike[selectindex]} Super Like for ${bottom_packageeach[selectindex]}",style: new TextStyle(color: Colors.black.withOpacity(0.5),fontSize: 20,fontWeight: FontWeight.w600),),
                            //                           ),
                            //                           new SizedBox(height:30),
                            //                         ],
                            //                       ),
                            //                     ),
                            //                   ),
                            //                   Positioned(
                            //                       child:  Container(
                            //                         height:117,
                            //                         width: 117,
                            //                         child: ClipRRect(
                            //                             borderRadius: BorderRadius.circular(90.0),
                            //                             child: Container(
                            //                                 height:117,
                            //                                 width: 117,
                            //                                 color:Colors.blue,
                            //                                 child: Image.asset("assets/star_image.png")
                            //                             )
                            //
                            //
                            //                         ),
                            //                       )
                            //                   )
                            //                 ],
                            //               )
                            //           ),
                            //         );
                            //       },
                            //     );
                            //   },
                            // );


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
                new SizedBox(height: 40,),
              ],
            )
        ),
      )
    );
  }
}