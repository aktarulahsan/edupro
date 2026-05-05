import 'dart:convert';

BaseResponse responseFromJson(String str) =>
    BaseResponse.fromJson(json.decode(str));

String responseToJson(BaseResponse data) => json.encode(data.toJson());

class BaseResponse {
  BaseResponse({
    this.success,
    this.info,
    this.warning,
    this.message,
    this.valid,
    this.id,
    this.model,
    this.data,
    this.items,
    this.obj,
    this.status,
  });

  bool? success;
  bool? info;
  bool? warning;
  String? message;
  bool? valid;
  dynamic id;
  dynamic model;
  dynamic data;
  dynamic items;
  dynamic obj;
  dynamic status;

  factory BaseResponse.fromJson(Map<String, dynamic> json) => BaseResponse(
    success: json["success"],
    info: json["info"],
    warning: json["warning"],
    message: json["message"],
    valid: json["valid"],
    id: json["id"],
    model: json["model"],
    data: json["data"],
    items: json["items"],
    obj: json["obj"],
    status: json["status"],
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "info": info,
    "warning": warning,
    "message": message,
    "valid": valid,
    "id": id,
    "model": model,
    "data": data,
    "items": items,
    "obj": obj,
    "status": status,
  };
}
