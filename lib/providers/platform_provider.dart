import 'package:flutter/foundation.dart';
import 'package:dolbo_app/models/dolbo_model.dart';
import 'package:dolbo_app/const/dolbo_state.dart';

class Platform with ChangeNotifier {
  bool _isLoading = false;
  List<DolboModel> _myDolboList = [];
  int _myDolboListNum = 0;
  DolboModel _defualtDolbo = DolboModel();
  bool _isAlarmAllowed = false;
  String _alarmThreshold = '';
  int _lastSeen = 0;

  bool get isLoading => _isLoading;
  List<DolboModel> get myDolboList => _myDolboList;
  int get myDolboListNum => _myDolboListNum;
  DolboModel get defualtDolbo => _defualtDolbo;
  bool get isAlarmAllowed => _isAlarmAllowed;
  String get alarmThreshold => _alarmThreshold;
  int get lastSeen => _lastSeen;

  set isLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  set myDolboList(List<DolboModel> value) {
    _myDolboList = value;
    notifyListeners();
  }

  set myDolboListNum(int value) {
    _myDolboListNum = value;
    notifyListeners();
  }

  set defualtDolbo(DolboModel value) {
    _defualtDolbo = value;
    notifyListeners();
  }

  set isAlarmAllowed(bool value) {
    _isAlarmAllowed = value;
    notifyListeners();
  }

  set alarmThreshold(String value) {
    _alarmThreshold = value;
    notifyListeners();
  }

  set lastSeen(int value) {
    _lastSeen = value;
    notifyListeners();
  }
}
