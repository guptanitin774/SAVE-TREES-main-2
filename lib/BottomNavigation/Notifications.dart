
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:naturesociety_new/BottomNavigation/BottomNavigation.dart';
import 'package:naturesociety_new/CaseView/CaseDetailedView.dart';
import 'package:naturesociety_new/Utils/MaterialComponets.dart';
import 'package:naturesociety_new/Utils/NetworkCall.dart';
import 'package:naturesociety_new/Widgets/CommonFunction.dart';
import 'package:naturesociety_new/Widgets/CommonWidgets.dart';
import 'package:naturesociety_new/Widgets/NoConnection.dart';
import 'package:naturesociety_new/Widgets/ShimmerLoading.dart';
import 'package:naturesociety_new/Widgets/Redux.dart';

class Notifications extends StatefulWidget
{
  const Notifications({Key key}) : super(key: key);
  @override
  _Notifications createState() => _Notifications();
}

class _Notifications extends State<Notifications> {
  List notificationList= [];
  bool isConnected = true ,  isLoading = true;

  @override
  void initState() {
    super.initState();
    getFullNotificationsList(updateCount: true);
  }
  final fln = FlutterLocalNotificationsPlugin();

  Future<void> getFullNotificationsList({@required bool updateCount}) async{
    fln.cancelAll();
   if(updateCount == null )
     updateCount = true;
   else
     updateCount =  updateCount;
    CustomResponse response = await ApiCall.makeGetRequestToken("notification/getlist");
     if(response.status == 200)
      {if(json.decode(response.body)["status"]) {
          notificationList = json.decode(response.body)["result"].reversed.toList();
          if(updateCount){
            CustomResponse response2 = await ApiCall.makeGetRequestToken("notification/getunreadlist");
            StoreProvider.of<AppState>(context).dispatch(NotificationCount(json.decode(response2.body)["result"].length));
          }

          else{}
          isLoading = false;
        }
    else
      Fluttertoast.showToast(msg: "Something went wrong!");
    isConnected = true;
    }
     else if(response.status == 403){
       isLoading = true;
       CommonWidgets.loginLimit(context);
     }
    else {
      isConnected = false;
      isLoading = false;
    }
    if(mounted)
      setState(() {});
  }


  Future<bool> _willPopScope() async{
    Navigator.pushAndRemoveUntil(context, CupertinoPageRoute(builder: (context) => BottomNavPage()), (route) => false);
    return Future.value(false);
  }

