// To parse this JSON data, do
//
//     final userDeleteModel = userDeleteModelFromJson(jsonString);

import 'dart:convert';

UserDeleteModel userDeleteModelFromJson(String str) => UserDeleteModel.fromJson(json.decode(str));

String userDeleteModelToJson(UserDeleteModel data) => json.encode(data.toJson());

class UserDeleteModel {
  int? status;
  String? message;

  UserDeleteModel({
    this.status,
    this.message
  });

  factory UserDeleteModel.fromJson(Map<String, dynamic> json) => UserDeleteModel(
    status: json["status"],
    message: json["message"],
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
  };
}
