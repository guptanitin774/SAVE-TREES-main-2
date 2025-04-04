import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:naturesociety_new/BottomNavigation/BottomNavigation.dart';
import 'package:naturesociety_new/CaseView/CaseDetailedView.dart';
import 'package:naturesociety_new/Utils/NetworkCall.dart';
import 'package:naturesociety_new/Widgets/CommonWidgets.dart';
import 'package:naturesociety_new/Widgets/Redux.dart';

class NavigatePage extends StatefulWidget {
  _NavigatePage createState() => _NavigatePage();
}

class _NavigatePage extends State<NavigatePage> {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  void initState() {
    super.initState();

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("onMessage: ${message.data}");
      getNotificationCount();
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("onMessageOpenedApp: ${message.data}");
      getNotificationCount();
      _handleMessage(message.data);
    });

    // Check if app was opened from a notification
    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        print("getInitialMessage: ${message.data}");
        getNotificationCount();
        _handleMessage(message.data);
      }
    });
  }

  void _handleMessage(Map<String, dynamic> data) {
    if (data["type"] == "Discussion") {
      Navigator.push(context, MaterialPageRoute(builder: (context) => CaseDetailedView(data["incident"], tabValue: 1)));
    } else if (data["type"] == "Update" ||
        data["type"] == "Watchlist" ||
        data["type"] == "Onway" ||
        data["type"] == "Nearby" ||
        data["type"] == "Savedlocation") {
      Navigator.push(context, MaterialPageRoute(builder: (context) => CaseDetailedView(data["incident"], tabValue: 0)));
    } else if (data["type"] == "Mention") {
      Navigator.push(context, MaterialPageRoute(builder: (context) => CaseDetailedView(data["incident"], tabValue: 1)));
    } else {
      Navigator.push(context, MaterialPageRoute(builder: (context) => BottomNavPage(navigationIndex: 2)));
    }
  }

  Future<void> getNotificationCount() async{
    CustomResponse response = await ApiCall.makeGetRequestToken("notification/getunreadlist");
    if(response.status == 200)
      StoreProvider.of<AppState>(context).dispatch(NotificationCount(json.decode(response.body)["result"].length));
    else
      StoreProvider.of<AppState>(context).dispatch(NotificationCount(0));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BottomNavPage(),
    );
  }
}
