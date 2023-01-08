import 'dart:async';
import 'package:dolbo_app/services/real_api_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:naver_map_plugin/naver_map_plugin.dart';
import 'package:dolbo_app/sizes.dart';
import 'package:dolbo_app/models/dolbo_model.dart';
import 'package:dolbo_app/const/dolbo_state.dart';
import 'package:dolbo_app/utils/number_handler.dart';
import 'package:dolbo_app/providers/platform_provider.dart';
import 'package:dolbo_app/const/colors.dart';
import 'package:dolbo_app/const/dolbo_state.dart';
import 'package:dolbo_app/services/encrypted_storage_service.dart';
import 'package:dolbo_app/utils/topic_handler.dart';
import './map_marker.dart';

class MapView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _MapView();
}

class _MapView extends State<MapView> {
  late NaverMapController _mapController;
  final MapType _mapType = MapType.Basic;

  final TextEditingController _textController = TextEditingController();
  List<String> _addressList = [];
  List<String> _nameList = [];
  final ValueNotifier<bool> _isSearchLoading = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _isAddressSelected = ValueNotifier<bool>(false);
  final ValueNotifier<List<DolboModel>> _myDolboList =
      ValueNotifier<List<DolboModel>>([]);
  final ValueNotifier<List<MapMarker>> _markerList =
      ValueNotifier<List<MapMarker>>([]);
  List<DolboModel> _searchDolboList = [];
  CameraPosition _cameraPosition = CameraPosition(
      target: LatLng(36.35052084022028, 127.38484589824647), zoom: 11.5);

  int _selected = -1;
  bool _isCameraChangedByGesture = false;

  final _realApiService = RealApiService();
  final _encryptedStorageService = EncryptedStorageService();

  List<DolboModel> _searchResultList = [];

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _textController.addListener(_onTextChanged);
    _initStorage();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      await _initData();
      _onCameraChange();
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _initStorage() async {
    await _encryptedStorageService.initStorage();
  }

  Future<void> _initData() async {
    final platformProvider = Provider.of<Platform>(context, listen: false);
    setState(() {
      _myDolboList.value = platformProvider.myDolboList;
    });
  }

  bool _checkContained(String id) {
    bool isContained = false;
    _myDolboList.value.asMap().forEach((index, element) {
      if (element.id == id) {
        isContained = true;
      }
    });
    return isContained;
  }

  void _onCameraChange() async {
    if (!_isCameraChangedByGesture) {
      _resetTempData();
      Future.delayed(const Duration(milliseconds: 200), () {
        _mapController.getVisibleRegion().then((bounds) async {
          await _setMarker(bounds, 'null');
        });
      });
    }
  }

  Future<void> _removeDolbo(DolboModel target) async {
    final platformProvider = Provider.of<Platform>(context, listen: false);
    int? idx;
    if (platformProvider.isAlarmAllowed) {
      final warningTopic =
          TopicHandler().makeTopicStr(target.id!, dolboState.DANGER);
      await FirebaseMessaging.instance.unsubscribeFromTopic(warningTopic);
      final dangerTopic =
          TopicHandler().makeTopicStr(target.id!, dolboState.OVERFLOW);
      await FirebaseMessaging.instance.unsubscribeFromTopic(dangerTopic);
    }
    final temp = [];
    _myDolboList.value.forEach((dynamic element) => temp.add(element));
    temp.asMap().forEach((index, element) {
      if (element.id == target.id) {
        idx = index;
        setState(() => _myDolboList.value.remove(element));
      }
    });
    platformProvider.myDolboListNum = _myDolboList.value.length;
    platformProvider.myDolboList = _myDolboList.value;
  }

  Future<void> _addDolbo(DolboModel target) async {
    final platformProvider = Provider.of<Platform>(context, listen: false);
    final dolboDetails = await _realApiService.getDolboData(target.id!);
    if (platformProvider.isAlarmAllowed) {
      if (platformProvider.alarmThreshold == dolboState.DANGER) {
        final warningTopic =
            TopicHandler().makeTopicStr(target.id!, dolboState.DANGER);
        await FirebaseMessaging.instance.subscribeToTopic(warningTopic);
      }
      final dangerTopic =
          TopicHandler().makeTopicStr(target.id!, dolboState.OVERFLOW);
      await FirebaseMessaging.instance.subscribeToTopic(dangerTopic);
    }
    setState(() => _myDolboList.value.add(dolboDetails));
    platformProvider.myDolboListNum = _myDolboList.value.length;
    platformProvider.myDolboList = _myDolboList.value;
  }

