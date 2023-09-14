import 'dart:io';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:shadiapp/CommonMethod/CommonColors.dart';
import 'package:shadiapp/CommonMethod/commonString.dart';
import 'package:shadiapp/Models/matchlist.dart';
import 'package:shadiapp/Models/new_matches_model.dart';
import 'package:shadiapp/ShadiApp.dart';
import 'package:shadiapp/view/home/Home.dart';
import 'package:shadiapp/view/home/fragment/chats/ChatRoom.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shadiapp/Services/Services.dart';



class Chat extends StatefulWidget {
  @override
  State<Chat> createState() => _ChatState();
}
class _ChatState extends State <Chat> {

  @override
  void initState() {
    super.initState();
    getAvailableuser();
    match();
    Getmatch();
  }

  List OneList = [];
  bool isLoading = true;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late SharedPreferences _preferences;
  String user_id="";

  bool isLoad=false;
  late MatchList matchList;
  List<Datum> _matchList=[];
  String user_plan="";
  void Getmatch()async{
    isLoad = true;
    _preferences = await SharedPreferences.getInstance();

    // print(">>>>${user_type}");
    matchList = await Services.MatchListMethod("${_preferences?.getString(ShadiApp.userId).toString()}");
    if(matchList.status == 1) {
      for(var i = 0; i < matchList.data!.length; i++){
        _matchList = matchList.data ?? <Datum> [];
      }
    }
    isLoad = false;
    if(mounted) {
      setState(() {});
    }
  }

  bool listbool=false;
  List<MatchDatum> _list = [];
  late NewMatchesModel _newMatchesModel;
  Future<void> match() async {
    setState(() {
      listbool = true;
    });
    _preferences = await SharedPreferences.getInstance();
    user_plan = "${_preferences?.getString(ShadiApp.user_plan).toString()}";
    _newMatchesModel = await Services.NewMatchesList(_preferences.getString(ShadiApp.userId).toString());
    if(_newMatchesModel.status == 1){
      for(var i = 0; i < _newMatchesModel.data!.length; i++){
        _list = _newMatchesModel.data ?? <MatchDatum> [];
      }
    }
    if(mounted) {
      setState(() {
        listbool = false;
      });
    }
  }


  // bool isonline=false;
  void getAvailableuser() async {
    _preferences = await SharedPreferences.getInstance();
    user_id = "${_preferences?.getString(ShadiApp.userId).toString()}";
    // isonline = _preferences?.getBool(ShadiApp.isOnline) ?? false;
    await _firestore
        .collection('chatroom')
        // .where("uid1", isEqualTo: "${user_id}")
        // .where("uid2",isEqualTo: "${user_id}")
        .get()
        .then((value) {
      print(value.docs);
      OneList = value.docs;
      isLoading = false;
      listbool=false;
      // if(mounted) {
        setState(() {});
      // }
    });
  }





  Future<String> getLastmsg(String id) async {
    String lastmsg = "";
    String type = "";
    // Use await to wait for the query to complete
    await _firestore
        .collection('chatroom')
        .doc(id) // Don't need to use "${id}"
        .collection('chats')
        .orderBy("time", descending: true)
        .limit(1)
        .get()
        .then((QuerySnapshot snapshot) {
      if (snapshot.docs.isNotEmpty) {
        var lastMessage = snapshot.docs.first;
        var messageData = lastMessage.data() as Map<String, dynamic>?;
        // print(messageData);
        if (messageData != null) {
          type = messageData["type"];
          lastmsg = messageData["message"];
        }
      }
    });
    if (type == "text") {
      lastmsg = lastmsg;
    }else if(type == "audio"){
      lastmsg = "audio";
    }else{
      lastmsg = "";
    }
    return lastmsg;
  }

  Future<Timestamp> getLastmsgDate(String id) async {
   late Timestamp lastmsgtime;
    // Use await to wait for the query to complete
    await _firestore
        .collection('chatroom')
        .doc(id) // Don't need to use "${id}"
        .collection('chats')
        .orderBy("time", descending: true)
        .limit(1)
        .get()
        .then((QuerySnapshot snapshot) {
      if (snapshot.docs.isNotEmpty) {
        var lastMessage = snapshot.docs.first;
        var messageData = lastMessage.data() as Map<String, dynamic>?;
        // print(messageData);
        if (messageData != null) {
          print("messageData ${messageData}");
          lastmsgtime = messageData["time"];

          // print("messageData ${lastmsgtime}");
        }
      }
    });
    return lastmsgtime;
  }

