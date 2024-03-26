// ignore_for_file: deprecated_member_use

import 'dart:developer';

// ignore: implementation_imports, depend_on_referenced_packages
import 'package:async/src/result/result.dart';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import '../../main.dart';
import '../helper/error_handler.dart';
import '../interfaces/i_connection_service.dart';
import 'connection_interceptor.dart';

@singleton
class NetworkService {
  late _NetworkClient _networkClient;

  NetworkService() {
    _networkClient = _NetworkClient();
  }

  Future<Result<Response>> getAsync(
      {required String url, Map<String, dynamic>? queryParameters}) async {
    try {
      var response = await _networkClient.getAsync(
          url: url, queryParameters: queryParameters);
      var isError = _errorMessageHandler(response.data);
      if (isError != '') {
        return Result.error(isError);
      }
      return Result.value(response);
    } on DioError catch (error) {
      String errorMsg = ErrorHandler.handleErrorMessage(error);
      return Result.error(errorMsg);
    } catch (error, stacktrace) {
      log('$error', stackTrace: stacktrace);
      return Result.error(error);
    }
  }

  Future<Result<Response>> postAsync({
    required String url,
    dynamic body,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      var response = await _networkClient.postAsync(
          url: url, body: body, queryParameters: queryParameters);

      var isError = _errorMessageHandler(response.data);
      if (isError != '') {
        return Result.error(isError);
      }
      return Result.value(response);
    } on DioError catch (error) {
      String errorMsg = ErrorHandler.handleErrorMessage(error);
      return Result.error(errorMsg);
    } catch (error, stacktrace) {
      log('$stacktrace');
      return Result.error(error);
    }
  }

  Future<Result<Response>> postMultiPartFormDataAsync({
    required String url,
    required ValueNotifier<double> uploadProgressNotifier,
    required Map<String,dynamic> formMap,
    Map<String,dynamic>? queryParameters,
  }) async {
    try {
      var response = await _networkClient.postMultiPartFormDataAsync(
          url: url,
          uploadProgressNotifier: uploadProgressNotifier,
          formMap: formMap,
          queryParameters: queryParameters
      );
      if (kDebugMode) print(response.toString());

      var isError = _errorMessageHandler(response.data);
      if (isError != '') {
        return Result.error(isError);
      }
      return Result.value(response);
    } on DioError catch (error) {
      if (kDebugMode) print(error);
      String errorMsg = ErrorHandler.handleErrorMessage(error);
      return Result.error(errorMsg);
    } catch (error, stacktrace) {
      if (kDebugMode) print(error);
      log('$stacktrace');
      return Result.error(error);
    }
  }

  Future<Result<Response>> putAsync({
    required String url,
    dynamic body,
    Map<String, dynamic>? query,
    Map<String, dynamic>? headers,
  }) async {
    try {
      var response = await _networkClient.putAsync(url: url, body: body);

      var isError = _errorMessageHandler(response.data);
      if (isError != '') {
        return Result.error(isError);
      }
      return Result.value(response);
    } on DioError catch (error) {
      String errorMsg = ErrorHandler.handleErrorMessage(error);
      return Result.error(errorMsg);
    } catch (error, stacktrace) {
      log('$stacktrace');
      return Result.error(error);
    }
  }

  Future<Result<Response>> putMultiPartFormDataAsync({
    required String url,
    required ValueNotifier<double> uploadProgressNotifier,
    required Map<String, dynamic> formMap,
  }) async {
    try {
      var response = await _networkClient.putMultiPartFormDataAsync(
        url: url,
        uploadProgressNotifier: uploadProgressNotifier,
        formMap: formMap,
      );

      var isError = _errorMessageHandler(response.data);
      if (isError != '') {
        return Result.error(isError);
      }
      return Result.value(response);
    } on DioError catch (error) {
      String errorMsg = ErrorHandler.handleErrorMessage(error);
      return Result.error(errorMsg);
    } catch (error, stacktrace) {
      log('$stacktrace');
      return Result.error(error);
    }
  }

