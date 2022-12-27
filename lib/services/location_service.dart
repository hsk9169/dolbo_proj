import 'package:geolocator/geolocator.dart';

class LocationService {
  final GeolocatorPlatform _geolocatorPlatform = GeolocatorPlatform.instance;
  Future<bool> checkPermission() async {
    return await _geolocatorPlatform
        .isLocationServiceEnabled()
        .then((bool serviceEnabled) async {
      if (!serviceEnabled) {
        return false;
      } else {
        return await _geolocatorPlatform
            .checkPermission()
            .then((LocationPermission permission) async {
          if (permission == LocationPermission.denied) {
            return await _geolocatorPlatform
                .requestPermission()
                .then((LocationPermission premission) {
              if (permission == LocationPermission.denied) {
                return false;
              } else {
                return true;
              }
            });
          } else if (permission == LocationPermission.deniedForever) {
            return false;
          } else {
            return true;
          }
        });
      }
    });
  }

  Future<Position> getCurrentLocation() async {
    return await _geolocatorPlatform.getCurrentPosition();
  }
}
