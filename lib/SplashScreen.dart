
import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:naturesociety_new/LoginScreens/LoginSignUpWithOnBoarding.dart';
import 'package:naturesociety_new/NavigatePage.dart';
import 'package:naturesociety_new/OfflineCreditinals/SaveCaseListLocally.dart';
import 'package:naturesociety_new/Utils/LocalPrefManager.dart';
import 'package:naturesociety_new/Utils/MaterialComponets.dart';
import 'package:naturesociety_new/Utils/NetworkCall.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen>   {

  startTime() async {
    var _duration = new Duration(seconds: 4);
    return new Timer(_duration, navigateFromSplash);
  }


  @override
  void initState() {

    super.initState();

    getIncidentList();
    setFeedbackLocalTime();
    startTime();
  }


  Future<void>setFeedbackLocalTime() async{
    int count = await LocalPrefManager.getLocalFeedbackTime();
    if(count == 0 || count == null)
      count = 1;
    else
      count++;
    SharedPreferences preference1 = await SharedPreferences.getInstance();
    preference1.setInt("local_feedback_time",count);
  }


  @override
  Widget build(BuildContext context) {
    hideKeyboard(context);
    return Scaffold(
      body:
         Padding(
           padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10.0),
           child: Column(
             mainAxisAlignment: MainAxisAlignment.center,

            children: <Widget>[
                 Image(image: AssetImage("assets/natureicon.png"),),
              SizedBox(height: 20,),
              Text(MaterialTools.appTitle, style: TextStyle(color: Colors.teal, fontWeight: FontWeight.w900, fontSize: 30),textAlign: TextAlign.center,),
              Padding(
                padding: EdgeInsets.only(left: MediaQuery.of(context).size.width /2 + 50),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(2)),
                        border: Border.all(color: Colors.black54, width:1)
                      ),
                      padding: EdgeInsets.all(5),
                      child: Text("BETA", textAlign: TextAlign.left,
                        style: TextStyle(color: Colors.black54,fontWeight: FontWeight.w800, fontSize: 12),),
                    ),
                  ],
                ),
              ),

              SizedBox(height: MediaQuery.of(context).size.height / 4,),



              SizedBox(
                height: 5.0,
                width: MediaQuery.of(context).size.width / 2,
                child: LinearProgressIndicator(backgroundColor: Colors.black12, valueColor: new AlwaysStoppedAnimation<Color>(Colors.grey), ),
              ),

            ],
        ),
         ),
     );
  }

  void hideKeyboard(BuildContext context) {
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    FocusScope.of(context).requestFocus(FocusNode());
  }
  Future<void>getIncidentList () async{
    CustomResponse response = await ApiCall.makeGetRequestToken("incident/getlist?type=all");
    if(response.status == 200)
    if(json.decode(response.body)["status"])
     await  SaveCaseListLocally.arrangeData(json.decode(response.body)["data"]);
  }

  var token;
  Future navigateFromSplash () async {
      token = await LocalPrefManager.getToken();
      token == null ?
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>LoginSignUpWithOnBoarding())):
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => NavigatePage()));

  }

   @override
  void dispose() {
    super.dispose();
  }
}


