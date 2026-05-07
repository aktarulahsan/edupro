import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';

UserModel userModelFromJson(String str) => UserModel.fromJson(json.decode(str));

String userModelToJson(UserModel data) => json.encode(data.toJson());

enum UserType {
  admin,
  user,
}

extension on String {
  UserType get type {
    switch (this) {
      case "admin":
        return UserType.admin;
      default:
        return UserType.admin;
    }
  }
}

class UserModel {
  UserModel({
    this.userId,
    this.emailAddress,
    this.fristName,
    this.lastName,
    this.referredBy,
    this.mobileNumber,
    this.imageUrl,
    this.password,
    this.gender,
    this.occupation,
    this.country,
    this.status,
    this.insertDate,
    this.entryBy,
    this.updateDate,
    this.updateBy,
    this.authorization,
    this.userType,
  });

  int? userId;
  String? emailAddress;
  String? fristName;
  String? lastName;
  String? referredBy;
  String? mobileNumber;
  String? imageUrl;
  String? password;
  String? gender;
  String? occupation;
  String? country;
  int? status;
  dynamic insertDate;
  String? entryBy;
  dynamic updateDate;
  dynamic updateBy;

  Authorization? authorization;
  UserType? userType;

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        userId: json["userId"]??json["id"],
        // emailAddress: json["emailAddress"],
        emailAddress: json["emailAddress"] ?? json["email"],
        fristName: json["frist_name"]??json["firstname"],
        lastName: json["last_name"]??json["lastname"],
        referredBy: json["referred_by"],
        mobileNumber: json["mobile_number"],
        imageUrl: json["image_url"] ??
            json["imageUrl"] ??
            json["photo_url"] ??
            json["photoUrl"] ??
            json["avatar"] ??
            json["image"],
        password: json["password"],
        gender: json["gender"],
        occupation: json["occupation"],
        country: json["country"],
        status: json["status"],
        insertDate: json["insert_date"],
        entryBy: json["entry_by"],
        updateDate: json["update_date"],
        updateBy: json["update_by"],
        // authorization: Authorization.fromMap(json['authorization']),
        // userType: json["userType"] == null
        //     ? json['userType'].toString().type
        //     : UserType.admin.name.type,
      );

  Map<String, dynamic> toJson() => {
        "userId": userId,
        "emailAddress": emailAddress,
        "frist_name": fristName,
        "last_name": lastName,
        "referred_by": referredBy,
        "mobile_number": mobileNumber,
        "image_url": imageUrl,
        "password": password,
        "gender": gender,
        "occupation": occupation,
        "country": country,
        "status": status,
        "insert_date": insertDate,
        "entry_by": entryBy,
        "update_date": updateDate,
        "update_by": updateBy,
        // 'authorization': authorization!.toMap(),
        // 'userType': userType!.name,
      };
}

class UserCache {
  static final _box = GetStorage();

  // Save user data to cache
  static Future<void> saveUserData(UserModel user) async {
    await _box.write('user', user.toJson());
  }

  // Get user data from cache
  static UserModel? getUserData() {
    final userData = _box.read('user');
    if (userData != null) {
      return UserModel.fromJson(userData);
    } else {
      return null;
    }
  }

  static String? getUserName() {
    final userData = _box.read('user');
    //print("userData  $userData");
    if (userData != null) {
      UserModel model = UserModel.fromJson(userData);
      return model.emailAddress!;
    } else {
      return "";
    }
  }

  static int? getUesrId() {
    final userData = _box.read('user');
    //print("userData2  $userData");
    if (userData != null) {
      UserModel model = UserModel.fromJson(userData);
      return model.userId;
    } else {
      return null;
    }
  }

  // Clear user data from cache
  static Future<void> clearUserData() async {
    await _box.remove('user');
  }

  static bool isUserEmpty() {
    // Retrieve user data from cache
    UserModel? cachedUser = UserCache.getUserData();
    if (cachedUser != null) {
      return false;
    }
    return true;
  }

  static bool isSessionExpire() {
    // if (isUserEmpty()) {
    //   return true;
    // }
    UserModel? cachedUser = UserCache.getUserData();

    if (cachedUser == null) {
      return true;
    }
    if (DateTime.parse(cachedUser.authorization!.expires_in)
        .isBefore(DateTime.now())) {
      return true;
    }
    return false;
  }

  static bool isUser() {
    // if (isUserEmpty()) {
    //   return false;
    // }
    UserModel cachedUser = UserCache.getUserData()!;
    if (cachedUser.userId == UserType.user) {
      return true;
    }
    return false;
  }

  static bool isAPIUser() {
    // if (isUserEmpty()) {
    //   return false;
    // }
    UserModel cachedUser = UserCache.getUserData()!;
    if (cachedUser.emailAddress == "admin@gmail.com") {
      return true;
    }
    return false;
  }

  // static Options getAuthOption() {
  //   UserModel cachedUser = UserCache.getUserData()!;
  //   return Options(contentType: Headers.jsonContentType, headers: {
  //     "Authorization": "Bearer token", //${cachedUser.authorization!.token}",
  //   });
  // }
  static Options getAuthOption() {
    UserModel cachedUser = UserCache.getUserData()!;
    return Options(contentType: Headers.jsonContentType, headers: {
      "Authorization": "Bearer ${cachedUser.authorization!.token}",
    });
  }

  static Options getOption() {
    return Options(contentType: Headers.jsonContentType, headers: {
      'Accept': "application/json",
    });
  }

// static sassingExistAndUserAdmin() {
//   if (!isSessionExpire()) {}
// }
}

class Authorization {
  final String token;
  final String expires_in;
  Authorization({
    required this.token,
    required this.expires_in,
  });

  Map<String, dynamic> toMap() {
    return {
      'token': token,
      'expires_in': expires_in,
    };
  }

  factory Authorization.fromMap(Map<String, dynamic> map) {
    return Authorization(
      token: map['token'] ?? '',
      expires_in: map['expires_in'].runtimeType == int
          ? DateTime.fromMillisecondsSinceEpoch(map['expires_in'])
              .toIso8601String()
          : map['expires_in'],
    );
  }

  String toJson() => json.encode(toMap());

  factory Authorization.fromJson(String source) =>
      Authorization.fromMap(json.decode(source));
}
