import 'dart:async';
import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:geolocator/geolocator.dart';
import 'package:naturesociety_new/SplashScreen.dart';
import 'package:naturesociety_new/Utils/LocalPrefManager.dart';
import 'package:naturesociety_new/Utils/MaterialComponets.dart';
import 'package:naturesociety_new/Utils/NetworkCall.dart';
import 'package:naturesociety_new/Widgets/Redux.dart';
import 'package:redux/redux.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

final BehaviorSubject<ReceivedNotification> didReceiveLocalNotificationSubject =
    BehaviorSubject<ReceivedNotification>();

final BehaviorSubject<String> selectNotificationSubject =
    BehaviorSubject<String>();

late NotificationAppLaunchDetails notificationAppLaunchDetails;

class ReceivedNotification {
  final int id;
  final String title;
  final String body;
  final String payload;

  ReceivedNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.payload,
  });
}

Future onDidReceiveLocalNotification(
    int id, String? title, String? body, String? payload) async {
  // handle your logic here
}

late Timer timer;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  notificationAppLaunchDetails = (await flutterLocalNotificationsPlugin
      .getNotificationAppLaunchDetails())!;

  var initializationSettingsAndroid =
      AndroidInitializationSettings("ic_launcher");
  final DarwinInitializationSettings initializationSettingsIOS =
      DarwinInitializationSettings(
    onDidReceiveLocalNotification: onDidReceiveLocalNotification,
  );

  var initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
    if (response.payload != null) {
      debugPrint('notification payload: ' + response.payload!);
    }
    selectNotificationSubject.add(response.payload!);
  });
  liveEnabled = await LocalPrefManager.getLiveNotification() ?? false;

  if (liveEnabled) {
    timer =
        Timer.periodic(Duration(minutes: 5), (timer) => getLiveNotification());
  }

  final _initialState = AppState(notificationCount: 1, cameraPhotosCount: 1);
  final Store<AppState> _store =
      Store<AppState>(reducer, initialState: _initialState);

  await LocalPrefManager.setMainLaunch(true);

  runApp(MyApp(store: _store));
}

bool liveEnabled = false;
Position position = Position(
    latitude: 0.0,
    longitude: 0.0,
    timestamp: DateTime.now(),
    accuracy: 0.0,
    altitude: 0.0,
    heading: 0.0,
    speed: 0.0,
    speedAccuracy: 0.0,
    altitudeAccuracy: 0.0,
    headingAccuracy: 0.0);

Future<void> getLiveNotification() async {
  position = await Geolocator.getCurrentPosition();
  await ApiCall.makeGetRequestToken(
      "incident/getnearbynotification?lat=${position.latitude}&lon=${position.longitude}");
}

class MyApp extends StatefulWidget {
  final Store<AppState> store;

  MyApp({required this.store});

  _MyApp createState() => _MyApp();
}

class _MyApp extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    offlinePendingNotification();
    removeDeviceToken();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
  }

  var storedValues;
  var offlineCount;

  offlinePendingNotification() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    storedValues = prefs.getString('offlineList');
    if (storedValues != null) {
      offlineCount = json.decode(storedValues).length;
      if (offlineCount > 0) _showNotification(offlineCount);
    }
  }

  Future<void> _showNotification(var offlineCount) async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'your channel id', 'your channel name',
        channelDescription: 'your channel description',
        importance: Importance.max,
        priority: Priority.high,
        ticker: 'ticker');
    var iOSPlatformChannelSpecifics = DarwinNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
        0,
        "$offlineCount pending ${offlineCount > 1 ? "cases" : "case"} ${offlineCount > 1 ? "need" : "needs"} to be uploaded",
        "",
        platformChannelSpecifics,
        payload: 'item x');
    await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
  }

  removeDeviceToken() async {
    int feedbackCount = await LocalPrefManager.getLocalFeedbackTime() ?? 1;
    feedbackCount++;
    await LocalPrefManager.setLocalFeedbackTime(feedbackCount);

    var firebaseFcm = await LocalPrefManager.getFcmToken();
    Map data = {
      'deviceToken': firebaseFcm,
    };
    CustomResponse response = await ApiCall.makePostRequestToken(
        'devicetoken/remove',
        paramsData: data);
    if (response.status == 200) {
      if (json.decode(response.body)["status"]) {
        LocalPrefManager.clearFcmToken();
        deviceToken();
      } else
        deviceToken();
    }
  }

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  deviceToken() async {
    String? fcmToken = await _fcm.getToken();
    SharedPreferences preference = await SharedPreferences.getInstance();
    preference.setString("firebase_fcm", fcmToken!);
    Map data = {'deviceToken': fcmToken, 'notify': true};
    await ApiCall.makePostRequestToken('devicetoken/add/edit',
        paramsData: data);
  }

  @override
  void dispose() {
    super.dispose();
  }

  final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey(debugLabel: "Main Navigator");

  @override
  Widget build(BuildContext context) {
    return StoreProvider<AppState>(
      store: widget.store,
      child: MaterialApp(
        title: MaterialTools.appTitle,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          scaffoldBackgroundColor: Colors.white30,
          //PopUp Menu
          popupMenuTheme: PopupMenuThemeData(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(5.0))),
              elevation: 5.0),
          // Bottom Sheet
          bottomSheetTheme: BottomSheetThemeData(
            modalElevation: 5.0,
          ),
          pageTransitionsTheme: PageTransitionsTheme(builders: {
            TargetPlatform.android: CupertinoPageTransitionsBuilder()
          }),
          tabBarTheme: TabBarTheme(
            indicatorSize: TabBarIndicatorSize.tab,
          ),
          //Dialog Box
          dialogTheme: DialogTheme(
              elevation: 10.0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8.0)))),
          visualDensity: VisualDensity.adaptivePlatformDensity,
          // App Bar
          appBarTheme: AppBarTheme(
              elevation: 5.0,
              color: Colors.white,
              iconTheme: IconThemeData(color: Colors.black, size: 20),
              titleTextStyle: TextStyle(fontSize: 16, color: Colors.black)),
          tooltipTheme: TooltipThemeData(
            preferBelow: true,
            showDuration: Duration(seconds: 3),
          ),
          // Text Theme
          textTheme: TextTheme(
            titleLarge: TextStyle(
                color: Colors.black,
                fontSize: 14.0,
                fontWeight: FontWeight.w500),
            titleMedium: TextStyle(
                color: Colors.black,
                fontSize: 14.0,
                fontWeight: FontWeight.normal),
            bodyMedium: TextStyle(
                color: Colors.black,
                fontSize: 14.0,
                fontWeight: FontWeight.normal),
          ),
          fontFamily: "OpenSans",
          primarySwatch: Colors.teal,
          // scaffoldBackgroundColor: Colors.white30,
        ),
        navigatorKey: navigatorKey,
        home: SplashScreen(),
      ),
    );
  }
}
