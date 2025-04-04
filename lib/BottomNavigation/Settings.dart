

import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:naturesociety_new/BottomNavigation/BottomNavigation.dart';
import 'package:naturesociety_new/OfflineCreditinals/OfflineDataFiles.dart';
import 'package:naturesociety_new/SettingsScreen/AllNotifications.dart';
import 'package:naturesociety_new/SettingsScreen/Anonymity.dart';
import 'package:naturesociety_new/SettingsScreen/Locations.dart';
import 'package:naturesociety_new/SettingsScreen/UserProfile&Activity.dart';
import 'package:naturesociety_new/SettingsScreen/Feedback.dart';
import 'package:naturesociety_new/SplashScreen.dart';
import 'package:naturesociety_new/Utils/LocalPrefManager.dart';
import 'package:naturesociety_new/Utils/MaterialComponets.dart';
import 'package:naturesociety_new/Utils/NetworkCall.dart';
import 'package:naturesociety_new/Widgets/CommonFunction.dart';
import 'package:naturesociety_new/Widgets/CommonWidgets.dart';
import 'package:naturesociety_new/Widgets/TutorialClass.dart';
import 'package:share/share.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Settings extends StatefulWidget {
  const Settings({Key key}) : super(key: key);

  @override
  _SettingsState createState() => _SettingsState();
}
String userName=''; String locationDetails="", notifications=""; bool isAnonymous = false; var lastFeedbackTime="";
int offlineListCount = 0; var storedValues; bool   profileLoading;

class _SettingsState extends State<Settings>  with SingleTickerProviderStateMixin {

  AnimationController animationController;
  Animation<double> animation;
  Animation<double> sizeAnimation;

  bool isLoading = false;
 @override
  void initState(){
    super.initState();
    getLocation();
    getUserDetails();
    getAnonymity();
    getLastFeedback();
    getOfflineDataCount();
    getNotificationDetails();
  }
  
  Future<void> getNotificationDetails() async{

   CustomResponse response = await ApiCall.makeGetRequestToken("notification/getsettings");
   if(response.status == 200)
 {  if(json.decode(response.body)["status"]){
     if(json.decode(response.body)["data"]== null){
       notifications = "All";
     }
     else {
       if(json.decode(response.body)["data"]["notification"] &&
           json.decode(response.body)["data"]["newpostsandupdates"] &&
           json.decode(response.body)["data"]["discussion"] &&
           json.decode(response.body)["data"]["nearbycases"] &&
           json.decode(response.body)["data"]["systemnotification"]
       )
         notifications = "All";
      else if(!json.decode(response.body)["data"]["notification"] &&
           !json.decode(response.body)["data"]["newpostsandupdates"] &&
           !json.decode(response.body)["data"]["discussion"] &&
           !json.decode(response.body)["data"]["nearbycases"] &&
           !json.decode(response.body)["data"]["systemnotification"]
       )
         notifications = "Disabled";
       else
         notifications = "Customized";
     }
   }}

   if(mounted)
   setState(() {});
  }
  
  bool isProfileCompleted = false;
  Future<void> getUserDetails() async{
    profileLoading = true;
   CustomResponse response = await ApiCall.makeGetRequestToken("user/profile");
   if(response.status == 200)
   if(json.decode(response.body)['status'])
     userName = json.decode(response.body)['data']['name'];
   else
     userName = "Profile not completed";
     if(mounted)
     setState(() {});
  }
  Future<void> getLastFeedback() async{
    int length;
    CustomResponse response = await ApiCall.makeGetRequestToken("feedback/mine");
    if(response.status == 200)
      if(json.decode(response.body)['status']) {
        length = json.decode(response.body)["data"].length;
        if (length >0)
          {
            lastFeedbackTime = CommonFunction.dateFormatter.format(DateTime.parse(json.decode(response.body)['data'][length-1]["createddate"]).toLocal());
            lastFeedbackTime = "Last submitted on "+lastFeedbackTime;
          }
        else
          lastFeedbackTime = "No Feedback Provided";
      }
        else
        lastFeedbackTime = "No Feedback Provided";
        profileLoading = false;
        if(mounted)
          setState(() {});
  }

