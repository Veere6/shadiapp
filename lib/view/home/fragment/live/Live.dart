import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:shadiapp/CommonMethod/CommonColors.dart';
import 'package:shadiapp/CommonMethod/Toaster.dart';
import 'package:shadiapp/Models/add_live_model.dart';
import 'package:shadiapp/Services/Services.dart';
import 'package:shadiapp/ShadiApp.dart';
import 'package:shadiapp/view/home/fragment/live/LiveRoom.dart';
import 'package:shadiapp/view/home/fragment/live/fragments/LiveScreen.dart';
import 'package:shadiapp/view/home/fragment/live/fragments/MyMatches.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Live extends StatefulWidget {
  @override
  State<Live> createState() => _LiveState();

}

class _LiveState extends State<Live> with TickerProviderStateMixin{

  @override
  Widget build(BuildContext context) {

    TabController _tabController = TabController(length: 2, vsync: this);

    return Scaffold(
     backgroundColor: CommonColors.themeblack,
     body: Container(
       child: Column(
         children: [
           Padding(
             padding: const EdgeInsets.only(top: 50.0),
             child: Row(
               children: [
                 Container(
                   padding: EdgeInsets.only(left: 20),
                   child: Text("LIVE",
                   style: TextStyle(color: Colors.white, fontSize: 20.0),),
                 ),
                 Padding(
                   padding: const EdgeInsets.all(8.0),
                   child: Container(
                     padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 2.0),
                     decoration: BoxDecoration(
                       color: Color(0xffFEDA14),
                       borderRadius: BorderRadius.all(
                           Radius.circular(5.0))
                     ),
                     child: InkWell(
                       onTap: ()async{
                         SharedPreferences _prefs = await SharedPreferences.getInstance();
                         Navigator.of(context).push(
                             MaterialPageRoute(
                                 builder: (context) => LiveRoom(
                                     "https://w0.peakpx.com/wallpaper/396/511/HD-wallpaper-bong-angel-bengali.jpg", '${_prefs.getString(ShadiApp.userId)}', "", true, true
                                 ))
                         );
                       },
                       child: Text("GoLIVE",
                       style: TextStyle(color: Color(0xff1E1E1E), fontSize: 11.0, fontWeight: FontWeight.w600),),
                     ),
                   ),
                 )
               ],
             ),
           ),
           Container(
             height: 30,
             margin: EdgeInsets.only(top: 10.0, left: 20.0, right: 100.0),
             child: TabBar(
               controller: _tabController,
               unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w400,
                   fontSize: 15, color: Color(0xffC4C4C4)),
               labelStyle:  TextStyle(fontWeight: FontWeight.w400,
                   fontSize: 15, color: Colors.white),
               indicator: BoxDecoration(
                   borderRadius: BorderRadius.all(
                       Radius.circular(35.0)),
                   color: CommonColors.buttonorg
               ),
               tabs: [
                 Tab(
                   child: Container(
                     child: Text('Featured'),
                   ),
                 ),
                 Tab(
                     child: Container(
                       child: Text('My Matches'),
                     ))

               ],
             ),
           ),
           Expanded(
               child: Container(
                 child: TabBarView(
                   controller: _tabController,
                   children: [
                     LiveScreen(),
                     MyMatches()
                   ],
                 ),
               )
           )
         ],
       ),
     ),
   );
  }

}