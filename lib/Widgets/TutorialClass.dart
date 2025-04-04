import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:naturesociety_new/SettingsScreen/GettingStarted.dart';
import 'package:naturesociety_new/SettingsScreen/YoutubeVideoPlayer.dart';
import 'package:naturesociety_new/Utils/LocalPrefManager.dart';
import 'package:naturesociety_new/Utils/MaterialComponets.dart';

class TutorialClass {

  static tutorialSession(BuildContext context, {required bool initial}) async{
    var userName = await LocalPrefManager.getUserName();
    return showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {

          return new WillPopScope(
              onWillPop: () async => false,
              child: SimpleDialog(
                  backgroundColor: Colors.white,
                  children: <Widget>[
                    Stack(
                      children: [
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(horizontal: 20.0,vertical: 15.0),
                          child: Center(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text("Hi ${userName == "" || userName == null ? " " : userName}",style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),),
                                  SizedBox(height: 8.0,),
                                  Text("The following tutorials can teach you how to use this app.",style: TextStyle(color: Colors.black),
                                  textAlign: TextAlign.center,),
                                  SizedBox(height: 10.0,),
                                  MaterialButton(
                                    shape: MaterialTools.materialButtonShapeBasic,
                                    height: 50.0,
                                    minWidth: double.infinity,
                                    color: MaterialTools.tutorialBoxColor,
                                    onPressed: ()async{
                                      if(initial){}
                                      else
                                        Navigator.pop(context);
                                      await LocalPrefManager.setInitialLaunch(false);
                                     Navigator.push(context, MaterialPageRoute(builder: (context)=> GettingStarted()));
                                    },
                                    child: FittedBox(
                                      fit: BoxFit.cover,
                                        child: Text("Getting Started")),
                                    textColor: Colors.black,
                                  ),

                                  SizedBox(height: 10.0,),
                                  MaterialButton(
                                    shape: MaterialTools.materialButtonShapeBasic,
                                    height: 50.0,
                                    minWidth: double.infinity,
                                    color: MaterialTools.tutorialBoxColor,
                                    onPressed: ()async{
                                      if(initial){}
                                      else
                                        Navigator.pop(context);
                                      await LocalPrefManager.setInitialLaunch(false);
                                      Navigator.push(context, MaterialPageRoute(builder: (context)=> VideoApp(videoLink: "1602223362964.mp4",)));
                                    },
                                    child: FittedBox(
                                        fit: BoxFit.cover,
                                        child: Text("Post and share a case")),
                                    textColor: Colors.black,
                                  ),

                                  SizedBox(height: 10.0,),
                                  MaterialButton(
                                    shape: MaterialTools.materialButtonShapeBasic,
                                    height: 50.0,
                                    minWidth: double.infinity,
                                    color: MaterialTools.tutorialBoxColor,
                                    onPressed: ()async{
                                      if(initial){}
                                      else
                                        Navigator.pop(context);
                                      await LocalPrefManager.setInitialLaunch(false);
                                      Navigator.push(context, MaterialPageRoute(builder: (context)=> VideoApp(videoLink: "1602498923925.mp4")));
                                    },
                                    child: FittedBox(
                                        fit: BoxFit.cover,
                                        child: Text("Add a case to your watchlist")),
                                    textColor: Colors.black,
                                  ),
                                  SizedBox(height: 10.0,),
                                  MaterialButton(
                                    shape: MaterialTools.materialButtonShapeBasic,
                                    height: 50.0,
                                    minWidth: double.infinity,
                                    color: MaterialTools.tutorialBoxColor,
                                    onPressed: ()async{
                                      if(initial){}
                                      else
                                        Navigator.pop(context);
                                      await LocalPrefManager.setInitialLaunch(false);
                                      Navigator.push(context, MaterialPageRoute(builder: (context)=> VideoApp(videoLink: "1610767720489.mp4",)));
                                    },
                                    child: FittedBox(
                                        fit: BoxFit.cover,
                                        child: Text("Update a case")),
                                    textColor: Colors.black,
                                  ),
                                  SizedBox(height: 10.0,),
                                  MaterialButton(
                                    shape: MaterialTools.materialButtonShapeBasic,
                                    height: 50.0,
                                    minWidth: double.infinity,
                                    color: MaterialTools.tutorialBoxColor,
                                    onPressed: ()async{
                                      if(initial){}
                                      else
                                        Navigator.pop(context);
                                      await LocalPrefManager.setInitialLaunch(false);
                                      Navigator.push(context, MaterialPageRoute(builder: (context)=> VideoApp(videoLink: "1611747609228.mp4",)));
                                    },
                                    child: FittedBox(
                                        fit: BoxFit.cover,
                                        child: Text("Add new locations")),
                                    textColor: Colors.black,
                                  ),
                                  SizedBox(height: 10.0,),
                                  MaterialButton(
                                    shape: MaterialTools.materialButtonShapeBasic,
                                    height: 50.0,
                                    minWidth: double.infinity,
                                    color: MaterialTools.tutorialBoxColor,
                                    onPressed: ()async{
                                      if(initial){}
                                      else
                                        Navigator.pop(context);
                                      await LocalPrefManager.setInitialLaunch(false);
                                      Navigator.push(context, MaterialPageRoute(builder: (context)=> VideoApp(videoLink: "1610428053588.mp4",)));
                                    },
                                    child: FittedBox(
                                        fit: BoxFit.cover,
                                        child: Text("Post cases while you are offline")),
                                    textColor: Colors.black,
                                  ),

                                  SizedBox(height: !initial ? 0.0: 20.0,),
                                  !initial ? SizedBox.shrink(): MaterialButton(
                                    shape: MaterialTools.materialButtonShape,
                                    height: 50.0,
                                    minWidth: double.infinity,
                                    color: MaterialTools.basicColor,
                                    onPressed: ()async{
                                      Navigator.pop(context);
                                      await LocalPrefManager.setInitialLaunch(false);
                                    },
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Text("See Later"),
                                        FittedBox(
                                          fit: BoxFit.cover,
                                          child: Text("You will be able to access these from settings", style: TextStyle(fontSize: 12.0),
                                            textAlign: TextAlign.center,),
                                        ),
                                      ],
                                    ),
                                    textColor: Colors.white,
                                  )
                                ]),
                          ),
                        ),

                        !initial? Positioned(
                            right: 0, top: -10,
                            child: IconButton(icon: Icon(Icons.close),onPressed:  (){Navigator.pop(context);},)) :
                            SizedBox.shrink()
                      ],
                    )
                  ]));
        });

  }

}