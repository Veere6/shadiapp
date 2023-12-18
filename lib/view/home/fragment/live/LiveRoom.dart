import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shadiapp/CommonMethod/CommonColors.dart';
import 'package:shadiapp/Models/view_profile_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../CommonMethod/Toaster.dart';
import '../../../../Models/add_live_model.dart';
import '../../../../Services/Services.dart';
import '../../../../ShadiApp.dart';
import 'package:agora_token_service/agora_token_service.dart';

class LiveRoom extends StatefulWidget {
  String image = "";
  String channelName = "";
  String token = "";
  bool _isJoined;
  bool _isHost;

  LiveRoom(
      this.image, this.channelName, this.token, this._isJoined, this._isHost);

  @override
  State<LiveRoom> createState() => _LiveRoomState();
}

const String appId = "c21ae17d2d9046478dafcaf516e68b3c";

class _LiveRoomState extends State<LiveRoom> {
  String channelName = "test";
  String token =
      "007eJxTYMjvc4iYExIhrH6Nb3KB/JzAJivmnoc8WadlMra+XLPG5IcCQ7KRYWKqoXmKUYqlgYmZiblFSmJacmKaqaFZqplFknHyyW/VqQ2BjAziqdnMjAwQCOKzMJSkFpcwMAAAz7Aecw==";

  int? _remoteUid; // uid of the remote user
  int uid = 0; // uid of the local user
  bool _isJoined = false; // Indicates if the local user has joined the channel
  bool _isHost = true; // Indicates whether the user has joined as a host or audience
  late RtcEngine agoraEngine;
  bool isLoading = false;
  final role = RtcRole.publisher;
  final appCertificate = 'ce478f8a13ce48d19bc01c934e6e9ae2';
  final expirationInSeconds = 3600;
  final currentTimestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
  late int expireTimestamp = currentTimestamp + expirationInSeconds;
  // Agora engine instance

  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  showMessage(String message) {
    scaffoldMessengerKey.currentState?.showSnackBar(SnackBar(
      content: Text(message),
    ));
  }

  TextEditingController comment = TextEditingController();

  // var message = [
  //   "hi",
  //   "how are you",
  //   "where are you from",
  //   "kya haal hai",
  //   "you are looking so good i am just want to see you soon as soon as posible."
  // ];
  late AddLiveModel _addLiveModel;
  late SharedPreferences _preferences;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;


  void sendMessage(String roomId, String _message, String userId) async {

    if (_message.isNotEmpty) {
      Map<String, dynamic> chatData = {
        "uid": "${user_id}",
        "name": "${username}",
        "message": _message,
        "image": user_image,
        "time": FieldValue.serverTimestamp(),
      };

      comment.clear();
      await _firestore
          .collection('groups')
          .doc("${widget.channelName}")
          .collection('chats')
          .add(chatData);

      // _scrollController.animateTo(_scrollController.position.maxScrollExtent,
      //     duration: const Duration(milliseconds: 300), curve: Curves.easeOut);

    } else {
      print("Enter Some Text");
    }
  }


  // Future<void> sendMessage(String roomId, String message, String userId) {
  //   return _firestore.collection('chatroom').add({
  //     'text': message,
  //     'sender': userId,
  //     'timestamp': FieldValue.serverTimestamp(),
  //   });
  // }

  @override
  void initState() {
    super.initState();
    // Set up an instance of Agora engine

    _isJoined = widget._isJoined;
    _isHost = widget._isHost;
    // token = widget.token;
    // channelName = widget.channelName;
    _isHost = widget._isHost;
    if (_isHost) {
      addLive(true);
    }
    viewProfile();
    setupVideoSDKEngine();

  }

  List<Map<String, dynamic>> membersList = [];

  String username="";
  String user_image="";
  late ViewProfileModel _viewProfileModel = ViewProfileModel();
  String user_id="";

