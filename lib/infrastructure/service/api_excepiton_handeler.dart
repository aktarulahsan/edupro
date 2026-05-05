import 'package:dio/dio.dart';

class APIExceptionHandler {
  static String handleException(dynamic error) {
    String errorMessage = "An error occurred. Please try again later.";
    if (error is DioException) {
      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout ||
          error.type == DioExceptionType.sendTimeout) {
        errorMessage = "Connection timed out. Please try again later.";
      } else if (error.type == DioExceptionType.badResponse) {
        if (error.response?.statusCode == 400) {
          errorMessage = "Invalid request. Please try again.";
        } else if (error.response?.statusCode == 401) {
          errorMessage = "Unauthorized. Please login again.";
        } else if (error.response?.statusCode == 403) {
          errorMessage = "Access denied. Please contact support.";
        } else if (error.response?.statusCode == 404) {
          errorMessage = "Resource not found. Please try again later.";
        } else if (error.response?.statusCode == 500) {
          errorMessage =
              "An error occurred on the server. Please try again later.";
        } else {
          errorMessage = "An error occurred. Please try again later.";
        }
      } else if (error.type == DioExceptionType.cancel) {
        errorMessage = "Request cancelled.";
      } else {
        errorMessage = "An error occurred. Please try again later.";
      }
    }
    return errorMessage;
  }
}

extension DioErrorAsString on DioException {
  String dioError() {
    switch (type) {
      case DioExceptionType.cancel:
        return "We're sorry, but there seems to be a delay in connecting to the server. Please check your internet connection and try again. If the problem persists, please contact our support team for further assistance. We apologize for any inconvenience caused";
      case DioExceptionType.connectionTimeout:
        return "We're sorry, but there seems to be a delay in connecting to the server. Please check your internet connection and try again. If the problem persists, please contact our support team for further assistance. We apologize for any inconvenience caused";
      case DioExceptionType.unknown:
        return "Slow or no internet connection";
      case DioExceptionType.receiveTimeout:
        return "We're sorry, but there seems to be a delay in connecting to the server. Please check your internet connection and try again. If the problem persists, please contact our support team for further assistance. We apologize for any inconvenience caused";
      case DioExceptionType.badResponse:
        switch (response?.statusCode) {
          case 400:
            return "Bad request";
          case 401:
            return "Unauthorized access";
          case 403:
            return "Forbidden access";
          case 404:
            return "Resource not found";
          case 409:
            return "Conflict";
          case 500:
            return "Internal server error";
          default:
            return "An error occurred. Please try again";
        }
      case DioExceptionType.sendTimeout:
        return "We're sorry, but there seems to be a delay in connecting to the server. Please check your internet connection and try again. If the problem persists, please contact our support team for further assistance. We apologize for any inconvenience caused";
      default:
    }
    return "An error occurred. Please try again";
  }
}
