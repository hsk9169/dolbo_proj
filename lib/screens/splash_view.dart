import 'dart:async';
import 'package:dolbo_app/const/dolbo_state.dart';
import 'package:dolbo_app/services/real_api_service.dart';
import 'package:naver_map_plugin/naver_map_plugin.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dolbo_app/utils/topic_handler.dart';
import 'package:dolbo_app/sizes.dart';
import 'package:dolbo_app/routes.dart';
import 'package:dolbo_app/screens/screens.dart';
import 'package:dolbo_app/providers/platform_provider.dart';
import 'package:dolbo_app/services/location_service.dart';
import 'package:dolbo_app/models/dolbo_model.dart';
import 'package:dolbo_app/services/encrypted_storage_service.dart';

class SplashView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SplashView();
}

class _SplashView extends State<SplashView> {
  final _encryptedStorageService = EncryptedStorageService();
  final _locationService = LocationService();
  final _realApiService = RealApiService();
  int _debugLevel = 0;
  late List<DolboModel> _myDolboList;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      await _initData();
      await _setAlarmData();
      await _routeToHome();
    });
  }

  Future<void> _initData() async {
    await _encryptedStorageService.initStorage();
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool('first_run') ?? true) {
      await _encryptedStorageService.deleteAllData();
      prefs.setBool('first_run', false);
    }
    await _getStoredData();
  }

  Future<void> _getStoredData() async {
    final platformProvider = Provider.of<Platform>(context, listen: false);
    final String listNum;
    final dynamic curLocation;
    final DolboModel nearest;
    List<DolboModel> myList = [];
    await _encryptedStorageService.readAll();
    listNum = await _encryptedStorageService.readData('list_num');
    curLocation = await _getCurrentLocation();
    if (curLocation.latitude < 0 || curLocation.longitude < 0) {
      nearest = await _realApiService.getNearestDolboList(
          37.48319126127905, 127.01326680880636);
    } else {
      nearest = await _realApiService.getNearestDolboList(
          curLocation.latitude, curLocation.longitude);
    }
    setState(() => _debugLevel++);
    if (listNum.isNotEmpty) {
      platformProvider.myDolboListNum = int.parse(listNum);
      for (int i = 0; i < int.parse(listNum); i++) {
        final id = await _encryptedStorageService.readData('element_$i');
        if (id.isNotEmpty) {
          final res = await _realApiService.getDolboData(id);
          myList.add(res);
        }
      }
    }
    platformProvider.myDolboList = myList;
    platformProvider.defualtDolbo = nearest;
    setState(() {
      _myDolboList = myList;
      _debugLevel++;
    });
  }

  Future<dynamic> _getCurrentLocation() async {
    final dynamic curPosition;
    final isPermitted = await _locationService.checkPermission();
    setState(() => _debugLevel++);
    if (isPermitted) {
      curPosition = await _locationService.getCurrentLocation();
    } else {
      curPosition = const LatLng(37.48319126127905, 127.01326680880636);
    }
    setState(() => _debugLevel++);
    return curPosition;
  }

  Future<void> _setAlarmData() async {
    final platformProvider = Provider.of<Platform>(context, listen: false);
    final isAllowed = await _encryptedStorageService.readData('alarm_allowed');
    final threshold =
        await _encryptedStorageService.readData('alarm_threshold');
    if (isAllowed == 'TRUE') {
      _myDolboList.forEach((DolboModel element) async {
        if (threshold == dolboState.DANGER) {
          final warningTopic =
              TopicHandler().makeTopicStr(element.id!, dolboState.DANGER);
          await FirebaseMessaging.instance.subscribeToTopic(warningTopic);
          final dangerTopic =
              TopicHandler().makeTopicStr(element.id!, dolboState.OVERFLOW);
          await FirebaseMessaging.instance.subscribeToTopic(dangerTopic);
        } else {
          final warningTopic =
              TopicHandler().makeTopicStr(element.id!, dolboState.DANGER);
          await FirebaseMessaging.instance.unsubscribeFromTopic(warningTopic);
          final dangerTopic =
              TopicHandler().makeTopicStr(element.id!, dolboState.OVERFLOW);
          await FirebaseMessaging.instance.subscribeToTopic(dangerTopic);
        }
        final dangerTopic =
            TopicHandler().makeTopicStr(element.id!, dolboState.OVERFLOW);
        await FirebaseMessaging.instance.subscribeToTopic(dangerTopic);
      });
    }
    platformProvider.isAlarmAllowed = isAllowed == 'TRUE' ? true : false;
    platformProvider.alarmThreshold = threshold;
  }

  Future<void> _routeToHome() async {
    final platformProvider = Provider.of<Platform>(context, listen: false);
    await _encryptedStorageService.readData('last_seen').then((pageNum) {
      platformProvider.lastSeen = pageNum.isNotEmpty ? int.parse(pageNum) : 0;
      Future.delayed(const Duration(seconds: 1), () {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    HomeView(pageNum.isEmpty ? 0 : int.parse(pageNum))),
            (Route<dynamic> route) => false);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: Container(
            width: context.pWidth,
            height: context.pHeight,
            alignment: Alignment.center,
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text('돌보 알리미',
                      style: TextStyle(
                          color: Color.fromRGBO(5, 34, 92, 1),
                          fontSize: context.pHeight * 0.05,
                          fontWeight: FontWeight.bold)),
                  Padding(padding: EdgeInsets.all(context.pHeight * 0.005)),
                  Text('대전시 3대 하천',
                      style: TextStyle(
                          color: Color.fromRGBO(5, 34, 92, 1),
                          fontSize: context.pHeight * 0.03,
                          fontWeight: FontWeight.bold)),
                  Padding(padding: EdgeInsets.all(context.pHeight * 0.03)),
                  Image(
                      width: context.pHeight * 0.25,
                      height: context.pHeight * 0.25,
                      image: AssetImage('assets/images/splash_img.jpg')),
                  Padding(padding: EdgeInsets.all(context.pHeight * 0.05)),
                  Text('안전하고 살기 좋은 대전!\n맑고 아름다운 하천이 함께합니다.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Color.fromRGBO(5, 34, 92, 1),
                          fontSize: context.pHeight * 0.03,
                          fontWeight: FontWeight.bold)),
                  Padding(padding: EdgeInsets.all(context.pHeight * 0.02)),
                  _debugLevel < 5
                      ? Text('앱 초기화 중...($_debugLevel/4)')
                      : Text('앱 초기화 완료')
                ])));
  }
}
