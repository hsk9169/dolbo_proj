import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dolbo_app/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // fix screen rotation
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]).then((_) {
    runApp(MyApp());
  });
}
