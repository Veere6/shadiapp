import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shadiapp/CommonMethod/CommonColors.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shadiapp/CommonMethod/Toaster.dart';
import 'package:shadiapp/Models/preference_list_model.dart';
import 'package:shadiapp/Models/user_add_preference_model.dart';
import 'package:shadiapp/Models/user_view_preference_model.dart';
import 'package:shadiapp/Services/Services.dart';
import 'package:shadiapp/ShadiApp.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:collection/collection.dart';

class Intrests extends StatefulWidget {
  @override
  State<Intrests> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<Intrests> {
  bool ActiveConnection = false;
  String T = "";
  late SharedPreferences _preferences;
  late PreferenceListModel _preferenceListModel;
  late AddPreferenceModel _addPreferenceModel;
  late UserViewPreferenceModel _viewPreferenceModel;
  bool clickLoad = false;
  bool isLoad = false;

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
  // List<File?> imagelist=[null,null,null,null,null,null];
  List<prefsDatum> prefList = [];
  // List<PrefsDatum> intrest = [];

  Future<void> viewPrefs() async {
    isLoad = true;
    prefList.clear();
    _preferences = await SharedPreferences.getInstance();
    _preferenceListModel = await Services.PrefView(
        "${_preferences?.getString(ShadiApp.userId).toString()}");
    if (_preferenceListModel.status == 1) {
      for (var i = 0; i < _preferenceListModel.data!.length; i++) {
        prefList = _preferenceListModel.data ?? <prefsDatum>[];
      }
    }
    isLoad = false;
    setState(() {});
  }

  Future<void> addPrefs(String preferenceId) async {
    setState(() {
      clickLoad = true;
    });
    _preferences = await SharedPreferences.getInstance();
    _addPreferenceModel = await Services.AddPrefsMethod(
        "${_preferences?.getString(ShadiApp.userId)}", preferenceId);
    // viewPrefs();
    // if (_addPreferenceModel.status == 1) {
    //   Toaster.show(context, _addPreferenceModel.message.toString());
    // } else {
    //   Toaster.show(context, _addPreferenceModel.message.toString());
    // }
    setState(() {
      clickLoad = false;
    });
  }
  Future<void> addCustomPrefs(String title) async {
    setState(() {
      clickLoad = true;
    });
    _preferences = await SharedPreferences.getInstance();
    _addPreferenceModel = await Services.AddCustomPrefsMethod(
        "${_preferences?.getString(ShadiApp.userId)}", title);
    tagsearch.text="";
    ischeck = false;
    viewPrefs();
    // if (_addPreferenceModel.status == 1) {
    //
    //   // Toaster.show(context, _addPreferenceModel.message.toString());
    // } else {
    //   // Toaster.show(context, _addPreferenceModel.message.toString());
    // }
    setState(() {
      clickLoad = false;
    });
  }

  // Future<void> userViewPreference() async {
  //   _preferences = await SharedPreferences.getInstance();
  //   _viewPreferenceModel = await Services.ViewUserPreference(
  //       _preferences.getString(ShadiApp.userId).toString());
  //   if (_viewPreferenceModel.status == 1) {
  //     for (int i = 0; i < _viewPreferenceModel.data!.length; i++) {
  //       intrest = _viewPreferenceModel.data ?? <PrefsDatum>[];
  //     }
  //     intrest.forEach((element) {
  //       if (prefList.contains(element)) {
  //         print("ahsdjfsdhfjshfs ${element.preference}");
  //       }
  //     });
  //   }
  //   setState(() {});
  // }

  @override
  void initState() {
    CheckUserConnection();
    viewPrefs();
    // userViewPreference();
    super.initState();
  }

  List<int> selectedIndex = [];

  bool ischeck = false;

  TextEditingController tagsearch = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CommonColors.themeblack,
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            // crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              new SizedBox(
                height: MediaQuery.of(context).padding.top + 20,
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
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
              new SizedBox(
                height: 8,
              ),
              Container(
                alignment: Alignment.centerLeft,
                margin: const EdgeInsets.only(left: 20, right: 55),
                child: Text(
                  'How would you describe\nyourself ? select 4',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.start,
                ),
              ),
              new SizedBox(
                height: 20,
              ),
              Container(
                height: 50,
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  // color: Colors.white,
                  border: Border.all(color: Colors.white),
                  borderRadius: const BorderRadius.all(Radius.circular(25)),
                ),
                alignment: Alignment.centerLeft,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 20,
                      width: 20,
                      child: Image.asset(
                        "assets/tag_interest.png",
                        color: Colors.white.withOpacity(0.6),
                        height: 20,
                        width: 20,
                      ),
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Expanded(
                      child: TextFormField(
                        keyboardType: TextInputType.name,
                        textInputAction: TextInputAction.done,
                        controller: tagsearch,
                        decoration: InputDecoration(
                          hintText: 'Add New Tag...',
                          border: InputBorder.none,
                          hintStyle: new TextStyle(
                              color: Colors.white.withOpacity(0.6),
                              fontSize: 14,
                              fontWeight: FontWeight.w400),
                          // prefixIcon: SizedBox(
                          //   height:5,width:5,
                          //   child: Image.asset("assets/tag_interest.png",color: Colors.white.withOpacity(0.6),height:5,width:5,),),
                          // suffixIcon: ischeck ? new InkWell(
                          //   onTap: (){
                          //       if(selectedIndex.length!=4){
                          //         setState((){
                          //         tags.add(tagsearch.text!);
                          //         selectedIndex.add(tags.length-1);
                          //         });
                          //       }else{
                          //         Toaster.show(context, "You can select only 4");
                          //       }
                          //   },
                          //   child: SizedBox(child: Icon(Icons.done,color: Colors.cyan,),),
                          // ):null
                        ),
                        onChanged: (value) {
                          if (value.isNotEmpty) {
                            setState(() {
                              ischeck = true;
                            });
                          } else {
                            setState(() {
                              ischeck = false;
                            });
                          }
                        },
                        style: new TextStyle(color: Colors.white, fontSize: 14),
                        textAlign: TextAlign.left,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter your Tag';
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    ischeck
                        ? new InkWell(
                            onTap: () {
                              // if (selectedIndex.length != 4) {
                                // setState(() {
                                  addCustomPrefs(tagsearch.text!);
                                  // tags.add(tagsearch.text!);
                                  // selectedIndex.add(tags.length - 1);
                                // });
                              // } else {
                              //   Toaster.show(context, "You can select only 4");
                              // }
                            },
                            child: SizedBox(
                              child: Icon(
                                Icons.done,
                                color: Colors.cyan,
                              ),
                            ),
                          )
                        : Container()
                  ],
                ),
              ),
              new SizedBox(
                height: 10,
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 17),
                alignment: Alignment.centerLeft,
                child: isLoad
                    ? Center(
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 3.0,
                        ),
                      )
                    : Wrap(
                        children: [
                          ...List.generate(prefList.length, (index) {

                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  addPrefs(prefList![index].id.toString());
                                  if (prefList.where((item) => item?.is_select ??false).length < 4){
                                    if (prefList[index].is_select==true) {
                                      prefList[index].is_select=false;
                                    }else{
                                      prefList[index].is_select=true;
                                    }
                                  }
                                });
                              },
                              child: Container(
                                  margin: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.white),
                                    color: prefList[index].is_select ?? false
                                        ? CommonColors.buttonorg
                                        : null,
                                    borderRadius: BorderRadius.circular(65),
                                  ),
                                  padding: EdgeInsets.all(8),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        "${prefList![index].title}",
                                        style: new TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w400,
                                            color:
                                                Colors.white.withOpacity(0.6)),
                                      ),
                                      new SizedBox(
                                        width: 5,
                                      ),
                                      prefList[index].is_select ?? false
                                          ? new SizedBox(
                                              child: InkWell(
                                                  onTap: () {
                                                    setState(() {
                                                      addPrefs(prefList![index].id.toString());
                                                      if (prefList[index].is_select==true) {
                                                        prefList[index].is_select=false;
                                                      }else{
                                                        prefList[index].is_select=true;
                                                      }
                                                    });
                                                    // setState(() {
                                                    //   addPrefs(prefList![index].id.toString());
                                                    // });
                                                  },
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            0.0),
                                                    child: Icon(
                                                      Icons.close,
                                                      size: 16,
                                                      color: Colors.white
                                                          .withOpacity(0.6),
                                                    ),
                                                  )),
                                            )
                                          : Container()
                                    ],
                                  )),
                            );
                          })
                        ],
                      ),
              ),
              new SizedBox(
                height: 40,
              ),
              Container(
                height: 50,
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: CommonColors.buttonorg,
                  borderRadius: const BorderRadius.all(Radius.circular(25)),
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
                                  "Continue",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              )),
                      ],
                    ),
                    SizedBox.expand(
                      child: Material(
                        type: MaterialType.transparency,
                        child: InkWell(
                          onTap: () {
                            Navigator.of(context).pushNamed("EnableLocation");
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
                height: 40,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
