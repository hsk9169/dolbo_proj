import 'package:dolbo_app/const/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:dolbo_app/sizes.dart';

class NotifyTime extends StatefulWidget {
  final String type;
  final String time;
  final Function onTap;
  final List<String> minList;
  final List<int> hourList;

  const NotifyTime({
    required this.type,
    required this.time,
    required this.onTap,
    required this.hourList,
    required this.minList,
  });

  @override
  State<StatefulWidget> createState() => _NotifyTime();
}

class _NotifyTime extends State<NotifyTime> {
  bool _isTapped = false;

  void onPressOk() {
    Navigator.pop(context);
  }

  List<Widget> getHourList() {
    return List.generate(
        widget.hourList.length,
        (index) => Center(
            child: Text(widget.hourList[index].toString(),
                style: TextStyle(
                    fontSize: MediaQuery.of(context).size.width * 0.06,
                    fontWeight: FontWeight.bold))));
  }

  List<Widget> getMinList() {
    return List.generate(
        widget.minList.length,
        (index) => Center(
            child: Text(widget.minList[index],
                style: TextStyle(
                    fontSize: MediaQuery.of(context).size.width * 0.06,
                    fontWeight: FontWeight.bold))));
  }

  List<Widget> getDayList() {
    return <Widget>[
      Center(
          child: Text('오전',
              style: TextStyle(
                  fontSize: MediaQuery.of(context).size.width * 0.06,
                  fontWeight: FontWeight.bold))),
      Center(
          child: Text('오후',
              style: TextStyle(
                  fontSize: MediaQuery.of(context).size.width * 0.06,
                  fontWeight: FontWeight.bold)))
    ];
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          widget.onTap(widget.type);
          modalPopup();
        },
        child: Container(
            padding: EdgeInsets.only(
              left: context.pWidth * 0.07,
              right: context.pWidth * 0.07,
              top: context.pHeight * 0.015,
              bottom: context.pHeight * 0.015,
            ),
            decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(
                    color: MyColors.fontColor, width: context.pWidth * 0.0005)),
            child: Text(widget.time,
                style: TextStyle(
                  color: MyColors.fontColor,
                  fontSize: context.pWidth * 0.045,
                  fontWeight: FontWeight.bold,
                ))));
  }

  void modalPopup() {
    showModalBottomSheet(
        enableDrag: false,
        isDismissible: false,
        isScrollControlled: true,
        context: context,
        backgroundColor: Colors.grey[200],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(0),
        ),
        builder: (BuildContext context) {
          return SizedBox(
              width: context.pWidth,
              height: context.pHeight * 0.35,
              child: Column(children: [
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  scrollItems(getDayList()),
                  scrollItems(getHourList()),
                  scrollItems(getMinList()),
                ]),
                SizedBox(
                  width: context.pWidth * 0.9,
                  height: context.pHeight * 0.05,
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          primary: Colors.blue,
                          shape: const RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)))),
                      onPressed: onPressOk,
                      child: Text('확인',
                          style: TextStyle(
                              fontSize:
                                  MediaQuery.of(context).size.width * 0.05,
                              fontWeight: FontWeight.bold,
                              color: Colors.white))),
                )
              ]));
        });
  }

  Widget scrollItems(List<Widget> list) {
    return SizedBox(
        width: context.pWidth * 0.3,
        height: context.pHeight * 0.25,
        child: CupertinoPicker(
            onSelectedItemChanged: (value) => print(value),
            diameterRatio: 1,
            itemExtent: 40,
            scrollController: FixedExtentScrollController(initialItem: 0),
            selectionOverlay: const CupertinoPickerDefaultSelectionOverlay(
                background: CupertinoColors.tertiarySystemFill,
                capStartEdge: false,
                capEndEdge: false),
            children: list));
  }
}
