
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:naturesociety_new/Utils/NetworkCall.dart';
import 'package:naturesociety_new/Widgets/CommonWidgets.dart';
import 'package:naturesociety_new/Widgets/NoConnection.dart';

class AllNotifications extends StatefulWidget{
  _AllNotifications createState()=> _AllNotifications();
}

class _AllNotifications extends State<AllNotifications>{

  @override
  void initState(){
    super.initState();
    getNotificationList();
  }
  bool isConnected = true, isLoading =true;
  
  Future<void> getNotificationList() async{

    CustomResponse response = await ApiCall.makeGetRequestToken("notification/getsettings");

    if(response.status == 200){
      if(json.decode(response.body)["status"]){
        if(json.decode(response.body)["data"] == null){
          notification = true; newPostsAndUpdates = true; discussion = true;
          allComments = true; mentioningMe = false; nearByCases= true ;systemNotification = true;
        }
        else{
          notification = json.decode(response.body)["data"]["notification"];
          newPostsAndUpdates = json.decode(response.body)["data"]["newpostsandupdates"];
          discussion =  json.decode(response.body)["data"]["discussion"];
          allComments = json.decode(response.body)["data"]["allcomments"];
          mentioningMe = json.decode(response.body)["data"]["mentioningme"];
          nearByCases= json.decode(response.body)["data"]["nearbycases"];
          systemNotification = json.decode(response.body)["data"]["watchlistnotification"];
        }
      }
      else
          Fluttertoast.showToast(msg: json.decode(response.body)["msg"]);


      isConnected = true;
    }
    else{
      Fluttertoast.showToast(msg: response.body);
      isConnected = false;
    }
    isLoading = false;
    setState(() {});
  }


  late bool notification,newPostsAndUpdates,discussion,allComments,mentioningMe,nearByCases,systemNotification ;
  
  Future<void> sendNotificationSettings() async{
    setState(() {
      isLoading = true;
    });

    CustomResponse response = await ApiCall.makeGetRequestToken("notification/settings?notification=$notification&newpostsandupdates=$newPostsAndUpdates&discussion=$discussion&allcomments=$allComments&mentioningme=$mentioningMe&nearbycases=$nearByCases&watchlistnotification=$systemNotification");
    if(response.status ==200){
      if(json.decode(response.body)["status"])
        {Fluttertoast.showToast(msg: "Updated Successfully");
          Navigator.of(context).pop(true);
        }
      else
        Fluttertoast.showToast(msg: json.decode(response.body)["msg"]);
      isConnected = true;
    }
    else{
      Fluttertoast.showToast(msg: response.body);
      isConnected = false;
    }
    isLoading = false;
    setState(() {});
  }

