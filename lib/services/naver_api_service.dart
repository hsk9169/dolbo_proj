import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:dolbo_app/models/naver_map_data_model.dart';

class NaverApiService {
  final _hostAddress = 'naveropenapi.apigw.ntruss.com';
  final _apiKeyId = '';
  final _secretKey = '';

  Future<dynamic> getCenterLatLngOfAddress(String address) async {
    try {
      final res = await http.get(
          Uri(
              scheme: 'https',
              host: _hostAddress,
              path: '/map-geocode/v2/geocode',
              queryParameters: {
                'query': address,
              }),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=utf-8',
            'X-NCP-APIGW-API-KEY-ID': _apiKeyId,
            'X-NCP-APIGW-API-KEY': _secretKey,
          });
      final body = jsonDecode(res.body);
      final List<NaverMapDataModel> ret = [];
      if (body['status'] == 'OK') {
        return body['addresses']
            .map<NaverMapDataModel>(
                (dynamic element) => NaverMapDataModel.fromJson(element))
            .toList();
      } else {
        return null;
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
}
