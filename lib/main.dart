import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dolbo_app/app.dart';
import 'package:dolbo_app/widgets/dismiss_keyboard.dart';
import 'package:provider/provider.dart';
import 'package:dolbo_app/providers/platform_provider.dart';
import 'package:dolbo_app/routes.dart';
import 'package:dolbo_app/screens/screens.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // fix screen rotation
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]).then((_) {
    runApp(DismissKeyboard(
        child: MultiProvider(providers: [
      ChangeNotifierProvider<Platform>.value(value: Platform()),
    ], child: MyApp())));
  });
}
