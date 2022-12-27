import 'package:dolbo_app/const/dolbo_state.dart';
import 'package:dolbo_app/utils/topic_handler.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:dolbo_app/models/models.dart';
import 'package:dolbo_app/sizes.dart';
import 'package:dolbo_app/routes.dart';
import 'package:dolbo_app/providers/platform_provider.dart';
import 'package:dolbo_app/services/encrypted_storage_service.dart';
import 'package:dolbo_app/const/colors.dart';

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
  StateChar? _state = StateChar.warning;

  final _encryptedStorageService = EncryptedStorageService();

  @override
  void initState() {
    super.initState();
    _fetchNotificationInfo();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      await _encryptedStorageService.initStorage();
    });
  }

  void _fetchNotificationInfo() {
    final platformProvider = Provider.of<Platform>(context, listen: false);
    setState(() {
      _isAllowed = platformProvider.isAlarmAllowed;
      _state = platformProvider.alarmThreshold == dolboState.OVERFLOW
          ? StateChar.danger
          : StateChar.warning;
    });
  }

  Future<void> _setAlarmData() async {
    final platformProvider = Provider.of<Platform>(context, listen: false);
    if (_isAllowed) {
      platformProvider.myDolboList.forEach((DolboModel element) async {
        if (_state == StateChar.warning) {
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
    } else {
      platformProvider.myDolboList.forEach((DolboModel element) async {
        final warningTopic =
            TopicHandler().makeTopicStr(element.id!, dolboState.DANGER);
        final dangerTopic =
            TopicHandler().makeTopicStr(element.id!, dolboState.OVERFLOW);
        await FirebaseMessaging.instance.unsubscribeFromTopic(warningTopic);
        await FirebaseMessaging.instance.unsubscribeFromTopic(dangerTopic);
      });
    }
    final String threshold =
        _state == StateChar.warning ? dolboState.DANGER : dolboState.OVERFLOW;
    await _encryptedStorageService.saveData(
        'alarm_allowed', _isAllowed ? 'TRUE' : 'FALSE');
    await _encryptedStorageService.saveData(
        'alarm_threshold', _isAllowed ? threshold : dolboState.DANGER);
    platformProvider.isAlarmAllowed = _isAllowed;
    platformProvider.alarmThreshold =
        _isAllowed ? threshold : dolboState.DANGER;
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
                    onPressed: () async {
                      await _setAlarmData()
                          .whenComplete(() => Navigator.pop(context));
                    }),
                title: _appBar(),
                centerTitle: true,
                elevation: 0)),
        body: Padding(
            padding: EdgeInsets.all(context.pWidth * 0.05),
            child: Column(children: [
              _toggleNotification(),
              _notificationCondition(),
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
}
