import 'package:flutter/foundation.dart';
import 'package:dolbo_app/models/dolbo_model.dart';

class Platform with ChangeNotifier {
  bool _isLoading = false;
  List<DolboModel> _myDolboList = [];
  int _myDolboListNum = 0;
  DolboModel _defualtDolbo = DolboModel();

  bool get isLoading => _isLoading;
  List<DolboModel> get myDolboList => _myDolboList;
  int get myDolboListNum => _myDolboListNum;
  DolboModel get defualtDolbo => _defualtDolbo;

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
}