  Future<void> viewProfile() async {
    _preferences = await SharedPreferences.getInstance();
    user_id = _preferences.getString(ShadiApp.userId).toString();
    _viewProfileModel = await Services.ProfileView(_preferences.getString(ShadiApp.userId).toString());
    if(_viewProfileModel.status ==1){
      username = "${_viewProfileModel.data![0].firstName![0].toUpperCase()+_viewProfileModel.data![0].firstName!.substring(1)}";
          // " ${_viewProfileModel.data![0].lastName![0].toUpperCase()+_viewProfileModel.data![0].lastName!.substring(1)}";
      user_image = "${_viewProfileModel.data?[0].image}";
    }
    getCurrentUserDetails();
    addmembers("${widget.channelName}","${username}");
    setState(() {});
  }
  void getCurrentUserDetails() async {

    membersList.add({
      "name": username,
      "uid": "${_preferences.getString(ShadiApp.userId).toString()}",
      "image":user_image,
      "isAdmin": false,
    });
  }

  int groupsize = 1;
  void addmembers(String groupID, groupname) async {
    try {
      await _firestore.collection('groups').doc(groupID).get().then((map) {
        try {
          groupsize = map["size"];
          for (int i = 0; i < map.get("members").length; i++) {
            String? uid = membersList[i]['uid'];
            if (uid != map.get("members")[i]['uid']) {
              membersList.add({
                "name": map.get("members")[i]['name'],
                "uid": map.get("members")[i]['uid'],
                "image": map.get("members")[i]['image'],
                "isAdmin": false,
              });
            } else {
              groupsize--;
            }
          }
          adduser(groupID, groupname);
        } catch (error) {
          createGroup(groupID, groupname);
          // print(error);
        }
      });
    } catch (error) {
      createGroup(groupID, groupname);
      // print(error);
    }
  }
  void deleteGroup(String groupId) async {
    // Create a Firestore batch
    WriteBatch batch = FirebaseFirestore.instance.batch();
    // Query and delete all documents in the "chats" subcollection
    QuerySnapshot chatSnapshot = await FirebaseFirestore.instance.collection("groups").doc(groupId).collection("chats").get();
    for (QueryDocumentSnapshot chatDocument in chatSnapshot.docs) {
      batch.delete(FirebaseFirestore.instance.collection("groups").doc(groupId).collection("chats").doc(chatDocument.id));
    }
    // Delete the main document with groupId
    batch.delete(FirebaseFirestore.instance.collection("groups").doc(groupId));

    // Commit the batched write
    await batch.commit();
  }

  void adduser(String groupId, String _groupName) async {
    print(groupId + ",<<>>" + _groupName);
    await _firestore.collection('groups').doc(groupId).update({
      "name": _groupName,
      "id": groupId,
      "size": groupsize + 1,
      "members": FieldValue.arrayUnion(membersList)
    }).then((value) {
      sendMessage(ShadiApp.userId, "${username} just joined", ShadiApp.userId);
      //  _firestore.collection('groups').doc(groupId).collection('chats').add({
      //   "message": "${username} just joined",
      //    "name":username,
      //    "image":user_image,
      //   "type": "notify",
      // });
    });
  }

  void createGroup(String groupId, String _groupName) async {
    print(groupId + ",>>" + _groupName);
    await _firestore.collection('groups').doc(groupId).set({
      "name": _groupName,
      "id": groupId,
      "size": groupsize,
      "members": membersList,
    }).then((value) {
      sendMessage(ShadiApp.userId, "${username} Created This Group.", ShadiApp.userId);
      // _firestore.collection('groups').doc(groupId).collection('chats').add({
      //   "message": "${username} Created This Group.",
      //   "name":username,
      //   "image":user_image,
      //   "type": "notify",
      // });
    });
    // }

    // await _firestore.collection('groups').doc(groupId).collection('chats').add({
    //   "message": "${_auth.currentUser!.displayName} Created This Group.",
    //   "type": "notify",
    // });
  }


  Future<void> addLive(status) async {
    final token1 = RtcTokenBuilder.build(
      appId: appId,
      appCertificate: appCertificate,
      channelName: channelName,
      uid: uid.toString(),
      role: role,
      expireTimestamp: expireTimestamp,
    );


    print('token: $token1');
    // token = token1;
    _preferences = await SharedPreferences.getInstance();
    _addLiveModel = await Services.AddLiveMethod({
      'userId': '${_preferences.getString(ShadiApp.userId)}',
      'status': '${status}',
      'channelName': '${widget.channelName}'
    });
    if (_addLiveModel.status == true) {
      // token = "${_addLiveModel.data}";
      if (status == false) {
        Navigator.of(context).pop();
      }
    } else {
      Toaster.show(context, "${_addLiveModel.message}");
    }
  }

