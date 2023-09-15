import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:carousel_indicator/carousel_indicator.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shadiapp/CommonMethod/CommonColors.dart';
import 'package:shadiapp/CommonMethod/StarRating.dart';
import 'package:shadiapp/CommonMethod/Toaster.dart';
import 'package:shadiapp/CommonMethod/commonString.dart';
import 'package:shadiapp/Models/add_location_model.dart';
import 'package:shadiapp/Models/age_height_range_model.dart';
import 'package:shadiapp/Models/like_model.dart';
import 'package:shadiapp/Models/user_detail_model.dart';
import 'package:shadiapp/Models/user_list_model.dart';
import 'package:shadiapp/Models/user_view_preference_model.dart';
import 'package:shadiapp/Models/view_image_model.dart';
import 'package:shadiapp/Services/Services.dart';
import 'package:shadiapp/ShadiApp.dart';
import 'package:shadiapp/view/home/fragment/ShowBottomSheet.dart';
import 'package:shadiapp/view/home/fragment/homesearch/Content.dart';
import 'package:shadiapp/view/home/fragment/homesearch/customlayout/Customlayout.dart';
import 'package:shadiapp/view/home/fragment/homesearch/customlayout/Customlayoutview.dart';
import 'package:shadiapp/view/home/fragment/match/Match.dart';
import 'package:shadiapp/view/home/fragment/profile/Profile.dart';
import 'package:share/share.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:swipe_cards/draggable_card.dart';
import 'package:swipe_cards/swipe_cards.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeSearch extends StatefulWidget {
  @override
  State<HomeSearch> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<HomeSearch> {

  bool ActiveConnection = false;
  String T = "";
  SharedPreferences? _preferences;
  late UserListModel _userListModel;
  late UserViewPreferenceModel _viewPreferenceModel;
  late LikeModel _likeModel;
  late UserDetailModel _userDetailModel = UserDetailModel();
  late AddLocationModel _addLocationModel;
  late PersistentBottomSheetController _bottomSheetController; // instance variable
  List<UserDatum> _userList = [];
  List<PrefsDatum> intrest = [];
  bool clickLoad = false;
  bool isLoad = false;

  String user_id = "";
  String name = "";
  String lastName = "";
  String age = "";
  String place = "";
  String country = "";
  String height = "";
  String weight = "";
  String religion = "";
  String maratialStatus = "";
  String type = "";
  String image = "";

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

  // Future<void> userList() async {
  //   isLoad = true;
  //   _preferences = await SharedPreferences.getInstance();
  //   _userListModel = await Services.GetUserMethod("${_preferences?.getString(ShadiApp.userId)}",CommonString.homesearch);
  //   if(_userListModel.status == 1){
  //     CommonString.homesearch=="";
  //     for(var i = 0; i < _userListModel.data!.length; i++){
  //       _userList = _userListModel.data ?? <UserDatum> [];
  //     }
  //   }
  //   isLoad = false;
  //   setState(() {
  //   });
  // }

  Future<void> userDetail() async {
    setState(() {
      clickLoad = true;
    });
    _preferences = await SharedPreferences.getInstance();
    _userDetailModel = await Services.UserDetailMethod("${_preferences?.getString(ShadiApp.userId).toString()}");
    if(_userDetailModel.status == 1){
      _preferences?.setString(ShadiApp.user_plan, _userDetailModel.data?[0].plan ?? "");
      user_id = _userDetailModel.data![0].id.toString();
      name = _userDetailModel.data![0].firstName.toString();
      lastName = _userDetailModel.data![0].lastName.toString();
      age = _userDetailModel.data![0].age.toString();
      place = _userDetailModel.data![0].city.toString();
      country = _userDetailModel.data![0].country.toString();
      height = _userDetailModel.data![0].height.toString();
      weight = _userDetailModel.data![0].weight.toString();
      image = _userDetailModel.data![0].image.toString();
      maratialStatus = _userDetailModel.data![0].maritalStatus.toString();
    }

   setState(() {
     clickLoad = false;
   });
  }
  Future<void> userViewPreference(String id) async {
    _viewPreferenceModel = await Services.ViewUserPreference(id);
    if(_viewPreferenceModel.status == 1){
      for (int i = 0; i < _viewPreferenceModel.data!.length; i++){
        intrest = _viewPreferenceModel.data ?? <PrefsDatum> [];
      }
    }
    setState(() {

    });
  }

  bool isLikeLoad=false;
  Future<void> like(String id, String type,String image,other_image,fullname,bool isonline) async {
    print(fullname);
    setState((){
      isLikeLoad=true;
    });
    _preferences = await SharedPreferences.getInstance();
    _likeModel = await Services.LikeMethod(_preferences!.getString(ShadiApp.userId).toString(), id, type);
    if(_likeModel.status == 1){
      if (_likeModel.data![0].matched == true) {
        Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => Match(
                image,other_image,_likeModel.data![0].id.toString(),fullname,"${name} ${lastName}","${user_id}",id,isonline
            ))
        );
      }
      // Toaster.show(context, _likeModel.message.toString());
    }else if(_likeModel.status==0){
      Toaster.show(context, _likeModel.message.toString());
      try {
        _matchEngine.rewindMatch();
      }catch(error){}
      Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => Profile(isback:true)
          )
      );
    }
    setState((){
      isLikeLoad=false;
    });
  }

  Future<void> location() async {
    var status = await Permission.location.request();
    if(status  == PermissionStatus.granted){
      _preferences = await SharedPreferences.getInstance();
      final currentLocation = await Geolocator.getCurrentPosition();
      _addLocationModel = await Services.AddLocation({"userId":"${_preferences?.getString(ShadiApp.userId)}","lng":"${currentLocation.longitude}","lat":"${currentLocation.latitude}"});
    }else if (status == PermissionStatus.denied) {
      // Permission denied
    } else if (status == PermissionStatus.permanentlyDenied) {
      // Permission permanently denied, take the user to app settings
    }
    setState(() {

    });
  }

  @override
  void initState() {
    userDetail();
    CheckUserConnection();
    Getdata("");
    location();
    // userList();
    super.initState();
  }

  late Content content;
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  List<SwipeItem> _swipeItems = <SwipeItem>[];
  late MatchEngine _matchEngine = MatchEngine();

  bool isshowhome=false;
  void Getdata(String my_id) async{
    // String jsonStu = jsonEncode(datastring);
    // var data = jsonDecode(jsonStu);
    // content = Content.fromJson(data);
    setState(() {
      isLoad=true;
    });
    setState(() {
      isshowhome=false;
    });
    _preferences = await SharedPreferences.getInstance();

    _userListModel = await Services.GetUserMethod("${_preferences?.getString(ShadiApp.userId)}",CommonString.homesearch,my_id,"${_preferences?.getString(ShadiApp.fToken)}");
    if(_userListModel.status==1) {
      CommonString.homesearch=="";
      if (_userListModel.data!.isNotEmpty) {
        showOnlineStatus(_userListModel?.data?.first?.id ?? "");
        for (int i = 0; i < _userListModel.data!.length; i++) {
          _userList = _userListModel.data ?? <UserDatum>[];
          _swipeItems.add(
              SwipeItem(
                  content: _userList.length,
                  likeAction: () {
                    // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    //   content: Text("Liked"),
                    //   duration: Duration(milliseconds: 500),
                    // ));
                    // print("objectLike");
                    type = "like";
                  },
                  nopeAction: () {
                    // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    //   content: Text("Nope"),
                    //   duration: Duration(milliseconds: 500),
                    // ));
                    type = "disLike";
                  },
                  superlikeAction: () {
                    // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    //   content: Text("Superliked"),
                    //   duration: Duration(milliseconds: 500),
                    // ));
                    type = "superLike";
                  },
                  onSlideUpdate: (SlideRegion? region) async {
                    // Toaster.show(context, "Region $region");
                  }));
        }
      }
    }
    _matchEngine = MatchEngine(swipeItems: _swipeItems);
    isshowhome=true;
    if(mounted) {
      setState(() {
        print("works");
      });
    }
    setState(() {
      isLoad=false;
    });
  }


  void showProfile(String image, String id){
    showBottomSheet(
      context: context,
      backgroundColor: CommonColors.themeblack,
      elevation: 10,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      builder: (context) {
        return  ShowBottomSheet(image, id);
      },
    );
  }

  StreamController<String>  _controller = StreamController<String>.broadcast();

  void showOnlineStatus(String userId) {
    FirebaseDatabase.instance
        .reference()
        .child('users/$userId/status')
        .onValue
        .listen((DatabaseEvent event) {
      final status = event.snapshot.value.toString();
      _controller.sink.add(status); // Update the stream with the status
    }, onError: (Object error) {
      print('Error getting online status: $error');
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: CommonColors.themeblack,
      body: Container(
          child: isLoad ? Center(
            child: CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 3.0,
            ),
          ):Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset("assets/no_match_icon.png",),
                        SizedBox(height: 20,),
                        Text("No more profile available", style: TextStyle(fontSize: 16, fontFamily: 'dubai', color: CommonColors.buttonorg, fontWeight: FontWeight.bold),textAlign: TextAlign.center,),
                      ],
                    )
                ),
                if(isshowhome) Container(
                  height: MediaQuery.of(context).size.height - 60,
                  child: SwipeCards(
                    matchEngine: _matchEngine,
                    itemBuilder: (BuildContext context, int index) {
                      UserDatum datum =  _userList[index];
                      return  Stack(
                        alignment: Alignment.bottomCenter,
                        children: [
                          Container(
                            color:Colors.grey,
                            height:MediaQuery.of(context).size.height-60,
                            width: MediaQuery.of(context).size.width,
                            child:FadeInImage.assetNetwork(
                                placeholder: 'assets/home_placeholder.jpeg',
                                image:"${_userList[index].image}",
                              fit: BoxFit.cover,
                            )
                            // Image.network("${_swipeItems[index].content.image}",fit: BoxFit.cover),
                          ),
                          Container(
                            height: MediaQuery.of(context).size.height/3,
                            width: MediaQuery.of(context).size.width,
                            padding:const EdgeInsets.only(left: 50,right: 30),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Colors.transparent, Colors.black],
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Container(
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      InkWell(
                                        onTap:(){
                                        },
                                        child: Container(
                                          height: 50,
                                          width: 50,
                                          margin: const EdgeInsets.only(right: 20),
                                          decoration: BoxDecoration(
                                            color: CommonColors.white,
                                            borderRadius: const BorderRadius.all(Radius.circular(25)),
                                          ),
                                          child: Stack(
                                            children: <Widget>[
                                              Center(
                                                  child: Image.asset("assets/home_back.png",color: Colors.black,height: 21,width: 21,)
                                              ),
                                              SizedBox.expand(
                                                child: Material(
                                                  type: MaterialType.transparency,
                                                  child: InkWell(onTap: () {
                                                    Getdata("${_preferences?.getString(ShadiApp.userId)}");
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
                                      ),
                                      Spacer(),
                                      InkWell(
                                        onTap:(){
                                          if(!isLikeLoad) {
                                            _matchEngine.currentItem?.nope();
                                            like(
                                                _userList![index].id.toString(),
                                                "disLike", image,
                                                _userList![index].image,
                                                "${_userList[index]
                                                    .firstName![0]
                                                    .toUpperCase() +
                                                    _userList[index].firstName!
                                                        .substring(
                                                        1)} ${_userList[index]
                                                    .lastName![0]
                                                    .toUpperCase() +
                                                    _userList[index].lastName!
                                                        .substring(1)}",
                                                _userList![index].isOnline ??
                                                    false);
                                          }
                                        },
                                        child: Container(
                                          height: 50,
                                          width: 50,
                                          margin: const EdgeInsets.only(right: 20),
                                          decoration: BoxDecoration(
                                            color: CommonColors.red,
                                            borderRadius: const BorderRadius.all(Radius.circular(25)),
                                          ),
                                          child: Stack(
                                            children: <Widget>[
                                              Center(
                                                  child: Image.asset("assets/home_close.png",color: Colors.white,height: 21,width: 21)
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Spacer(),
                                      InkWell(
                                        onTap:(){
                                          if(!isLikeLoad) {
                                            _matchEngine!.currentItem
                                                ?.superLike();
                                            like(
                                                _userList![index].id.toString(),
                                                "superLike", image,
                                                _userList![index].image,
                                                "${_userList[index]
                                                    .firstName![0]
                                                    .toUpperCase() +
                                                    _userList[index].firstName!
                                                        .substring(
                                                        1)} ${_userList[index]
                                                    .lastName![0]
                                                    .toUpperCase() +
                                                    _userList[index].lastName!
                                                        .substring(1)}",
                                                _userList![index].isOnline ??
                                                    false);
                                          }
                                          },
                                        child: Container(
                                          height: 50,
                                          width: 50,
                                          margin: const EdgeInsets.only(right: 20),
                                          decoration: BoxDecoration(
                                            color: CommonColors.blue,
                                            borderRadius: const BorderRadius.all(Radius.circular(25)),
                                          ),
                                          child: Stack(
                                            children: <Widget>[
                                              Center(
                                                  child: Image.asset("assets/home_star.png",color: Colors.white,height: 27,width: 27)
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Spacer(),
                                      InkWell(
                                        onTap:(){
                                          if(!isLikeLoad) {
                                            print("like");
                                            _matchEngine!.currentItem?.like();
                                            like(
                                                _userList![index].id.toString(),
                                                "like", image,
                                                _userList![index].image,
                                                "${_userList[index]
                                                    .firstName![0]
                                                    .toUpperCase() +
                                                    _userList[index].firstName!
                                                        .substring(
                                                        1)} ${_userList[index]
                                                    .lastName![0]
                                                    .toUpperCase() +
                                                    _userList[index].lastName!
                                                        .substring(1)}",
                                                _userList![index].isOnline ??
                                                    false);
                                          }
                                          },
                                        child: Container(
                                          height: 50,
                                          width: 50,
                                          margin: const EdgeInsets.only(right: 20),
                                          decoration: BoxDecoration(
                                            color: CommonColors.green,
                                            borderRadius: const BorderRadius.all(Radius.circular(25)),
                                          ),
                                          child: Stack(
                                            children: <Widget>[
                                              Center(
                                                  child: Image.asset("assets/home_like.png",color: Colors.white,height: 29,width: 29)
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      // Spacer(),
                                    ],
                                  ),
                                ),
                                Container(
                                  child: Row(
                                    children: [
                                      // new SizedBox(width: 40,),
                                      Expanded(
                                          child: Container(
                                            child: Column(
                                              children: [
                                                SizedBox(height: 15,),
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: Container(
                                                        alignment: Alignment.topLeft,
                                                        // margin: const EdgeInsets.symmetric(horizontal: 20),
                                                        child: Row(
                                                          children: [
                                                           if(_userList[index].firstName.toString()!="null" && _userList[index].firstName.toString()!="")
                                                             Text(
                                                              "${_userList[index].firstName![0].toUpperCase() + _userList[index].firstName!.substring(1)}",
                                                              style: TextStyle(
                                                                color: Colors.white,
                                                                fontSize: 20,
                                                                fontWeight: FontWeight.w900,
                                                                // height: 1.4
                                                              ),
                                                              textAlign: TextAlign.left,
                                                            ),
                                                           if(_userList[index].lastName.toString()!="null" && _userList[index].lastName.toString()!="")
                                                             Text(
                                                              " ${_userList[index].lastName![0].toUpperCase() + _userList[index].lastName!.substring(1)}",
                                                              style: TextStyle(
                                                                color: Colors.white,
                                                                fontSize: 20,
                                                                fontWeight: FontWeight.w900,
                                                                // height: 1.4
                                                              ),
                                                              textAlign: TextAlign.left,
                                                            ),
                                                           if(_userList[index].age.toString()!="null" || _userList[index].age.toString()!="")
                                                             Text(
                                                               "  ${_userList[index].age ?? ""}",
                                                              style: TextStyle(
                                                                color: Colors.white,
                                                                fontSize: 20,
                                                                fontWeight: FontWeight.w900,
                                                                // height: 1.4
                                                              ),
                                                              textAlign: TextAlign.left,
                                                            ),
                                                            SizedBox(width: 10,),
                                                            if(_userList[index].isOnline==true) StreamBuilder(
                                                              stream: _controller.stream,
                                                              builder: (context, snapshot) {
                                                                if (snapshot.hasData) {
                                                                  final status = snapshot.data;
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
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: Container(
                                                        alignment: Alignment.topLeft,
                                                        // margin: const EdgeInsets.symmetric(horizontal: 20),
                                                        child: Row(
                                                          children: [
                                                            if(_userList[index].city.toString()!="null" && _userList[index].city.toString()!="") Flexible(
                                                              child: Text(
                                                               "${_userList[index].city}",
                                                                style: TextStyle(
                                                                  color: CommonColors.lightblue,
                                                                  fontSize: 14,
                                                                  fontWeight: FontWeight.w800,
                                                                ),
                                                                overflow: TextOverflow.ellipsis,
                                                                maxLines: 1,
                                                                textAlign: TextAlign.left,
                                                              ),
                                                            ),
                                                            if(_userList[index].state.toString()!="null" && _userList[index].state.toString()!="") Text(
                                                              " | ",
                                                              style: TextStyle(
                                                                color: CommonColors.lightblue,
                                                                fontSize: 14,
                                                                fontWeight: FontWeight.w800,
                                                              ),
                                                              maxLines: 1,
                                                            ),
                                                            if(_userList[index].state.toString()!="null" && _userList[index].state.toString()!="") Flexible(
                                                              child: Text(
                                                                "${_userList[index].state}",
                                                                style: TextStyle(
                                                                  color: CommonColors.lightblue,
                                                                  fontSize: 14,
                                                                  fontWeight: FontWeight.w800,
                                                                ),
                                                                maxLines: 1,
                                                                overflow: TextOverflow.ellipsis,
                                                                textAlign: TextAlign.left,
                                                              ),
                                                            ),
                                                            if(_userList[index].country.toString()!="null" && _userList[index].country.toString()!="") Text(
                                                              " | ",
                                                              style: TextStyle(
                                                                color: CommonColors.lightblue,
                                                                fontSize: 14,
                                                                fontWeight: FontWeight.w800,
                                                              ),
                                                              maxLines: 1,
                                                            ),
                                                            if(_userList[index].country.toString()!="null" && _userList[index].country.toString()!="") Flexible(
                                                              child: Text(
                                                                "${_userList[index].country}",
                                                                style: TextStyle(
                                                                  color: CommonColors.lightblue,
                                                                  fontSize: 14,
                                                                  fontWeight: FontWeight.w800,
                                                                ),
                                                                maxLines: 1,
                                                                overflow: TextOverflow.ellipsis,
                                                                textAlign: TextAlign.left,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),

                                                SizedBox(height: 5,),
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: Container(
                                                        alignment: Alignment.topLeft,
                                                        // margin: const EdgeInsets.symmetric(horizontal: 20),
                                                        child: Row(
                                                          children: [
                                                           if(_userList[index].height.toString()!="null" && _userList[index].height.toString()!="") Text(
                                                              "${_userList[index].height?.replaceAll(".", "`") } | ",
                                                                  // "${_userList[index].weight}kg | "
                                                                  // "${_userList[index].religion} |"
                                                                  // "${_userList[index].maritalStatus}",
                                                              style: TextStyle(
                                                                color: CommonColors.white,
                                                                fontSize: 14,
                                                                fontWeight: FontWeight.w800,
                                                              ),
                                                              textAlign: TextAlign.left,
                                                            ),
                                                            if(_userList[index].weight.toString()!="null" && _userList[index].weight.toString()!="") Text(
                                                              // "${_userList[index].height?.replaceAll(".", "`") } | "
                                                                  "${_userList[index].weight}kg | "
                                                                  // "${_userList[index].religion} |"
                                                                  // "${_userList[index].maritalStatus}"
                                                              ,
                                                              style: TextStyle(
                                                                color: CommonColors.white,
                                                                fontSize: 14,
                                                                fontWeight: FontWeight.w800,
                                                              ),
                                                              textAlign: TextAlign.left,
                                                            ),
                                                            if(_userList[index].religion.toString()!="null" && _userList[index].religion.toString()!="") Text(
                                                              // "${_userList[index].height?.replaceAll(".", "`") } | "
                                                                  // "${_userList[index].weight}kg | "
                                                                  "${_userList[index].religion} |"
                                                                  // "${_userList[index].maritalStatus}"
                                                              ,
                                                              style: TextStyle(
                                                                color: CommonColors.white,
                                                                fontSize: 14,
                                                                fontWeight: FontWeight.w800,
                                                              ),
                                                              textAlign: TextAlign.left,
                                                            ),
                                                            if(_userList[index].maritalStatus.toString()!="null" && _userList[index].maritalStatus.toString()!="") Text(
                                                              // "${_userList[index].height?.replaceAll(".", "`") } | "
                                                                  // "${_userList[index].weight}kg | "
                                                                  // "${_userList[index].religion} |"
                                                                  "${_userList[index].maritalStatus}"
                                                              ,
                                                              style: TextStyle(
                                                                color: CommonColors.white,
                                                                fontSize: 14,
                                                                fontWeight: FontWeight.w800,
                                                              ),
                                                              textAlign: TextAlign.left,
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(height: 10,),
                                              ],
                                            ),
                                          )
                                      ),
                                      SizedBox(width: 20,),
                                      InkWell(
                                        onTap:(){
                                          SwipeItem item = _swipeItems[index];
                                          showProfile(_userList![index].image.toString(),_userList![index].id.toString());
                                          // userDetail();
                                          // userViewPreference(_userList![index].id.toString());
                                          },
                                        child: Container(
                                          height: 29,
                                          width: 29,
                                          margin: const EdgeInsets.symmetric(horizontal: 0),
                                          decoration: BoxDecoration(
                                            color: CommonColors.white,
                                            borderRadius: const BorderRadius.all(Radius.circular(25)),
                                          ),
                                          child: Stack(
                                            children: <Widget>[
                                              Center(
                                                  child: Image.asset("assets/home_backup.png",color: Colors.black,height: 21,width: 21,)
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      // new SizedBox(width: 20,),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                    itemChanged: (SwipeItem item, int index) {
                      if(!isLikeLoad) {
                        print("item: ${_userList![index]
                            .firstName}, index: $index");
                        showOnlineStatus(_userList![index - 1].id.toString());
                        like(_userList![index - 1].id.toString(), type, image,
                            _userList![index - 1].image, "${_userList[index - 1]
                                .firstName![0].toUpperCase() + _userList[index -
                                1].firstName!.substring(1)} ${_userList[index -
                                1].lastName![0].toUpperCase() +
                                _userList[index - 1].lastName!.substring(1)}",
                            _userList![index - 1].isOnline ?? false);
                      }
                      },
                    leftSwipeAllowed: true,
                    rightSwipeAllowed: true,
                    upSwipeAllowed: true,
                    fillSpace: true,
                    likeTag: Container(
                      margin: const EdgeInsets.all(15.0),
                      padding: const EdgeInsets.all(3.0),
                      // decoration: BoxDecoration(
                      //     border: Border.all(color: Colors.green)
                      // ),
                      child: Text('Like',style: TextStyle(fontSize: 30,fontWeight: FontWeight.bold,color: Colors.white),),
                    ),
                    nopeTag: Container(
                      margin: const EdgeInsets.all(15.0),
                      padding: const EdgeInsets.all(3.0),
                      // decoration: BoxDecoration(
                      //     border: Border.all(color: Colors.red)
                      // ),
                      child: Text('Nope',style: TextStyle(fontSize: 30,fontWeight: FontWeight.bold,color: Colors.white)),
                    ),
                    superLikeTag: Container(
                      margin: const EdgeInsets.all(15.0),
                      padding: const EdgeInsets.all(3.0),
                      // decoration: BoxDecoration(
                      //     border: Border.all(color: Colors.orange)
                      // ),
                      child: Text('Super Like',style: TextStyle(fontSize: 30,fontWeight: FontWeight.bold,color: Colors.white)),
                    ),
                    onStackFinished: () {
                      if(!isLikeLoad) {
                        print("item: ${_userList.last.firstName}");
                        showOnlineStatus(_userList.last.id.toString());
                        like(_userList.last.id.toString(), type, image,
                            _userList.last.image, "${_userList.last
                                .firstName![0].toUpperCase() +
                                _userList.last.firstName!.substring(
                                    1)} ${_userList.last.lastName![0]
                                .toUpperCase() +
                                _userList.last.lastName!.substring(1)}",
                            _userList.last.isOnline ?? false);
                        // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        //   content: Text("Stack Finished"),
                        //   duration: Duration(milliseconds: 500),
                        // ));
                      }
                    },
                  ),
                )
                // Align(
                //   alignment: Alignment.bottomCenter,
                //   child: Container(
                //     height: MediaQuery.of(context).size.height/5.5,
                //     width: MediaQuery.of(context).size.width,
                //     child: Column(
                //       crossAxisAlignment: CrossAxisAlignment.center,
                //       mainAxisAlignment: MainAxisAlignment.start,
                //       children: [
                //         new Container(
                //           child: Row(
                //             crossAxisAlignment: CrossAxisAlignment.center,
                //             mainAxisAlignment: MainAxisAlignment.center,
                //             children: [
                //               InkWell(
                //                 onTap:(){
                //                   },
                //                 child: Container(
                //                   height: 50,
                //                   width: 50,
                //                   margin: const EdgeInsets.symmetric(horizontal: 20),
                //                   decoration: BoxDecoration(
                //                     color: CommonColors.white,
                //                     borderRadius: const BorderRadius.all(Radius.circular(25)),
                //                   ),
                //                   child: Stack(
                //                     children: <Widget>[
                //                       Center(
                //                           child: Image.asset("assets/home_back.png",color: Colors.black,height: 21,width: 21,)
                //                       ),
                //                       SizedBox.expand(
                //                         child: Material(
                //                           type: MaterialType.transparency,
                //                           child: InkWell(onTap: () {
                //                           },splashColor: Colors.blue.withOpacity(0.2),
                //                             customBorder: RoundedRectangleBorder(
                //                               borderRadius: BorderRadius.circular(25),
                //                             ),
                //                           ),
                //                         ),
                //                       ),
                //                     ],
                //                   ),
                //                 ),
                //               ),
                //               InkWell(
                //                 onTap:(){
                //                   _matchEngine!.currentItem?.nope();
                //                 },
                //                 child: Container(
                //                   height: 50,
                //                   width: 50,
                //                   margin: const EdgeInsets.symmetric(horizontal: 20),
                //                   decoration: BoxDecoration(
                //                     color: CommonColors.red,
                //                     borderRadius: const BorderRadius.all(Radius.circular(25)),
                //                   ),
                //                   child: Stack(
                //                     children: <Widget>[
                //                       Center(
                //                           child: Image.asset("assets/home_close.png",color: Colors.white,height: 21,width: 21)
                //                       ),
                //                     ],
                //                   ),
                //                 ),
                //               ),
                //               InkWell(
                //                 onTap:(){
                //                   _matchEngine!.currentItem?.superLike();
                //
                //                 },
                //                 child: Container(
                //                   height: 50,
                //                   width: 50,
                //                   margin: const EdgeInsets.symmetric(horizontal: 20),
                //                   decoration: BoxDecoration(
                //                     color: CommonColors.blue,
                //                     borderRadius: const BorderRadius.all(Radius.circular(25)),
                //                   ),
                //                   child: Stack(
                //                     children: <Widget>[
                //                       Center(
                //                           child: Image.asset("assets/home_star.png",color: Colors.white,height: 21,width: 21)
                //                       ),
                //                     ],
                //                   ),
                //                 ),
                //               ),
                //
                //               InkWell(
                //                 onTap:(){
                //                   print("like");
                //                   _matchEngine!.currentItem?.like();
                //                 },
                //                 child: Container(
                //                   height: 50,
                //                   width: 50,
                //                   margin: const EdgeInsets.symmetric(horizontal: 20),
                //                   decoration: BoxDecoration(
                //                     color: CommonColors.green,
                //                     borderRadius: const BorderRadius.all(Radius.circular(25)),
                //                   ),
                //                   child: Stack(
                //                     children: <Widget>[
                //                       Center(
                //                           child: Image.asset("assets/home_like.png",color: Colors.white,height: 21,width: 21)
                //                       ),
                //                     ],
                //                   ),
                //                 ),
                //               ),
                //
                //
                //
                //             ],
                //           ),
                //         )
                //       ],
                //     ),
                //   ),
                // ),
                // Align(
                //   alignment: Alignment.bottomCenter,
                //   child:
                //   new Container(
                //     child: Row(
                //       crossAxisAlignment: CrossAxisAlignment.start,
                //       mainAxisAlignment: MainAxisAlignment.start,
                //       children: [
                //         Container(
                //           height: 50,
                //           width: 50,
                //           margin: const EdgeInsets.only(right: 40),
                //           decoration: BoxDecoration(
                //             color: CommonColors.white,
                //             borderRadius: const BorderRadius.all(Radius.circular(25)),
                //           ),
                //           child: Stack(
                //             children: <Widget>[
                //               Center(
                //                   child: Image.asset("assets/home_back.png",color: Colors.black,height: 21,width: 21,)
                //               ),
                //               SizedBox.expand(
                //                 child: Material(
                //                   type: MaterialType.transparency,
                //                   child: InkWell(onTap: () {
                //                   },splashColor: Colors.blue.withOpacity(0.2),
                //                     customBorder: RoundedRectangleBorder(
                //                       borderRadius: BorderRadius.circular(25),
                //                     ),
                //                   ),
                //                 ),
                //               ),
                //             ],
                //           ),
                //         ),
                //         Container(
                //           height: 50,
                //           width: 50,
                //           margin: const EdgeInsets.only(right: 40),
                //           decoration: BoxDecoration(
                //             color: CommonColors.red,
                //             borderRadius: const BorderRadius.all(Radius.circular(25)),
                //           ),
                //           child: Stack(
                //             children: <Widget>[
                //               Center(
                //                   child: Image.asset("assets/home_close.png",color: Colors.white,height: 21,width: 21)
                //               ),
                //               SizedBox.expand(
                //                 child: Material(
                //                   type: MaterialType.transparency,
                //                   child: InkWell(onTap: () {
                //                     _matchEngine!.currentItem?.nope();
                //                   },splashColor: Colors.blue.withOpacity(0.2),
                //                     customBorder: RoundedRectangleBorder(
                //                       borderRadius: BorderRadius.circular(25),
                //                     ),
                //                   ),
                //                 ),
                //               ),
                //             ],
                //           ),
                //         ),
                //         Container(
                //           height: 50,
                //           width: 50,
                //           margin: const EdgeInsets.only(right: 40),
                //           decoration: BoxDecoration(
                //             color: CommonColors.blue,
                //             borderRadius: const BorderRadius.all(Radius.circular(25)),
                //           ),
                //           child: Stack(
                //             children: <Widget>[
                //               Center(
                //                   child: Image.asset("assets/home_star.png",color: Colors.white,height: 21,width: 21)
                //               ),
                //               SizedBox.expand(
                //                 child: Material(
                //                   type: MaterialType.transparency,
                //                   child: InkWell(onTap: () {
                //                     _matchEngine!.currentItem?.superLike();
                //                   },splashColor: Colors.blue.withOpacity(0.2),
                //                     customBorder: RoundedRectangleBorder(
                //                       borderRadius: BorderRadius.circular(25),
                //                     ),
                //                   ),
                //                 ),
                //               ),
                //             ],
                //           ),
                //         ),
                //         Container(
                //           height: 50,
                //           width: 50,
                //           // margin: const EdgeInsets.symmetric(horizontal: 20),
                //           decoration: BoxDecoration(
                //             color: CommonColors.green,
                //             borderRadius: const BorderRadius.all(Radius.circular(25)),
                //           ),
                //           child: Stack(
                //             children: <Widget>[
                //               Center(
                //                   child: Image.asset("assets/home_like.png",color: Colors.white,height: 21,width: 21)
                //               ),
                //               SizedBox.expand(
                //                 child: Material(
                //                   type: MaterialType.transparency,
                //                   child: InkWell(onTap: () {
                //                     _matchEngine!.currentItem?.like();
                //                   },splashColor: Colors.blue.withOpacity(0.2),
                //                     customBorder: RoundedRectangleBorder(
                //                       borderRadius: BorderRadius.circular(25),
                //                     ),
                //                   ),
                //                 ),
                //               ),
                //             ],
                //           ),
                //         ),
                //       ],
                //     ),
                //   ),
                // )
              ]))
    );
  }
}

