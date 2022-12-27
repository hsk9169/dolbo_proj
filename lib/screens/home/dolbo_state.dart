import 'package:flutter/material.dart';
import 'package:dolbo_app/sizes.dart';
import 'package:dolbo_app/models/dolbo_model.dart';
import 'package:dolbo_app/const/dolbo_state.dart';
import 'package:dolbo_app/const/colors.dart';
import 'package:dolbo_app/utils/number_handler.dart';

class DolboState extends StatefulWidget {
  final DolboModel? dolboData;

  const DolboState({
    Key? key,
    this.dolboData,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _DolboState();
}

class _DolboState extends State<DolboState> {
  Color _checkStateColor(String state) {
    return state == dolboState.SAFE
        ? MyColors.normalColor
        : state == dolboState.DANGER
            ? MyColors.warningColor
            : state == dolboState.OVERFLOW
                ? MyColors.dangerColor
                : MyColors.fontColor;
  }

  @override
  Widget build(BuildContext context) {
    final fontColor = _checkStateColor(widget.dolboData!.safety!);
    final time = widget.dolboData!.lastDataTime!.isNotEmpty
        ? NumberHandler().serverTimeToString(widget.dolboData!.lastDataTime!)
        : '????-??-?? ??:??';
    return Padding(
        padding: EdgeInsets.all(context.pWidth * 0.02),
        child:
            Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          Text(widget.dolboData!.name ?? '----',
              style: TextStyle(
                color: MyColors.fontColor,
                fontSize: context.pHeight * 0.048,
                fontWeight: FontWeight.bold,
              )),
          Text(widget.dolboData!.address ?? '----',
              style: TextStyle(
                color: MyColors.fontColor,
                fontSize: context.pHeight * 0.032,
                fontWeight: FontWeight.bold,
              )),
          Padding(padding: EdgeInsets.all(context.pHeight * 0.005)),
          Text('$time 수신',
              style: TextStyle(
                color: MyColors.fontColor,
                fontSize: context.pHeight * 0.022,
                fontWeight: FontWeight.normal,
              )),
          Padding(padding: EdgeInsets.all(context.pHeight * 0.02)),
          widget.dolboData!.safety == dolboState.UNKNOWN
              ? Icon(Icons.question_mark,
                  size: context.pHeight * 0.2, color: MyColors.fontColor)
              : Image(
                  fit: BoxFit.contain,
                  width: context.pHeight * 0.18,
                  height: context.pHeight * 0.18,
                  image: AssetImage(widget.dolboData!.safety == dolboState.SAFE
                      ? 'assets/images/normal_img.png'
                      : widget.dolboData!.safety == dolboState.DANGER
                          ? 'assets/images/warning_img.png'
                          : widget.dolboData!.safety == dolboState.OVERFLOW
                              ? 'assets/images/danger_img.png'
                              : '')),
          Padding(padding: EdgeInsets.all(context.pHeight * 0.005)),
          Text(
              widget.dolboData!.safety == dolboState.SAFE
                  ? '안전'
                  : widget.dolboData!.safety == dolboState.DANGER
                      ? '위험'
                      : widget.dolboData!.safety == dolboState.OVERFLOW
                          ? '범람'
                          : '----',
              style: TextStyle(
                color: fontColor,
                fontSize: context.pHeight * 0.07,
                fontWeight: FontWeight.bold,
              )),
          Padding(padding: EdgeInsets.all(context.pHeight * 0.001)),
          Text(
              widget.dolboData!.safety == dolboState.SAFE
                  ? '산책길 등 주변시설을 이용해보세요~'
                  : widget.dolboData!.safety == dolboState.DANGER
                      ? '산책길 등 주변시설 이용을 자제해주세요~'
                      : widget.dolboData!.safety == dolboState.OVERFLOW
                          ? '산책길 등 주변시설 이용이 어렵습니다.'
                          : '----',
              style: TextStyle(
                color: fontColor,
                fontSize: context.pWidth * 0.05,
                fontWeight: FontWeight.bold,
              )),
        ]));
  }
}