  Future<void> setupVideoSDKEngine() async {
    print("objecthfhfghhirhyr $_isJoined");
    print("objecthfhfghhirhyr $_isHost");
    setState(() {
      isLoading = true;
    });
    // retrieve or request camera and microphone permissions
    await [Permission.microphone, Permission.camera].request();

    //create an instance of the Agora engine
    agoraEngine = createAgoraRtcEngine();
    await agoraEngine.initialize(const RtcEngineContext(appId: appId));

    await agoraEngine.enableVideo();

    // Register the event handler
    agoraEngine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          showMessage(
              "Local user uid:${connection.localUid} joined the channel");
          print("Local user uid:${connection.localUid} joined the channel");
          setState(() {
            _isJoined = true;
          });
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          showMessage("Remote user uid:$remoteUid joined the channel");
          print("Remote user uid:$remoteUid joined the channel");
          setState(() {
            _remoteUid = remoteUid;
          });
        },
        onUserOffline: (RtcConnection connection, int remoteUid,
            UserOfflineReasonType reason) {
          showMessage("Remote user uid:$remoteUid left the channel");
          print("Remote user uid:$remoteUid left the channel");
          if (connection.channelId == channelName) {
            setState(() {
              _remoteUid = null;
            });
          }
        },
      ),
    );
    join();
  }

  void join() async {
    // Set channel options
    ChannelMediaOptions options;

    // Set channel profile and client role
    if (_isHost) {
      options = const ChannelMediaOptions(
        clientRoleType: ClientRoleType.clientRoleBroadcaster,
        channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
      );
      await agoraEngine.startPreview();
    } else {
      options = const ChannelMediaOptions(
        clientRoleType: ClientRoleType.clientRoleAudience,
        channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
      );
    }

    await agoraEngine.joinChannel(
      token: token,
      channelId: channelName,
      options: options,
      uid: uid,
    );
    setState(() {
      isLoading = false;
    });
  }

  void leave() {
    setState(() {
      _isJoined = false;
      _remoteUid = null;
    });
    agoraEngine.leaveChannel();
  }

