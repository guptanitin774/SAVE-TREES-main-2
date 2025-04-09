import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:location/location.dart' as location;
import 'package:geocoding/geocoding.dart';
import 'package:naturesociety_new/LocationSettings/SearchPlaces.dart';
import 'package:naturesociety_new/SettingsScreen/SearchPlaces.dart';
import 'package:naturesociety_new/Utils/MaterialComponets.dart';
import 'package:naturesociety_new/Utils/NetworkCall.dart';
import 'package:naturesociety_new/Widgets/CommonWidgets.dart';
import 'package:naturesociety_new/Widgets/NoConnection.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart' as appHandler;

class EditCurrentLocation extends StatefulWidget
{
  final locationDetails;
  EditCurrentLocation(this.locationDetails);
  @override
  _EditCurrentLocation createState() => _EditCurrentLocation();
}

class _EditCurrentLocation extends State<EditCurrentLocation>
{

  String selectedChoice= "";
  Completer<GoogleMapController> _controller = Completer();
  var currentLocation;
  var latitude="",longitude="";
  final Set<Marker> markers = Set();
  final Set<Circle> locationRadius = Set();


  @override
  void initState()
  {
    super.initState();
    checkConnection();
    _getAddressFromLatLng();
    timer = Timer.periodic(Duration(seconds: 10), (timer)=>checkConnection());
  }

  bool isLoading = true;
  var placeLocation ;

  late String placeDetail;
  _getAddressFromLatLng() async {
    _locationController.text = widget.locationDetails["name"];
    selectedKm =(widget.locationDetails["range"] / 1000) .toInt();
    try {
      // List<Placemark> placemarks = await placemarkFromCoordinates(
      //     widget.locationDetails["location"][1],
      //     widget.locationDetails["location"][0]);

      double latitude = widget.locationDetails["location"][1];
      double longitude = widget.locationDetails["location"][0];
      List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
      // var geocoder = await Geocoder2.getDataFromCoordinates(
      //     latitude: widget.locationDetails["location"][1],
      //     longitude: widget.locationDetails["location"][0],
      //     googleMapApiKey: "AIzaSyCaccNxbzwR9tMvkppT7bT7zNKjChc_yAw");
      // var addresses = geocoder.address;
      var first = placemarks.first;
      print("${first.street} : ${first.administrativeArea}");


      if(mounted){
        http
            .get(Uri.parse("https://maps.googleapis.com/maps/api/geocode/json?"
            "latlng=${widget.locationDetails["location"][1]},${widget.locationDetails["location"][0]}&"
            "key=AIzaSyCaccNxbzwR9tMvkppT7bT7zNKjChc_yAw")).then((response) {
          if (response.statusCode == 200) {
            var responseJson = jsonDecode(response.body)["results"];
            placeDetail = "${responseJson[1]["address_components"][0]["long_name"]} ,${responseJson[2]["address_components"][0]["long_name"]}"
                "${responseJson[3]["address_components"][0]["long_name"]}, "
                "${responseJson[4]["address_components"][0]["long_name"]}, "
                "${responseJson[5]["address_components"][0]["long_name"]} ";

            if(mounted)
              setState(() {});
          }
        }).catchError((error) {
          print(error);
        });
        setState(() {
          // lat = addresses.first.coordinates.latitude;
          // long = addresses.first.coordinates.longitude;
          placeLocation = LatLng(widget.locationDetails["location"][1], widget.locationDetails["location"][0]);
          markers.add(Marker(
            position: LatLng(widget.locationDetails["location"][1], widget.locationDetails["location"][0]),
            markerId: MarkerId("selected-location"),
          ));
          locationRadius.add(Circle(
            circleId: CircleId("id"),
            strokeColor: Colors.blue.withOpacity(.8),
            strokeWidth: 1,
            fillColor: Colors.blue.withOpacity(.2),
            radius: selectedKm.toDouble() *1000,
            center: LatLng(widget.locationDetails["location"][1], widget.locationDetails["location"][0]),
          ));
        });
      }
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
      Navigator.of(context).pop(false);
    }
    if(mounted)
    setState(() {
      isLoading = false;
    });
  }


  location.Location locationInstance = new location.Location();
  late bool _serviceEnabled;
  late PermissionStatus _permissionGranted;
  late LocationData _locationData;

