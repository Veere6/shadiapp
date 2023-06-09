// To parse this JSON data, do
//
//     final cItyListModel = cItyListModelFromJson(jsonString);

import 'dart:convert';

CItyListModel cItyListModelFromJson(String str) => CItyListModel.fromJson(json.decode(str));

String cItyListModelToJson(CItyListModel data) => json.encode(data.toJson());

class CItyListModel {
  bool? status;
  String? message;
  List<Datum>? data;

  CItyListModel({
    this.status,
    this.message,
    this.data,
  });

  factory CItyListModel.fromJson(Map<String, dynamic> json) => CItyListModel(
    status: json["status"],
    message: json["message"],
    data: json["data"] == null ? [] : List<Datum>.from(json["data"]!.map((x) => Datum.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
  };
}

class Datum {
  String? name;
  String? countryCode;
  String? stateCode;
  String? latitude;
  String? longitude;

  Datum({
    this.name,
    this.countryCode,
    this.stateCode,
    this.latitude,
    this.longitude,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    name: json["name"],
    countryCode: json["countryCode"],
    stateCode: json["stateCode"],
    latitude: json["latitude"],
    longitude: json["longitude"],
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "countryCode": countryCode,
    "stateCode": stateCode,
    "latitude": latitude,
    "longitude": longitude,
  };
}

