import 'dart:convert';
import 'dart:ffi';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:shadiapp/Models/CasteModel.dart';
import 'package:shadiapp/Models/DropdownModel.dart';
import 'package:shadiapp/Models/ReligionModel.dart';
import 'package:shadiapp/Models/add_location_model.dart';
import 'package:shadiapp/Models/age_height_range_model.dart';
import 'package:shadiapp/Models/city_list_model.dart';
import 'package:shadiapp/Models/country_list_model.dart';
import 'package:shadiapp/Models/delete_image_model.dart';
import 'package:shadiapp/Models/like_model.dart';
import 'package:shadiapp/Models/matchlist.dart';
import 'package:shadiapp/Models/my_matches_model.dart';
import 'package:shadiapp/Models/new_matches_model.dart';
import 'package:shadiapp/Models/otp_verify_model.dart';
import 'package:shadiapp/Models/otpsend.dart';
import 'package:shadiapp/Models/phone_login_Model.dart';
import 'package:shadiapp/Models/plan_list_model.dart';
import 'package:shadiapp/Models/preference_list_model.dart';
import 'package:shadiapp/Models/statelistmodel.dart';
import 'package:shadiapp/Models/top_picks_model.dart';
import 'package:shadiapp/Models/update_image_model.dart';
import 'package:shadiapp/Models/update_setting_model.dart';
import 'package:shadiapp/Models/upload_image_model.dart';
import 'package:shadiapp/Models/user_add_preference_model.dart';
import 'package:shadiapp/Models/user_delete_model.dart';
import 'package:shadiapp/Models/user_detail_model.dart';
import 'package:shadiapp/Models/user_list_model.dart';
import 'package:shadiapp/Models/user_update_model.dart';
import 'package:shadiapp/Models/user_view_preference_model.dart';
import 'package:shadiapp/Models/verifiedModel.dart';
import 'package:shadiapp/Models/view_image_model.dart';
import 'package:shadiapp/Models/view_like_sent_model.dart';
import 'package:shadiapp/Models/view_profile_model.dart';

class Services {
  static String BaseUrl = "http://52.63.253.231:4000/api/v1/";

  static String Login = BaseUrl + "login";
  static String GoogleLogin = BaseUrl + "google/login";
  static String match_list = BaseUrl + "own/matches";
  static String OtpVerify = BaseUrl + "otp-verify";
  static String UserDetail = BaseUrl + "userDetails";
  static String otherUserDetail = BaseUrl + "view/profile";
  static String UserUpdate = BaseUrl + "update";
  static String username = BaseUrl + "update/username";
  static String updateemail = BaseUrl + "update/email";
  static String updatephone = BaseUrl + "update/phone";
  static String UploadImge = BaseUrl + "user/uploadImage/";
  static String ViewImage = BaseUrl + "user/images";
  static String PrefList = BaseUrl + "user/preference";
  static String Verify = BaseUrl + "profile/copmplete";
  static String Verifypro = BaseUrl + "profile/verify";
  static String AddPrefs = BaseUrl + "user/addpreference";
  static String UserList = BaseUrl + "users/list";
  static String ViewPrefs = BaseUrl + "user/preferenceList";
  static String LikeApi = BaseUrl + "user/creatematch";
  static String ViewProfile = BaseUrl + "profile";
  static String LikeView = BaseUrl + "sent/req";
  static String SetRange = BaseUrl + "set/range";
  static String MyMatches = BaseUrl + "own/matches";
  static String ListPlan = BaseUrl + "plan/list";
  static String TopPicks = BaseUrl + "top/pics";
  static String NewMatch = BaseUrl + "new/match";
  static String keytype = BaseUrl + "keytype";
  static String Country = BaseUrl + "country/list";
  static String City = BaseUrl + "city/list";
  static String State = BaseUrl + "state/list";
  static String religion = BaseUrl + "religion/list";
  static String caste = BaseUrl + "caste/list";
  static String ImageDelete = BaseUrl + "user/delete/image";
  static String UserDelete = BaseUrl + "delete/account";
  static String ImageUpdate = BaseUrl + "user/updateImage/";
  static String subscribePlan = BaseUrl + "subscribePlan";
  static String location = BaseUrl + "location";