  Future<bool> _onWillPop() async{
    Navigator.of(context).pop(false);
    return Future.value(false);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(10.0),
          child: AppBar(
            elevation: 0.0,
            backgroundColor: Colors.white,
            automaticallyImplyLeading: false,
          ),
        ),
        body: isLoading ? Center(child: CommonWidgets.progressIndicator(context),) : isConnected? mainScreen(context): NoConnection(notifyParent: getNotificationList, key: UniqueKey(),) ,

        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: isLoading || !isConnected ? SizedBox.shrink(): MaterialButton(
          color: Colors.teal,
          child: Text("Apply Changes", style: TextStyle(fontWeight: FontWeight.w700),),
          textColor: Colors.white,
          onPressed: ()=> sendNotificationSettings(),
          height: 70, minWidth: MediaQuery.of(context).size.width,
        ),
      ),
    );
  }
  
  
  Widget mainScreen(BuildContext context){
    return SafeArea(
      child: ListView(
        children: AnimationConfiguration.toStaggeredList(
          duration: const Duration(milliseconds: 375),
          childAnimationBuilder: (widget) => SlideAnimation(
            horizontalOffset: 50.0,
            child: FadeInAnimation(
              child: widget,
            ),
          ),
          children: <Widget>[

            ListTile(
              leading: IconButton(icon:  Icon(Icons.arrow_back), color: Colors.black, onPressed: ()=> _onWillPop(),),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text("Notifications"),
                  Switch(
                    value: notification,
                    onChanged: (v){
                      if(!v){
                        newPostsAndUpdates = false;
                        discussion = false;
                        nearByCases = false;
                        systemNotification = false;
                        notification = false;
                      }
                      else
                        notification = !notification;
                      setState(() {});
                    },
                  )
                ],
              ),
            ),

            Divider(thickness: 1.0,color: Colors.black,),

            ListTile(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Expanded(
                      child: Text("New cases and updates in selected locations")),
                  Switch(
                    value: newPostsAndUpdates,
                    onChanged: (v){
                      newPostsAndUpdates = !newPostsAndUpdates;
                      setState(() {});
                    },
                  )
                ],
              ),

              subtitle: Text("Notify me when a new case is posted and when an existing case is updated in the locations selected by me.", style: TextStyle(fontSize: 12),),
            ),

            Divider(thickness: 0.5,color: Colors.black45,),

            ListTile(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Expanded(child: Text("New cases and updates nearby")),
                  Switch(
                    value: nearByCases,
                    onChanged: (v){
                      nearByCases = !nearByCases;
                      setState(() {});
                    },
                  )
                ],
              ),

              subtitle: Text("Notify me when there is a case posted or updated nearby me, within a 1 km radius.", style: TextStyle(fontSize: 12),),
            ),
            Divider(thickness: 0.5,color: Colors.black45,),

            ListTile(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Expanded(child: Text("New comments in watchlist cases")),
                  Switch(
                    value: discussion,
                    onChanged: (v){
                      discussion = !discussion;
                      setState(() {});
                    },
                  )
                ],
              ),

              subtitle:  Column(
                children: [
                  Text("Notify me when someone adds a comment in one of the cases in my watchlist.", style: TextStyle(fontSize: 12),),

                  !discussion? SizedBox.shrink():Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        SizedBox(height: 8.0,),
                        Text("Get notified for:", style: TextStyle(fontSize: 12.0),),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Expanded(
                              flex:0,
                              child: Radio(
                                value: 'all_comments',
                                groupValue: _radioValue,
                                onChanged: (value) => value != null ? radioButtonChanges(value) : null,
                              ),
                            ),
                            Expanded(
                              flex:1,
                              child: GestureDetector(
                                onTap: ()=>radioButtonChanges('all_comments'),
                                child: Text(
                                  "All Comments",maxLines: 2,overflow: TextOverflow.fade, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                                ),
                              ),
                            ),

                          ],
                        ),


                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Expanded(
                              flex:0,
                              child: Radio(
                                value: 'mentioning_me',
                                groupValue: _radioValue,
                                onChanged: (value) => value != null ? radioButtonChanges(value) : null,
                              ),
                            ),
                            Expanded(
                              flex:1,
                              child: GestureDetector(
                                onTap: ()=> radioButtonChanges('mentioning_me'),
                                child: Text(
                                  "Only the one mentioning me",maxLines: 2,overflow: TextOverflow.fade,style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14.0),
                                ),
                              ),
                            ),

                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Divider(thickness: 0.5,color: Colors.black45,),



            ListTile(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Expanded(child: Text("Updates to cases in watchlist")),
                  Switch(
                    value: systemNotification,
                    onChanged: (v){
                      systemNotification = ! systemNotification;
                      setState(() {});
                    },
                  )
                ],
              ),

              subtitle: Text("Notify me when a case in my watchlist is updated.", style: TextStyle(fontSize: 12),),
            ),
            Divider(thickness: 0.5,color: Colors.black45,),


          ],
        ),



      ),
    );
  }


  String _radioValue = "all_comments"; //Initial definition of radio button value
  String? choice = "all_comments";  // Make choice nullable by adding ?

  void radioButtonChanges(String value) async{
    setState(() {
      _radioValue = value;
      switch (value) {
        case 'all_comments':
          choice = value;
          allComments = true;
          mentioningMe = false;
          //Navigator.pop(context);
          break;
        case 'mentioning_me':
          choice = value;
          allComments = false;
          mentioningMe = true;
         // Navigator.pop(context);
          break;
        default:
          choice = null;
      }
//      debugPrint(choice); //Debug the choice in console
    });
  }

}