  @override
  Widget build(BuildContext context) {
     return WillPopScope(
       onWillPop: _willPopScope,
       child: Scaffold(
         backgroundColor: Colors.white,
         appBar: AppBar(
           automaticallyImplyLeading: false,
           iconTheme: IconThemeData(color: Colors.grey),
           backgroundColor: Colors.grey.withOpacity(.04),
           centerTitle: true,
           title: Text("NOTIFICATIONS ", style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold),),
           elevation: 0.0,
           actions: [


             notificationList.length == 0 ? SizedBox.shrink(): PopupMenuButton<int>(
               tooltip: "Options",
               icon: Icon(Icons.more_horiz, size: 20.0,),
               itemBuilder: (context)=>[

                 PopupMenuItem(
                   value: 1,
                   child: Row(
                     children: <Widget>[
                       Icon(Icons.done, size: 15.0, color: MaterialTools.basicColor,), SizedBox(width: 4.0,),
                       Text("Mark all notifications as read", style: TextStyle(fontSize: 12.0),),
                     ],
                   ),
                 ),

                 PopupMenuItem(
                   value: 2,
                   child: Row(
                     children: <Widget>[
                       Icon(Icons.delete_sweep, size: 15.0, color: Colors.redAccent,), SizedBox(width: 4.0,),
                       Text("Delete all read notifications", style: TextStyle(fontSize: 12.0),),
                     ],
                   ),
                 ),

                 PopupMenuItem(
                   value: 3,
                   child: Row(
                     children: <Widget>[
                       Icon(Icons.delete_forever, size: 15.0, color: Colors.redAccent,), SizedBox(width: 4.0,),
                       Text("Delete all notifications", style: TextStyle(fontSize: 12.0),),
                     ],
                   ),
                 ),
               ],
               onSelected: (value)=>
                 notificationMenuOptions(value),
             ),
           ],
         ),
         body: isConnected? SafeArea(
           child: !isLoading ? mainScreen(context) : ShimmerLoading.listShimmerLoading(context),
         ): NoConnection(
           notifyParent: getFullNotificationsList,
         ),
       ),
     );
  }

  Future<void> notificationMenuOptions(int index) async{
    String url;
    if(index == 1)
      url = "notification/markallasread";
    else if(index == 2)
      url = "notification/removeallread";
    else
      url = "notification/removeall";
    List listIds=[];
    notificationList.forEach((element) {listIds.add(element["_id"]);});
    Map data={
      "ids" : listIds
    };
    CustomResponse response = await ApiCall.makePostRequestToken(url, paramsData: data);
    if(response.status ==200){
      print(json.decode(response.body));
      if(json.decode(response.body)["status"]){
        getFullNotificationsList(updateCount: true);
      }
      else
        Fluttertoast.showToast(msg: json.decode(response.body)["msg"]);
    }
    else
      Fluttertoast.showToast(msg: response.body);
  }

  Widget mainScreen(BuildContext context){
    return notificationList.length > 0 ?
    StoreConnector<AppState, AppState>(
        converter: (store) => store.state,
        builder: (context, state) {
         return RefreshIndicator(
           onRefresh: () async {
             await Future.delayed(Duration(seconds: 2));
             getFullNotificationsList(updateCount: true);
             },
           child: AnimationLimiter(
             child: ListView.builder(
                  physics: ClampingScrollPhysics(),
                  itemCount: notificationList.length,
                  padding:  EdgeInsets.symmetric(horizontal: 0.0, vertical: 10.0),
                  itemBuilder: (BuildContext context, int index){
                    var date = CommonFunction.notificationTimeStatus(notificationList[index]["createddate"]);

                    return AnimationConfiguration.staggeredList(
                      position: index,
                      duration: const Duration(milliseconds: 375),
                      child: SlideAnimation(
                        verticalOffset: 50.0,
                        child: FadeInAnimation(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 15.0),
                            child: InkWell(
                              onTap: () {
                                redirectPage(index);
                                StoreProvider.of<AppState>(context).dispatch(NotificationCount(state.notificationCount -1));},

                              child: Row(
                                children: <Widget>[
                                  notificationList[index]["status"] == "Read" ? SizedBox(width: 10,) :
                                  SizedBox(
                                    width: 10,
                                    child: Icon(Icons.brightness_1,
                                        size: 8.0, color: Colors.redAccent),
                                  ),
                                  SizedBox(width: 0,),
                                  Icon(
                                    notificationList[index]["type"] == "Discussion" ?Icons.chat :
                                    notificationList[index]["type"] == "Onway" ?Icons.navigation :
                                    notificationList[index]["type"] == "Nearby" ?Icons.location_on :
                                    notificationList[index]["type"] == "Savedlocation" ?Icons.location_on :
                                    notificationList[index]["type"] == "Mention" ?Icons.person_outline :
                                    notificationList[index]["type"] == "Admin" ?Icons.security :
                                    notificationList[index]["type"] == "Update" ?Icons.update :
                                    notificationList[index]["type"] == "Watchlist" ?Icons.remove_red_eye :

                                    Icons.announcement , color: Colors.teal,size: 30,),
                                  SizedBox(width: 15.0,),
                                  Expanded(
                                      flex: 2,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Text(notificationList[index]["message"]?? "", maxLines: 2,overflow: TextOverflow.ellipsis, style: TextStyle(fontWeight: FontWeight.w600),),
                                          Transform.translate(
                                              offset: const Offset(0.0, 5.0),
                                              child: Text(date , style: TextStyle(fontSize: 11.0, color: Colors.black54, fontWeight: FontWeight.w600),
                                                textAlign: TextAlign.end,)
                                          ),
                                        ],
                                      )),

                                  SizedBox(
                                    height: 30.0, width: 30.0,
                                    child: PopupMenuButton<int>(
                                      tooltip: "Options",
                                      icon: Icon(Icons.more_horiz, size: 15.0,),
                                      itemBuilder: (context)=>[
                                        PopupMenuItem(
                                          value: 1,
                                          child: Row(
                                            children: <Widget>[
                                              Icon(Icons.delete_forever, size: 15.0, color: Colors.redAccent,), SizedBox(width: 4.0,),
                                              Text("Remove", style: TextStyle(fontSize: 12.0),),
                                            ],
                                          ),
                                        ),
                                      ],
                                      onSelected: (value){
                                        if(value == 1)
                                        { removeNotification(index, notificationList[index]["_id"]);
                                        StoreProvider.of<AppState>(context).dispatch(NotificationCount(state.notificationCount --));
                                        }
                                      },
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );


              }),
           ),
         );},
        ) :

    Center(child: Text("No Notifications found", style: MaterialTools.errorMessageStyle));
  }
  Future<void> removeNotification(int index, var removeId) async{
    CustomResponse response = await ApiCall.makeGetRequestToken("notification/remove?id=$removeId");
    if(response.status == 200)
      if(json.decode(response.body)["result"])
       { setState(() {
          notificationList.removeAt(index);
        }); }
      else
        Fluttertoast.showToast(msg: "Something went wrong");
      else
        Fluttertoast.showToast(msg: response.body);
  }
  Future<void> readNotification(var id) async{
   await ApiCall.makeGetRequestToken("notification/markasread?id=$id");
  }
  void redirectPage(int indexVal) async{

    readNotification(notificationList[indexVal]["_id"]);

    notificationList[indexVal]["type"] == "Discussion" ?
    await Navigator.push(context, MaterialPageRoute(builder: (context)=>CaseDetailedView(notificationList[indexVal]["incident"],tabValue: 1,))):
    notificationList[indexVal]["type"] == "Update" ?
    await Navigator.push(context, MaterialPageRoute(builder: (context)=>CaseDetailedView(notificationList[indexVal]["incident"],tabValue: 0,))):

    notificationList[indexVal]["type"] == "Watchlist" ?
    await Navigator.push(context, MaterialPageRoute(builder: (context)=>CaseDetailedView(notificationList[indexVal]["incident"],tabValue: 0,))):

    notificationList[indexVal]["type"] == "Onway" ?
    await Navigator.push(context, MaterialPageRoute(builder: (context)=>CaseDetailedView(notificationList[indexVal]["incident"],tabValue: 0,))):

    notificationList[indexVal]["type"] == "Nearby" ?
    await Navigator.push(context, MaterialPageRoute(builder: (context)=>CaseDetailedView(notificationList[indexVal]["incident"],tabValue: 0,))):

    notificationList[indexVal]["type"] == "Savedlocation" ?
    await Navigator.push(context, MaterialPageRoute(builder: (context)=>CaseDetailedView(notificationList[indexVal]["incident"],tabValue: 0,))):

    notificationList[indexVal]["type"] == "Mention" ?
    await Navigator.push(context, MaterialPageRoute(builder: (context)=>CaseDetailedView(notificationList[indexVal]["incident"],tabValue: 1,))):

    notificationList[indexVal]["type"] == "Admin" ?
    CommonWidgets.newAlertBox(context, notificationList[indexVal]["message"]??"", notificationList[indexVal]["title"]??"", leaveThatPage: false):


    CommonWidgets.newAlertBox(context, "Navigation not set", "Title", leaveThatPage: false);

    getFullNotificationsList(updateCount: false);
  }
}

