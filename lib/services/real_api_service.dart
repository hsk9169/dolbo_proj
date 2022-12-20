import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import './api.dart';
import 'package:dolbo_app/models/dolbo_model.dart';

class RealApiService implements Api {
  final _hostAddress = 'epops.kr';
  final _apiKey = '50c525-c81d27-310a67-ee3767-88ff41';

  @override
  Future<dynamic> getDolboData(String id) async {
    try {
      final res = await http.get(
          Uri(
              scheme: 'http',
              host: _hostAddress,
              path: '/iot/api/v1/bridge/$id',
              queryParameters: {
                'key': _apiKey,
              }),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=utf-8',
          });
      final body = jsonDecode(res.body);
      if (body['result'] == 'success') {
        return DolboModel.fromJson(body['data']);
      } else {
        return body['message'];
      }
    } catch (err) {
      if (err is SocketException) {
        return 'SOCKET_EXCEPTION';
      } else if (err is TimeoutException) {
        return 'SERVER_TIMEOUT';
      } else {
        return 'UNKNOWN_ERROR';
      }
    }
  }

  @override
  Future<dynamic> getDolboListByLatLng(
      double lat1, double lng1, double lat2, double lng2) async {
    try {
      final res = await http.get(
          Uri(
              scheme: 'http',
              host: _hostAddress,
              path: '/iot/api/v1/bridge',
              queryParameters: {
                'key': _apiKey,
                'area': '$lat1:$lng1-$lat2:$lng2'
              }),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=utf-8',
          });
      final body = jsonDecode(res.body);
      if (body['result'] == 'success') {
        return body['data']
            .map<DolboModel>((dynamic element) => DolboModel.fromJson(element))
            .toList();
      } else {
        return body['message'];
      }
    } catch (err) {
      if (err is SocketException) {
        return 'SOCKET_EXCEPTION';
      } else if (err is TimeoutException) {
        return 'SERVER_TIMEOUT';
      } else {
        return 'UNKNOWN_ERROR';
      }
    }
  }

  @override
  Future<dynamic> getDolboListByKeyword(String keyword) async {
    try {
      final res = await http.get(
          Uri(
              scheme: 'http',
              host: _hostAddress,
              path: '/iot/api/v1/bridge',
              queryParameters: {
                'key': _apiKey,
                'keyword': keyword,
              }),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=utf-8',
          });
      final body = jsonDecode(res.body);
      if (body['result'] == 'success') {
        return body['data']
            .map<DolboModel>((dynamic element) => DolboModel.fromJson(element))
            .toList();
      } else {
        return body['message'];
      }
    } catch (err) {
      if (err is SocketException) {
        return 'SOCKET_EXCEPTION';
      } else if (err is TimeoutException) {
        return 'SERVER_TIMEOUT';
      } else {
        return 'UNKNOWN_ERROR';
      }
    }
  }

  @override
  Future<dynamic> getNearestDolboList(double lat, double lng) async {
    try {
      final res = await http.get(
          Uri(
              scheme: 'http',
              host: _hostAddress,
              path: '/iot/api/v1/bridge/nearest',
              queryParameters: {'key': _apiKey, 'from': '$lat:$lng'}),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=utf-8',
          });
      print('sub debug 1');
      final body = jsonDecode(res.body);
      if (body['result'] == 'success') {
        print('sub debug 2');
        return DolboModel.fromJson(body['data']);
      } else {
        print('sub debug 3');
        return body['message'];
      }
    } catch (err) {
      print('sub debug 4');
      if (err is SocketException) {
        print('sub debug 5');
        return 'SOCKET_EXCEPTION';
      } else if (err is TimeoutException) {
        print('sub debug 6');
        return 'SERVER_TIMEOUT';
      } else {
        print('sub debug 7');
        return 'UNKNOWN_ERROR';
      }
    }
  }
}
