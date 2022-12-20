import 'package:dolbo_app/models/models.dart';

abstract class Api {
  Future<dynamic> getDolboData(String id);
  Future<dynamic> getDolboListByLatLng(
      double lat1, double lng1, double lat2, double lng2);
  Future<dynamic> getDolboListByKeyword(String keyword);
  Future<dynamic> getNearestDolboList(double lat, double lng);
}
