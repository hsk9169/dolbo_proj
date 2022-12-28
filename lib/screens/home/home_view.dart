import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:modal_side_sheet/modal_side_sheet.dart';
import 'package:dolbo_app/sizes.dart';
import 'package:dolbo_app/routes.dart';
import 'package:dolbo_app/providers/platform_provider.dart';
import 'package:dolbo_app/models/dolbo_model.dart';
import 'package:dolbo_app/routes.dart';
import 'package:dolbo_app/const/dolbo_state.dart';
import 'package:dolbo_app/const/colors.dart';
import 'package:dolbo_app/services/encrypted_storage_service.dart';
import 'package:dolbo_app/services/real_api_service.dart';
import './dolbo_state.dart';
import './dolbo_chart.dart';
import './dolbo_metric.dart';
import 'package:dolbo_app/app.dart';

class HomeView extends StatefulWidget {
  final int? pageNum;

  const HomeView(this.pageNum);

  @override
  State<StatefulWidget> createState() => _HomeView();
}

class _HomeView extends State<HomeView> {
  List<DolboModel> _myDolboList = [];
  List<Widget> _pageList = [];

  late PageController _pageController;
  late int _pageNum;

  var scaffoldKey = GlobalKey<ScaffoldState>();

  late Future<List<DolboModel>> _future;
  final _encryptedStorageService = EncryptedStorageService();
  final _realApiService = RealApiService();

