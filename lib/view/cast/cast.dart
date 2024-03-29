import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shadiapp/CommonMethod/CommonColors.dart';
import 'package:shadiapp/CommonMethod/Toaster.dart';
import 'package:shadiapp/Models/CasteModel.dart';
import 'package:shadiapp/Models/ReligionModel.dart';
import 'package:shadiapp/Models/user_detail_model.dart';
import 'package:shadiapp/Models/user_update_model.dart';
import 'package:shadiapp/Services/Services.dart';
import 'package:shadiapp/ShadiApp.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class Cast extends StatefulWidget {
  @override
  State<Cast> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<Cast> {

  bool ActiveConnection = false;
  SharedPreferences? _preferences;
  late UserDetailModel _userDetailModel;
  late UpdateUserModel _updateUserModel;
  String T = "";
  String firstName = "";
  String lastName = "";
  String birthDate = "";
  String gender = "";
  String country = "";
  String city = "";
  String state = "";
  String height = "";
  String weight = "";
  String maritalStatus = "";
  String email = "";
  String lookingFor = "";
  String about = "";
  String education = "";
  String company = "";
  String jobTitle = "";


  String zodiac_sign = "";
  String education_level = "";
  String covid_vaccine = "";
  String pets = "";
  String dietary_preference = "";
  String sleeping_habits = "";
  String social_media = "";
  String workout = "";
  String smoking = "";
  String health = "";
  String drinking = "";
  String personality_type = "";

  bool clickLoad = false;

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

  getAsync() async {
    try{
      _preferences = await SharedPreferences.getInstance();
      setState(() {

      });
    }catch (e) {
      print(e);
    }
  }

  Future<void> userDetail() async {
    _preferences = await SharedPreferences.getInstance();
    _userDetailModel = await Services.UserDetailMethod("${_preferences?.getString(ShadiApp.userId)}");
    if(_userDetailModel.status == 1){
      firstName = _userDetailModel.data![0].firstName.toString();
      lastName = _userDetailModel.data![0].lastName.toString();
      if(_userDetailModel.data![0].birthDate == null){
        birthDate = "";
      }else {
        birthDate = _userDetailModel.data![0].birthDate.toString();
      }
      gender = _userDetailModel.data![0].gender.toString();
      country = _userDetailModel.data![0].country.toString();
      city = _userDetailModel.data![0].city.toString();
      state = _userDetailModel.data![0].state.toString();
      weight = _userDetailModel.data![0].weight.toString();
      height = _userDetailModel.data![0].height.toString();
      maritalStatus = _userDetailModel.data![0].maritalStatus.toString();
      email = _userDetailModel.data![0].email.toString();
      if (_userDetailModel.data![0].religion == "") {
        religion = "Select religion";
      }else {
        religion = _userDetailModel.data![0].religion.toString();
        Castemethod(religion);
      }
      if (_userDetailModel.data![0].caste == ""){
        cast = "Select caste";
      }else {
        cast = _userDetailModel.data![0].caste.toString();
      }
      about = _userDetailModel.data![0].about.toString();
      education = _userDetailModel.data![0].education.toString();
      company = _userDetailModel.data![0].company.toString();
      jobTitle = _userDetailModel.data![0].jobTitle.toString();


      zodiac_sign = _userDetailModel.data![0].zodiacSign.toString();
      covid_vaccine = _userDetailModel.data![0].covidVaccine.toString();
      pets = _userDetailModel.data![0].pets.toString();
      dietary_preference = _userDetailModel.data![0].dietaryPreference.toString();
      education_level = _userDetailModel.data![0].educationLevel.toString();
      sleeping_habits = _userDetailModel.data![0].sleepingHabits.toString();
      social_media = _userDetailModel.data![0].socialMedia.toString();
      workout = _userDetailModel.data![0].workout.toString();
      health = _userDetailModel.data![0].health.toString();
      smoking = _userDetailModel.data![0].smoking.toString();
      drinking = _userDetailModel.data![0].drinking.toString();
      personality_type = _userDetailModel.data![0].personalityType.toString();
      setState(() {

      });
    }
  }

  Future<void> updateUser() async {
    setState(() {
      clickLoad = true;
    });

    _preferences = await SharedPreferences.getInstance();
    _updateUserModel = await Services.UpdateUser2(
        {
          "userId": "${_preferences?.getString(ShadiApp.userId)}",
          "religion": religion == "Select religion" ? "":religion,
          "caste": cast == "Select caste" ? "":cast,
        }
    );
    if(_updateUserModel.status == 1){
      Toaster.show(context, _updateUserModel.message.toString());
      Navigator.of(context).pushNamed('NameDOB');
    }else{
      Toaster.show(context, _updateUserModel.message.toString());
    }
    setState(() {
      clickLoad = false;
    });
  }

  @override
  void initState() {
    userDetail();
    Religionmethod();
    CheckUserConnection();
    super.initState();
  }

  String religion = 'Select religion';
  String cast = 'Select caste';
  List<String> religionList=['Select religion'];
  List<String> castList=["Select caste"];
  bool isloadreligion=false;
  void Religionmethod() async{
    setState(() {
      isloadreligion=true;
    });
    religionList.clear();
    ReligionModel religionModel = await Services.ReligionMethod();
    if(religionModel.data?.isNotEmpty ?? false){
      religionList.add("Select religion");
      for(ReligionDatum item in religionModel.data ?? []){
        religionList.add(item.name ?? "");
      }
    }
    setState(() {
      isloadreligion=false;
    });
  }
  bool isloadcaste=false;
  void Castemethod(String name) async{
    setState(() {
      isloadcaste=true;
    });
    castList.clear();
    CasteModel casteModel = await Services.CasteMethod(name);
    if(casteModel.data?.isNotEmpty ?? false){
      castList.add("Select caste");
      for(CasteDatum item in casteModel.data ?? []){
        castList.add(item.caste ?? "");
      }
    }
    setState(() {
      isloadcaste=false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CommonColors.themeblack,
      body: SingleChildScrollView(
        child:  Column(
          mainAxisAlignment: MainAxisAlignment.start,
          // crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            new SizedBox(height: MediaQuery.of(context).padding.top+20,),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 10,vertical: 0),
              alignment: Alignment.centerLeft,
              child: InkWell(
                onTap: (){
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
            new SizedBox(height: 40,),
            Container(
              alignment: Alignment.centerLeft,
              margin: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Religion',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            new SizedBox(height: 15,),
            Container(
              height: 50,
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                // color: Colors.white,
                border: Border.all(color: Colors.white),
                borderRadius: const BorderRadius.all(Radius.circular(25)),
              ),
              child: isloadreligion==false ? DropdownButton<String>(
                value: religion,
                underline: Container(
                  // height: 1,
                  // margin:const EdgeInsets.only(top: 20),
                  // color: Colors.white,
                ),
                isExpanded: true,
                style: TextStyle(color:Colors.white,fontSize: 16),
                onChanged: (newValue) {
                  setState(() {
                    religion = newValue!;
                    cast = "Select caste";
                    Castemethod(religion);
                  });
                },
                selectedItemBuilder: (BuildContext context) {
                  return religionList.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value,style: TextStyle(color:religion == 'Select religion' ? Colors.grey:  Colors.white,fontSize: 16),),
                    );
                  }).toList();
                },
                iconSize: 24,
                icon: Icon(Icons.arrow_forward_ios),
                iconDisabledColor: Colors.white,
                items: religionList // add your own dial codes
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value,style: TextStyle(color: CommonColors.themeblack,fontSize: 16),),
                  );
                }).toList(),
              ):Container(),
            ),
            new SizedBox(height: 15,),
            Container(
              alignment: Alignment.centerLeft,
              margin: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Caste',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            new SizedBox(height: 15,),
            Container(
              height: 50,
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                // color: Colors.white,
                border: Border.all(color: Colors.white),
                borderRadius: const BorderRadius.all(Radius.circular(25)),
              ),
              child:isloadcaste==false ? DropdownButton<String>(
                value: castList.isEmpty ? "":cast,
                underline: Container(
                  // height: 1,
                  // margin:const EdgeInsets.only(top: 20),
                  // color: Colors.white,
                ),
                isExpanded: true,
                style: TextStyle(color: Colors.white,fontSize: 16),
                onChanged: (newValue) {
                  setState(() {
                    cast = newValue!;
                  });
                },
                selectedItemBuilder: (BuildContext context) {
                  return castList.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value,style: TextStyle(color:cast == 'Select caste' ? Colors.grey : Colors.white,fontSize: 16),),
                    );
                  }).toList();
                },
                iconSize: 24,
                icon:  Icon(Icons.arrow_forward_ios),
                iconDisabledColor: Colors.white,
                items: castList // add your own dial codes
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value,style: TextStyle(color: CommonColors.themeblack,fontSize: 16),),
                  );
                }).toList(),
              ):Container(),
            ),

            Container(
              alignment: Alignment.center,
              margin: const EdgeInsets.only(top: 16,bottom: 30,left: 28,right: 28),
              child: Text(
                'This will appear on Shaadi-App, however you can choose to hide or show your religion and caste.',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.center,
              ),
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
                      clickLoad ? Expanded(
                          child: Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 3.0,
                            ),
                          )
                      ):
                      Expanded(
                          child: Center(
                            child: Text("Continue", style: TextStyle(
                              color: Colors.white, fontSize: 20,fontWeight: FontWeight.w600,),),
                          )),
                    ],
                  ),
                  SizedBox.expand(
                    child: Material(
                      type: MaterialType.transparency,
                      child: InkWell(onTap: () {
                        // if (religion == "Select religion"){
                        //   Navigator.of(context).pushNamed('NameDOB');
                        // }else{
                        //   if(cast == "Select caste"){
                        //     Navigator.of(context).pushNamed('NameDOB');
                        //   }else {
                            updateUser();
                          // }
                        // }
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
            InkWell(
              onTap: (){
                Navigator.of(context).pushNamed('NameDOB');
              },
              child: Container(
                alignment: Alignment.center,
                margin: const EdgeInsets.only(top: 16,bottom: 30,left: 28,right: 28),
                child: Text(
                  'SKIP',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

