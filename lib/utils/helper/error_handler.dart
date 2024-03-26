import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

@singleton
class ErrorHandler {
  // ignore: deprecated_member_use
  static String handleErrorMessage(DioError error) {
    if (error.response != null &&
        error.response!.statusCode == HttpStatus.internalServerError) {
      if (kDebugMode) print(error.response.toString());
      return 'Something went wrong please try again later';
    } else if (error.response != null &&
        error.response?.statusCode != HttpStatus.notFound) {
      String errorMsg = error.response?.data.toString() ?? '';
      return errorMsg;
    } else if (error.response?.statusCode == HttpStatus.serviceUnavailable) {
      return 'You\'re offline';
    }
    return 'Something went wrong please try again later';
  }
}
