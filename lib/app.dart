import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dolbo_app/widgets/dismiss_keyboard.dart';
import 'package:dolbo_app/providers/platform_provider.dart';
import 'package:dolbo_app/const/colors.dart';
import 'package:dolbo_app/routes.dart';
import 'package:dolbo_app/screens/screens.dart';

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  Widget build(BuildContext context) {
    return DismissKeyboard(
        child: MultiProvider(
            providers: [
          ChangeNotifierProvider<Platform>.value(value: Platform()),
        ],
            child: MaterialApp(
              navigatorObservers: [routeObserver],
              debugShowCheckedModeBanner: false,
              theme: ThemeData(
                primarySwatch: Colors.blue,
                scaffoldBackgroundColor: Colors.white,
                bottomSheetTheme: BottomSheetThemeData(
                    backgroundColor: Colors.black.withOpacity(0)),
              ),
              routes: {
                Routes.SPLASH: (context) => SplashView(),
                Routes.HOME: (context) =>
                    HomeView(ModalRoute.of(context)!.settings.arguments as int),
                Routes.MAP: (context) => MapView(),
                Routes.LIKE: (context) => LikeView(),
                Routes.NOTIFY: (context) => NotifyView(),
              },
              initialRoute: Routes.SPLASH,
            )));
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
