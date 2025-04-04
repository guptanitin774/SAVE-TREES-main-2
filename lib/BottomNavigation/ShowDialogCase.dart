
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:naturesociety_new/Utils/LocalPrefManager.dart';
import 'package:naturesociety_new/Utils/NetworkCall.dart';
import 'package:naturesociety_new/Widgets/CommonFunction.dart';
import 'package:naturesociety_new/Widgets/CommonWidgets.dart';

class ShowDialogCase extends StatefulWidget{
  _ShowDialogCase createState() => _ShowDialogCase();
}

class _ShowDialogCase extends State<ShowDialogCase>{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text("checking Dialog"),
            TextButton(onPressed: () {getIncidentFullView();}, child: Text("Tap Here"))
          ],
        ),
      ),
    );
  }
  var caseDetails; bool isLoading = false;
  Future<void> getIncidentFullView() async{

      showLoading(context);
    Position   currentLocation ;
    currentLocation = await Geolocator.getCurrentPosition();

    CustomResponse response = await ApiCall.makeGetRequestToken('incident/get?id=5fa398fefd447c00184fc688&lat=${currentLocation.latitude}&lon=${currentLocation.longitude}');
    print(json.decode(response.body));
    if(response.status == 200)
    { if(json.decode(response.body)["status"]) {
      caseDetails = json.decode(response.body)["data"];
      Navigator.pop(context);
      showPostFeedbackDialog(context);
      // dataLoading = false;
      // StoreProvider.of<AppState>(context).dispatch(IsInWatchList(caseDetails["isinwatchlist"] ? true : false));
    }
    else
      CommonWidgets.alertBox(context, json.decode(response.body)["msg"], leaveThatPage: true);
   // isConnected = true;
    }
    else if(response.status == 403){
      // dataLoading = true;
      // authError = true;
      CommonWidgets.loginLimit(context);
    }
    else
  //    isConnected = false;
      isLoading=false;
    if(mounted)
      setState(() {});
  }

  Future<void> showLoading(BuildContext context) async {
    return showDialog<void>(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
    return  WillPopScope(
        onWillPop: () async => true,
          child: Center(child:  Container(
              height: 80, width: 80,
              color: Colors.white,
              child: Center(
                child: SizedBox(
                    height: 40,width: 40,
                    child: CircularProgressIndicator()),
              )),));
    });
  }
  Future<void> showPostFeedbackDialog(BuildContext context) async {

    return showDialog<void>(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return
            WillPopScope(
              onWillPop: () async => true,
              child: Dialog(
                  backgroundColor: Colors.white,
                  child:
                    Container(
                      width: double.infinity,
                      child:  ListView(
                        children: [
                          Image(image:  NetworkImage("https://images.unsplash.com/photo-1494548162494-384bba4ab999?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&w=1000&q=80"),
                            height: 250, width: double.infinity, fit: BoxFit.cover,),
                          SizedBox(height: 8.0,),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      flex:1,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          Text("Posted by:"),
                                          Text("Anonymous"),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      flex:0,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                        Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: <Widget>[
                                          SizedBox(width: 5,),
                                          Container(
                                            decoration: BoxDecoration(color: Colors.white,
                                                border: Border.all(color: Colors.black45),
                                                borderRadius: BorderRadius.all(Radius.circular(5))),
                                            padding:EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            child: Text("60",  textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w600),),
                                          ),

                                          SizedBox(width:  8,),
                                         // caseChart["beencut"] == 0? SizedBox.shrink():
                                          Container(decoration: BoxDecoration(color: Colors.red,
                                              border: Border.all(color: Colors.red),
                                              borderRadius: BorderRadius.all(Radius.circular(5))),
                                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              child: Text("20",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w600),)),

                                          SizedBox(width:  8,),
                                          //caseChart["mightbecut"] == 0? SizedBox.shrink():
                                          Container( decoration: BoxDecoration(color: Colors.orange,
                                              border: Border.all(color: Colors.orange),
                                              borderRadius: BorderRadius.all(Radius.circular(5))),
                                            padding:EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            child: Text("20", textAlign: TextAlign.center,
                                              style: TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w600),),),

                                          SizedBox(width:   8,),
                                         // caseChart["havebeencut"] == 0 ? SizedBox.shrink() :
                                          Container( decoration: BoxDecoration(
                                              color: Colors.grey,
                                              border: Border.all(color: Colors.grey),
                                              borderRadius: BorderRadius.all(Radius.circular(5))),
                                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            child: Text("20", textAlign: TextAlign.center,
                                              style: TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w600),),),
                                        ],
                                      ),
                                      SizedBox(height: 8.0,),

                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          Text("500" +" km, ",
                                            style: TextStyle(color: Colors.black, fontSize: 12),),

                                          Text("12:30pm",
                                            style: TextStyle(color: Colors.black, fontSize: 12),),
                                        ],
                                      ),
                                      ]
                                      ),
                                    ),
                                  ],
                                ),
                                Text("Amal Jyothi college of ENGINERRING Kanjirapplyy, kottyam, kerala",
                                  style: TextStyle(fontWeight: FontWeight.w800),),
                                SizedBox(height: 8.0,),
                                Container(
                                  padding: EdgeInsets.all(5.0),
                                  color: Colors.transparent.withOpacity(0.1),
                                  width: double.infinity,
                                  child: Text("Click on the pin to see navigation options",
                                    style: TextStyle(color: Colors.black),
                                    textAlign: TextAlign.center,),
                                ),
                                Container(
                                  height: 200,
                                  child: GoogleMap(
                                    mapType: MapType.normal,
                                    zoomGesturesEnabled: true,
                                    tiltGesturesEnabled: false,
                                    scrollGesturesEnabled: true,

                                    gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>[
                                      new Factory<OneSequenceGestureRecognizer>(() => new ScaleGestureRecognizer(),),
                                    ].toSet(),


                                    initialCameraPosition: CameraPosition(
                                      target: LatLng(9.5273768, 76.8229044),
                                      zoom: 15.77,
                                    ),
                                    // markers:  markers,
                                    // onMapCreated: (GoogleMapController controller)
                                    // {
                                    //   _controller.complete(controller);
                                    // },
                                  ),
                                ),

                                SizedBox(height: 8.00,),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      flex: 1,
                                      child: Text("jh fnjkgh kfk gjdkgjdflkg jlgjgkl  djgdl kdkjg ld"
                                          " jdfklgjg mdd kdjg dlkgl dkng gdjlkg gnjklfdg d dl lkg", textAlign: TextAlign.left,
                                      overflow: TextOverflow.ellipsis, maxLines: 2,),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 8.0,),
                                Row(
                                  children: [
                                   TextButton(
                                       style: TextButton.styleFrom(
                                         minimumSize: Size(20, 0),
                                       ),
                                       onPressed: (){}, child: Icon(Icons.remove_red_eye)),
                                    TextButton(
                                        style: TextButton.styleFrom(
                                          minimumSize: Size(20, 0),
                                        ),
                                        onPressed: (){}, child: Icon(Icons.share_sharp)),

                                    Spacer(),
                                    TextButton(
                                        onPressed: (){},
                                        style: TextButton.styleFrom(
                                          foregroundColor: Colors.white,
                                          backgroundColor: Colors.teal,
                                        ),
                                        child: Row(
                                      children: [
                                        Text("View Case in detail"),
                                        Icon(Icons.arrow_forward, color: Colors.white,),
                                      ],
                                    ))
                                  ],
                                ),

                              ],
                            ),
                          ),


                        ],
                      )
                    )
                  ));
        });
  }

}