  Future<Result<Response>> deleteAsync({
    required String url,
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  }) async {
    try {
      var response = await _networkClient.deleteAsync(
          url: url, queryParameters: queryParameters);

      var isError = _errorMessageHandler(response.data);
      if (isError != '') {
        return Result.error(isError);
      }
      return Result.value(response);
    } on DioError catch (error) {
      String errorMsg = ErrorHandler.handleErrorMessage(error);
      return Result.error(errorMsg);
    } catch (error, stacktrace) {
      log('$stacktrace');
      return Result.error(error);
    }
  }

  String _errorMessageHandler(Map<String, dynamic> decodedResponse) {
    if (decodedResponse['isError'] == false) return '';
    if (decodedResponse['result'] != null &&
        decodedResponse['result'] is Map &&
        decodedResponse['result']['message'] != null) {
      return decodedResponse['result']['message'];
    } else if (decodedResponse['message'] != null) {
      return decodedResponse['message'];
    }
    return '';
  }
}

class _NetworkClient {
  late Dio _client;

  _NetworkClient() {
    _client = Dio(
      BaseOptions(
        baseUrl: 'http://20.229.143.71:8082/',
        headers: {'accept': 'text/plain'},
        contentType: 'application/json',
        receiveTimeout: const Duration(milliseconds: 100000),
      ),
    );
    _client.interceptors.addAll([
      ConnectionInterceptor(getIt<IConnectionService>()),
      PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        responseHeader: false,
        compact: false,
      )
    ]);
  }

  Future<Response> getAsync(
      {required String url, Map<String, dynamic>? queryParameters}) async {
    return await _client.get<dynamic>(url, queryParameters: queryParameters);
  }

  Future<Response> postAsync(
      {required String url,
        dynamic body,
        Map<String, dynamic>? queryParameters}) async {
    return await _client.post<dynamic>(url,
        data: body, queryParameters: queryParameters);
  }

  Future<Response> postMultiPartFormDataAsync({
    required String url,
    required ValueNotifier<double> uploadProgressNotifier,
    required Map<String,dynamic> formMap,
    Map<String,dynamic>? queryParameters
  }) async {
    final cancelToken = CancelToken();
    var formData = FormData.fromMap(formMap);

    return await _client.post<dynamic>(url,
        data: formData, options: Options(contentType: 'multipart/form-data'),
        onSendProgress: (int send, int total) {
          final progress = (send / total) * 100;
          uploadProgressNotifier.value = progress;
        }, cancelToken: cancelToken);
  }

  Future<Response> putMultiPartFormDataAsync({
    required String url,
    required ValueNotifier<double> uploadProgressNotifier,
    required Map<String, dynamic> formMap,
    Map<String, dynamic>? queryParameters
  }) async {
    final cancelToken = CancelToken();
    var formData = FormData.fromMap(formMap);

    return await _client.post<dynamic>(url,
        queryParameters: queryParameters,
        data: formData, options: Options(contentType: 'multipart/form-data'),
        onSendProgress: (int send, int total) {
          final progress = (send / total) * 100;
          uploadProgressNotifier.value = progress;
        }, cancelToken: cancelToken);
  }

  Future<Response> putAsync({
    required String url,
    required dynamic body,
    Map<String, dynamic>? query,
    Map<String, dynamic>? headers,
  }) async {
    return await _client.put<dynamic>(
      url,
      data: body,
      queryParameters: query,
      options: Options(
        headers: _client.options.headers
          ..addAll(headers ?? <String, dynamic>{}),
      ),
    );
  }

  Future<Response> deleteAsync({
    required String url,
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  }) async {
    return await _client.delete<dynamic>(
      url,
      data: body,
      queryParameters: queryParameters,
      options: Options(
        headers: _client.options.headers
          ..addAll(headers ?? <String, dynamic>{}),
      ),
    );
  }
}
