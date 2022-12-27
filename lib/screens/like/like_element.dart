import 'package:dolbo_app/app.dart';
import 'package:flutter/material.dart';
import 'package:dolbo_app/models/dolbo_model.dart';
import 'package:dolbo_app/sizes.dart';
import 'package:dolbo_app/const/dolbo_state.dart';
import 'package:dolbo_app/const/colors.dart';

class LikeElement extends StatelessWidget {
  final DolboModel? dolboData;
  final bool? isEditting;
  final VoidCallback? onDelete;

  const LikeElement({
    Key? key,
    this.dolboData,
    this.isEditting,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        key: key,
        padding: EdgeInsets.only(
            left: context.pWidth * 0.03,
            right: context.pWidth * 0.03,
            bottom: context.pHeight * 0.005,
            top: context.pHeight * 0.005),
        child: Container(
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(context.pWidth * 0.02)),
            padding: EdgeInsets.all(context.pWidth * 0.01),
            child: Stack(children: [
              Padding(
                  padding: EdgeInsets.all(context.pWidth * 0.02),
                  child: Row(children: [
                    Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(dolboData!.name ?? '----',
                                style: TextStyle(
                                  color: MyColors.fontColor,
                                  fontSize: context.pWidth * 0.05,
                                  fontWeight: FontWeight.bold,
                                )),
                            Padding(
                                padding:
                                    EdgeInsets.all(context.pHeight * 0.003)),
                            Text(dolboData!.address ?? '----',
                                style: TextStyle(
                                  color: MyColors.fontColor,
                                  fontSize: context.pWidth * 0.04,
                                  fontWeight: FontWeight.normal,
                                )),
                            Padding(
                                padding:
                                    EdgeInsets.all(context.pHeight * 0.002)),
                            Text(dolboData!.lastDataTime ?? '----',
                                style: TextStyle(
                                  color: MyColors.fontColor,
                                  fontSize: context.pWidth * 0.02,
                                  fontWeight: FontWeight.normal,
                                )),
                          ],
                        )),
                    Expanded(
                      flex: 1,
                      child: dolboData!.safety == dolboState.UNKNOWN
                          ? Icon(Icons.question_mark,
                              size: context.pWidth * 0.5,
                              color: MyColors.fontColor)
                          : Image(
                              width: context.pWidth * 0.18,
                              height: context.pWidth * 0.18,
                              image: AssetImage(dolboData!.safety ==
                                      dolboState.SAFE
                                  ? 'assets/images/normal_img.png'
                                  : dolboData!.safety == dolboState.DANGER
                                      ? 'assets/images/warning_img.png'
                                      : dolboData!.safety == dolboState.OVERFLOW
                                          ? 'assets/images/danger_img.png'
                                          : '')),
                    )
                  ])),
              Container(
                  alignment: Alignment.topRight,
                  child: GestureDetector(
                    onTap: onDelete,
                    child: Icon(isEditting! ? Icons.close : null,
                        color: MyColors.fontColor,
                        size: context.pHeight * 0.03),
                  ))
            ])));
  }
}
