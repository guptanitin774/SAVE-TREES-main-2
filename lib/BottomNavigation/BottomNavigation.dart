
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:naturesociety_new/BottomNavigation/Notifications.dart';
import 'package:naturesociety_new/BottomNavigation/Settings.dart';
import 'package:naturesociety_new/BottomNavigation/UserMainPage.dart';
import 'package:naturesociety_new/BottomNavigation/Watchlist.dart';
import 'package:naturesociety_new/PostACase/AddCase.dart';
import 'package:naturesociety_new/SettingsScreen/Feedback.dart';
import 'package:naturesociety_new/Utils/LocalPrefManager.dart';
import 'package:naturesociety_new/Utils/NetworkCall.dart';
import 'package:naturesociety_new/Widgets/FABBottomAppBarItem.dart';
import 'package:naturesociety_new/Widgets/Redux.dart';
import 'package:naturesociety_new/Widgets/TutorialClass.dart';
import 'package:quick_actions/quick_actions.dart';
import 'package:shared_preferences/shared_preferences.dart';


class BottomNavPage extends StatefulWidget
{
  final navigationIndex;
  BottomNavPage({this.navigationIndex});
  @override
  _BottomNavPage createState() => _BottomNavPage();
}



class _BottomNavPage extends State<BottomNavPage>
{



  final PageStorageBucket bucket = PageStorageBucket();

  int _selectedIndex =0;
  String shortcut = "no action set";
  final QuickActions quickActions = QuickActions();
  @override
  void initState()
  {
    print(widget.navigationIndex);

    WidgetsBinding.instance
        .addPostFrameCallback((_){
      if(widget.navigationIndex != null){
        _selectedIndex = widget.navigationIndex;
        pageController.animateToPage(_selectedIndex,
            duration: const Duration(milliseconds: 100), curve:  Curves.ease);
        setState(() {});}
    });

    setUser();
    getLocalFeedbackTime();
    //versionCheck(context);

    getNotificationCount();
    checkInitialLaunch();
    super.initState();

    quickActions.setShortcutItems(<ShortcutItem>[
      const ShortcutItem(
          type: 'action_two',
          localizedTitle: 'Post Case',
          icon: 'ic_launcher'),
    ]);

    quickActions.initialize((String shortcutType) {
      if (shortcutType != null) {
        if(shortcutType == 'action_two'){
          Navigator.push(context, MaterialPageRoute(builder: (ctx)=> AddACase()));
        }
      }
      else
        debugPrint("No action selected!");
    });
    checkForUpdate();
  }

  AppUpdateInfo? _updateInfo;
  Future<void> checkForUpdate() async {
    InAppUpdate.checkForUpdate().then((info) {
      setState(() {
        _updateInfo = info;
      });
    }).catchError((e) => {_showError(e), print(e)});
  }

  void _showError(dynamic exception) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(exception.toString())));
  }

  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey();
  Future<void> checkInitialLaunch() async{
    bool needOpen = await LocalPrefManager.getInitialLaunch();
    if(needOpen)
     { TutorialClass.tutorialSession(context, initial: true);
        await LocalPrefManager.setInitialLaunch(true);}
    else{}
  }

  //BottomNav Notification Count
  Future<void> getNotificationCount() async{
    CustomResponse response = await ApiCall.makeGetRequestToken("notification/getunreadlist");
    if(response.status == 200)
      StoreProvider.of<AppState>(context).dispatch(NotificationCount(json.decode(response.body)["result"].length));
    else
      StoreProvider.of<AppState>(context).dispatch(NotificationCount(0));
  }

  bool isConnected = true;

  //Set UserName
  Future<void> setUser() async {
    SharedPreferences preference = await SharedPreferences.getInstance();
    CustomResponse response = await ApiCall.makeGetRequestToken("user/profile");
    if (response.status == 200) {
      if (json.decode(response.body)["status"])
        preference.setString("User_Name", json.decode(response.body)["data"]["name"] ?? "");
      else
        preference.setString("User_Name", "");
  }
      else
        {
          var userData = await LocalPrefManager.getUserName();
          preference.setString("User_Name",userData);
          setState(() {
            isConnected = false;
          });
        }
  }


  Future<void>getLocalFeedbackTime() async{
    int count = await LocalPrefManager.getLocalFeedbackTime();
    var userName = await LocalPrefManager.getUserName();
    if(count == 25 && isConnected)
      Future.delayed(const Duration(seconds: 4), () async{
        showPostFeedbackDialog(context, userName);
        await LocalPrefManager.clearLocalFeedbackTime();
      });
  }





  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      floatingActionButtonLocation: FloatingActionButtonLocation.miniCenterDocked,
      floatingActionButton: SizedBox(
        height: 65,width: 65,
        child: FloatingActionButton(

          onPressed: () =>Navigator.push(context, MaterialPageRoute(builder: (context)=>AddACase())),
          tooltip: 'Post a case',
          child: Icon(Icons.add_a_photo, size: 30,),
          elevation: 2.0,
        ),
      ),
      bottomNavigationBar: StoreConnector<AppState, AppState>(
          converter: (store) => store.state,
          builder: (context, state) {
        return FABBottomAppBar(
          iconSize: 30,
          notchedShape: CircularNotchedRectangle(),
          selectedColor: Colors.teal,
          color: Colors.black54,
          onTabSelected: (v){
            _selectedIndex = v;
            navigationTapped(v);
            setState(() {});
          },

          items: [
            FABBottomAppBarItem(iconData: Icon(Icons.home, color: _selectedIndex == 0? Colors.teal : Colors.black54, ), text: 'Home'),
            FABBottomAppBarItem(iconData: Icon(Icons.remove_red_eye,color: _selectedIndex == 1? Colors.teal : Colors.black54,), text: 'Watchlist'),
            FABBottomAppBarItem(iconData: Stack(
              children: [
                Icon(Icons.notifications, color: _selectedIndex == 2? Colors.teal : Colors.black54,),
                state.notificationCount >0 ? Positioned(
                  // draw a red marble
                  top: 0.0,
                  right: 0.0,
                 // child: Text(state.notificationCount.toString(), style: TextStyle(color: Colors.green),),
                  child: new Icon(Icons.brightness_1,
                      size: 8.0, color: Colors.redAccent),
                ) : SizedBox.shrink()
              ],
            ), text: 'Notification'),
            FABBottomAppBarItem(iconData: Icon(Icons.menu_rounded , color: _selectedIndex == 3? Colors.teal : Colors.black54,), text: 'More'),
          ],
        );}
      ),





      //_bottomNavigationBar(_selectedIndex),
      body:
