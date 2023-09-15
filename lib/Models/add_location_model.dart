// To parse this JSON data, do
//
//     final addLocationModel = addLocationModelFromJson(jsonString);

import 'dart:convert';

AddLocationModel addLocationModelFromJson(String str) => AddLocationModel.fromJson(json.decode(str));

String addLocationModelToJson(AddLocationModel data) => json.encode(data.toJson());

class AddLocationModel {
  int? status;
  String? message;
  Data? data;

  AddLocationModel({
    this.status,
    this.message,
    this.data,
  });

  factory AddLocationModel.fromJson(Map<String, dynamic> json) => AddLocationModel(
    status: json["status"],
    message: json["message"],
    data: json["data"] == null ? null : Data.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": data?.toJson(),
  };
}

class Data {
  String? id;
  String? firstName;
  String? lastName;
  String? email;
  DateTime? birthDate;
  String? countryCode;
  String? phone;
  String? height;
  String? gender;
  String? image;
  String? weight;
  String? city;
  String? state;
  String? country;
  String? about;
  String? managedBy;
  String? createdBy;
  String? token;
  int? otp;
  String? religion;
  String? caste;
  String? jobTitle;
  String? company;
  String? education;
  bool? isBlocked;
  bool? isSuspended;
  String? socialId;
  String? socialPlatform;
  bool? isLocation;
  String? plan;
  int? minAge;
  int? maxAge;
  int? minHeight;
  int? maxHeight;
  bool? isOnline;
  bool? isShowOnCard;
  bool? goGlobel;
  bool? goIncognito;
  bool? showPeopleInRange;
  bool? isAge;
  bool? isHeight;
  bool? isWeight;
  bool? isSmoke;
  bool? isDrink;
  bool? isDiet;
  int? isVerified;
  bool? dataIsEmail;
  bool? isPush;
  bool? isPhotoOption;
  String? saveCountry;
  String? isEmail;
  String? isPhone;
  String? voiceRecord;
  String? spotifyUsername;
  String? spotifyId;
  List<dynamic>? spotifyPlaylist;
  List<dynamic>? spotifyArtistlist;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? v;
  String? lookingFor;
  String? maritalStatus;
  bool? showMeOnline;
  Location? location;

