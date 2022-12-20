import 'package:flutter/material.dart';

extension MediaQueryValues on BuildContext {
  double get pWidth => MediaQuery.of(this).size.width;
  double get pHeight => MediaQuery.of(this).size.height;
  double get leftPadding => pWidth * 0.05;
  double get rightPadding => pWidth * 0.05;
  double get markerSmallWidth => pWidth * 0.1;
  double get markerSmallHeight => pHeight * 0.05;
}
