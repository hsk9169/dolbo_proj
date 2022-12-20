import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:dolbo_app/services/api.dart';
import 'package:dolbo_app/models/models.dart';

class FakeApiService implements Api {
  static const _jsonDir = 'assets/json/';
  static const _jsonExtension = '.json';

  @override
  Future<dynamic> getDolboData(String id) async {
    dynamic ret;
    Random rnd;
    int min = 0;
    int max = 4;
    rnd = new Random();
    int r = min + rnd.nextInt(max - min);
    final _resourcePath = _jsonDir + 'dolbo_details' + _jsonExtension;
    final _data = await rootBundle.load(_resourcePath);
    final _map = json.decode(
      utf8.decode(
        _data.buffer.asUint8List(_data.offsetInBytes, _data.lengthInBytes),
      ),
    );
    if (_map['result'] == 'success') {
      ret = DolboModel.fromJson(_map['data']);
    }
    return ret;
  }

  @override
  Future<dynamic> getDolboListByLatLng(
      double lat1, double lng1, double lat2, double lng2) async {
    List<DolboModel> ret = [];
    final _resourcePath = _jsonDir + 'my_dolbo_list' + _jsonExtension;
    final _data = await rootBundle.load(_resourcePath);
    final _map = json.decode(
      utf8.decode(
        _data.buffer.asUint8List(_data.offsetInBytes, _data.lengthInBytes),
      ),
    );
    if (_map['result'] == 'success') {
      ret = _map['data']
          .map<DolboModel>((dynamic element) => DolboModel.fromJson(element))
          .toList();
    }
    return ret;
  }

  @override
  Future<dynamic> getDolboListByKeyword(String keyword) async {
    List<DolboModel> ret = [];
    final _resourcePath = _jsonDir + 'my_dolbo_list' + _jsonExtension;
    final _data = await rootBundle.load(_resourcePath);
    final _map = json.decode(
      utf8.decode(
        _data.buffer.asUint8List(_data.offsetInBytes, _data.lengthInBytes),
      ),
    );
    if (_map['result'] == 'success') {
      ret = _map['data']
          .map<DolboModel>((dynamic element) => DolboModel.fromJson(element))
          .toList();
    }
    return ret;
  }

  @override
  Future<dynamic> getNearestDolboList(double lat, double lng) async {
    dynamic ret;
    final _resourcePath = _jsonDir + 'nearest_dolbo_list' + _jsonExtension;
    final _data = await rootBundle.load(_resourcePath);
    final _map = json.decode(
      utf8.decode(
        _data.buffer.asUint8List(_data.offsetInBytes, _data.lengthInBytes),
      ),
    );
    if (_map['result'] == 'success') {
      ret = DolboModel.fromJson(_map['data']);
    }
    return ret;
  }
}