  Data({
    this.id,
    this.firstName,
    this.lastName,
    this.email,
    this.birthDate,
    this.countryCode,
    this.phone,
    this.height,
    this.gender,
    this.image,
    this.weight,
    this.city,
    this.state,
    this.country,
    this.about,
    this.managedBy,
    this.createdBy,
    this.token,
    this.otp,
    this.religion,
    this.caste,
    this.jobTitle,
    this.company,
    this.education,
    this.isBlocked,
    this.isSuspended,
    this.socialId,
    this.socialPlatform,
    this.isLocation,
    this.plan,
    this.minAge,
    this.maxAge,
    this.minHeight,
    this.maxHeight,
    this.isOnline,
    this.isShowOnCard,
    this.goGlobel,
    this.goIncognito,
    this.showPeopleInRange,
    this.isAge,
    this.isHeight,
    this.isWeight,
    this.isSmoke,
    this.isDrink,
    this.isDiet,
    this.isVerified,
    this.dataIsEmail,
    this.isPush,
    this.isPhotoOption,
    this.saveCountry,
    this.isEmail,
    this.isPhone,
    this.voiceRecord,
    this.spotifyUsername,
    this.spotifyId,
    this.spotifyPlaylist,
    this.spotifyArtistlist,
    this.createdAt,
    this.updatedAt,
    this.v,
    this.lookingFor,
    this.maritalStatus,
    this.showMeOnline,
    this.location,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    id: json["_id"],
    firstName: json["first_name"],
    lastName: json["last_name"],
    email: json["email"],
    birthDate: json["birth_date"] == null ? null : DateTime.parse(json["birth_date"]),
    countryCode: json["country_code"],
    phone: json["phone"],
    height: json["height"],
    gender: json["gender"],
    image: json["image"],
    weight: json["weight"],
    city: json["city"],
    state: json["state"],
    country: json["country"],
    about: json["about"],
    managedBy: json["managedBy"],
    createdBy: json["created_by"],
    token: json["token"],
    otp: json["otp"],
    religion: json["religion"],
    caste: json["caste"],
    jobTitle: json["job_title"],
    company: json["company"],
    education: json["education"],
    isBlocked: json["is_Blocked"],
    isSuspended: json["is_suspended"],
    socialId: json["social_id"],
    socialPlatform: json["social_platform"],
    isLocation: json["is_location"],
    plan: json["plan"],
    minAge: json["minAge"],
    maxAge: json["maxAge"],
    minHeight: json["minHeight"],
    maxHeight: json["maxHeight"],
    isOnline: json["is_online"],
    isShowOnCard: json["is_showOnCard"],
    goGlobel: json["goGlobel"],
    goIncognito: json["go_incognito"],
    showPeopleInRange: json["show_people_in_range"],
    isAge: json["is_age"],
    isHeight: json["is_height"],
    isWeight: json["is_weight"],
    isSmoke: json["is_smoke"],
    isDrink: json["is_drink"],
    isDiet: json["is_diet"],
    isVerified: json["is_verified"],
    dataIsEmail: json["is_email"],
    isPush: json["is_push"],
    isPhotoOption: json["is_photo_option"],
    saveCountry: json["save_country"],
    isEmail: json["is_Email"],
    isPhone: json["is_Phone"],
    voiceRecord: json["voice_record"],
    spotifyUsername: json["spotify_username"],
    spotifyId: json["spotify_id"],
    spotifyPlaylist: json["spotify_playlist"] == null ? [] : List<dynamic>.from(json["spotify_playlist"]!.map((x) => x)),
    spotifyArtistlist: json["spotify_artistlist"] == null ? [] : List<dynamic>.from(json["spotify_artistlist"]!.map((x) => x)),
    createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
    updatedAt: json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
    v: json["__v"],
    lookingFor: json["looking_for"],
    maritalStatus: json["marital_status"],
    showMeOnline: json["show_me_online"],
    location: json["location"] == null ? null : Location.fromJson(json["location"]),
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "first_name": firstName,
    "last_name": lastName,
    "email": email,
    "birth_date": birthDate?.toIso8601String(),
    "country_code": countryCode,
    "phone": phone,
    "height": height,
    "gender": gender,
    "image": image,
    "weight": weight,
    "city": city,
    "state": state,
    "country": country,
    "about": about,
    "managedBy": managedBy,
    "created_by": createdBy,
    "token": token,
    "otp": otp,
    "religion": religion,
    "caste": caste,
    "job_title": jobTitle,
    "company": company,
    "education": education,
    "is_Blocked": isBlocked,
    "is_suspended": isSuspended,
    "social_id": socialId,
    "social_platform": socialPlatform,
    "is_location": isLocation,
    "plan": plan,
    "minAge": minAge,
    "maxAge": maxAge,
    "minHeight": minHeight,
    "maxHeight": maxHeight,
    "is_online": isOnline,
    "is_showOnCard": isShowOnCard,
    "goGlobel": goGlobel,
    "go_incognito": goIncognito,
    "show_people_in_range": showPeopleInRange,
    "is_age": isAge,
    "is_height": isHeight,
    "is_weight": isWeight,
    "is_smoke": isSmoke,
    "is_drink": isDrink,
    "is_diet": isDiet,
    "is_verified": isVerified,
    "is_email": dataIsEmail,
    "is_push": isPush,
    "is_photo_option": isPhotoOption,
    "save_country": saveCountry,
    "is_Email": isEmail,
    "is_Phone": isPhone,
    "voice_record": voiceRecord,
    "spotify_username": spotifyUsername,
    "spotify_id": spotifyId,
    "spotify_playlist": spotifyPlaylist == null ? [] : List<dynamic>.from(spotifyPlaylist!.map((x) => x)),
    "spotify_artistlist": spotifyArtistlist == null ? [] : List<dynamic>.from(spotifyArtistlist!.map((x) => x)),
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
    "__v": v,
    "looking_for": lookingFor,
    "marital_status": maritalStatus,
    "show_me_online": showMeOnline,
    "location": location?.toJson(),
  };
}

class Location {
  String? type;
  List<double>? coordinates;

  Location({
    this.type,
    this.coordinates,
  });

  factory Location.fromJson(Map<String, dynamic> json) => Location(
    type: json["type"],
    coordinates: json["coordinates"] == null ? [] : List<double>.from(json["coordinates"]!.map((x) => x?.toDouble())),
  );

  Map<String, dynamic> toJson() => {
    "type": type,
    "coordinates": coordinates == null ? [] : List<dynamic>.from(coordinates!.map((x) => x)),
  };
}
