import 'package:dartz/dartz.dart';
import 'package:edupro/infrastructure/dal/daos/usersModel.dart';
import 'package:edupro/infrastructure/service/apiService.dart';

import '../dal/daos/baseResponse.dart';
import 'api_excepiton_handeler.dart';
// import 'package:work_at_home/infrastructure/dal/daos/baseResponse.dart';
// import 'package:work_at_home/infrastructure/dal/daos/usersModel.dart';
// import 'package:work_at_home/services/apiService.dart';
// import 'package:work_at_home/services/api_excepiton_handeler.dart';

class ApiRepository {
  static ApiRepository? _instance;
  // Avoid self instance
  ApiRepository._();
  static ApiRepository get instance => _instance ??= ApiRepository._();

  Future<Either<String, BaseResponse>> get(
      APIRequestParam requestPayload) async {
    return await AppApiProvider.instance
        .get(requestPayload.copyWith(options: UserCache.getAuthOption()))
        .then((response) {
      return response.fold((error) {
        final errorString = error.response?.data ?? error.dioError();
        return Left(errorString);
      }, (success) {
        try {
          final BaseResponse output = BaseResponse.fromJson(success.data);
          if (output.status == 200) {
            return Right(output);
          } else {
            return Left(output.message!);
          }
        } catch (e) {
          return Left(e.toString());
        }
      });
    });
  }
}