// Release the resources when you leave
  @override
  void dispose() async {
    await agoraEngine.leaveChannel();
    agoraEngine.release();
    if (_isHost) {
      addLive(false);
      deleteGroup("${widget.channelName}");
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CommonColors.themeblack,
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: SingleChildScrollView(
            child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Stack(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          margin: EdgeInsets.only(left: 20.0, top: 50.0),
                          height: 50,
                          child: CircleAvatar(
                            radius: 30,
                            backgroundImage: NetworkImage(widget.image),
                            backgroundColor: CommonColors.bottomgrey,
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(left: 5.0, top: 50.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                child: Text(
                                  "Ana, 24",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.only(bottom: 5.0),
                                child: Text("Denmark",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 12)),
                              )
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 10.0, vertical: 5.0),
                          margin: EdgeInsets.only(left: 5.0, top: 50.0),
                          decoration: BoxDecoration(
                              color: CommonColors.buttonorg,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(45.0))),
                          child: Text(
                            "+Follow",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Expanded(
                            child: InkWell(
                          highlightColor: Colors.transparent,
                          splashColor: Colors.transparent,
                          onTap: () {
                            leave();
                            if (_isHost) {
                              addLive(false);
                              deleteGroup("${widget.channelName}");
                            } else {
                              Navigator.of(context).pop();
                            }
                          },
                          child: Container(
                            alignment: Alignment.centerRight,
                            padding: EdgeInsets.only(top: 50.0, right: 10.0),
                            child: Image.asset(
                              'assets/popup-06.png',
                              width: 20,
                              height: 20,
                            ),
                          ),
                        )),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Container(
                      alignment: Alignment.centerRight,
                      child: Container(
                        margin: EdgeInsets.only(right: 10.0, bottom: 10.0),
                        padding: EdgeInsets.symmetric(
                            horizontal: 10.0, vertical: 2.0),
                        decoration: BoxDecoration(
                            color: Color(0xffFEDA14),
                            borderRadius:
                                BorderRadius.all(Radius.circular(5.0))),
                        child: Text(
                          "Join LIVE",
                          style: TextStyle(
                              color: Color(0xff1E1E1E),
                              fontSize: 11.0,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ),
                  isLoading
                      ? Center(
                    child: CircularProgressIndicator(
                      color: Colors.white,
                    ),
                  )
                      : Container(
                      height: 350,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20.0),
                          child: _videoPanel())),
                  Expanded(
                    child:
                    user_id!="" ? StreamBuilder<QuerySnapshot>(
                      stream: _firestore
                          .collection('groups')
                          .doc("${widget.channelName}")
                          .collection('chats')
                          .orderBy('time')
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return ListView.builder(
                            // controller: _scrollController,
                            padding: const EdgeInsets.all(5),
                            itemCount: snapshot.data!.docs.length,
                            itemBuilder: (context, index) {
                              Map<String, dynamic> chatMap =
                              snapshot.data!.docs[index].data()
                              as Map<String, dynamic>;
                              return Container(
                                margin: const EdgeInsets.symmetric(vertical: 5),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      // margin: EdgeInsets.all(8.0),
                                        height: 34,
                                        width: 34,
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(17.0),
                                          child: Image.network(
                                            "${chatMap["image"]=="null" ? "${widget.image}":"${chatMap["image"]}"}",
                                            height: 34,
                                            width: 34,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, stacktrace, error){
                                              return Image.network(widget.image,
                                                height: 34,
                                                width: 34,
                                                fit: BoxFit.cover);
                                            },
                                          ),
                                        )),
                                    SizedBox(
                                      width: 12,
                                    ),
                                    Expanded(
                                      child: Container(
                                        alignment: Alignment.centerLeft,
                                        child: Column(
                                          mainAxisAlignment:
                                          MainAxisAlignment.start,
                                          crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                            chatMap['name'],
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w400),
                                            ),
                                            Text(
                                              chatMap['message'],
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w400),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              );
                            },
                          );
                        } else {
                          return Container();
                        }
                      },
                    ):Container(),


                    // StreamBuilder<QuerySnapshot>(
                    //   stream: null,
                    //   builder: (context, snapshot) {
                    //     return ListView.builder(
                    //         itemCount: message.length,
                    //         reverse: true,
                    //         shrinkWrap: true,
                    //         padding: const EdgeInsets.symmetric(horizontal: 33),
                    //         itemBuilder: (context, index) {
                    //           return Container(
                    //             margin: const EdgeInsets.symmetric(vertical: 5),
                    //             child: Row(
                    //               mainAxisAlignment: MainAxisAlignment.center,
                    //               crossAxisAlignment: CrossAxisAlignment.center,
                    //               children: [
                    //                 Container(
                    //                     // margin: EdgeInsets.all(8.0),
                    //                     height: 34,
                    //                     width: 34,
                    //                     child: ClipRRect(
                    //                       borderRadius: BorderRadius.circular(17.0),
                    //                       child: Image.network(
                    //                         widget.image,
                    //                         height: 34,
                    //                         width: 34,
                    //                         fit: BoxFit.cover,
                    //                       ),
                    //                     )),
                    //                 SizedBox(
                    //                   width: 12,
                    //                 ),
                    //                 Expanded(
                    //                   child: Container(
                    //                     alignment: Alignment.centerLeft,
                    //                     child: Column(
                    //                       mainAxisAlignment:
                    //                           MainAxisAlignment.start,
                    //                       crossAxisAlignment:
                    //                           CrossAxisAlignment.start,
                    //                       children: [
                    //                         Text(
                    //                           message[index],
                    //                           style: TextStyle(
                    //                               color: Colors.white,
                    //                               fontSize: 12,
                    //                               fontWeight: FontWeight.w400),
                    //                         ),
                    //                         Text(
                    //                           "Arun just joined",
                    //                           style: TextStyle(
                    //                               color: Colors.white,
                    //                               fontSize: 10,
                    //                               fontWeight: FontWeight.w400),
                    //                         ),
                    //                       ],
                    //                     ),
                    //                   ),
                    //                 )
                    //               ],
                    //             ),
                    //           );
                    //         });
                    //   }
                    // ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(
                        left: 33, right: 27, bottom: 20, top: 20),
                    alignment: Alignment.bottomCenter,
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            // width: MediaQuery.of(context).size.width,
                            height: 38.0,
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.white),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(30))),
                            alignment: Alignment.centerLeft,
                            // margin: EdgeInsets.only(left: 0, top: 20, right: 5.0 , bottom: 20.0),
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  left: 15.0, right: 5.0),
                              child: TextField(
                                textCapitalization:
                                    TextCapitalization.sentences,
                                controller: comment,
                                maxLines: 1,
                                decoration: InputDecoration(
                                  suffixIcon: InkWell(
                                    onTap: (){
                                      sendMessage(ShadiApp.userId, comment.text, ShadiApp.userId);
                                      comment.text="";
                                    },
                                    child: Icon(Icons.send,color: Colors.white,),
                                  ),
                                  isDense: true,
                                  border: InputBorder.none,
                                  hintText: 'Add Comment',
                                  hintStyle: TextStyle(
                                      color: Color(0xffC4C4C4),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w400,
                                      letterSpacing: 0.1),
                                ),
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w400,
                                    letterSpacing: 0.1),
                                onSubmitted: (value){
                                  print("alsfksdkj ${value}");
                                  sendMessage(ShadiApp.userId, value, ShadiApp.userId);
                                },
                              ),
                            ),
                          ),
                        ),
                        // Expanded(
                        //   child:

                        Padding(
                          padding: const EdgeInsets.only(right: 5.0, left: 5),
                          child: Column(
                            children: [
                              Container(
                                child: Image.asset("assets/following.png"),
                              ),
                              Text(
                                "Following",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w400,
                                ),
                              )
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 0.0),
                          child: Column(
                            children: [
                              Container(
                                child: Image.asset("assets/share.png"),
                              ),
                              Text(
                                "Next Live",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w400,
                                ),
                              )
                            ],
                          ),
                        ),
                        // )
                      ],
                    ),
                  ),
                  // Container(
                  //   margin: EdgeInsets.only(top: 10.0),
                  //   width: MediaQuery.of(context).size.width,
                  //   height: 500,
                  //   decoration: BoxDecoration(
                  //     borderRadius: BorderRadius.all(
                  //         Radius.circular(20.0)),
                  //     color: CommonColors.bottomgrey,
                  //   ),
                  //   child:
                  //   ClipRRect(
                  //     borderRadius: BorderRadius.circular(20.0),
                  //     child: Container(
                  //         // decoration: BoxDecoration(
                  //         //     image: DecorationImage(
                  //         //         image: NetworkImage(widget.image),
                  //         //         fit: BoxFit.cover)
                  //         // ),
                  //         child: Stack(
                  //           children: [
                  //
                  //             Column(
                  //               children: [
                  //
                  //               ],
                  //             )
                  //           ],
                  //         )
                  //         // Column(
                  //         //     mainAxisAlignment: MainAxisAlignment.start,
                  //         //     crossAxisAlignment: CrossAxisAlignment.start,
                  //         //     children: [
                  //         //       Spacer(),
                  //         //       Padding(
                  //         //         padding: const EdgeInsets.only(left: 10.0, right: 10.0, bottom: 5.0),
                  //         //         child:
                  //         //         Container(
                  //         //           child: Text("Ana, 24",
                  //         //             style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),),
                  //         //         ),
                  //         //       ),
                  //         //     ]
                  //         // )
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            ],
          ),
        )),
      ),
    );
  }

  Widget _videoPanel() {
    if (_isHost) {
      // Show local video preview
      print("objectmnbvgcbg,h./jhgmncbnvisHost $_remoteUid");

      return AgoraVideoView(
        controller: VideoViewController(
          rtcEngine: agoraEngine,
          canvas: VideoCanvas(
              uid: 0,
          ),
        ),
      );
    } else {
      // Show remote video
      print("objectmnbvgcbg,h./jhgmncbnvuser $_remoteUid");
      if (_remoteUid != null) {
        return AgoraVideoView(
          controller: VideoViewController.remote(
            rtcEngine: agoraEngine,
            canvas: VideoCanvas(uid: _remoteUid),
            connection: RtcConnection(channelId: channelName),
          ),
        );
      } else {
        print("objectmnbvgcbg,h./jhgmncbnv $_remoteUid");
        return Center(
          child: const Text(
            'Waiting for a host to join',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white),
          ),
        );
      }
    }
  }
}
