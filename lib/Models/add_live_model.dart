// To parse this JSON data, do
//
//     final addLiveModel = addLiveModelFromJson(jsonString);

import 'dart:convert';

AddLiveModel addLiveModelFromJson(String str) => AddLiveModel.fromJson(json.decode(str));

String addLiveModelToJson(AddLiveModel data) => json.encode(data.toJson());

class AddLiveModel {
  bool? status;
  String? message;
  dynamic data;

  AddLiveModel({
    this.status,
    this.message,
    this.data,
  });

  factory AddLiveModel.fromJson(Map<String, dynamic> json) => AddLiveModel(
    status: json["status"],
    message: json["message"],
    data: json["data"],
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": data,
  };
}
