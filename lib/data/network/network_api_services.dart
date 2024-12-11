import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:learn_mvvm/data/app_exception.dart';
import 'package:learn_mvvm/data/network/base_api_services.dart';
import '../../shared/shared.dart';

class NetworkApiServices implements BaseApiServices{

dynamic returnResponse(http.Response response) {
    switch (response.statusCode) {
      case 200:
        dynamic responseJson = jsonDecode(response.body);
        return responseJson;
      case 400:
        throw BadRequestException(response.body.toString());
      case 500:
      case 404:
        throw UnauthorisedException(response.body.toString());
      default:
        throw FetchDataException(
            'Error occured while communicating with server');
    }
  }

  @override
  Future getApiResponse(String endpoint) async {
    dynamic responseJson;
     try {
      final response = await http
          .get(Uri.https(Const.baseUrl, endpoint), headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'key': Const.apiKey,
      });
      responseJson = returnResponse(response);
    } on SocketException {
      throw NoInternetException('');
    } on TimeoutException {
      throw FetchDataException('Network request time out!');
    }

    return responseJson;
  }

  @override
  Future<dynamic> postApiResponse(String endpoint,
      {Map<String, dynamic>? body}) async {
    dynamic responseJson;
    try {
      final response = await http
          .post(
            Uri.https(Const.baseUrl, endpoint),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
              'key': Const.apiKey,
            },
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 30));

      responseJson = returnResponse(response);
    } on SocketException {
      throw NoInternetException('No Internet Connection');
    } on TimeoutException {
      throw FetchDataException('Network request timed out!');
    } on Exception catch (e) {
      throw FetchDataException('Unexpected error occurred: $e');
    }

    return responseJson;
  }
  

}