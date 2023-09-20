// To parse this JSON data, do
//
//     final otpVerifyModel = otpVerifyModelFromJson(jsonString);

import 'dart:convert';

OtpVerifyModel otpVerifyModelFromJson(String str) {
  final jsonData = json.decode(str);
  return OtpVerifyModel.fromJson(jsonData);
}

String otpVerifyModelToJson(OtpVerifyModel data) {
  final dyn = data.toJson();
  return json.encode(dyn);
}

class OtpVerifyModel {
  int? status;
  String? massege;
  Data? data;

  OtpVerifyModel({
    this.status,
    this.massege,
    this.data,
  });

  factory OtpVerifyModel.fromJson(Map<String, dynamic> json) => new OtpVerifyModel(
    status: json["status"] == null ? null : json["status"],
    massege: json["massege"] == null ? null : json["massege"],
    data: Data.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "status": status == null ? null : status,
    "massege": massege == null ? null : massege,
    "data": data?.toJson(),
  };
}

class Data {
  String? id;
  String? firstName;
  int? profilePercentage;
  String? lastName;
  String? email;
  String? birthDate;
  String? phone;
  String? createdBy;
  String? token;
  String? plan;
  int? otp;
  bool? isBlocked;
  bool? isSuspended;
  bool? isLocation;
  String? createdAt;
  String? updatedAt;
  int? v;

  Data({
    this.id,
    this.firstName,
    this.profilePercentage,
    this.lastName,
    this.email,
    this.birthDate,
    this.phone,
    this.createdBy,
    this.token,
    this.plan,
    this.otp,
    this.isBlocked,
    this.isSuspended,
    this.isLocation,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  factory Data.fromJson(Map<String, dynamic> json) => new Data(
    id: json["_id"] == null ? null : json["_id"],
    firstName: json["first_name"] == null ? null : json["first_name"],
    profilePercentage: json["profilePercentage"] == null ? null : json["profilePercentage"],
    lastName: json["last_name"] == null ? null : json["last_name"],
    email: json["email"] == null ? null : json["email"],
    birthDate: json["birth_date"] == null ? null : json["birth_date"],
    phone: json["phone"] == null ? null : json["phone"],
    createdBy: json["created_by"] == null ? null : json["created_by"],
    token: json["token"] == null ? null : json["token"],
    plan: json["plan"] == null ? null : json["plan"],
    otp: json["otp"] == null ? null : json["otp"],
    isBlocked: json["is_Blocked"] == null ? null : json["is_Blocked"],
    isSuspended: json["is_suspended"] == null ? null : json["is_suspended"],
    isLocation: json["is_location"] == null ? null : json["is_location"],
    createdAt: json["createdAt"] == null ? null : json["createdAt"],
    updatedAt: json["updatedAt"] == null ? null : json["updatesAt"],
    v: json["__v"] == null ? null : json["__v"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id == null ? null : id,
    "first_name": firstName == null ? null : firstName,
    "profilePercentage": profilePercentage == null ? null : profilePercentage,
    "last_name": lastName == null ? null : lastName,
    "email": email == null ? null : email,
    "birth_date": birthDate == null ? null : birthDate,
    "phone": phone == null ? null : phone,
    "created_by": createdBy == null ? null : createdBy,
    "token": token == null ? null : token,
    "plan": plan == null ? null : plan,
    "otp": otp == null ? null : otp,
    "is_Blocked": isBlocked == null ? null : isBlocked,
    "is_suspended": isSuspended == null ? null : isSuspended,
    "is_location": isLocation == null ? null : isLocation,
    "createdAt": createdAt == null ? null : createdAt,
    "updatedAt": updatedAt == null ? null : updatedAt,
    "__v": v == null ? null : v,
  };
}
