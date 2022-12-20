import 'package:naver_map_plugin/naver_map_plugin.dart';

class NaverMapDataModel {
  late LatLng? centerLatLng = LatLng(0, 0);
  late String? roadAddress = '';

  NaverMapDataModel({
    this.centerLatLng,
    this.roadAddress,
  });

  NaverMapDataModel.fromJson(Map<String, dynamic> json) {
    centerLatLng = LatLng(double.parse(json['y']), double.parse(json['x']));
    roadAddress = json['roadAddress'];
  }

  Map<String, dynamic> toJson() => {
        'centerLatLng':
            'lat: ${centerLatLng!.latitude}, lng: ${centerLatLng!.longitude}',
        'roadAddress': roadAddress,
      };
}
