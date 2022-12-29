import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:dolbo_app/providers/platform_provider.dart';
import 'package:dolbo_app/services/encrypted_storage_service.dart';
import 'package:dolbo_app/routes.dart';
import 'package:dolbo_app/screens/screens.dart';
import 'firebase_options.dart';

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();
final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
final _encryptedStorageService = EncryptedStorageService();

final notificationDetails = NotificationDetails(
  // Android details
  android: AndroidNotificationDetails(
      'high_importance_channel', 'High Importance Channel',
      channelDescription: "ashwin",
      importance: Importance.max,
      priority: Priority.max),
  // iOS details
  iOS: IOSNotificationDetails(),
);

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  AndroidNotificationChannel channel = const AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    description:
        'This channel is used for important notifications.', // description
    importance: Importance.high,
  );

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      navigatorObservers: [routeObserver],
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
        bottomSheetTheme:
            BottomSheetThemeData(backgroundColor: Colors.black.withOpacity(0)),
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
    );
  }

  @override
  void initState() {
    _initMessaging(context);
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _initMessaging(BuildContext context) async {
    await _encryptedStorageService.initStorage();
    tz.initializeTimeZones();
    final String? timeZoneName = await FlutterNativeTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName!));
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

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      if (android != null) {
        showLocalNotification(notification!, true);
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      int pageNum = 0;
      final platformProvider = Provider.of<Platform>(context, listen: false);
      final myDolboList = platformProvider.myDolboList;
      String targetDolboId = message.data['id'];
      for (int i = 0; i < myDolboList.length; i++) {
        if (myDolboList[i].id == targetDolboId) {
          pageNum = i + 1;
        }
      }
      navigatorKey.currentState!.pushNamed(Routes.HOME, arguments: pageNum);
    });
  }
}

Future<void> showLocalNotification(
    RemoteNotification notification, bool isForeground) async {
  _flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      notification.title,
      notification.body,
      tz.TZDateTime.now(tz.local).add(const Duration(milliseconds: 500)),
      notificationDetails,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidAllowWhileIdle: true);
  print('${notification.title} : ${notification.body}');
}
