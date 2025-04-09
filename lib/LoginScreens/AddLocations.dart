

import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart';
import 'package:naturesociety_new/LocationSettings/AddRadiusLocation.dart';
import 'package:naturesociety_new/LocationSettings/SearchPlaces.dart';
import 'package:naturesociety_new/LoginScreens/LiveNotificationBanner.dart';
import 'package:naturesociety_new/Utils/MaterialComponets.dart';
import 'package:naturesociety_new/Utils/NetworkCall.dart';
import 'package:naturesociety_new/Widgets/CommonWidgets.dart';
import 'package:naturesociety_new/Widgets/NoConnection.dart';
import 'package:permission_handler/permission_handler.dart' as appHandler;
import 'package:location/location.dart' as location;

class AddBasicLocations extends StatefulWidget{
  _AddBasicLocations createState()=> _AddBasicLocations();
}

class _AddBasicLocations extends State<AddBasicLocations>{


  bool isLoading = true;
  @override
  void initState(){
    super.initState();
    locationPermission();

  }

  location.Location locationInstance = new location.Location();
  late bool _serviceEnabled;
  late PermissionStatus _permissionGranted;
  late LocationData _locationData;

  locationPermission() async{
    _serviceEnabled = await locationInstance.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await locationInstance.requestService();
      if (!_serviceEnabled) {
        Navigator.pop(context);
        return;
      }
    }
    permissionGranted();
  }
  permissionGranted() async{
    _permissionGranted = await locationInstance.hasPermission();
    print(_permissionGranted);
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await locationInstance.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        Fluttertoast.showToast(msg: "Location permission not granted");
        Navigator.pop(context);
        await locationInstance.hasPermission();
        appHandler.openAppSettings();
        return;
      }
    }
    _locationData = await locationInstance.getLocation();
    myCurrentLocationUpdate();
  }

  var locations; bool isConnected = true ;


  late Position position;

  Future<void> myCurrentLocationUpdate() async{

    List toAddCity =[];
    var myCity, myState ;
    try{
      if(mounted) {
        List<Placemark> placemarks = await placemarkFromCoordinates(_locationData.latitude!, _locationData.longitude!);
        var first = placemarks.first;
        print("${first.name} : ${first.street}");

       //  var address = await Geolocator .placemarkFromCoordinates(_locationData.latitude,_locationData.longitude);

        // myState = addresses.first.adminArea;
        // myCity = addresses.first.locality;
         CustomResponse response = await ApiCall.makeGetRequestToken("location/search?keyword=$myCity");
         print(json.decode(response.body));
         if(response.status == 200){
           if(json.decode(response.body)["status"]){
             toAddCity =json.decode(response.body)["Citylist"];
             for(int i=0; i< toAddCity.length; i++){
               if(toAddCity[i]["state"]["state"] == myState && toAddCity[i]["city"] == myCity){
                 onLocationSave(myCity,"City");
                 break;
             }
               else{}
             }
           }
           else{
             addPlaceManually(first);
           }
         }

      }
    }catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    }
  }

  Future<void> addPlaceManually(var addresses) async{
    print("manuel location");
    Map data = {
      "name": addresses.first.locality,
      "lat": _locationData.latitude,
      "lon": _locationData.longitude,
      "range": 3.0 *1000,
    };

    var response = await ApiCall.makePostRequestToken('user/savelocation',paramsData: data);
    if(json.decode(response.body)["status"])
     {
       print(json.decode(response.body));
       getLocations();
     }
    else
      {Fluttertoast.showToast(msg: json.decode(response.body)["msg"]);
      getLocations();}
  }

  Future<void> onLocationSave(String name, String type) async{

    print("Automatic location");
    Map data={
      "name": name,
      "type": type
    };
    CustomResponse response = await ApiCall.makePostRequestToken("user/saveplace", paramsData: data);
    if(response.status == 200){
      if(json.decode(response.body)["status"])
        print("Location Added");

      else
        print(json.decode(response.body)["msg"]);
    }
    else if(response.status == 403){
      //  Navigator.pop(context);
      CommonWidgets.loginLimit(context);
    }
    else{
      // Navigator.pop(context);
      isConnected = false;
      Fluttertoast.showToast(msg: response.body);
    }
    if(mounted)
      getLocations();
  }
  
  
  

  Future<void> getLocations() async{
    print("Getting locations");
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
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>LiveNearByNotification()));
    isConnected = true;
    }
    else
      isConnected = false;
    isLoading = false;
    setState(() {});
  }
  final buttonStyle = TextStyle(fontSize: 10.0, fontWeight: FontWeight.bold);

  static void alertBox (BuildContext context){
    showDialog(
        context: context,
        builder: (context) =>
        Platform.isIOS ?
        new CupertinoAlertDialog(
          content: new Text("Do you want to Skip adding Locations? "),
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
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>LiveNearByNotification()));
              },
            ),
          ],
        ) :
        new AlertDialog(
          content: new Text("Do you want to Skip adding Locations? "),
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
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>LiveNearByNotification()));
              },
            ),
          ],
        )
    );
  }

  Future<bool> onWillPopScope() async{
    alertBox(context);
    //Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>LiveNearByNotification()));
    return  false;
  }

  @override
  Widget build(BuildContext context) {

    return WillPopScope(
      onWillPop: onWillPopScope,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          elevation: 0.0,
          backgroundColor: Colors.white,
          iconTheme: IconThemeData(color: Colors.black),
          centerTitle: true,
          title: Text("Add locations to monitor", style: TextStyle(color: Colors.teal, fontWeight: FontWeight.w800),),
        ),

        body:!isConnected ? NoConnection(
          notifyParent: getLocations, key: UniqueKey(),
        ) : isLoading  ? CommonWidgets.progressIndicator(context) : screen(context),

        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: MaterialButton(
          color: Colors.teal,
          onPressed: ()=>  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>LiveNearByNotification())),
          height: 60,
          minWidth: MediaQuery.of(context).size.width,
          textColor: Colors.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text("Continue", style: TextStyle(fontWeight: FontWeight.w700),),
              Icon(Icons.arrow_forward, color: Colors.white,)
            ],
          ),
        ),
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
      Fluttertoast.showToast(msg: "Location has been removed Successfully");
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
            Column(
              children: locationsTile(context),
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
                      borderRadius: BorderRadius.all(Radius.circular(5)),
                        border: Border.all(color: Colors.black, width:0.0)
                    ),
                    height: 40, width: 40,
                    child: Icon(Icons.add, size: 25,),
                  ),
                  SizedBox(width: 15.0,),
                  Text("Add Location", style: TextStyle(fontWeight: FontWeight.w600),),

                ],
              ),
            ),
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.black45, width: 1.0)
              ),
              height: 40, width: 40,
              child: Icon(Icons.near_me, size: 25,),
            ),
            SizedBox(width: 15.0,),
            Text(locations[i+1]["name"] ?? " "),
            Spacer(),
            IconButton(
              icon: Icon(Icons.clear, color: Colors.grey,),
              onPressed: ()=> alertBoxWithOption(context, locations[i+1]["_id"] ),
            ),

          ],
        ),
      ));

    return onBoard;
  }


  //Location Selection
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