//      PageStorage(
//        child: pages[_selectedIndex],
//        bucket: bucket,
//      ),
      PageView(

          physics: NeverScrollableScrollPhysics(),
          controller: pageController,
          onPageChanged: onPageChanged,
          children: <Widget>[
            HomePage(),
            Watchlist(),
            Notifications(),
            Settings(),
          ]),
    );
  }
  PageController pageController = PageController();

  void onPageChanged(int value) {
    setState(() {
      _selectedIndex  = value;
     });
  }
  void navigationTapped(int value) {
    pageController.jumpToPage(value);
  }
  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  Future<void> showPostFeedbackDialog(BuildContext context, var userName) async {
    return showDialog<void>(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return new WillPopScope(
              onWillPop: () async => true,
              child: SimpleDialog(
                  backgroundColor: Colors.white,
                  children: <Widget>[
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(horizontal: 10.0),
                      child: Center(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text("Feedback time!",style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),),
                              SizedBox(height: 10.0,),
                              Text("Hey $userName, looks like you have been using Save Trees for quite some time now"
                                  "after you give us your last feedback.\n\n"
                                  "Would you like to spare a minute to give us any more feedback for us to make this app more useful?"),
                              SizedBox(height: 15.0,),
                              MaterialButton(
                                textColor: Colors.white,
                                color: Colors.teal,
                                minWidth: double.infinity,
                                onPressed: (){
                                  Navigator.pop(context);
                                  Navigator.push(context, CupertinoPageRoute(builder: (context)=>FeedbackForm("User Settings")));
                                },
                                child: Text("Give feedback"),
                              ),
                              SizedBox(height: 3.0,),
                              MaterialButton(
                                textColor: Colors.white,
                                color: Colors.teal,
                                minWidth: double.infinity,
                                onPressed: () async{
                                  LocalPrefManager.clearLocalFeedbackTime();
                                   Navigator.pop(context);
                                },
                                child: Text("Maybe later"),
                              ),
                            ]),
                      ),
                    )
                  ]));
        });
  }

  //  versionCheck(context) async {
  //   final PackageInfo info = await PackageInfo.fromPlatform();
  //   double currentVersion = double.parse(info.version.trim().replaceAll(".", ""));
  //
  //   final RemoteConfig remoteConfig = await RemoteConfig.instance;
  //   try {
  //     // Using default duration to force fetching from remote server.
  //     await remoteConfig.fetch(expiration: const Duration(seconds: 0));
  //     await remoteConfig.activateFetched();
  //     remoteConfig.getString('release_app_version');
  //     double newVersion = double.parse(remoteConfig.getString('release_app_version').trim().replaceAll(".", ""));
  //     if (newVersion > currentVersion) {
  //     bool needs =   await LocalPrefManager.getMainLaunch();
  //     // ignore: unnecessary_statements
  //     needs?  CommonWidgets.showVersionDialog(context) : (){};
  //     }
  //   } on FetchThrottledException catch (exception) {
  //     // Fetch throttled.
  //     print(exception);
  //   } catch (exception) {
  //     print('Unable to fetch remote config. Cached or default values will be '
  //         'used');
  //   }
  // }



}