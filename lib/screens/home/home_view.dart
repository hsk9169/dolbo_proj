import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:share/share.dart';
import 'package:modal_side_sheet/modal_side_sheet.dart';
import 'package:dolbo_app/sizes.dart';
import 'package:dolbo_app/routes.dart';
import 'package:dolbo_app/providers/platform_provider.dart';
import 'package:dolbo_app/models/dolbo_model.dart';
import 'package:dolbo_app/routes.dart';
import 'package:dolbo_app/const/dolbo_state.dart';
import 'package:dolbo_app/const/colors.dart';
import 'package:dolbo_app/services/encrypted_storage_service.dart';
import 'package:dolbo_app/utils/number_handler.dart';

import './dolbo_state.dart';
import './dolbo_chart.dart';
import './dolbo_metric.dart';

class HomeView extends StatefulWidget {
  final int? arg;

  const HomeView(this.arg);

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

  @override
  void initState() {
    super.initState();
    _pageController =
        PageController(initialPage: widget.arg ?? 0, keepPage: true);
    _encryptedStorageService.initStorage();
    _future = _fetchMyDolboList(widget.arg ?? 0);
    _pageNum = widget.arg!;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {});
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<List<DolboModel>> _fetchMyDolboList(int pageNum) async {
    final platformProvider = Provider.of<Platform>(context, listen: false);
    final tempWidgetList = List.generate(platformProvider.myDolboList.length,
        (index) => DolboState(dolboData: platformProvider.myDolboList[index]));
    if (_pageController.hasClients) {
      _pageController.jumpToPage(pageNum);
    }
    setState(() {
      _myDolboList = [
        platformProvider.defualtDolbo,
        ...platformProvider.myDolboList
      ];
      _pageNum = pageNum;
      _pageList = [
        DolboState(dolboData: platformProvider.defualtDolbo),
        ...tempWidgetList
      ];
    });
    return _myDolboList;
  }

  void _onPageChanged() async {
    if (_myDolboList.isNotEmpty) {
      setState(() {
        _pageNum = _pageController.page!.round();
      });
      await _encryptedStorageService.saveData('last_seen', _pageNum.toString());
    }
  }

  void _refreshMyDolboList() async {
    final platformProvider = Provider.of<Platform>(context, listen: false);
    final myDolboList = platformProvider.myDolboList;
    int pageNum = 0;
    if (myDolboList.isNotEmpty) {
      pageNum = _pageController.page!.toInt() > myDolboList.length
          ? myDolboList.length
          : _pageController.page!.toInt();
    }
    await _fetchMyDolboList(pageNum);
    await _encryptedStorageService.saveData('last_seen', pageNum.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: scaffoldKey,
        drawer: _sideDrawer(),
        appBar: PreferredSize(
            preferredSize: Size(context.pWidth, context.pHeight * 0.06),
            child: AppBar(
              backgroundColor: Colors.white,
              leading: IconButton(
                icon: Icon(Icons.menu,
                    color: MyColors.fontColor, size: context.pHeight * 0.035),
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
                })));
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
              Navigator.of(context).pushNamed(Routes.LIKE).then((_) {
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
              Navigator.of(context).pushNamed(Routes.NOTIFY);
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
        onTap: () => Navigator.of(context)
            .pushNamed(Routes.MAP)
            .then((_) => _refreshMyDolboList()),
        child: Padding(
            padding: EdgeInsets.only(right: context.pWidth * 0.02),
            child: Icon(Icons.location_on,
                color: MyColors.fontColor, size: context.pHeight * 0.035)));
  }

  Widget __shareIcon() {
    String text = '';
    String url = Theme.of(context).platform == TargetPlatform.iOS
        ? 'https://apps.apple.com/us/app/kakaotalk/id362057947'
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
        onTap: () => Navigator.of(context)
            .pushNamed(Routes.LIKE)
            .then((_) => _refreshMyDolboList()),
        child: Padding(
            padding: EdgeInsets.only(left: context.pWidth * 0.02),
            child: Icon(Icons.star,
                color: MyColors.fontColor, size: context.pHeight * 0.035)));
  }
}