  static Future<PhoneLoginModel> LoginCrdentials(String phone) async {
    final params = {
      "phone": phone
    };
    print("PhoneLoginParams " + params.toString());
    http.Response response = await http.post(Uri.parse(Login), body: params);
    print("PhoneLoginResponse" + response.body);

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      PhoneLoginModel user = PhoneLoginModel.fromJson(data);
      return user;
    } else {
      print(response.body);
      throw Exception('Failed');
    }
  }
  static Future<OtpSend> UpdateEmail(String userId,email) async {
    final params = {
      "id": userId,
      if(email.isNotEmpty) "is_Email": email,
    };
    print("OtpSend " + params.toString());
    http.Response response = await http.post(Uri.parse(updateemail), body: params);
    print("OtpSend" + response.body);

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      OtpSend user = OtpSend.fromJson(data);
      return user;
    } else {
      var data = jsonDecode(response.body);
      OtpSend user = OtpSend.fromJson(data);
      return user;
    }
  }
  static Future<OtpSend> UpdatePhone(String userId,phone) async {
    final params = {
      "id": userId,
      if(phone.isNotEmpty) "phone": phone,
    };
    print("OtpSend " + params.toString());
    http.Response response = await http.post(Uri.parse(updatephone), body: params);
    print("OtpSend" + response.body);

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      OtpSend user = OtpSend.fromJson(data);
      return user;
    } else {
      var data = jsonDecode(response.body);
      OtpSend user = OtpSend.fromJson(data);
      return user;
    }
  }
  static Future<OtpVerifyModel> GoogleCrdentials(String token) async {
    final params = {"token": token};
    print("GoogleCrdentials " + params.toString());
    http.Response response = await http.post(Uri.parse(GoogleLogin), body: params);
    print("GoogleCrdentials" + response.body);


    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      OtpVerifyModel user = OtpVerifyModel.fromJson(data);
      return user;
    } else {
      print(response.body);
      throw Exception('Failed');
    }
  }
  static Future<MatchList> MatchListMethod(String user_id) async {
    final params = {"id": user_id};
    // final params = {"id": "6452535298f7692c6a731291"};
    print("MatchListMethod" + params.toString());
    http.Response response = await http.post(Uri.parse(match_list), body: params);
    print("MatchListMethod" + response.body);

    if(response.statusCode == 200) {
      var data = jsonDecode(response.body);
      MatchList user = MatchList.fromJson(data);
      return user;
    }else{
      print(response.body);
      throw Exception('Failed');
    }
  }
  static Future<ReligionModel> ReligionMethod() async {

    http.Response response = await http.post(Uri.parse(religion));
    print("ReligionModel" + response.body);

    if(response.statusCode == 200) {
      var data = jsonDecode(response.body);
      ReligionModel user = ReligionModel.fromJson(data);
      return user;
    }else{
      var data = jsonDecode(response.body);
      ReligionModel user = ReligionModel.fromJson(data);
      return user;
    }
  }
  static Future<CasteModel> CasteMethod(String name) async {
    final params = {"name": name};
    print("CasteModel $params");
    http.Response response = await http.post(Uri.parse(caste), body: params);
    print("CasteModel" + response.body);

    if(response.statusCode == 200) {
      var data = jsonDecode(response.body);
      CasteModel user = CasteModel.fromJson(data);
      return user;
    }else{
      var data = jsonDecode(response.body);
      CasteModel user = CasteModel.fromJson(data);
      return user;
    }
  }

  static Future<OtpVerifyModel> Otp(String Id, String otp) async {
    final params = {"userId": Id, "otp": otp};
    print("OtpVerifyParams ${params.toString()}");
    http.Response response =
    await http.post(Uri.parse(OtpVerify), body: params);
    print("OtpVerifyResponse ${response.body}");

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      OtpVerifyModel user = OtpVerifyModel.fromJson(data);
      return user;
    } else {
      var data = jsonDecode(response.body);
      OtpVerifyModel user = OtpVerifyModel.fromJson(data);
      return user;
    }
  }

  static Future<UserDetailModel> UserDetailMethod(String uId) async {
    var request = http.MultipartRequest(
      'GET',
      Uri.parse(UserDetail),
    );
    request.fields["userId"] = uId;
    var response = await request.send();
    var response2 = await http.Response.fromStream(response);
    print("UserDetailMethodParams ${request.fields}");
    print("UserDetailMethodResponse ${response2.body}");
    if (response2.statusCode==200) {
      var data = json.decode(response2.body);
      UserDetailModel user = UserDetailModel.fromJson(data);
      return user;
    } else {
      throw Exception('Failed');
    }
  }
  static Future<UserDetailModel> OtherUserDetailMethod(String uId) async {
    var request = http.MultipartRequest(
      'GET',
      Uri.parse(otherUserDetail),
    );
    request.fields["userId"] = uId;
    var response = await request.send();
    var response2 = await http.Response.fromStream(response);
    print("OtherUserDetailMethod ${request.fields}");
    print("OtherUserDetailMethod ${response2.body}");
    if (response2.statusCode==200) {
      var data = json.decode(response2.body);
      UserDetailModel user = UserDetailModel.fromJson(data);
      return user;
    } else {
      throw Exception('Failed');
    }
  }

  static Future<UpdateUserModel> UpdateUser(
      String uId,
      String firstName,
      String lastName,
      String birthDate,
      String gender,
      String country,
      String city,
      String state,
      String height,
      String weight,
      String maritalStatus,
      String email,
      String lookinFor,
      String religion,
      String caste,
      String about,
      String education,
      String company,
      String jobTitle,
      String zodiac_sign,
      String education_level,
      String covid_vaccine,
      String pets,
      String dietary_preference,
      String sleeping_habits,
      String social_media,
      String workout,
      String smoking,
      String health,
      String drinking,
      String personality_type,
      String marriage_plan,
      String mother_tongue,
      String managedBy,
      ) async {
    final params = {
      "userId": uId,
      "first_name": firstName,
      "last_name": lastName,
      "birth_date": birthDate,
      "gender": gender,
      "country": country,
      "city": city,
      "state": state,
      "height": height,
      "weight": weight,
      "marital_status": maritalStatus,
      "email": email,
      "looking_for": lookinFor,
      "religion": religion,
      "caste": caste,
      "about": about,
      "education": education,
      "job_title": jobTitle,
      "company": company,
      "zodiac_sign":zodiac_sign,
      "education_level":education_level,
      "covid_vaccine":covid_vaccine,
      "pets":pets,
      "dietary_preference":dietary_preference,
      "sleeping_habits":sleeping_habits,
      "social_media":social_media,
      "workout":workout,
      "smoking":smoking,
      "health":health,
      "drinking":drinking,
      "personality_type":personality_type,
      "marriage_plan":marriage_plan,
      "mother_tongue":mother_tongue,
      "managedBy":managedBy
    };

    print("UpdateUserParams " + params.toString());
    http.Response response =
    await http.post(Uri.parse(UserUpdate), body: params);
    print("UpdateUserResponse" + response.body);

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      UpdateUserModel user = UpdateUserModel.fromJson(data);
      return user;
    } else {
      var data = jsonDecode(response.body);
      UpdateUserModel user = UpdateUserModel.fromJson(data);
      return user;

    }
  }

  static Future<UpdateUserModel> UpdateUser2(final object) async {
    final params = object;
    print("UpdateUserParams2 " + params.toString());
    http.Response response =
    await http.post(Uri.parse(UserUpdate), body: params);
    print("UpdateUserResponse2" + response.body);

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      UpdateUserModel user = UpdateUserModel.fromJson(data);
      return user;
    } else {
      var data = jsonDecode(response.body);
      UpdateUserModel user = UpdateUserModel.fromJson(data);
      return user;

    }
  }
  static Future<UpdateUserModel> Updatevoice(String user_id,File voice) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse(UserUpdate),
    );
    var file = await http.MultipartFile.fromPath("voice_record", voice.path);
    request.files.add(file);
    request.fields["userId"] = user_id;
    var response = await request.send();
    var response2 = await http.Response.fromStream(response);
    print("UpdatevoiceMethodParams ${request.fields}");
    print("UpdatevoiceMethodParams ${request.files}");
    print("UpdatevoiceMethodResponse ${response2.body}");
    if (response2.statusCode==200) {
      var data = json.decode(response2.body);
      UpdateUserModel user = UpdateUserModel.fromJson(data);
      return user;
    } else {
      throw Exception('Failed');
    }
  }



  static Future<UpdateUserModel> CheckUpdateUser2(final object) async {
    final params = object;
    print("CheckUpdateUser2Params " + params.toString());
    http.Response response =
    await http.post(Uri.parse(username), body: params);
    print("CheckUpdateUser2Response" + response.body);

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      UpdateUserModel user = UpdateUserModel.fromJson(data);
      return user;
    } else {
      var data = jsonDecode(response.body);
      UpdateUserModel user = UpdateUserModel.fromJson(data);
      return user;

    }
  }

  static Future<UploadImageModel> ImageUpload(File image, String uId) async {
    var request =
    new http.MultipartRequest("POST", Uri.parse("${UploadImge}${uId}"));

    var file = await http.MultipartFile.fromPath("fileUrl", image.path);
    request.files.add(file);

    var response = await request.send();
    var response2 = await http.Response.fromStream(response);

    print(response.toString());
    print("ImageUpload " + response2.body);

    if (response2.statusCode == 200) {
      var data = json.decode(response2.body);
      UploadImageModel user = UploadImageModel.fromJson(data);
      return user;
    } else {
      throw Exception('Failed');
    }
  }

  static Future<ViewImageModel> ImageView(String uId) async {
    var request = http.MultipartRequest(
      'GET',
      Uri.parse(ViewImage),
    );

    request.fields["userId"] = uId;
    var response = await request.send();
    var response2 = await http.Response.fromStream(response);
    print("ImageViewParams ${request.fields}");
    print("ImageViewResponse ${response2.body}");
    if (response2.statusCode == 200) {
      var data = json.decode(response2.body);
      ViewImageModel user = ViewImageModel.fromJson(data);
      return user;
    } else {
      throw Exception('Failed');
    }
  }

  static Future<PreferenceListModel> PrefView(String uId) async {
    var request = http.MultipartRequest(
      'GET',
      Uri.parse(PrefList),
    );

    request.fields["userId"] = uId;
    var response = await request.send();
    var response2 = await http.Response.fromStream(response);
    print("ImageViewParams ${request.fields}");
    print("ImageViewResponse ${response2.body}");
    if (response2.statusCode == 200) {
      var data = json.decode(response2.body);
      PreferenceListModel user = PreferenceListModel.fromJson(data);
      return user;
    } else {
      throw Exception('Failed');
    }
  }
  static Future<VerifiedModel> VerifyMethod(String uId,File image) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse(Verifypro),
    );
    var file = await http.MultipartFile.fromPath("image", image.path);
    request.files.add(file);
    request.fields["id"] = uId;
    var response = await request.send();
    var response2 = await http.Response.fromStream(response);
    print("VerifyMethod ${request.files}");
    print("VerifyMethod ${request.fields}");
    print("VerifyMethod ${response2.body}");
    if (response2.statusCode == 200) {
      var data = json.decode(response2.body);
      VerifiedModel user = VerifiedModel.fromJson(data);
      return user;
    } else {
      var data = json.decode(response2.body);
      VerifiedModel user = VerifiedModel.fromJson(data);
      return user;
    }
  }

  static Future<AddPreferenceModel> AddPrefsMethod(
      String uId, preferenceId) async {
    final params = {"userId": uId, "preferenceId": preferenceId};

    print("AddPrefsMethodParams " + params.toString());
    http.Response response = await http.post(Uri.parse(AddPrefs), body: params);
    print("AddPrefsMethodResponse" + response.body);

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      AddPreferenceModel user = AddPreferenceModel.fromJson(data);
      return user;
    } else {
      var data = jsonDecode(response.body);
      AddPreferenceModel user = AddPreferenceModel.fromJson(data);
      return user;
    }
  }
  static Future<AddPreferenceModel> AddCustomPrefsMethod(
      String uId, title) async {
    final params = {"userId": uId, "title": title};

    print("AddPrefsMethodParams " + params.toString());
    http.Response response = await http.post(Uri.parse(AddPrefs), body: params);
    print("AddPrefsMethodResponse" + response.body);

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      AddPreferenceModel user = AddPreferenceModel.fromJson(data);
      return user;
    } else {
      var data = jsonDecode(response.body);
      AddPreferenceModel user = AddPreferenceModel.fromJson(data);
      return user;
    }
  }

  static Future<UserListModel> GetUserMethod(String uId,other_user,my_id,firebasetoken) async {
    var request = http.MultipartRequest(
      'GET',
      Uri.parse(UserList),
    );

    request.fields["id"] = uId;
    if(my_id!="") request.fields["my_id"] = my_id;
   if(other_user!="") request.fields["other_user"] = other_user;
   if(firebasetoken!="") request.fields["fcm_token"] = firebasetoken;
    var response = await request.send();
    var response2 = await http.Response.fromStream(response);
    print("GetUserMethodParams ${request.fields}");
    print("GetUserMethodResponse ${response2.body}");
    if (response2.statusCode == 200) {
      var data = json.decode(response2.body);
      UserListModel user = UserListModel.fromJson(data);
      return user;
    } else {
      throw Exception('Failed');
    }
  }

  static Future<UserViewPreferenceModel> ViewUserPreference(String uId) async {
    var request = http.MultipartRequest(
      'GET',
      Uri.parse(ViewPrefs),
    );

    request.fields["userId"] = uId;
    var response = await request.send();
    var response2 = await http.Response.fromStream(response);
    print("ViewPreferenceParams ${request.fields}");
    print("ViewPreferenceResponse ${response2.body}");
    if (response2.statusCode == 200) {
      var data = json.decode(response2.body);
      UserViewPreferenceModel user = UserViewPreferenceModel.fromJson(data);
      return user;
    } else {
      throw Exception('Failed');
    }
  }

  static Future<LikeModel> LikeMethod(
      String senderId, String receiverId, String type) async {
    final params = {"sender": senderId, "receiver": receiverId, "type": type};
    // final params = {"receiver": senderId, "sender": receiverId, "type": type};

    print("LikeMethodParams " + params.toString());
    http.Response response = await http.post(Uri.parse(LikeApi), body: params);
    print("LikeMethodResponse" + response.body);

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      LikeModel user = LikeModel.fromJson(data);
      return user;
    } else {
      var data = jsonDecode(response.body);
      LikeModel user = LikeModel.fromJson(data);
      return user;
    }
  }

  static Future<ViewProfileModel> ProfileView(String id) async {
    final params = {"id": id};

    print("ProfileViewParams " + params.toString());
    http.Response response =
    await http.post(Uri.parse(ViewProfile), body: params);
    print("ProfileViewResponse" + response.body);

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      ViewProfileModel user = ViewProfileModel.fromJson(data);
      return user;
    } else {
      print(response.body);
      throw Exception('Failed');
    }
  }

  static Future<ViewLikeSentModel> ViewLike(String id) async {
    final params = {"id": id};

    print("ViewLikeParams " + params.toString());
    http.Response response = await http.post(Uri.parse(LikeView), body: params);
    print("ViewLikeResponse" + response.body);

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      ViewLikeSentModel user = ViewLikeSentModel.fromJson(data);
      return user;
    } else {
      print(response.body);
      throw Exception('Failed');
    }
  }

  static Future<AgeHeightRangeModel> RangeSet(final object) async {
    final params = object;
    print("RangeSetParams " + params.toString());
    http.Response response = await http.post(Uri.parse(SetRange), body: params);
    print("RangeSetResponse" + response.body);

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      AgeHeightRangeModel user = AgeHeightRangeModel.fromJson(data);
      return user;
    } else {
      print(response.body);
      throw Exception('Failed');
    }
  }

  static Future<MyMatchesModel> MyMatchesList(String id) async {
    final params = {
      "id": id,
    };

    print("MyMatchesListParams " + params.toString());
    http.Response response = await http.post(Uri.parse(MyMatches), body: params);
    print("MyMatchesListResponse" + response.body);

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      MyMatchesModel user = MyMatchesModel.fromJson(data);
      return user;
    } else {
      print(response.body);
      throw Exception('Failed');
    }
  }

  static Future<PlanListModel> PlanList(String id) async {
    final params = {
      "id": id,
    };

    http.Response response = await http.post(Uri.parse(ListPlan),body: params);
    print("PlanListResponse" + response.body);
    print("PlanListResponse ${response.statusCode}");

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      PlanListModel user = PlanListModel.fromJson(data);
      return user;
    } else {
      print(response.body);
      throw Exception('Failed');
    }
  }

  static Future<TopPicksModel> TopPicksList(String id) async {
    final params = {
      "userId": id,
    };

    print("TopPicksListParams " + params.toString());
    http.Response response = await http.post(Uri.parse(TopPicks), body: params);
    print("TopPicksListResponse" + response.body);

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      TopPicksModel user = TopPicksModel.fromJson(data);
      return user;
    } else {
      var data = jsonDecode(response.body);
      TopPicksModel user = TopPicksModel.fromJson(data);
      return user;
      throw Exception('Failed');
    }
  }

  static Future<NewMatchesModel> NewMatchesList(String id) async {
    final params = {
      "id": id,
    };

    print("NewMatchesListParams " + params.toString());
    http.Response response = await http.post(Uri.parse(NewMatch), body: params);
    print("NewMatchesListResponse" + response.body);

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      NewMatchesModel user = NewMatchesModel.fromJson(data);
      return user;
    } else {
      print(response.body);
      throw Exception('Failed');
    }
  }

  static Future<DropdownModel> DropdownList(String id) async {
    // final params = {
    //   "id": id,
    // };
    //
    // print("DropdownModel " + params.toString());
    // http.Response response = await http.get(Uri.parse(keytype), body: params);
    // print("DropdownModel" + response.body);

    var request = http.MultipartRequest(
      'GET',
      Uri.parse(keytype),
    );

    request.fields["id"] = id;
    var response = await request.send();
    var response2 = await http.Response.fromStream(response);
    print("DropdownModel${response2.body}");
    if (response2.statusCode == 200) {
      var data = jsonDecode(response2.body);
      DropdownModel user = DropdownModel.fromJson(data);
      return user;
    } else {
      print(response2.body);
      throw Exception('Failed');
    }
  }

  static Future<CountryListModel> CountryList() async {

    http.Response response = await http.post(Uri.parse(Country));
    print("CountryListResponse" + response.body);

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      CountryListModel user = CountryListModel.fromJson(data);
      return user;
    } else {
      print(response.body);
      throw Exception('Failed');
    }
  }
  static Future<CountryListModel> CountryListLogin() async {

    http.Response response = await http.post(Uri.parse(Country));
    print("CountryListResponse" + response.body);

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      CountryListModel user = CountryListModel.fromJson(data);
      return user;
    } else {
      print(response.body);
      throw Exception('Failed');
    }
  }

  static Future<StateListModel> StateList(String name,String stateName) async {

    final params = {
      "name": name,
      "stateName":stateName,
    };

    print("CityListResponse $params");
    http.Response response = await http.post(Uri.parse(State), body: params);
    print("CityListResponse" + response.body);

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      StateListModel user = StateListModel.fromJson(data);
      return user;
    } else {
      print(response.body);
      var data = jsonDecode(response.body);
      StateListModel user = StateListModel.fromJson(data);
      return user;
      // throw Exception('Failed');
    }
  }
  static Future<CItyListModel> CityList(String name,String isoCode,String countryCode) async {

    final params = {
      "name": name,
      "isoCode":isoCode,
      "countryCode":countryCode
    };

    print("CityListResponse??? $params");
    http.Response response = await http.post(Uri.parse(City), body: params);
    print("CityListResponse???" + response.body);

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      CItyListModel user = CItyListModel.fromJson(data);
      return user;
    } else {
      print(response.body);
      var data = jsonDecode(response.body);
      CItyListModel user = CItyListModel.fromJson(data);
      return user;
      // throw Exception('Failed');
    }
  }

  static Future<DeleteImageModel> DeleteImage(String imageId) async {

    final params = {
      "id": imageId
    };

    print("DeleteImageResponse $params");
    http.Response response = await http.delete(Uri.parse(ImageDelete), body: params);
    print("DeleteImageResponse" + response.body);

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      DeleteImageModel user = DeleteImageModel.fromJson(data);
      return user;
    } else {
      print(response.body);
      throw Exception('Failed');
    }
  }

  static Future<UserDeleteModel> DeleteUser(String id) async {

    final params = {
      "id": id
    };

    print("DeleteUserResponse $params");
    http.Response response = await http.delete(Uri.parse(UserDelete), body: params);
    print("DeleteUserResponse" + response.body);

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      UserDeleteModel user = UserDeleteModel.fromJson(data);
      return user;
    } else {
      print(response.body);
      throw Exception('Failed');
    }
  }

  static Future<UpdateImageModel> UpdateImage(String id, String imageId, File image) async {

    var request = http.MultipartRequest(
      'PUT',
      Uri.parse("${ImageUpdate}${id}"),
    );

    request.fields["id"] = imageId;

    var file = await http.MultipartFile.fromPath("fileUrl", image.path);
    request.files.add(file);

    var response = await request.send();
    var response2 = await http.Response.fromStream(response);

    print(response.toString());
    print("ImageUpload " + response2.body);

    if (response2.statusCode == 200) {
      var data = json.decode(response2.body);
      UpdateImageModel user = UpdateImageModel.fromJson(data);
      return user;
    } else {
      throw Exception('Failed');
    }
  }

  static Future<UpdateSettingModel> updateSetting(final object) async{
    final params = object;
    print("updateSettingParams " + params.toString());
    http.Response response =
    await http.post(Uri.parse(UserUpdate), body: params);
    print("updateSettingResponse" + response.body);

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      UpdateSettingModel user = UpdateSettingModel.fromJson(data);
      return user;
    } else {
      var data = jsonDecode(response.body);
      UpdateSettingModel user = UpdateSettingModel.fromJson(data);
      return user;

    }
  }
  static Future<UpdateSettingModel> SubscribePlan(final object) async{
    final params = object;
    print("SubscribePlan " + params.toString());
    http.Response response =
    await http.post(Uri.parse(subscribePlan), body: params);
    print("SubscribePlan" + response.body);

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      UpdateSettingModel user = UpdateSettingModel.fromJson(data);
      return user;
    } else {
      var data = jsonDecode(response.body);
      UpdateSettingModel user = UpdateSettingModel.fromJson(data);
      return user;

    }
  }
  static Future<AddLocationModel> AddLocation(final object) async{
    final params = object;
    print("AddLocation " + params.toString());
    http.Response response =
    await http.post(Uri.parse(location), body: params);
    print("AddLocation" + response.body);

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      AddLocationModel user = AddLocationModel.fromJson(data);
      return user;
    } else {
      var data = jsonDecode(response.body);
      AddLocationModel user = AddLocationModel.fromJson(data);
      return user;

    }
  }
}