  Future<bool> _willPopScope() async{
    Navigator.pushAndRemoveUntil(context, CupertinoPageRoute(builder: (context) => BottomNavPage()), (route) => false);
    return Future.value(false);
  }

  void getLocation() async{
    CustomResponse response = await ApiCall.makeGetRequestToken("user/mylocations");
    if(response.status == 200)
    {if(json.decode(response.body)["status"])
      if(json.decode(response.body)['locations'].length > 3)
        locationDetails = json.decode(response.body)['locations'][1] + ", " +
            json.decode(response.body)['locations'][2] + " and ${json.decode(response.body)['locations'].length - 3} more";
      else if(json.decode(response.body)['locations'].length == 3)
        locationDetails = json.decode(response.body)['locations'][1] + ", " + json.decode(response.body)['locations'][2];
      else if(json.decode(response.body)['locations'].length == 2)
        locationDetails = json.decode(response.body)['locations'][1];
      else
        locationDetails = "Not Completed";}
    else if(response.status == 403){

      CommonWidgets.loginLimit(context);
    }
    else
      locationDetails = "Not Completed";
      if(mounted)
      setState(() {});
  }

  Future<void>getAnonymity() async{
    isAnonymous = await LocalPrefManager.getAnonymity();

  }

  //Offline List Count