  String calculateTimeDifference(Timestamp firestoreTimestamp) {
    // Convert Firestore timestamp to DateTime
    DateTime firestoreDateTime = firestoreTimestamp.toDate();

    // Get the current DateTime
    DateTime currentDateTime = DateTime.now();

    // Calculate the time difference
    Duration difference = currentDateTime.difference(firestoreDateTime);

    // Calculate days, hours, and minutes
    int days = difference.inDays;
    int hours = difference.inHours % 24;
    int minutes = difference.inMinutes % 60;

    if (days > 0) {
      return '${days} D';
    } else if (hours > 0) {
      return '${hours} H';
    } else {
      return '${minutes} M';
    }
  }

  // Duration calculateTimeDifferenceFromString(Timestamp firestoreTimestamp) {
  //   // Split the string to extract seconds and nanoseconds
  //   // List<String> parts = timestampString.split(',');
  //   // int seconds = int.parse(parts[0].substring(parts[0].indexOf('=') + 1));
  //   // int nanoseconds = int.parse(parts[1].trim().substring(parts[1].indexOf('=') + 1));
  //
  //   // Create a Firestore Timestamp object
  //   // Timestamp firestoreTimestamp = Timestamp(seconds, nanoseconds);
  //
  //   // Convert Firestore timestamp to DateTime
  //   DateTime firestoreDateTime = firestoreTimestamp.toDate();
  //
  //   // Get the current DateTime
  //   DateTime currentDateTime = DateTime.now();
  //
  //   // Calculate the time difference
  //   Duration difference = currentDateTime.difference(firestoreDateTime);
  //
  //   return difference;
  // }





