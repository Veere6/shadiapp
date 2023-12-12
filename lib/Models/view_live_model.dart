// To parse this JSON data, do
//
//     final viewLiveModel = viewLiveModelFromJson(jsonString);

import 'dart:convert';

ViewLiveModel viewLiveModelFromJson(String str) => ViewLiveModel.fromJson(json.decode(str));

String viewLiveModelToJson(ViewLiveModel data) => json.encode(data.toJson());

class ViewLiveModel {
  bool? status;
  String? message;
  int? page;
  int? totalRow;
  List<Datum>? data;

  ViewLiveModel({
    this.status,
    this.message,
    this.page,
    this.totalRow,
    this.data,
  });

  factory ViewLiveModel.fromJson(Map<String, dynamic> json) => ViewLiveModel(
    status: json["status"],
    message: json["message"],
    page: json["page"],
    totalRow: json["totalRow"],
    data: json["data"] == null ? [] : List<Datum>.from(json["data"]!.map((x) => Datum.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "page": page,
    "totalRow": totalRow,
    "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
  };
}

class Datum {
  String? id;
  String? userId;
  int? v;
  DateTime? createdAt;
  bool? isLive;
  String? token;
  String? channelName;
  DateTime? updatedAt;

  Datum({
    this.id,
    this.userId,
    this.v,
    this.createdAt,
    this.isLive,
    this.token,
    this.channelName,
    this.updatedAt,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    id: json["_id"],
    userId: json["userId"],
    v: json["__v"],
    createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
    isLive: json["isLive"],
    token: json["token"],
    channelName: json["channelName"],
    updatedAt: json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "userId": userId,
    "__v": v,
    "createdAt": createdAt?.toIso8601String(),
    "isLive": isLive,
    "token": token,
    "channelName": channelName,
    "updatedAt": updatedAt?.toIso8601String(),
  };
}