  void getOfflineDataCount() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    storedValues = prefs.getString('offlineList');
    if(storedValues != null)
      offlineListCount = json.decode(storedValues).length;
    else
      offlineListCount=0;
      setState(() {});
  }

  final headingStyle = TextStyle(color: Colors.black, fontWeight: FontWeight.bold);
  final subHeadingStyle = TextStyle(color: Colors.grey, fontWeight: FontWeight.bold);

  Widget mainScreen(BuildContext context){

    return SafeArea(
      child: ListView(
        scrollDirection: Axis.vertical,
        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(10.0),
            child: InkWell(
              onTap: ()  async {
             bool result = await Navigator.push(context, CupertinoPageRoute(builder: (context)=>Locations()));
              //   Navigator.push(context, CupertinoPageRoute(builder: (context)=>ShowDialogCase()));
                if(result)
                  getLocation();
              } ,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    flex: 1,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text("Locations", style: headingStyle,),
                        Text(locationDetails ?? " ", style: subHeadingStyle, maxLines: 2, overflow: TextOverflow.fade,),
                      ],
                    ),
                  ),
                  Expanded(
                      flex: 0,
                      child: Icon(Icons.arrow_forward_ios)),
                ],
              ),
            ),
          ),
          Divider(thickness: 1.5,),

          Container(
            padding: EdgeInsets.all(10.0),
            child: InkWell(
               onTap: () async{
                bool refresh = await
              Navigator.push(context, CupertinoPageRoute(builder: (context)=> Anonymity()));
                if(refresh)
                  getAnonymity();
                if(mounted)
                  setState(() {});
                },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    flex: 1,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text("Post case as", style: headingStyle,),
                        Row(
                          children: <Widget>[
                            Expanded(
                              flex:0,
                                child: Text(isAnonymous? "Anonymous" : userName ?? " " +" by default", style: subHeadingStyle,maxLines: 2, overflow: TextOverflow.fade,)),
                          ],
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                      flex: 0,
                      child: Icon(Icons.arrow_forward_ios)),
                ],
              ),
            ),
          ),
          Divider(thickness: 1.5,),
          Container(
            padding: EdgeInsets.all(10.0),
            child: InkWell(
              onTap: ()async {
                bool needRefresh = await Navigator.push(context, CupertinoPageRoute(builder: (context)=> AllNotifications()));
                if(needRefresh)
                  getNotificationDetails();
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    flex: 1,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text("Notifications", style: headingStyle,),
                        Text(notifications ?? " ", style: subHeadingStyle, maxLines: 2,overflow: TextOverflow.fade,),
                      ],
                    ),
                  ),

                  Expanded(
                      flex: 0,
                      child: Icon(Icons.arrow_forward_ios)),
                ],
              ),
            ),
          ),
          Divider(thickness: 1.5,),
          Container(
            padding: EdgeInsets.all(10.0),
            child: InkWell(
              onTap: ()async{
                if(profileLoading){}
                else{
                  await Navigator.push(context, CupertinoPageRoute(builder: (context)=>UserProfileActivity()));
                  await getUserDetails();
                  setState(() {
                    profileLoading=false;
                  });
                  // if(userName != null)
                  //   Navigator.push(context, CupertinoPageRoute(builder: (context)=>UserProfileActivity()));
                  // else
                  //   Navigator.push(context, CupertinoPageRoute(builder: (context)=>ViewProfile()));
                }
              } ,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    flex: 1,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text("User Details and Activity", style: headingStyle,),
                        Text(userName ?? "Profile not completed ", style: subHeadingStyle, maxLines: 2, overflow: TextOverflow.fade,),
                      ],
                    ),
                  ),

                  Expanded(
                      flex: 0,
                      child: Icon(Icons.arrow_forward_ios)),
                ],
              ),
            ),
          ),

          offlineListCount > 0 ?Divider(thickness: 1.5,): SizedBox.shrink(),
          offlineListCount > 0 ?GestureDetector(
            onTap: ()async{
               await Navigator.push(context, CupertinoPageRoute(builder: (context)=>OfflineDataFiles()));
                getOfflineDataCount();
              },

            child: Container(
              padding: EdgeInsets.all(10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    flex: 1,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text("Offline Pending Cases", style: headingStyle,),
                        Text("${offlineListCount.toString()} ${offlineListCount> 1 ? "cases" : "case"} pending", style: subHeadingStyle,maxLines: 2,overflow: TextOverflow.fade,),
                      ],
                    ),
                  ),
                  Expanded(
                      flex: 0,
                      child: Icon(Icons.arrow_forward_ios)),
                ],
              ),
            ),
          ): SizedBox.shrink(),

          Divider(thickness: 1.5,),
          InkWell(
           onTap: ()=>  Navigator.push(context, CupertinoPageRoute(builder: (context)=>FeedbackForm("User Settings"))),
            child: Container(
              padding: EdgeInsets.all(10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    flex: 1,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text("Feedback", style: headingStyle,),
                        Text(lastFeedbackTime ?? "No Feedback Provided ", style: subHeadingStyle, maxLines: 2,overflow: TextOverflow.fade,),
                      ],
                    ),
                  ),

                  Expanded(
                      flex: 0,
                      child: Icon(Icons.arrow_forward_ios)),
                ],
              ),
            ),
          ),

          Divider(thickness: 1.5, height: 20.0,),

          MaterialButton(
            elevation: 1.0,
            color: Colors.white,
            shape: RoundedRectangleBorder(
              side: BorderSide(color: Colors.black45, width: 0.5, )
            ),
            onPressed: ()=>  TutorialClass.tutorialSession(context, initial: false),
            height: 60,
            minWidth: double.infinity,
            child: Text("Tutorials", style: TextStyle(fontWeight: FontWeight.w800),),
          ),
          SizedBox(height: 8.0,),
          MaterialButton(
            color: Colors.white,
            elevation: 1.0,
            shape: RoundedRectangleBorder(
                side: BorderSide(color: Colors.black45, width: 0.5, )
            ),
            onPressed: ()=> _onShareTap(),
            height: 60,
            minWidth: double.infinity,
            child: Text("Invite People", style: TextStyle(fontWeight: FontWeight.w800),),
          ),
          SizedBox(height: 8.0,),
          MaterialButton(
            color: Colors.white,
            shape: RoundedRectangleBorder(
                side: BorderSide(color: Colors.black45, width: 0.5, )
            ),
            onPressed: ()=> deleteDialog(context),
            height: 60,
            elevation: 1.0,
            minWidth: double.infinity,
            child: Text("Delete My Account", style: TextStyle(fontWeight: FontWeight.w800),),
          ),

          SizedBox(height: 30.0,),
        ],
      ),
    );
  }

  void onDeactivateAccount() async{

     CustomResponse response = await ApiCall.makeGetRequestToken("devicetoken/removeuser");

     CustomResponse response1 = await ApiCall.makePostRequestToken("user/removeaccount");
    if(response.status == 200 && response1.status == 200){
      if(json.decode(response.body)["status"]){
          ApiCall.clearLocalStorage();
          Navigator.pop(context);
        Navigator.pushAndRemoveUntil(context, CupertinoPageRoute(builder: (context) => SplashScreen()), (route) => false);
      }
      else
        {Fluttertoast.showToast(msg: json.decode(response.body)["msg"]);  Navigator.pop(context);}
    }
    else
      {Fluttertoast.showToast(msg: response.body);    Navigator.pop(context);}
  }



  void _onShareTap() {
    final RenderBox box = context.findRenderObject();
    var text = "Hey! I am using the Save Trees app to monitor trees around me and to get support for saving trees."
        "\n\nPlease download the app from the link below. The next time you want to save a tree, just post it on this app. ";
    Share.share(text+ "\n" + ApiCall.playStoreUrl, sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size);
  }

  @override
  Widget build(BuildContext context) {

    return WillPopScope(
      onWillPop: _willPopScope ,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.grey.withOpacity(.04),
          elevation: 0.0,
          title: Text("MORE", style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold),),
          centerTitle: true,
          automaticallyImplyLeading: false,
        ),

        body: isLoading  ? CommonWidgets.progressIndicator(context) : mainScreen(context),
      ),
    );
  }

  Future<void> showLoadingDialog(BuildContext context) async {
    return showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return new WillPopScope(
              onWillPop: () async => false,
              child: SimpleDialog(
                  backgroundColor: Colors.grey.withOpacity(.7),
                  children: <Widget>[
                    Center(
                      child: Column(children: [
                        CircularProgressIndicator(),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          "Please Wait",
                          style: TextStyle(color: Colors.white),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          "Deleting Account",
                          style: TextStyle(color: Colors.white),
                        )
                      ]),
                    )
                  ]));
        });
  }


  Future<void> deleteDialog(BuildContext context) async {
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
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("Account Deletion",style: TextStyle(color: MaterialTools.deletionColor,fontSize: 20,
                                  fontWeight: FontWeight.w800),textAlign: TextAlign.center,),

                              SizedBox(height: 20.0,),
                              Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Text("If you delete your account then all you account data like Name, Phone number,"
                                    " Email ID etc will be removed from out system.", style: TextStyle(fontWeight: FontWeight.w600),),
                              ),
                              SizedBox(height: 15.0,),
                              Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Text("In order to use Save Trees app again, you will have to sign up once more.",
                                  style: TextStyle(fontWeight: FontWeight.w600),),
                              ),

                              SizedBox(height: MediaQuery.of(context).size.height / 6,),
                              MaterialButton(
                                height: 50,
                                minWidth: double.infinity,
                                shape: MaterialTools.materialButtonShapeBasic,
                                onPressed: ()=> Navigator.pop(context),
                                child: Text("Cancel", style: TextStyle(fontWeight: FontWeight.bold),),
                              ),
                              SizedBox(height: 10.0,),
                              MaterialButton(
                                height: 50,
                                minWidth: double.infinity,
                                onPressed: (){
                                  Navigator.of(context).pop();
                                  showLoadingDialog(context);
                                  onDeactivateAccount();
                                },
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(5)),
                                    side: BorderSide(color: MaterialTools.deletionColor, width: 1)
                                ),
                                color: MaterialTools.deletionColor,
                                child: Text("Delete Account", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),),
                              ),
                              //Column(children: updateRenderList(context),),
                            ]),
                      ),
                    )
                  ]));
        });
  }


}
