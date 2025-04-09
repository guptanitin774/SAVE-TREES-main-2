
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:naturesociety_new/NavigatePage.dart';
import 'package:naturesociety_new/Utils/MaterialComponets.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LiveNearByNotification extends StatefulWidget{

  _LiveNearByNotification createState() => _LiveNearByNotification();
}
class _LiveNearByNotification extends State<LiveNearByNotification>{
  late DateTime currentBackPressedTime;
   Future<bool> onWillPop()
  {
    DateTime now = DateTime.now();
    if(currentBackPressedTime == null || now.difference(currentBackPressedTime) > Duration(seconds: 3))
    {
      currentBackPressedTime = now;
      Fluttertoast.showToast(msg: "Press again to exit the app");
      return Future.value(false);
    }
    else {
      SystemNavigator.pop();
      return Future.value(false);
    }
  }

  bool isEnable = false, initialTouch = true;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: onWillPop,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          centerTitle: true,
          title: Text("Live Nearby Notifications",style: TextStyle(color: Colors.teal, fontWeight: FontWeight.w800),),
        ),
        body: SafeArea(
          child: Container(
            padding:  EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: 2,
                  child:  Container(
                    width: double.infinity,
                    child: Icon(Icons.notifications, size: 100, color: MaterialTools.basicColor,),
                  ),
                ),
                SizedBox(height: 20.0,),
                Expanded(
                  flex: 1,
                  child: Column(
                    children: <Widget>[

                      Text("By turning this feature on, you can get live notifications of cases when you are travelling.",
                        style: TextStyle(fontSize: 16),
                        textAlign: TextAlign.center, maxLines: 3, overflow:  TextOverflow.ellipsis,),

                    ],
                  ),
                ),

                Expanded(
                    flex: 1,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Checkbox(
                            value: isEnable,
                            onChanged: (value) {
                              initialTouch = false;
                              isEnable =! isEnable;
                              setState(() {});
                            }),
                        InkWell(
                          onTap:(){
                            isEnable =! isEnable;
                            setState(() {});
                          },
                          child: Text("Enable this feature", style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),)
                        )

                      ],
                )),
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      SizedBox(height: 20.0,),
                      Text("* You can turn this on later from settings.",style: TextStyle(fontSize: 16), textAlign: TextAlign.center,),
                      SizedBox(height: 60),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: MaterialButton(
          minWidth: double.infinity,
          height: 60,
          onPressed: ()=> enableLiveNotification(),
          color: MaterialTools.basicColor,
          textColor: Colors.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(initialTouch  ? "Skip " : "Continue ",style: TextStyle(fontWeight: FontWeight.bold),),
              Icon(Icons.arrow_forward, color: Colors.white,)
            ],
          ),
        ),
      ),
    );
  }


  Future<void> enableLiveNotification () async{
    SharedPreferences preference = await SharedPreferences.getInstance();
      isEnable? preference.setBool("LiveNotification",true) : preference.setBool("LiveNotification",false);

    Navigator.pushAndRemoveUntil(context, CupertinoPageRoute(builder: (context) => NavigatePage()), (route) => false);
  }

}