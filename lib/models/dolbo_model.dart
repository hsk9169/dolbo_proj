import 'package:dolbo_app/const/data_type.dart';

class DolboModel {
  late String? id = '';
  late String? type = '';
  late String? name = '';
  late String? address = '';
  late double? latitude = 0.0;
  late double? longitude = 0.0;
  late String? lastDataTime = '';
  late String? state = '';
  late String? safety = '';
  late double? waterLevel = 0.0;
  late double? temperature = 0;
  late double? humidity = 0;
  late int? traffic = 0;
  late List<ChartData>? dailyWaterLevel = [];
  late List<ChartData>? weeklyWaterLevel = [];
  late double? warningIndicator = 0;
  late double? dangerIndicator = 0;

  DolboModel({
    this.id,
    this.type,
    this.name,
    this.address,
    this.latitude,
    this.longitude,
    this.lastDataTime,
    this.state,
    this.safety,
    this.waterLevel,
    this.temperature,
    this.humidity,
    this.traffic,
    this.dailyWaterLevel,
    this.weeklyWaterLevel,
    this.warningIndicator,
    this.dangerIndicator,
  });

  DolboModel.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? '';
    type = json['type'] ?? '';
    name = json['name'] ?? '';
    address = json['address'] ?? '';
    latitude = json['latitude'] ?? 0.0;
    longitude = json['longitude'] ?? 0.0;
    state = json['state'] ?? '';
    safety = json['safety'] ?? '';

    json['sensors'].forEach((dynamic element) {
      if (element['type'] == 'WATER_LEVEL') {
        lastDataTime = element.containsKey('time')
            ? element['time']
            : element['values'].length > 0
                ? element['values'].last['time']
                : '-';
        waterLevel = element.containsKey('value')
            ? element['value']
            : element.containsKey('values')
                ? element['values'].last['value']
                : 0.0;
        warningIndicator = element['indicator']['warning'];
        dangerIndicator = element['indicator']['danger'];
        dailyWaterLevel = element.containsKey('values')
            ? element['values']
                ?.map<ChartData>((element) =>
                    ChartData(time: element['time'], value: element['value']))
                .toList()
            : [];
        weeklyWaterLevel = element.containsKey('days')
            ? element['days']
                ?.map<ChartData>((element) =>
                    ChartData(time: element['date'], value: element['value']))
                .toList()
            : [];
      } else if (element['type'] == 'HUMIDITY') {
        humidity = element.containsKey('value')
            ? element['value']
            : element.containsKey('values') && element['values'].length > 0
                ? element['values'].last['value']
                : 0.0;
      } else if (element['type'] == 'TEMPERATURE') {
        temperature = element.containsKey('value')
            ? element['value']
            : element.containsKey('values') && element['values'].length > 0
                ? element['values'].last['value']
                : 0.0;
      }
    });
  }
}
