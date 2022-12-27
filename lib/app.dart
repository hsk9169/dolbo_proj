import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:dolbo_app/widgets/dismiss_keyboard.dart';
import 'package:dolbo_app/providers/platform_provider.dart';
import 'package:dolbo_app/routes.dart';
import 'package:dolbo_app/screens/screens.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'firebase_options.dart';

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  AndroidNotificationChannel channel = const AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    description:
        'This channel is used for important notifications.', // description
    importance: Importance.high,
  );

  final notificationDetails = NotificationDetails(
    // Android details
    android: AndroidNotificationDetails('main_channel', 'Main Channel',
        channelDescription: "ashwin",
        importance: Importance.max,
        priority: Priority.max),
    // iOS details
    iOS: IOSNotificationDetails(),
  );

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
  void initState() {
    _initMessaging();
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _initMessaging() async {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);

    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    await FirebaseMessaging.instance.getToken();

    const IOSInitializationSettings initializationSettingsIOS =
        IOSInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    await _flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: (String? payload) => print(payload!));

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      if (android != null) {
        print('android message received');
      }

      showLocalNotification(notification!, true);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('open app by tapping message');
    });
  }
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  RemoteNotification? notification = message.notification;
  AndroidNotification? android = message.notification?.android;

  showLocalNotification(notification!, false);
}

Future<void> showLocalNotification(
    RemoteNotification notification, bool isForeground) async {
  print('${notification.title} : ${notification.body}');
}