  Future<int> getUnreadMessageCount(String room_id) async {
    int unreadCount = 0;

    var snapshot = await FirebaseFirestore.instance
        .collection('chatroom')
        .doc(room_id)
        .collection('chats');

    var querySnapshot = await snapshot
        .where('uid',isNotEqualTo: user_id)
        .where('read',isEqualTo: false)
        .get();
    print("object gfds ${querySnapshot.docs.length}");
    unreadCount = querySnapshot.size;
    // if (snapshot.docs.isNotEmpty) {
    //   var lastMessage = snapshot.docs as List;
    //   for(var item in lastMessage){
    //     if(item["uid"]!=user_id) {
    //       if (item["read"] == false) {
    //         unreadCount = unreadCount + 1;
    //       }
    //     }
    //   }
    //   // var messageData = lastMessage;
    //   print(unreadCount);
    // }

    // unreadCount = snapshot.docs.length;
    print("unreadCount ${unreadCount}");
    return unreadCount;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CommonColors.themeblack,
      endDrawer: Drawer(
        width: 180,
        backgroundColor: CommonColors.matchDrawer,
    child: ListView(
    padding: EdgeInsets.zero,
      children: <Widget>[
        Container(
          margin: EdgeInsets.only(top: 70.0),
          child: Text(
              'My Matches',
              style: TextStyle(fontSize: 16.0, color: CommonColors.buttonorg),
              textAlign: TextAlign.center,
            ),
        ),
        Expanded(
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height-150,
            child: Container(
                  height: double.maxFinite,
                  child: ListView.builder(
                      itemCount: _matchList.length,
                      physics: AlwaysScrollableScrollPhysics(),
                      itemBuilder: (BuildContext context, i) {
                        return ListTile(
                          title: Container(
                            width: 120,
                            height: 150,
                            margin: EdgeInsets.fromLTRB(10, 0, 10, 20),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(
                                  Radius.circular(15.0)),
                              color: CommonColors.bottomgrey,
                            ),
                            child:
                            ClipRRect(
                                borderRadius: BorderRadius.circular(15.0),
                                child: Image.network("${_matchList[i].image}",
                                  fit: BoxFit.cover,
                                )
                            ),
                          ),
                        );
                      }
                  )
              ),
          ),
        )
      ],
    ),
    ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: MediaQuery.of(context).padding.top+15,),
            Row(
              children: [
                // Container(
                //   margin: const EdgeInsets.symmetric(horizontal: 10,vertical: 0),
                //   alignment: Alignment.centerLeft,
                //   // child: InkWell(
                //   //   onTap: (){
                //   //     Navigator.of(context).pop();
                //   //   },
                //   //   child: Padding(
                //   //     padding: const EdgeInsets.all(10.0),
                //   //     child: Image.asset(
                //   //       'assets/back_icon.png',
                //   //     ),
                //   //   ),
                //   // ),
                // ),
                Spacer(),
                InkWell(
                  onTap:(){
                    Navigator.of(context).pushNamed('MatchPro');
                  },
                  child: SizedBox(
                    width: 20,
                    height: 24,
                    child: Image.asset("assets/shield_pro.png",height:24,width: 20,),
                  ),
                ),
                SizedBox(
                  width: 15,
                ),
                InkWell(
                  onTap: (){
                    Navigator.of(context).pushNamed("Settings");
                  },
                  child: SizedBox(
                    width: 22,
                    height: 24,
                    child: Image.asset("assets/setting_pro.png",height:24,width: 22,color: Colors.white,),
                  ),
                ),
                SizedBox(
                  width: 24,
                ),
              ],
            ),
            if(_list.isNotEmpty) Container(
                margin: EdgeInsets.symmetric(horizontal: 35.0),
                child: Text("Likes you ${_list.length}",
                  style: TextStyle(color: CommonColors.buttonorg),
                ),
              ),
            if(_list.isNotEmpty) Container(
              margin: EdgeInsets.only(left: 25.0, top: 10.0, right: 0.0, bottom: 10.0),
              height: 100,
              child: ListView.builder(
                  itemCount: _list.length,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index){
                    MatchDatum data = _list[index];
                    return InkWell(
                      onTap: (){
                        if(user_plan=="Gold" || user_plan=="Vip"){
                          print(user_plan);
                          CommonString.homesearch = "${data.id}";
                          Navigator.pushReplacement(context,
                              MaterialPageRoute(builder: (context) => Home()));
                        }
                      },
                      child: Container(
                        margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                        padding: const EdgeInsets.all(2),
                        decoration: index==0 ? BoxDecoration(
                            borderRadius: BorderRadius.all(
                                Radius.circular(15.0)),
                          border: Border.all(color: Colors.yellow,width: 2)
                        ):null,
                        child: Container(
                          width: 80,
                          height: 97,
                          child: Stack(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.all(
                                      Radius.circular(15.0)),
                                  color: CommonColors.bottomgrey,
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(15.0),
                                  child: Container(
                                      decoration: BoxDecoration(
                                          image: DecorationImage(
                                              image: NetworkImage("${data.image}"),
                                              fit: BoxFit.cover)
                                      ),
                                      child: Column(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Spacer(),
                                            Container(
                                              color: Colors.white30,
                                              child: Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 5.0),
                                                child: Row(
                                                  children: [
                                                    Expanded(
                                                      child: Text("${data.firstName}, ${data.age.toString().substring(0,2)}",
                                                        style: TextStyle(color: Colors.white,fontWeight: FontWeight.w600),maxLines: 1,),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ]
                                      )
                                  ),
                                ),
                              ),
                             if(user_plan!="Gold" && user_plan!="Vip")
                               Positioned.fill(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(15.0),
                                  child: BackdropFilter(
                                    filter: ImageFilter.blur(
                                      sigmaX: 3.0,
                                      sigmaY: 3.0,
                                    ),
                                    child: Container(
                                      color: Colors.black.withOpacity(0.2),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
            ),
            listbool==false ? Expanded(
              child: Container(
                child:
              isLoad==false ?  matchList?.data?.isEmpty ?? false ?
                Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset("assets/no_chat_icon.png",),
                        SizedBox(height: 20,),
                        Text("No Chat", style: TextStyle(fontSize: 16, fontFamily: 'dubai', color: CommonColors.buttonorg, fontWeight: FontWeight.bold),textAlign: TextAlign.center,),
                      ],
                    )
                ) :
                ListView.builder(
                    itemCount: OneList.length,
                    scrollDirection: Axis.vertical,
                    itemBuilder: (context, index) {
                      bool isvisible=false;
                      String members= OneList[index]["uid1"];
                      String members2= OneList[index]["uid2"];
                      String membersn= OneList[index]["user1"];
                      String membersn2= OneList[index]["user2"];
                      String image1= OneList[index]["image1"];
                      String image2= OneList[index]["image2"];
                      bool isOnline= OneList[index]["isOnline"] ?? false;
                      String id= OneList[index]["id"];
                      if(members==user_id || members2==user_id){
                        isvisible = true;
                      }
                      String username = "";
                      String useriamge = "";
                      String userid = "";

                      if(members==user_id){
                        username = membersn2;
                        useriamge = image2;
                        userid = members2;
                      }else if(members2==user_id){
                        username = membersn;
                        useriamge = image1;
                        userid = members;
                      }

                      print("isVisible :${isvisible}");
                      return isvisible==true ? Container(
                        width: MediaQuery.of(context).size.width,
                        child: Column(
                          children: [
                            Container(
                              height: 1,
                              color: Colors.white30,
                            ),
                            InkWell(
                              onTap: (){
                                // print(">>>${_matchList[index].id}");
                                Navigator.of(context).push(
                                    MaterialPageRoute(
                                        builder: (context) => ChatRoom(useriamge,id,id,"${username}","")
                                    )
                                );
                              },
                              child: Container(
                                // decoration:index==0 ? BoxDecoration(
                                //   color: Color(0xff373737),
                                //   borderRadius: BorderRadius.all(Radius.circular(10))
                                // ):null,
                                margin: EdgeInsets.only(top: 2,bottom: 5),
                                padding: EdgeInsets.only(top: 10,bottom: 10,left: 35),
                                child: Row(
                                  children: [
                                    Container(
                                      height: 62,
                                      child: CircleAvatar(
                                        radius: 31,
                                        // backgroundImage: NetworkImage(_matchList[index].image ?? ""),
                                        backgroundImage: NetworkImage(useriamge),
                                        backgroundColor: CommonColors.bottomgrey,
                                      ),
                                    ),
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              margin: EdgeInsets.only(left: 13.0),
                                              child: Text("${username}",
                                              // child: Text("${_matchList[index].firstName} ${_matchList[index].lastName}",
                                                style: TextStyle(
                                                  color: Colors.white, fontSize: 16,
                                                    fontWeight: FontWeight.w500, fontStyle: FontStyle.normal
                                                ),
                                              )
                                            ),
                                            SizedBox(width: 10,),
                                           if(isOnline==true) StreamBuilder(
                                              stream: FirebaseDatabase.instance
                                                  .reference()
                                                  .child('users/${userid}/status')
                                                  .onValue,
                                              builder: (context, snapshot) {
                                                if (snapshot.hasData) {
                                                  final status = snapshot.data?.snapshot.value;
                                                  final isOnline = status == 'online';
                                                  return CircleAvatar(
                                                    backgroundColor: isOnline ? Colors.green : Colors.grey,
                                                    radius: 5.0,
                                                  );
                                                }else{
                                                  return CircleAvatar(
                                                    backgroundColor: Colors.grey,
                                                    radius: 5.0,
                                                  );
                                                }
                                                // Loading indicator
                                              },
                                            ),

                                          ],
                                        ),
                                        FutureBuilder<String>(
                                          future: getLastmsg(id),
                                          builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                                            if (snapshot.connectionState == ConnectionState.waiting) {
                                              // While the future is still running, display a loading indicator or placeholder.
                                              return Text('');
                                            } else if (snapshot.hasError) {
                                              // Handle any error that occurred.
                                              return Text('');
                                            } else {
                                              // The future is complete and the data is available.
                                              return Container(
                                                  margin: EdgeInsets.only(left: 13.0),
                                                  child: Text(snapshot.data ?? "",
                                                    style: TextStyle(
                                                        color: Colors.white30, fontSize: 16,
                                                        fontFamily: "OpenSans_Regular",
                                                        fontWeight: FontWeight.w400, fontStyle: FontStyle.normal
                                                    ),
                                                  )
                                              );
                                            }
                                          },
                                        )

                                      ],
                                    ),
                                    Spacer(),
                                    FutureBuilder<int>(
                                      future: getUnreadMessageCount(id),
                                      builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
                                        if (snapshot.connectionState == ConnectionState.waiting) {
                                          // While the future is still running, display a loading indicator or placeholder.
                                          return Text('');
                                        } else if (snapshot.hasError) {
                                          // Handle any error that occurred.
                                          return Text('');
                                        } else {
                                          // The future is complete and the data is available.
                                          return
                                            snapshot.data != 0 ?
                                            Container(
                                              height: 26,
                                              width: 26,
                                              margin: EdgeInsets.only(right: 45.0),
                                              decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(20),
                                                  color:CommonColors.themeblack
                                              ),
                                              alignment: Alignment.center,
                                              child: Text("${snapshot.data.toString()}",
                                                style: TextStyle(
                                                    color: Color(0xffEF7D90), fontSize: 15,fontWeight: FontWeight.w400
                                                ),
                                                textAlign: TextAlign.center,
                                              )
                                          ):
                                            Container(
                                                alignment: Alignment.topCenter,
                                                margin: EdgeInsets.only( right: 45.0,),
                                                child:
                                                FutureBuilder<Timestamp>(
                                                  future: getLastmsgDate(id),
                                                  builder: (BuildContext context, AsyncSnapshot<Timestamp> snapshot) {
                                                    if (snapshot.connectionState == ConnectionState.waiting) {
                                                      // While the future is still running, display a loading indicator or placeholder.
                                                      return Text('');
                                                    } else if (snapshot.hasError) {
                                                      // Handle any error that occurred.
                                                      return Text('');
                                                    } else {
                                                      // The future is complete and the data is available.
                                                      return
                                                        // Text("${DateTime.now().difference(snapshot.data).inHours}h",
                                                        Text("${calculateTimeDifference(snapshot.data ?? Timestamp.now())}",
                                                          style: TextStyle(
                                                              color: Colors.white30, fontSize: 12,fontWeight: FontWeight.w400
                                                          ),
                                                          textAlign: TextAlign.center,
                                                        );
                                                    }
                                                  },
                                                )

                                            );
                                        }
                                      },
                                    )
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                      ):Container();
                    }
                    ):Container(),
              ),
            ) :
            Expanded(child: Center(child: CircularProgressIndicator(),))
          ],
        ),
      ),
    );
  }

}