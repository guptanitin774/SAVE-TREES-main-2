

import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:naturesociety_new/LocationSettings/AddRadiusLocation.dart';
import 'package:naturesociety_new/LocationSettings/EditCurrentLocation.dart';
import 'package:naturesociety_new/LocationSettings/SearchPlaces.dart';
import 'package:naturesociety_new/Utils/MaterialComponets.dart';
import 'package:naturesociety_new/Utils/NetworkCall.dart';
import 'package:naturesociety_new/Widgets/CommonWidgets.dart';
import 'package:naturesociety_new/Widgets/NoConnection.dart';

class Locations extends StatefulWidget{
  _Locations createState()=>_Locations();
}

class _Locations extends State<Locations>{

  bool isLoading = true;
  @override
  void initState(){
    super.initState();
    getLocations();
  }

  var locations; bool isConnected = true;
  Future<void> getLocations() async{
    setState(() {
      isLoading = true;
    });

    CustomResponse response = await ApiCall.makeGetRequestToken("user/mylocations");
    if(response.status == 200)
     { if(json.decode(response.body)['status']){
        locations = json.decode(response.body)['data'];
        isLoading = false;
      }
      else
        Fluttertoast.showToast(msg: "Something went wrong!");
     isConnected = true;
     isLoading = false;
     }
    else if(response.status == 403){
      isLoading = true;
      CommonWidgets.loginLimit(context);
    }

      else
      isConnected = false;

    setState(() {});
  }
  final buttonStyle = TextStyle(fontSize: 10.0, fontWeight: FontWeight.bold);

  Future<bool> onWillPopScope() async{
    Navigator.of(context).pop(true);
    return  false;
  }

  @override
  Widget build(BuildContext context) {

    return WillPopScope(
      onWillPop: onWillPopScope,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: ()=> onWillPopScope(),
          ),

          elevation: 2.0,
          backgroundColor: Colors.white,
          iconTheme: IconThemeData(color: Colors.black),
          centerTitle: true,
          title: Text("Add locations to monitor", style: TextStyle(color: Colors.teal, fontWeight: FontWeight.w800),),
        ),

