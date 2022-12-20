import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:dolbo_app/models/models.dart';
import 'package:dolbo_app/sizes.dart';
import 'package:dolbo_app/routes.dart';
import 'package:dolbo_app/providers/platform_provider.dart';
import 'package:dolbo_app/const/colors.dart';
import './notify_time.dart';

List<String> min = [
  '00',
  '10',
  '20',
  '30',
  '40',
  '50',
];

List<int> hour = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12];

enum StateChar { warning, danger }

class NotifyView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _NotifyView();
}

class _NotifyView extends State<NotifyView> {
  late bool _isAllowed;
  late bool _isTimeSet;
  bool _isDropdownTapped = false;
  StateChar? _state = StateChar.warning;
  String _startTime = '오전 09:00';
  String _endTime = '오후 07:00';

  @override
  void initState() {
    super.initState();
    _fetchNotificationInfo();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {});
  }

  void _fetchNotificationInfo() async {
    final platformProvider = Provider.of<Platform>(context, listen: false);
    _isAllowed = false;
    _isTimeSet = false;
  }

  void _onTapTime(String type) {
    print(type);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color.fromRGBO(239, 239, 239, 1),
        appBar: PreferredSize(
            preferredSize: Size(context.pWidth, context.pHeight * 0.06),
            child: AppBar(
                backgroundColor: Colors.white,
                leading: IconButton(
                    icon: Icon(Icons.arrow_back_ios,
                        color: MyColors.fontColor,
                        size: context.pHeight * 0.035),
                    onPressed: () => Navigator.pop(context)),
                title: _appBar(),
                centerTitle: true,
                elevation: 0)),
        body: Padding(
            padding: EdgeInsets.all(context.pWidth * 0.05),
            child: Column(children: [
              _toggleNotification(),
              _notificationCondition(),
              _notificationTime(),
            ])));
  }

  Widget _appBar() {
    return Text('알림 설정',
        style: TextStyle(
            color: MyColors.fontColor,
            fontSize: context.pHeight * 0.03,
            fontWeight: FontWeight.bold));
  }

  Widget _toggleNotification() {
    return SizedBox(
        width: context.pWidth,
        child: Column(children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('알림 끄기/켜기',
                style: TextStyle(
                  color: MyColors.fontColor,
                  fontSize: context.pHeight * 0.035,
                  fontWeight: FontWeight.bold,
                )),
            Transform.scale(
                scale: 1,
                child: CupertinoSwitch(
                  value: _isAllowed,
                  thumbColor: Colors.white,
                  trackColor: Colors.grey[400],
                  activeColor: Colors.blue[400],
                  onChanged: (bool? value) {
                    setState(() {
                      _isAllowed = value!;
                    });
                  },
                ))
          ]),
          _isAllowed
              ? Padding(
                  padding: EdgeInsets.only(top: context.pHeight * 0.007),
                  child: Divider(
                      thickness: context.pWidth * 0.0005,
                      color: MyColors.fontColor))
              : Container(
                  padding: EdgeInsets.only(
                    top: context.pHeight * 0.007,
                    bottom: context.pHeight * 0.007,
                  ),
                  alignment: Alignment.centerLeft,
                  child: Text('알림을 켜시면 설정 화면이 나옵니다.',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: context.pHeight * 0.02,
                      )))
        ]));
  }

  Widget _notificationCondition() {
    return _isAllowed
        ? Padding(
            padding: EdgeInsets.only(top: context.pHeight * 0.007),
            child: SizedBox(
              width: context.pWidth,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('알림 받을 상태',
                        style: TextStyle(
                            color: MyColors.fontColor,
                            fontSize: context.pHeight * 0.035,
                            fontWeight: FontWeight.bold)),
                    Padding(padding: EdgeInsets.all(context.pHeight * 0.005)),
                    Text('위험이거나 더 나쁠 때 알림을 받음',
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: context.pHeight * 0.02,
                        )),
                    Padding(padding: EdgeInsets.all(context.pHeight * 0.01)),
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('위험',
                                style: TextStyle(
                                    color: MyColors.fontColor,
                                    fontSize: context.pHeight * 0.03,
                                    fontWeight: FontWeight.bold)),
                            Transform.scale(
                                scale: 1.3,
                                child: Radio<StateChar>(
                                  value: StateChar.warning,
                                  groupValue: _state,
                                  onChanged: (StateChar? value) {
                                    setState(() {
                                      _state = value;
                                    });
                                  },
                                )),
                          ],
                        ),
                        Padding(
                            padding: EdgeInsets.all(context.pHeight * 0.01)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('범람',
                                style: TextStyle(
                                    color: MyColors.fontColor,
                                    fontSize: context.pHeight * 0.03,
                                    fontWeight: FontWeight.bold)),
                            Transform.scale(
                                scale: 1.3,
                                child: Radio<StateChar>(
                                  value: StateChar.danger,
                                  groupValue: _state,
                                  onChanged: (StateChar? value) {
                                    setState(() {
                                      _state = value;
                                    });
                                  },
                                ))
                          ],
                        ),
                      ],
                    )
                  ]),
            ))
        : const SizedBox();
  }

  Widget _notificationTime() {
    return _isAllowed
        ? Padding(
            padding: EdgeInsets.only(top: context.pHeight * 0.04),
            child: SizedBox(
                width: context.pWidth,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('알림 작동 시간',
                              style: TextStyle(
                                  color: MyColors.fontColor,
                                  fontSize: context.pHeight * 0.035,
                                  fontWeight: FontWeight.bold)),
                          Transform.scale(
                              scale: 1,
                              child: CupertinoSwitch(
                                value: _isTimeSet,
                                thumbColor: Colors.white,
                                trackColor: Colors.grey[400],
                                activeColor: Colors.blue[400],
                                onChanged: (bool? value) {
                                  setState(() {
                                    _isTimeSet = value!;
                                  });
                                },
                              ))
                        ],
                      ),
                      Padding(padding: EdgeInsets.all(context.pHeight * 0.01)),
                      _isTimeSet
                          ? Container(
                              alignment: Alignment.center,
                              width: context.pWidth,
                              child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    NotifyTime(
                                        type: 'START',
                                        time: _startTime,
                                        minList: min,
                                        hourList: hour,
                                        onTap: _onTapTime),
                                    Padding(
                                        padding: EdgeInsets.all(
                                            context.pWidth * 0.03)),
                                    Text('~',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: context.pWidth * 0.04,
                                          fontWeight: FontWeight.bold,
                                        )),
                                    Padding(
                                        padding: EdgeInsets.all(
                                            context.pWidth * 0.03)),
                                    NotifyTime(
                                        type: 'END',
                                        time: _endTime,
                                        minList: min,
                                        hourList: hour,
                                        onTap: _onTapTime),
                                  ]))
                          : Text('하루 중 알림이 활성화되는 시간을 설정합니다.',
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontSize: context.pHeight * 0.02,
                              ))
                    ])))
        : SizedBox();
  }
}
