// ignore_for_file: deprecated_member_use

import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../interfaces/i_connection_service.dart';

class ConnectionInterceptor extends Interceptor {
  final IConnectionService connectionService;

  ConnectionInterceptor(this.connectionService);

  @override
  Future onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    var connectivityResult = await connectionService.checkConnection();
    log(connectivityResult.toString());
    if (connectivityResult == false) {
      final error = DioError(
        requestOptions: options,
        response: Response(
          requestOptions: options,
          statusCode: HttpStatus.serviceUnavailable,
          statusMessage: 'You\'re offline',
        ),
      );
      return handler.reject(error);
    }
    return super.onRequest(options, handler);
  }

  @override
  void onError(DioError err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 503) {
      Fluttertoast.showToast(
        msg: err.response?.statusMessage ?? 'Something went wrong',
        toastLength: Toast.LENGTH_SHORT,
        backgroundColor: Colors.grey,
        gravity: ToastGravity.BOTTOM,
      );
    } else {
      Fluttertoast.showToast(
        msg: 'An error occurred: ${err.message}',
        toastLength: Toast.LENGTH_SHORT,
        backgroundColor: Colors.grey,
        gravity: ToastGravity.BOTTOM,
      );
    }
    return super.onError(err, handler);
  }
}
