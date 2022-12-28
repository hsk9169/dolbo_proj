import 'dart:async';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_shake_animated/flutter_shake_animated.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:dolbo_app/models/models.dart';
import 'package:dolbo_app/sizes.dart';
import 'package:dolbo_app/routes.dart';
import 'package:dolbo_app/providers/platform_provider.dart';
import 'package:dolbo_app/const/colors.dart';
import 'package:dolbo_app/services/encrypted_storage_service.dart';
import 'package:dolbo_app/utils/topic_handler.dart';
import 'package:dolbo_app/const/dolbo_state.dart';
import 'package:dolbo_app/services/real_api_service.dart';
import './like_element.dart';

class LikeView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _LikeView();
}

class _LikeView extends State<LikeView> {
  DolboModel _defaultDolboData = DolboModel();
  List<DolboModel> _myDolboList = [];
  bool _isEditting = false;
  late Future<List<DolboModel>> _future;
  final _encryptedStorageService = EncryptedStorageService();
  final _realApiService = RealApiService();

  late Timer _updateTimer;

  @override
  void initState() {
    super.initState();
    _initStorage();
    _future = _fetchMyDolboList();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _startTimer();
    });
  }

  @override
  void dispose() {
    _updateTimer.cancel();
    super.dispose();
  }

  void _initStorage() async {
    await _encryptedStorageService.initStorage();
  }

  Future<List<DolboModel>> _fetchMyDolboList() async {
    final platformProvider = Provider.of<Platform>(context, listen: false);
    setState(() {
      _defaultDolboData = platformProvider.defualtDolbo;
      _myDolboList = platformProvider.myDolboList;
    });
    return _myDolboList;
  }

  Future<void> _initMyDolboList() async {
    final platformProvider = Provider.of<Platform>(context, listen: false);
    DolboModel tempDefaultDolbo;
    List<DolboModel> tempMyDolboList;

    tempDefaultDolbo =
        await _realApiService.getDolboData(platformProvider.defualtDolbo.id!);
    Iterable<Future<DolboModel>> mappedList =
        platformProvider.myDolboList.map((DolboModel element) async {
      return await _realApiService.getDolboData(element.id!).then((res) {
        if (res is String) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('데이터 최신화 실패 : ${element.name}'),
              backgroundColor: Colors.black87.withOpacity(0.6),
              duration: const Duration(seconds: 2)));
        }
        return res is String ? element : res;
      });
    });
    tempMyDolboList = await Future.wait(mappedList);
    setState(() {
      _defaultDolboData = tempDefaultDolbo;
      _myDolboList = tempMyDolboList;
    });
  }

  void _startTimer() {
    _updateTimer = Timer.periodic(
        const Duration(minutes: 5), (Timer timer) => _refreshData());
  }

  void _refreshData() async {
    _updateTimer.cancel();
    await _initMyDolboList().whenComplete(() => _startTimer());
  }

  void _onDeleteItem(int index) async {
    final platformProvider = Provider.of<Platform>(context, listen: false);
    if (platformProvider.isAlarmAllowed) {
      final warningTopic = TopicHandler()
          .makeTopicStr(_myDolboList[index].id!, dolboState.DANGER);
      await FirebaseMessaging.instance.unsubscribeFromTopic(warningTopic);
      final dangerTopic = TopicHandler()
          .makeTopicStr(_myDolboList[index].id!, dolboState.OVERFLOW);
      await FirebaseMessaging.instance.unsubscribeFromTopic(dangerTopic);
    }
    setState(() => _myDolboList.removeAt(index));
    platformProvider.myDolboList = _myDolboList;
    platformProvider.myDolboListNum = _myDolboList.length;
    await _encryptedStorageService.saveData(
        'list_num', (_myDolboList.length).toString());
    await _encryptedStorageService.removeData('element_$index');
    if (platformProvider.lastSeen > _myDolboList.length) {
      final maxPageNum = _myDolboList.length;
      platformProvider.lastSeen = maxPageNum;
      await _encryptedStorageService.saveData(
          'last_seen', maxPageNum.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: const Color.fromRGBO(239, 239, 239, 1),
        appBar: PreferredSize(
            preferredSize: Size(context.pWidth, context.pHeight * 0.06),
            child: AppBar(
                backgroundColor: Colors.white,
                leading: IconButton(
                    icon: Icon(Icons.arrow_back_ios,
                        color: MyColors.fontColor,
                        size: context.pHeight * 0.035),
                    onPressed: () {
                      _updateTimer.cancel();
                      Navigator.pop(context);
                    }),
                title: _appBar(),
                elevation: 0)),
        body: FutureBuilder(
            future: _future,
            builder: (BuildContext context,
                AsyncSnapshot<List<DolboModel>> snapshot) {
              if (snapshot.data != null) {
                return Column(children: [
                  Padding(padding: EdgeInsets.all(context.pHeight * 0.01)),
                  _defaultDolbo(),
                  _likeList(),
                  _moveToMapButton(),
                ]);
              } else {
                return SizedBox();
              }
            }));
  }

  Widget _appBar() {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      const SizedBox(),
      Text('관심 돌보',
          style: TextStyle(
              color: MyColors.fontColor,
              fontSize: context.pHeight * 0.03,
              fontWeight: FontWeight.bold)),
      GestureDetector(
          onTap: () {
            if (_isEditting) {
              _startTimer();
            } else {
              _updateTimer.cancel();
            }
            setState(() => _isEditting = !_isEditting);
          },
          child: Text(_isEditting ? '완료' : '편집',
              style: TextStyle(
                  color: MyColors.fontColor,
                  fontSize: context.pHeight * 0.027)))
    ]);
  }

  Widget _defaultDolbo() {
    return GestureDetector(
        onTap: () {
          if (!_isEditting) {
            _updateTimer.cancel();
            Navigator.of(context).pushNamed(Routes.HOME, arguments: 0);
          }
        },
        child: LikeElement(
            dolboData: _defaultDolboData, isEditting: false, onDelete: null));
  }

  Widget _likeList() {
    return SizedBox(
        height: context.pHeight * 0.54,
        width: context.pWidth,
        child: ReorderableListView(
            shrinkWrap: true,
            scrollController: null,
            buildDefaultDragHandles: _isEditting,
            children: List.generate(
                _myDolboList.length,
                (index) => _isEditting
                    ? ShakeWidget(
                        key: Key('$index'),
                        shakeConstant: ShakeLittleConstant2(),
                        autoPlay: true,
                        duration: const Duration(milliseconds: 2500),
                        child: LikeElement(
                          dolboData: _myDolboList[index],
                          isEditting: _isEditting,
                          onDelete: () => _onDeleteItem(index),
                        ))
                    : GestureDetector(
                        key: Key('$index'),
                        onTap: () {
                          _updateTimer.cancel();
                          Navigator.of(context)
                              .pushNamed(Routes.HOME, arguments: index + 1);
                        },
                        child: LikeElement(
                          dolboData: _myDolboList[index],
                          isEditting: _isEditting,
                          onDelete: () => _onDeleteItem(index),
                        ))),
            onReorder: (int oldIndex, int newIndex) async {
              setState(() {
                if (oldIndex < newIndex) {
                  newIndex -= 1;
                }
                final DolboModel item = _myDolboList.removeAt(oldIndex);
                _myDolboList.insert(newIndex, item);
              });
              _reorderStorage();
            }));
  }

  void _reorderStorage() async {
    final platformProvider = Provider.of<Platform>(context, listen: false);
    platformProvider.myDolboListNum = _myDolboList.length;
    _myDolboList.asMap().forEach((index, element) async {
      await _encryptedStorageService.saveData(
          'element_$index', element.id.toString());
    });
  }

  Widget _moveToMapButton() {
    return Padding(
        padding: EdgeInsets.only(
          top: context.pHeight * 0.05,
          bottom: context.pHeight * 0.05,
          left: context.pWidth * 0.03,
          right: context.pWidth * 0.03,
        ),
        child: GestureDetector(
            onTap: () {
              _isEditting
                  ? null
                  : Navigator.of(context).pushNamed(Routes.MAP).then((_) {
                      _fetchMyDolboList();
                    });
            },
            child: Container(
                height: context.pHeight * 0.07,
                padding: EdgeInsets.all(context.pHeight * 0.01),
                decoration: BoxDecoration(
                    color: _isEditting ? Colors.grey : const Color(0xFF1F4C9A),
                    borderRadius: BorderRadius.circular(context.pWidth * 0.02)),
                alignment: Alignment.center,
                child: Text('관심 돌보 추가하기',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: context.pWidth * 0.05,
                    )))));
  }
}