  late Timer _updateTimer;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _pageController =
        PageController(initialPage: widget.pageNum ?? 0, keepPage: true);
    _future = _initMyDolboList(widget.pageNum ?? 0);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _startTimer();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _updateTimer.cancel();
    super.dispose();
  }

  Future<List<DolboModel>> _initMyDolboList(int pageNum) async {
    await _encryptedStorageService.initStorage();
    final platformProvider = Provider.of<Platform>(context, listen: false);
    DolboModel tempDefaultDolbo;
    List<DolboModel> tempMyDolboList;
    if (_pageController.hasClients) {
      _pageController.jumpToPage(pageNum);
    }
    await _encryptedStorageService.saveData('last_seen', pageNum.toString());
    platformProvider.lastSeen = pageNum;
    tempDefaultDolbo = await _realApiService
        .getDolboData(platformProvider.defualtDolbo.id!)
        .then((res) {
      if (res is String) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('데이터 최신화 실패 : ${platformProvider.defualtDolbo.name}'),
            backgroundColor: Colors.black87.withOpacity(0.6),
            duration: const Duration(seconds: 2)));
      }
      return res is String ? platformProvider.defualtDolbo : res;
    });
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

    final tempWidgetList = List.generate(tempMyDolboList.length,
        (index) => DolboState(dolboData: tempMyDolboList[index]));
    setState(() {
      _myDolboList = [tempDefaultDolbo, ...tempMyDolboList];
      _pageNum = pageNum;
      _pageList = [DolboState(dolboData: tempDefaultDolbo), ...tempWidgetList];
      _isInitialized = true;
    });
    return _myDolboList;
  }

  void _startTimer() {
    _updateTimer = Timer.periodic(
        const Duration(minutes: 5), (Timer timer) => _refreshData());
  }

  void _refreshData() async {
    _updateTimer.cancel();
    await _initMyDolboList(_pageNum).whenComplete(() => _startTimer());
  }

  void _onPageChanged() async {
    final platformProvider = Provider.of<Platform>(context, listen: false);
    if (_myDolboList.isNotEmpty) {
      setState(() {
        _pageNum = _pageController.page!.round();
      });
      await _encryptedStorageService.saveData('last_seen', _pageNum.toString());
      platformProvider.lastSeen = _pageNum;
    }
  }

  void _refreshMyDolboList() async {
    setState(() => _isInitialized = false);
    final platformProvider = Provider.of<Platform>(context, listen: false);
    final pageNum = platformProvider.lastSeen;
    await _initMyDolboList(pageNum);
  }

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
        absorbing: !_isInitialized,
        child: Stack(children: [
          Scaffold(
              key: scaffoldKey,
              drawer: _sideDrawer(),
              appBar: PreferredSize(
                  preferredSize: Size(context.pWidth, context.pHeight * 0.06),
                  child: AppBar(
                    backgroundColor: Colors.white,
                    leading: IconButton(
                      icon: Icon(Icons.menu,
                          color: MyColors.fontColor,
                          size: context.pHeight * 0.035),
                      onPressed: () => scaffoldKey.currentState?.openDrawer(),
                    ),
                    title: _appBar(),
                    elevation: 0,
                  )),
              body: SingleChildScrollView(
                  child: FutureBuilder(
                      future: _future,
                      builder: (BuildContext context,
                          AsyncSnapshot<List<DolboModel>> snapshot) {
                        if (snapshot.data != null) {
                          return Column(
                            children: [
                              _sideSlidePages(),
                              _pageNumDots(),
                              _dolboMetrics(),
                              _dataCharts(),
                            ],
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            mainAxisSize: MainAxisSize.max,
                          );
                        } else {
                          return SizedBox();
                        }
                      }))),
          _isInitialized
              ? SizedBox()
              : Container(
                  width: context.pWidth,
                  height: context.pHeight,
                  color: Colors.grey.withOpacity(0.4),
                  child: CupertinoActivityIndicator(
                      radius: context.pHeight * 0.02))
        ]));
  }

  Widget _sideDrawer() {
    return Drawer(
      width: context.pWidth * 0.7,
      child: Column(
        children: [
          SizedBox(
            height: context.pHeight * 0.15,
            child: DrawerHeader(
                margin: const EdgeInsets.all(0),
                padding: EdgeInsets.only(
                    top: context.pHeight * 0.015,
                    left: context.pHeight * 0.015,
                    right: context.pHeight * 0.005),
                child: ListTile(
                  leading: Text('메뉴',
                      style: TextStyle(
                          fontSize: context.pHeight * 0.035,
                          fontWeight: FontWeight.bold)),
                  trailing: GestureDetector(
                      child: Icon(Icons.close,
                          color: MyColors.fontColor,
                          size: context.pHeight * 0.03),
                      onTap: () => Navigator.pop(context)),
                )),
          ),
          ListTile(
            leading: Icon(Icons.star_border,
                color: MyColors.fontColor, size: context.pHeight * 0.03),
            title: Text('관심 돌보',
                style: TextStyle(
                    fontSize: context.pHeight * 0.025,
                    fontWeight: FontWeight.bold,
                    color: MyColors.fontColor)),
            onTap: () {
              _updateTimer.cancel();
              Navigator.of(context).pushNamed(Routes.LIKE).then((_) {
                _startTimer();
                _refreshMyDolboList();
              });
            },
          ),
          ListTile(
            leading: Icon(Icons.notifications_none_outlined,
                color: MyColors.fontColor, size: context.pHeight * 0.03),
            title: Text('알림 설정',
                style: TextStyle(
                    fontSize: context.pHeight * 0.025,
                    fontWeight: FontWeight.bold,
                    color: MyColors.fontColor)),
            onTap: () {
              _updateTimer.cancel();
              Navigator.of(context).pushNamed(Routes.NOTIFY).then((_) {
                _startTimer();
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _appBar() {
    return Row(mainAxisAlignment: MainAxisAlignment.end, children: [
      __mapIcon(),
      __shareIcon(),
      __likeIcon(),
    ]);
  }

  Widget _sideSlidePages() {
    return SizedBox(
        height: context.pHeight * 0.6,
        child: PageView(
            controller: _pageController,
            children: _pageList,
            onPageChanged: (index) => _onPageChanged()));
  }

  Widget _pageNumDots() {
    return SizedBox(
        child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
                _pageList.length,
                (index) => Padding(
                    padding: EdgeInsets.only(
                        top: context.pHeight * 0.03,
                        left: context.pWidth * 0.005,
                        right: context.pWidth * 0.005),
                    child: Icon(
                        index == _pageNum
                            ? Icons.circle_rounded
                            : Icons.circle_outlined,
                        color: MyColors.fontColor,
                        size: context.pWidth * 0.03)))));
  }

  Widget _dolboMetrics() {
    return Padding(
        padding: EdgeInsets.only(
          left: context.pWidth * 0.02,
          right: context.pWidth * 0.02,
          top: context.pHeight * 0.12,
          bottom: context.pHeight * 0.02,
        ),
        child: _myDolboList.isNotEmpty
            ? DolboMetric(
                dolboData: _myDolboList.isNotEmpty
                    ? _myDolboList[_pageNum]
                    : DolboModel())
            : const SizedBox());
  }

  Widget _dataCharts() {
    return Padding(
        padding: EdgeInsets.only(
          left: context.pWidth * 0.02,
          right: context.pWidth * 0.02,
          top: context.pHeight * 0.02,
          bottom: context.pHeight * 0.02,
        ),
        child: _myDolboList.isNotEmpty
            ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('시간별 수위',
                    style: TextStyle(
                        color: MyColors.fontColor,
                        fontSize: context.pHeight * 0.036,
                        fontWeight: FontWeight.bold)),
                Padding(padding: EdgeInsets.all(context.pHeight * 0.005)),
                DolboChart(
                  chartData: _myDolboList[_pageNum].dailyWaterLevel!,
                  warningIndicator: _myDolboList[_pageNum].warningIndicator!,
                  dangerIndicator: _myDolboList[_pageNum].dangerIndicator!,
                ),
                Padding(padding: EdgeInsets.all(context.pHeight * 0.02)),
                Text('일별 수위',
                    style: TextStyle(
                        color: MyColors.fontColor,
                        fontSize: context.pHeight * 0.036,
                        fontWeight: FontWeight.bold)),
                Padding(padding: EdgeInsets.all(context.pHeight * 0.005)),
                DolboChart(
                  chartData: _myDolboList[_pageNum].weeklyWaterLevel!,
                  warningIndicator: _myDolboList[_pageNum].warningIndicator!,
                  dangerIndicator: _myDolboList[_pageNum].dangerIndicator!,
                ),
              ])
            : const SizedBox());
  }

  Widget __mapIcon() {
    return GestureDetector(
        onTap: () {
          _updateTimer.cancel();
          Navigator.of(context).pushNamed(Routes.MAP).then((_) {
            _startTimer();
            _refreshMyDolboList();
          });
        },
        child: Padding(
            padding: EdgeInsets.only(right: context.pWidth * 0.02),
            child: Icon(Icons.location_on,
                color: MyColors.fontColor, size: context.pHeight * 0.035)));
  }

  Widget __shareIcon() {
    String text = '';
    String url = Theme.of(context).platform == TargetPlatform.iOS
        ? 'https://apps.apple.com/kr/app/%EB%8F%8C%EB%B3%B4-%EC%95%8C%EB%A6%AC%EB%AF%B8/id1658985064'
        : Theme.of(context).platform == TargetPlatform.android
            ? 'https://play.google.com/store/apps/details?id=com.acts1soft.dolbo_app'
            : '';
    if (_myDolboList.isNotEmpty) {
      final dolbo = _myDolboList[_pageNum];
      String state = dolbo.safety == dolboState.SAFE
          ? '안전'
          : dolbo.safety == dolboState.DANGER
              ? '위험'
              : dolbo.safety == dolboState.OVERFLOW
                  ? '범람'
                  : 'UNKNOWN';
      text = '''** 현재 ${dolbo.address} ${dolbo.name} 수위 상태 : $state **\n
돌보 알리미는 대전시 3대 하천의 돌보에 대한 수위 상태를 알려주는 서비스입니다.\n
건강도시 대전, 3대하천 돌보 알리미 어플 다운 받기: [$url]''';
    }

    return GestureDetector(
        onTap: () {
          if (text.isNotEmpty) {
            Share.share(text);
          }
        },
        child: Padding(
            padding: EdgeInsets.only(
                right: context.pWidth * 0.02, left: context.pWidth * 0.02),
            child: Icon(Icons.share,
                color: MyColors.fontColor, size: context.pHeight * 0.035)));
  }

  Widget __likeIcon() {
    return GestureDetector(
        onTap: () {
          _updateTimer.cancel();
          Navigator.of(context).pushNamed(Routes.LIKE).then((_) {
            _startTimer();
            _refreshMyDolboList();
          });
        },
        child: Padding(
            padding: EdgeInsets.only(left: context.pWidth * 0.02),
            child: Icon(Icons.star,
                color: MyColors.fontColor, size: context.pHeight * 0.035)));
  }
}
