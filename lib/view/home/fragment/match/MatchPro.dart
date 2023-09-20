import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shadiapp/CommonMethod/CommonColors.dart';
import 'package:shadiapp/CommonMethod/StarRating.dart';
import 'package:shadiapp/CommonMethod/Toaster.dart';
import 'package:shadiapp/CommonMethod/commonString.dart';
import 'package:shadiapp/Models/new_matches_model.dart';
import 'package:shadiapp/Services/Services.dart';
import 'package:shadiapp/ShadiApp.dart';
import 'package:shadiapp/view/home/Home.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:swipe_cards/draggable_card.dart';
import 'package:swipe_cards/swipe_cards.dart';
import 'package:url_launcher/url_launcher.dart';

class MatchPro extends StatefulWidget {
  @override
  State<MatchPro> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MatchPro> {

  bool ActiveConnection = false;
  late SharedPreferences _preferences;
  late NewMatchesModel _newMatchesModel;
  bool isLoad = false;
  List<MatchDatum> _list = [];

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

  String user_plan="";
  String plan="";
  Future<void> match() async {
    isLoad = true;
    _preferences = await SharedPreferences.getInstance();
    user_plan = _preferences.getString(ShadiApp.userId).toString();
    plan = _preferences.getString(ShadiApp.user_plan).toString();
    _newMatchesModel = await Services.NewMatchesList(_preferences.getString(ShadiApp.userId).toString());
    if(_newMatchesModel.status == 1){
      for(var i = 0; i < _newMatchesModel.data!.length; i++){
        _list = _newMatchesModel.data ?? <MatchDatum> [];
      }
    }
    isLoad = false;
    setState(() {
    });
  }

  @override
  void initState() {
    CheckUserConnection();
    match();
    super.initState();
  }

  List<Color> colorList=[CommonColors.buttonorg,CommonColors.yellow,CommonColors.bluepro,CommonColors.green];
  List<String> packagetittle=["Premium","Gold","VIP","Free"];
  int selectindex = 0 ;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CommonColors.themeblack,
      body: SafeArea(
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Column(
            children: [
              new SizedBox(
                height: 15,
              ),
              new Container(
                child: Row(
                  children: [
                    new Spacer(),
                    // new SizedBox(
                    //   width: 24,
                    //   height: 24,
                    //   child: Image.asset("assets/shield_pro.png",height:24,width: 20,),
                    // ),
                    // new SizedBox(
                    //   width: 15,
                    // ),
                    InkWell(
                      onTap: (){
                        Navigator.of(context).pushNamed("Settings");
                      },
                      child: new SizedBox(
                        width: 24,
                        height: 24,
                        child: Image.asset("assets/setting_pro.png",height:24,width: 20,color: Colors.white,),
                      ),
                    ),
                    new SizedBox(
                      width: 24,
                    ),
                  ],
                ),
              ),
              new SizedBox(height: 30,),
              new Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                alignment: Alignment.centerLeft,
                child: Text("New Likes",style: new TextStyle(fontWeight: FontWeight.w600,fontSize: 20,color:Colors.white),),
              ),
              new Container(
                height: MediaQuery.of(context).size.width/2,
                width: MediaQuery.of(context).size.width,
                child: isLoad ? Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 3.0,
                  ),
                ):
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _list.isNotEmpty ? plan == "Free"? Container(
                      child: Text("Please Purchase Any Package",style: TextStyle(color: Colors.white),),
                    ):Expanded(
                      child: ListView.builder(
                        // shrinkWrap: true,
                        itemCount: _list.length,
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (ctx,index){
                          MatchDatum data = _list[index];
                          int position=0;
                          if("Premium"==data.plan){
                            position=0;
                          }else if("Vip"==data.plan){
                            position=2;
                          }else if("Gold"==data.plan){
                            position=1;
                          }else{
                            position=3;
                          }

                          return selectindex==index ? InkWell(
                            onTap: (){
                              setState(() {
                                selectindex=index;
                              });
                              if(user_plan=="Gold" || user_plan=="Vip"){
                                print(user_plan);
                                CommonString.homesearch = "${data.id}";
                                Navigator.pushReplacement(context,
                                    MaterialPageRoute(builder: (context) => Home()));
                              }
                            },
                            child: InkWell(
                                onTap: (){
                                    print(user_plan);
                                    CommonString.homesearch = "${data.id}";
                                    Navigator.pushReplacement(context,
                                        MaterialPageRoute(builder: (context) => Home()));
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
                                          border: Border.all(width: 1,color: colorList[position]),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(15.0) //                 <--- border radius here
                                          ),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(10),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(15.0),
                                            child: Image.network(data.image.toString(),fit: BoxFit.cover,height: 180,width: 180,),
                                          ),
                                        ),
                                      ),
                                    ),

                                    // Positioned(
                                    //   bottom: 0,
                                    //   child: Container(
                                    //       margin: const EdgeInsets.only(right: 5,top:5),
                                    //       decoration: BoxDecoration(
                                    //         color: colorList[position],
                                    //         borderRadius: BorderRadius.circular(30),
                                    //       ),
                                    //       padding: const EdgeInsets.symmetric(horizontal: 12,vertical: 3),
                                    //       child: Row(
                                    //         mainAxisSize: MainAxisSize.min,
                                    //         // children: [
                                    //         //   Text("${data.plan}",style: new TextStyle(fontSize: 11,fontWeight: FontWeight.w700,color: Colors.white),),
                                    //         // ],
                                    //       )
                                    //   ),
                                    // ),
                                  ],
                                ),
                              ),
                            ),
                          ):InkWell(
                            onTap: (){
                              setState(() {
                                selectindex=index;
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
                                        // border: Border.all(width: 1,color: colorList[position]),
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(15.0) //                 <--- border radius here
                                        ),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(10),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(15.0),
                                          child: Image.network(data.image.toString(),fit: BoxFit.cover,height: 180,width: 180,),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    )
                        : Container(
                      child: Text("No Likes Found",style: TextStyle(color: Colors.white),),
                    )
                  ],
                ),
              ),
              new SizedBox(height:15,),
              Spacer(),
              new SizedBox(
                height:206,
                width:157,
                child:Image.asset("assets/drop_pro2.png",height: 206,width: 157,fit: BoxFit.cover,),
              ),
              new SizedBox(height: 27,),
              Container(
                height: 50,
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  // color: CommonColors.buttonorg,
                  border: Border.all(width: 1,color: Colors.white),
                  borderRadius:
                  const BorderRadius.all(Radius.circular(25)),
                ),
                child: Stack(
                  children: <Widget>[
                    Row(
                      children: <Widget>[

                        Expanded(
                            child: Center(
                              child: Text("Start Liking", style: TextStyle(
                                  color: Colors.white, fontSize: 20),),
                            )),
                      ],
                    ),
                    SizedBox.expand(
                      child: Material(
                        type: MaterialType.transparency,
                        child: InkWell(onTap: () {
                          Navigator.of(context).pushNamedAndRemoveUntil(
                            'Home',
                                (Route<dynamic> route) => false,
                          );
                          // Navigator.of(context).pushNamed("Home");
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
          ),
        ),
      )
    );
  }
}