  Future<void> _saveToStorage() async {
    final platformProvider = Provider.of<Platform>(context, listen: false);
    await _encryptedStorageService.saveData(
        'list_num', (_myDolboList.value.length).toString());
    for (int i = 0; i < _myDolboList.value.length; i++) {
      await _encryptedStorageService.saveData(
          'element_$i', _myDolboList.value[i].id!);
    }
    if (platformProvider.lastSeen > _myDolboList.value.length) {
      final maxPageNum = _myDolboList.value.length;
      platformProvider.lastSeen = maxPageNum;
      await _encryptedStorageService.saveData(
          'last_seen', maxPageNum.toString());
    }
  }

  void _resetTempData() {
    setState(() {
      _selected = -1;
      _searchDolboList = [];
      _addressList = [];
      _nameList = [];
      _markerList.value = [];
    });
  }

  void _setMarkerOnMap(int index, DolboModel dolboData) async {
    _markerList.value[index].setOnMarkerTab((marker, iconSize) {
      _onTapMarker(index);
    });
  }

  void _onTapMarker(int index) async {
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => _isCameraChangedByGesture = true);
    await _mapController.moveCamera(CameraUpdate.scrollTo(LatLng(
        _searchDolboList[index].latitude, _searchDolboList[index].longitude)));
    Future.delayed(const Duration(milliseconds: 400), () {
      setState(() {
        _isCameraChangedByGesture = false;
        if (_selected >= 0) {
          _markerList.value[_selected].setMarkerSmall(context);
        }
        _selected = index;
        _markerList.value[index].setMarkerBig(context);
      });
    });
  }

  void _onTextChanged() {}

  void _onSearchAddress(String address) async {
    if (address.isNotEmpty) {
      setState(() => _isSearchLoading.value = true);
      final res = await _realApiService.getDolboListByKeyword(address);
      _resetTempData();
      setState(() {
        _searchResultList = res;
        res.forEach((DolboModel element) {
          _nameList.add(element.name!);
          _addressList.add(element.address!);
        });
        _isAddressSelected.value = true;
        _isSearchLoading.value = false;
      });
    }
  }

  void _onTapAddressFromList(int index) async {
    setState(() => _isCameraChangedByGesture = true);
    await _mapController.moveCamera(CameraUpdate.toCameraPosition(
        CameraPosition(
            target: LatLng(_searchResultList[index].latitude!,
                _searchResultList[index].longitude!),
            zoom: 14.0)));
    Future.delayed(const Duration(milliseconds: 400), () {
      setState(() => _isCameraChangedByGesture = false);
      _mapController.getVisibleRegion().then((bounds) async {
        await _setMarker(bounds, _searchResultList[index].id!);
      });
    });
  }

  void _onDeleteText() {
    _textController.text = '';
    setState(() {
      _isAddressSelected.value = false;
      _addressList = [];
      _nameList = [];
    });
    _onCameraChange();
  }

  Future<void> _setMarker(LatLngBounds bounds, String? selectedId) async {
    final list = await _realApiService.getDolboListByLatLng(
        bounds.southwest.latitude,
        bounds.southwest.longitude,
        bounds.northeast.latitude,
        bounds.northeast.longitude);

    list.asMap().forEach((index, element) async {
      await OverlayImage.fromAssetImage(
              assetName: element.safety == dolboState.SAFE
                  ? "assets/images/normal_marker.png"
                  : element.safety == dolboState.DANGER
                      ? "assets/images/warning_marker.png"
                      : element.safety == dolboState.OVERFLOW
                          ? "assets/images/danger_marker.png"
                          : '',
              context: context)
          .then((icon) {
        setState(() {
          _markerList.value.add(MapMarker.fromData(element, icon));
          _setMarkerOnMap(index, element);
          if (selectedId == element.id) {
            _selected = index;
            _markerList.value[index].setMarkerBig(context);
          }
        });
      });
    });

    setState(() {
      _searchDolboList = list;
      _isAddressSelected.value = false;
    });
  }

  void _onPressGoBack() async {
    await _saveToStorage().whenComplete(() => Navigator.pop(context));
  }

  void _onTapLike(DolboModel dolboData) {
    bool isContained = _checkContained(dolboData.id!);
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('관심 돌보 설정'),
          content: SingleChildScrollView(
            child: isContained
                ? const Text('해당 돌보를 관심 돌보에서 삭제하시겠습니까?')
                : const Text('해당 돌보를 관심 돌보에 추가하시겠습니까?'),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('확인'),
              onPressed: () async {
                Navigator.of(context).pop();
                setState(() => _isLoading = true);
                if (isContained) {
                  await _removeDolbo(dolboData);
                } else {
                  await _addDolbo(dolboData);
                }
                setState(() => _isLoading = false);
              },
            ),
            TextButton(
              child: const Text('취소'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
        absorbing: _isLoading,
        child: Stack(children: [
          GestureDetector(
              onTapDown: (_) => FocusManager.instance.primaryFocus?.unfocus(),
              child: Scaffold(
                resizeToAvoidBottomInset: false,
                body: SafeArea(
                    top: true,
                    bottom: false,
                    child: ValueListenableBuilder(
                        valueListenable: _markerList,
                        builder: (BuildContext context, List<MapMarker> value,
                            Widget? child) {
                          return Stack(children: [
                            Column(children: [
                              Container(
                                  padding: EdgeInsets.only(
                                    left: context.pWidth * 0.02,
                                    right: context.pWidth * 0.02,
                                  ),
                                  alignment: Alignment.center,
                                  width: context.pWidth,
                                  height: context.pHeight * 0.06,
                                  child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        _goBackIcon(),
                                        SizedBox(
                                            width: context.pWidth * 0.7,
                                            height: context.pHeight * 0.06,
                                            child: TextField(
                                                onSubmitted: (value) {
                                                  _onSearchAddress(value);
                                                },
                                                textAlignVertical:
                                                    TextAlignVertical.center,
                                                style: TextStyle(
                                                    fontSize: context.pHeight *
                                                        0.025),
                                                autofocus: false,
                                                decoration: InputDecoration(
                                                    border: InputBorder.none,
                                                    hintText: '장소 검색'),
                                                controller: _textController,
                                                keyboardType:
                                                    TextInputType.text)),
                                        ValueListenableBuilder(
                                            builder: (BuildContext context,
                                                bool value, Widget? child) {
                                              return value
                                                  ? CupertinoActivityIndicator()
                                                  : _searchIcon();
                                            },
                                            valueListenable: _isSearchLoading),
                                        _deleteIcon(),
                                      ])),
                              Expanded(
                                  child: Stack(children: [
                                _renderNaverMap(value),
                                ValueListenableBuilder(
                                    valueListenable: _isAddressSelected,
                                    builder: (BuildContext context, bool value,
                                        Widget? child) {
                                      return value
                                          ? Container(
                                              width: context.pWidth,
                                              height: context.pHeight,
                                              decoration: BoxDecoration(
                                                  color: Colors.black
                                                      .withOpacity(0.5)),
                                              child: SingleChildScrollView(
                                                  child: Column(
                                                      children:
                                                          _renderAddressList())))
                                          : SizedBox();
                                    })
                              ]))
                            ]),
                            value.isNotEmpty
                                ? Align(
                                    alignment: Alignment.bottomCenter,
                                    child: _selected < 0
                                        ? null
                                        : _dolboPopup(
                                            _searchDolboList[_selected]))
                                : SizedBox(),
                          ]);
                        })),
              )),
          _isLoading
              ? Container(
                  width: context.pWidth,
                  height: context.pHeight,
                  color: Colors.grey.withOpacity(0.4),
                  child: CupertinoActivityIndicator(
                      radius: context.pHeight * 0.02))
              : SizedBox()
        ]));
  }

  Widget _renderNaverMap(List<MapMarker> markerList) {
    return SizedBox(
        child: NaverMap(
      zoomGestureEnable: true,
      onMapCreated: (NaverMapController ct) {
        _mapController = ct;
      },
      mapType: _mapType,
      markers: markerList,
      locationButtonEnable: true,
      initialCameraPosition: _cameraPosition,
      onCameraIdle: () => _onCameraChange(),
      onMapTap: (_) => FocusManager.instance.primaryFocus?.unfocus(),
    ));
  }

  List<Widget> _renderAddressList() {
    return List.generate(_addressList.length, (idx) => _addressListItem(idx));
  }

  Widget _addressListItem(int index) {
    return GestureDetector(
        child: Container(
            padding: EdgeInsets.only(
              top: context.pHeight * 0.01,
              bottom: context.pHeight * 0.01,
              left: context.pWidth * 0.04,
              right: context.pWidth * 0.04,
            ),
            child: Text('${_nameList[index]}(${_addressList[index]})',
                style: TextStyle(
                    color: MyColors.fontColor,
                    fontSize: context.pHeight * 0.018),
                overflow: TextOverflow.fade,
                maxLines: 1,
                softWrap: false),
            width: context.pWidth,
            color: Colors.white),
        onTap: () => _onTapAddressFromList(index));
  }

  Widget _searchIcon() {
    return GestureDetector(
        onTap: () => _onSearchAddress(_textController.text),
        child: Icon(Icons.search,
            color: MyColors.fontColor, size: context.pHeight * 0.035));
  }

  Widget _deleteIcon() {
    return GestureDetector(
        onTap: () => _onDeleteText(),
        child: Icon(Icons.close,
            color: MyColors.fontColor, size: context.pHeight * 0.035));
  }

  Widget _goBackIcon() {
    return GestureDetector(
        onTap: () => _onPressGoBack(),
        child: Icon(Icons.arrow_back_ios,
            color: MyColors.fontColor, size: context.pHeight * 0.035));
  }

  Widget _dolboPopup(DolboModel dolboData) {
    final fontSizeBig = context.pHeight * 0.026;
    final fontSizeSmall = context.pHeight * 0.02;
    final vPadding = context.pHeight * 0.005;
    bool isContained = _checkContained(dolboData.id!);
    return Container(
        padding: EdgeInsets.all(context.pWidth * 0.02),
        margin: EdgeInsets.only(
            bottom: context.pHeight * 0.05,
            left: context.pWidth * 0.02,
            right: context.pWidth * 0.02),
        width: context.pWidth,
        height: context.pHeight * 0.2,
        decoration: BoxDecoration(
            color: dolboData.safety == dolboState.SAFE
                ? MyColors.normalColor
                : dolboData.safety == dolboState.DANGER
                    ? MyColors.warningColor
                    : dolboData.safety == dolboState.OVERFLOW
                        ? MyColors.dangerColor
                        : Colors.grey,
            border: Border.all(
                color: MyColors.fontColor, width: context.pWidth * 0.0001)),
        child: Column(children: [
          Expanded(
              child: Row(children: [
            dolboData.safety == dolboState.UNKNOWN
                ? Icon(Icons.question_mark,
                    size: context.pWidth * 0.2, color: MyColors.fontColor)
                : Image(
                    width: context.pWidth * 0.2,
                    image: AssetImage(dolboData.safety == dolboState.SAFE
                        ? 'assets/images/normal_img.png'
                        : dolboData.safety == dolboState.DANGER
                            ? 'assets/images/warning_img.png'
                            : dolboData.safety == dolboState.OVERFLOW
                                ? 'assets/images/danger_img.png'
                                : '')),
            SizedBox(
                width: context.pWidth * 0.4,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                          child: Text(dolboData.name ?? '----',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: fontSizeBig,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.fade,
                              maxLines: 1,
                              softWrap: false)),
                      Padding(padding: EdgeInsets.all(context.pHeight * 0.001)),
                      SizedBox(
                          child: Text(dolboData.address ?? '----',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: fontSizeSmall,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.fade,
                              maxLines: 1,
                              softWrap: false))
                    ])),
            Padding(padding: EdgeInsets.all(context.pWidth * 0.015)),
            SizedBox(
                width: context.pWidth * 0.28,
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                          dolboData.safety == dolboState.SAFE
                              ? '안전'
                              : dolboData.safety == dolboState.DANGER
                                  ? '위험'
                                  : dolboData.safety == dolboState.OVERFLOW
                                      ? '범람'
                                      : '----',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: context.pHeight * 0.04,
                            fontWeight: FontWeight.bold,
                          )),
                      Padding(padding: EdgeInsets.all(context.pWidth * 0.005)),
                      GestureDetector(
                          onTap: () => _onTapLike(dolboData),
                          child: Icon(
                              isContained
                                  ? Icons.star_outlined
                                  : Icons.star_border,
                              color: Colors.white,
                              size: context.pHeight * 0.04))
                    ]))
          ])),
          Padding(padding: EdgeInsets.all(context.pHeight * 0.002)),
          Divider(
            thickness: context.pWidth * 0.001,
            color: Colors.white,
          ),
          Padding(padding: EdgeInsets.all(context.pHeight * 0.002)),
          Expanded(
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                Column(children: [
                  Text('수위',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: fontSizeBig,
                          fontWeight: FontWeight.bold)),
                  Padding(padding: EdgeInsets.all(vPadding)),
                  Text(
                      dolboData.waterLevel == 0
                          ? '-'
                          : '${dolboData.waterLevel! / 10}cm',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: fontSizeSmall,
                          fontWeight: FontWeight.normal)),
                ]),
                Column(children: [
                  Text('온도',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: fontSizeBig,
                          fontWeight: FontWeight.bold)),
                  Padding(padding: EdgeInsets.all(vPadding)),
                  Text(
                      dolboData.temperature == 0
                          ? '-'
                          : '${dolboData.temperature}\u2103',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: fontSizeSmall,
                          fontWeight: FontWeight.normal)),
                ]),
                Column(children: [
                  Text('습도',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: fontSizeBig,
                          fontWeight: FontWeight.bold)),
                  Padding(padding: EdgeInsets.all(vPadding)),
                  Text(dolboData.humidity == 0 ? '-' : '${dolboData.humidity}%',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: fontSizeSmall,
                          fontWeight: FontWeight.normal)),
                ]),
                Column(children: [
                  Text('통행량',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: fontSizeBig,
                          fontWeight: FontWeight.bold)),
                  Padding(padding: EdgeInsets.all(vPadding)),
                  Text(
                      dolboData.traffic == 0
                          ? '-'
                          : '${NumberHandler().addComma(dolboData.traffic.toString())}명',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: fontSizeSmall,
                          fontWeight: FontWeight.normal)),
                ]),
              ]))
        ]));
  }
}