        body:!isConnected ? NoConnection(
          notifyParent: getLocations, key: UniqueKey(),
        ) : isLoading  ? CommonWidgets.progressIndicator(context) : screen(context),


      ),
    );
  }
  
  Future<void> removeUserLocation(var id) async {
    Map data={
      "id": id,
    };
    var response =  await ApiCall. makePostRequestToken("user/removelocation", paramsData: data);
    if(json.decode(response.body)['status'])
      {
        Fluttertoast.showToast(msg: "Location has been removed successfully");
        getLocations();
      }
    else
      Fluttertoast.showToast(msg: "Failed to Remove Location");
    
  }


  Widget screen (BuildContext context){
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[

            SizedBox(height: 10.0,),
            Text("You will get notified about all the activity at these locations on your home page.",
            style: TextStyle(fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,),

            SizedBox(height: 30.0,),
        AnimationLimiter(
            child: Column(
              children: AnimationConfiguration.toStaggeredList(
                duration: const Duration(milliseconds: 375),
                childAnimationBuilder: (widget) => SlideAnimation(
                  horizontalOffset: 50.0,
                  child: FadeInAnimation(
                    child: widget,
                  ),
                ),
                children: locationsTile(context),
              ),

            ),
          ),
            InkWell(
              onTap: ()=> _settingModalBottomSheet(context),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black12,
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                        border: Border.all(color: Colors.black, width:0.0)
                    ),
                    height: 40, width: 40,
                    child: Icon(Icons.add, size: 25,),
                  ),
                  SizedBox(width: 15.0,),
                  Text("Add Location", style: TextStyle(fontWeight: FontWeight.w500, color: Colors.black),),

                ],
              ),
            ),

            SizedBox(height: 20.0,),

          ],
        ),
      ),
    );
  }

  locationsTile(BuildContext context){
    List <Widget> onBoard =<Widget>[];
    for(int i=0; i< locations.length -1 ; i++)
      onBoard.add(Padding(
        padding: const EdgeInsets.only(bottom: 20.0),
        child: InkWell(
          onTap: ()async{
            bool needRefresh ;
            if(locations[i+1]["type"]  == "Range")
              needRefresh = await Navigator.push(context, MaterialPageRoute(builder: (context)=> EditCurrentLocation(locations[i+1])));
            else {
              needRefresh = false;
            }
            if(needRefresh)
              getLocations();
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                decoration: BoxDecoration(border: Border.all(color: Colors.black45, width: 1.0)),
                height: 40, width: 40,
                child: Icon(Icons.near_me, size: 25,),
              ),
              SizedBox(width: 15.0,),
              Expanded(
                flex: 1,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(locations[i+1]["name"] ?? " ", style: TextStyle(fontWeight: FontWeight.w800),),
                    locations[i+1]["place"] == null ? SizedBox.shrink() : Row(
                      children: [
                        Expanded(
                            child: Text(locations[i+1]["place"] ?? " ", maxLines: 2, overflow: TextOverflow.ellipsis,)),
                      ],
                    ),
                  ],
                ),
              ),

              IconButton(
                icon: Icon(Icons.clear, color: Colors.black45,),
                onPressed: ()=>alertBoxWithOption(context, locations[i+1]["_id"] ),
              )
            ],
          ),
        ),
      ));

    return onBoard;
  }

  void _settingModalBottomSheet(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return Container(
            child: new Wrap(
              spacing: 10.0,
              children: <Widget>[
               Padding(
                 padding: const EdgeInsets.all(8.0),
                 child: MaterialButton(
                   elevation: 0.0,
                   height: 40,
                   minWidth: double.infinity,
                   onPressed: ()async{
                     Navigator.pop(context);
                     bool needRefresh =  await Navigator.push(context, MaterialPageRoute(builder: (context)=> SearchPlaces()));
                     if(needRefresh)
                       getLocations();
                   },
                   shape: RoundedRectangleBorder(
                     side: BorderSide(color: MaterialTools.basicColor, width: 1)
                   ),
                   child: Text("Add a City / State / Country", style: TextStyle(fontWeight: FontWeight.w600),),
                   textColor: MaterialTools.basicColor,
                   color: MaterialTools.basicColor.withOpacity(0.3),
                 ),
               ),
               Padding(
                 padding: const EdgeInsets.all(8.0),
                 child: MaterialButton(
                   elevation: 0.0,
                   height: 40,
                   minWidth: double.infinity,
                   onPressed: () async{
                     Navigator.pop(context);
                     bool result =  await Navigator.push(context, MaterialPageRoute(builder: (context)=> AddCurrentLocation()));
                     if(result)
                       getLocations();
                   },
                   shape: RoundedRectangleBorder(
                       side: BorderSide(color: MaterialTools.basicColor, width: 1)
                   ),
                   child: Text("Add a location from map", style: TextStyle(fontWeight: FontWeight.w600),),
                   textColor: MaterialTools.basicColor,
                   color: MaterialTools.basicColor.withOpacity(0.3),
                 ),
               ),
              ],
            ),
          );
        });
  }


  void alertBoxWithOption(BuildContext context ,String id,){
    showDialog(
        context: context,
        builder: (context) =>
        Platform.isIOS ?
        new CupertinoAlertDialog(
          content: new Text("Do you want to remove this location ?"),
          actions: <Widget>[
            CupertinoDialogAction(
              child: Text("CANCEL"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            CupertinoDialogAction(
              isDefaultAction: true,
              child: Text("OK"),
              onPressed: () {
                removeUserLocation(id);
                Navigator.of(context).pop();
              },
            ),
          ],
        ) :
        new AlertDialog(
          content: new Text("Do you want to remove this location ?"),
          actions: [
            TextButton(
              child: new Text("CANCEL"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: new Text("OK"),
              onPressed: () {
                removeUserLocation(id);
                Navigator.of(context).pop();
              },
            ),
          ],
        )
    );
  }

}