  Future<void> locationPermission() async{
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

    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await locationInstance.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        Fluttertoast.showToast(msg: "Location permission not granted");
        Navigator.of(context).pop(false);
        await locationInstance.hasPermission();
        appHandler.openAppSettings();
        return;
      }
    }
    _locationData = await locationInstance.getLocation();
    _getAddressFromLatLng();
  }

  late Timer timer;
  bool isConnected = true;

  Future<void> checkConnection() async{
    try{
      var result = await InternetAddress.lookup("google.com");
      if(result.isNotEmpty && result[0].rawAddress.isNotEmpty)
        setState(() {
          isConnected = true;
        });

    }on SocketException catch(_){
      setState(() {
        isConnected = false;
      });
    }
  }
  List choices=["Home", "Office", "Others"];

  late String locationChoice = "",selected1;
  late String myPlaceHolder;

  List<int> radiusKm = [1,5,10,20,50];
  int selectedKm = 1;
  radiusBox(BuildContext  context){
    List <Widget> items =<Widget>[];
    radiusKm.forEach((element) {
      items.add(InkWell(
        onTap: (){
          selectedKm = element;
          setState(() {});
        },
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 4.0, horizontal: 3.0),
          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 10.0),
          decoration: BoxDecoration(
              color: selectedKm == element ? MaterialTools.basicColor.withOpacity(0.5) : Colors.white,
              border: Border.all(color: selectedKm == element ? MaterialTools.basicColor.withOpacity(0.5) : Colors.black45,
                  width: 1.0)
          ),
          child: Text(element.toString()+ " Km", style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700, fontSize: 14),),
        ),
      ));
    });

    return items;
  }

  Widget mainScreen(BuildContext context){
    return SafeArea(
      child: Container(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.stretch,

          children: [
            Expanded(
              flex: 5,
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.only(left: 10.0, right: 10.0, top:10.0 ),
                  child:    Column(

                    children: <Widget>[
                      IgnorePointer(
                        ignoring : true,
                        child: SearchPlaces(
                          // placeholder: placeDetail ?? "Search Places..",
                          // placeType: PlaceType.cities,
                          // strictBounds: true,
                          // apiKey: apiKEY,
                          // hasClearButton: true,

                        ),
                      ),

                      Expanded(
                        flex: 0,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 10,),
                            Text("Notification Radius:", ),
                            SizedBox(height: 8,),
                            Wrap(
                              children: radiusBox(context),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),

                      Container(
                        height: MediaQuery.of(context).size.height*0.45,
                        child: GoogleMap(
                          mapType: MapType.normal,
                          myLocationEnabled: true,
                          myLocationButtonEnabled: true,
                          markers: markers,
                          initialCameraPosition: CameraPosition(
                            target: LatLng(widget.locationDetails["location"][1],widget.locationDetails["location"][0]),
                            zoom: 11.77,
                          ),
                          tiltGesturesEnabled: true,
                          gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>[
                            new Factory<OneSequenceGestureRecognizer>(() => new EagerGestureRecognizer(),),
                          ].toSet(),


                          onMapCreated: (GoogleMapController controller) {
                            _controller.complete(controller);
                          },


                          circles: Set.from([Circle(
                            circleId: CircleId("id"),
                            strokeColor: Colors.blue.withOpacity(.8),
                            strokeWidth: 1,
                            fillColor: Colors.blue.withOpacity(.2),
                            radius: selectedKm.toDouble() *1000,
                            center: LatLng(widget.locationDetails["location"][1],widget.locationDetails["location"][0]),
                          )]),
                        ),
                      ),
                      SizedBox(height: 10.0,),

                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Save location as "),
                          Icon(Icons.star, size: 5, color: Colors.red,),
                        ],
                      ),

                      TextFormField(
                        decoration: new InputDecoration(
                          hintText: 'Ex: Home, Office, etc',
                        ),
                        textCapitalization: TextCapitalization.sentences,
                        keyboardType: TextInputType.text,
                        maxLines: 1,
                        controller: _locationController,
                      ),
                      SizedBox(height: 10.0,),

                    ],

                  ),
                ),
              ),
            ),



            Expanded(
              flex: 0,
              child: MaterialButton(
                height: 60,
                minWidth: double.infinity,
                color: Color(0xff3c908d),
                onPressed: (){
                  if(_locationController.text.length == 0 )
                    CommonWidgets.alertBox(context, "Please enter the location named to be saved", leaveThatPage: false);

                  else
                    addLocationCall();
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Update Location ",
                      style: TextStyle(color: Colors.white, fontSize: 16),),
                    Icon(Icons.arrow_forward, color: Colors.white,),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  TextEditingController _locationController  = TextEditingController();
  var lat,long;

//Move Marker to Location

  void setMarker(LatLng latLng) {
    setState(() {
      markers.clear();
      markers.add(
        Marker(
          markerId: MarkerId("selected-location"),
          position: latLng,
        ),
      );
    });
  }

  void setLocationRadius(LatLng latLng, int valueHolder ){
    setState(() {
      locationRadius.clear();
      locationRadius.add(Circle(
        circleId: CircleId("id"),
        strokeColor: Colors.blue.withOpacity(.8),
        strokeWidth: 1,
        fillColor: Colors.blue.withOpacity(.2),
        radius: selectedKm.toDouble() *1000,
        center: latLng,
      ));
    });
  }




  Future<bool>_onWillPop() async{
    Navigator.of(context).pop(false);
    return Future.value(false);
  }
  void hideKeyboard(BuildContext context) {
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    FocusScope.of(context).requestFocus(FocusNode());
  }

  @override
  Widget build(BuildContext context) {
    return  WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          iconTheme: IconThemeData(color: Colors.black),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: ()=> _onWillPop(),
          ),
          title: Text("Add a location from map", style: TextStyle(color: Colors.teal, fontWeight: FontWeight.w600),),
          elevation: 5.0,
        ),
        body: !isConnected ? NoConnection( notifyParent: locationPermission, key: UniqueKey()) : isLoading ?
        CommonWidgets.progressIndicator(context): mainScreen(context),


      ),
    );
  }

  Future<void> addLocationCall() async{
    Map data = {
      "name": _locationController.text,
      "id": widget.locationDetails["_id"],
      "range": selectedKm.toDouble() *1000,
      "place": widget.locationDetails["place"]
    };

    var response = await ApiCall.makePostRequestToken('user/editlocation',paramsData: data);
    if(json.decode(response.body)["status"])
      Navigator.of(context).pop(true);
    else
      Fluttertoast.showToast(msg: json.decode(response.body)["msg"]);
  }




  @override
  void dispose(){
    timer.cancel();
    super.dispose();
  }
}

class LocationResult {

  late String name; // or road
  late String locality;
  late LatLng latLng;
  late String formattedAddress;
  late String placeId;
}