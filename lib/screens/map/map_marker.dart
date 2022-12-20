import 'package:flutter/material.dart';
import 'package:naver_map_plugin/naver_map_plugin.dart'
    show Marker, OverlayImage, LatLng;
import 'package:dolbo_app/models/dolbo_model.dart';
import 'package:dolbo_app/const/dolbo_state.dart';

class MapMarker extends Marker {
  final DolboModel dolboData;

  MapMarker({
    required this.dolboData,
    required super.position,
    required super.icon,
    required super.width,
    required super.height,
  }) : super(markerId: dolboData.name);

  factory MapMarker.fromData(DolboModel dolbo, OverlayImage icon) => MapMarker(
        dolboData: dolbo,
        position: LatLng(dolbo.latitude, dolbo.longitude),
        icon: icon,
        width: 29,
        height: 39,
      );

  void setMarkerSmall(BuildContext context) async {
    width = 29;
    height = 39;
  }

  void setMarkerBig(BuildContext context) async {
    width = 43;
    height = 60;
  }

  void setOnMarkerTab(
      void Function(Marker marker, Map<String, int> iconSize) callBack) {
    onMarkerTab = callBack;
  }
}
