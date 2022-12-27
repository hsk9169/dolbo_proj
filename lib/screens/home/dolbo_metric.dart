import 'package:flutter/material.dart';
import 'package:dolbo_app/sizes.dart';
import 'package:dolbo_app/models/dolbo_model.dart';
import 'package:dolbo_app/utils/number_handler.dart';
import 'package:dolbo_app/const/colors.dart';

class DolboMetric extends StatelessWidget {
  final DolboModel dolboData;

  const DolboMetric({Key? key, required this.dolboData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final fontSize = context.pWidth * 0.045;
    final vPadding = context.pHeight * 0.005;
    return Container(
        padding: EdgeInsets.only(
          top: context.pHeight * 0.02,
          bottom: context.pHeight * 0.02,
        ),
        color: MyColors.bgColor,
        child: IntrinsicHeight(
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Expanded(
              child: Column(children: [
            Text('수위',
                style: TextStyle(
                    color: MyColors.fontColor,
                    fontSize: fontSize,
                    fontWeight: FontWeight.bold)),
            Padding(padding: EdgeInsets.all(vPadding)),
            Text(
                dolboData.waterLevel == 0
                    ? '-'
                    : '${dolboData.waterLevel! / 10}cm',
                style: TextStyle(
                    color: MyColors.fontColor,
                    fontSize: fontSize,
                    fontWeight: FontWeight.normal)),
          ])),
          VerticalDivider(
            width: 0,
            thickness: context.pWidth * 0.001,
            color: MyColors.fontColor,
          ),
          Expanded(
              child: Column(children: [
            Text('온도',
                style: TextStyle(
                    color: MyColors.fontColor,
                    fontSize: fontSize,
                    fontWeight: FontWeight.bold)),
            Padding(padding: EdgeInsets.all(vPadding)),
            Text(
                dolboData.temperature == 0
                    ? '-'
                    : '${dolboData.temperature}\u2103',
                style: TextStyle(
                    color: MyColors.fontColor,
                    fontSize: fontSize,
                    fontWeight: FontWeight.normal)),
          ])),
          VerticalDivider(
            width: 0,
            thickness: context.pWidth * 0.001,
            color: MyColors.fontColor,
          ),
          Expanded(
              child: Column(children: [
            Text('습도',
                style: TextStyle(
                    color: MyColors.fontColor,
                    fontSize: fontSize,
                    fontWeight: FontWeight.bold)),
            Padding(padding: EdgeInsets.all(vPadding)),
            Text(dolboData.humidity == 0 ? '-' : '${dolboData.humidity}%',
                style: TextStyle(
                    color: MyColors.fontColor,
                    fontSize: fontSize,
                    fontWeight: FontWeight.normal)),
          ])),
          VerticalDivider(
            width: 0,
            thickness: context.pWidth * 0.001,
            color: MyColors.fontColor,
          ),
          Expanded(
              child: Column(children: [
            Text('통행량',
                style: TextStyle(
                    color: MyColors.fontColor,
                    fontSize: fontSize,
                    fontWeight: FontWeight.bold)),
            Padding(padding: EdgeInsets.all(vPadding)),
            Text(
                dolboData.traffic == 0
                    ? '-'
                    : '${NumberHandler().addComma(dolboData.traffic.toString())}명',
                style: TextStyle(
                    color: MyColors.fontColor,
                    fontSize: fontSize,
                    fontWeight: FontWeight.normal)),
          ])),
        ])));
  }
}
