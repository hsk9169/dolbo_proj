import 'package:flutter/material.dart';
import 'package:dolbo_app/models/dolbo_model.dart';
import 'package:dolbo_app/sizes.dart';
import 'package:dolbo_app/const/dolbo_state.dart';
import 'package:dolbo_app/utils/number_handler.dart';
import 'package:dolbo_app/const/colors.dart';

class DolboPopup extends StatelessWidget {
  final DolboModel? dolboData;
  final bool isLike;

  const DolboPopup({
    Key? key,
    this.dolboData,
    required this.isLike,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final fontSizeBig = context.pWidth * 0.045;
    final fontSizeSmall = context.pWidth * 0.04;
    final vPadding = context.pHeight * 0.005;
    return Container(
        padding: EdgeInsets.all(context.pWidth * 0.02),
        margin: EdgeInsets.only(
            bottom: context.pHeight * 0.05,
            left: context.pWidth * 0.02,
            right: context.pWidth * 0.02),
        width: context.pWidth,
        height: context.pHeight * 0.15,
        decoration: BoxDecoration(
            color: dolboData!.safety == dolboState.SAFE
                ? MyColors.normalColor
                : dolboData!.safety == dolboState.DANGER
                    ? MyColors.warningColor
                    : dolboData!.safety == dolboState.OVERFLOW
                        ? MyColors.dangerColor
                        : Colors.grey,
            border: Border.all(
                color: MyColors.fontColor, width: context.pWidth * 0.0001)),
        child: Column(children: [
          Expanded(
              child: Row(children: [
            SizedBox(
              width: context.pHeight * 0.05,
              height: context.pHeight * 0.05,
              child: dolboData!.safety == dolboState.UNKNOWN
                  ? Icon(Icons.question_mark,
                      size: context.pWidth * 0.5, color: MyColors.fontColor)
                  : Image(
                      fit: BoxFit.contain,
                      image: AssetImage(dolboData!.safety == dolboState.SAFE
                          ? 'assets/images/normal_img.png'
                          : dolboData!.safety == dolboState.DANGER
                              ? 'assets/images/warning_img.png'
                              : dolboData!.safety == dolboState.OVERFLOW
                                  ? 'assets/images/danger_img.png'
                                  : '')),
            ),
            Padding(padding: EdgeInsets.all(context.pWidth * 0.015)),
            SizedBox(
                width: context.pWidth * 0.25,
                height: context.pHeight * 0.01,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(dolboData!.name ?? '----',
                          style: TextStyle(
                            color: MyColors.fontColor,
                            fontSize: fontSizeBig,
                            fontWeight: FontWeight.bold,
                          )),
                      Text(dolboData!.address ?? '----',
                          style: TextStyle(
                            color: MyColors.fontColor,
                            fontSize: fontSizeSmall,
                            fontWeight: FontWeight.bold,
                          ))
                    ])),
            Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text(
                  dolboData!.safety == dolboState.SAFE
                      ? '안전'
                      : dolboData!.safety == dolboState.DANGER
                          ? '위험'
                          : dolboData!.safety == dolboState.OVERFLOW
                              ? '범람'
                              : '----',
                  style: TextStyle(
                    color: MyColors.fontColor,
                    fontSize: context.pWidth * 0.06,
                    fontWeight: FontWeight.bold,
                  )),
              Padding(padding: EdgeInsets.all(context.pWidth * 0.005)),
              Icon(isLike ? Icons.star_outlined : Icons.star_border,
                  color: MyColors.fontColor, size: context.pWidth * 0.1)
            ])
          ])),
          Divider(
            thickness: context.pWidth * 0.005,
            color: MyColors.fontColor,
          ),
          Expanded(
              child: Row(children: [
            Column(children: [
              Text('수위',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: fontSizeBig,
                      fontWeight: FontWeight.bold)),
              Padding(padding: EdgeInsets.all(vPadding)),
              Text(
                  dolboData!.waterLevel == 0
                      ? '-'
                      : '${dolboData!.waterLevel}cm',
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
                  dolboData!.waterLevel == 0
                      ? '-'
                      : '${dolboData!.temperature}\u2103',
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
              Text(dolboData!.waterLevel == 0 ? '-' : '${dolboData!.humidity}%',
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
                  dolboData!.waterLevel == 0
                      ? '-'
                      : '${NumberHandler().addComma(dolboData!.traffic.toString())}명',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: fontSizeSmall,
                      fontWeight: FontWeight.normal)),
            ]),
          ]))
        ]));
  }
}
