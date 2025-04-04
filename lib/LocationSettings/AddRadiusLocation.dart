import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:naturesociety_new/SettingsScreen/SearchPlaces.dart';
import 'package:naturesociety_new/Utils/MaterialComponets.dart';
import 'package:naturesociety_new/Utils/NetworkCall.dart';
import 'package:naturesociety_new/Widgets/CommonWidgets.dart';
import 'package:naturesociety_new/Widgets/NoConnection.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart' as appHandler;
import 'package:search_map_place/search_map_place.dart';

class AddCurrentLocation extends StatefulWidget
{
  @override
  _AddCurrentLocation createState() => _AddCurrentLocation();
}

class _AddCurrentLocation extends State<AddCurrentLocation>
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
    locationPermission();
    timer = Timer.periodic(Duration(seconds: 10), (timer)=>checkConnection());
  }

  bool isLoading = true;
  var placeLocation ;

  String placeDetail;
  _getAddressFromLatLng() async {
    try {
      final coordinates = new Coordinates(_locationData.latitude,_locationData.longitude);
      var addresses = await Geocoder.local.findAddressesFromCoordinates(coordinates);
      var first = addresses.first;
      print("${first.featureName} : ${first.addressLine}");
      // var adddress =
      // List<Placemark> placeMark = await Geolocator().placemarkFromCoordinates(_locationData.latitude,_locationData.longitude);

      if(mounted){
        http
            .get("https://maps.googleapis.com/maps/api/geocode/json?" +
            "latlng=${_locationData.latitude},${_locationData.longitude}&" +
            "key=AIzaSyCaccNxbzwR9tMvkppT7bT7zNKjChc_yAw")
            .then((response) {
          if (response.statusCode == 200) {
            var responseJson = jsonDecode(response.body)["results"];
            print(responseJson[1]["address_components"][0]["long_name"]);
            placeDetail = "${responseJson[0]["formatted_address"]} ";

            print(placeDetail);
            if(mounted)
              setState(() {});
          }
        }).catchError((error) {
          print(error);
        });


        setState(() {
          lat = _locationData.latitude;
          long = _locationData.longitude;

          placeLocation = LatLng(_locationData.latitude,_locationData.longitude);
          markers.add(Marker(
            position: LatLng(_locationData.latitude, _locationData.longitude),
            markerId: MarkerId("selected-location"),
          ));
          locationRadius.add(Circle(
            circleId: CircleId("id"),
            strokeColor: Colors.blue.withOpacity(.8),
            strokeWidth: 1,
            fillColor: Colors.blue.withOpacity(.2),
            radius: selectedKm.toDouble() *1000,
            center: LatLng(_locationData.latitude, _locationData.longitude),
          ));
        });
      }
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
      Navigator.of(context).pop(false);
    }
    setState(() {
      isLoading = false;
    });
  }


  Location location = new Location();
  bool _serviceEnabled;
  PermissionStatus _permissionGranted;
  LocationData _locationData;

  Future<void> locationPermission() async{
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        Navigator.pop(context);
        return;
      }
    }
    permissionGranted();
  }
  permissionGranted() async{
    _permissionGranted = await location.hasPermission();

    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        Fluttertoast.showToast(msg: "Location permission not granted");
        Navigator.of(context).pop(false);
        await location.hasPermission();
        appHandler.openAppSettings();
        return;
      }
    }
    _locationData = await location.getLocation();
    _getAddressFromLatLng();
  }

  Timer timer;
  bool isConnected = true;

  Future<void> checkConnection() async{
    try{
      var result = await InternetAddress.lookup("google.com");
      if(result.isNotEmpty && result[0].rawAddress.isNotEmpty)
        if(mounted)
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

  String locationChoice = "",selected1;
  String myPlaceHolder;

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
                  padding: EdgeInsets.only(left: 10.0, right: 10.0, top: 10.0),
                  child: Column(
                    children: <Widget>[
                      SearchMapPlaceWidget(
                        placeholder: placeDetail ?? "Search Places..",
                        placeType: PlaceType.cities,
                        strictBounds: true,
                        apiKey: apiKEY,
                        hasClearButton: true,
                        onSelected: (place) async {
                          var addresses = await Geocoder.local.findAddressesFromQuery(place.description) ;
                          moveToLocation(LatLng(addresses.first.coordinates.latitude, addresses.first.coordinates.longitude));
                          setState(() {});
                        },
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
                        child: Stack(
                          children: [
                            GoogleMap(
                              mapType: MapType.normal,
                              myLocationEnabled: true,
                              myLocationButtonEnabled: true,
                              markers: markers,
                              initialCameraPosition: CameraPosition(
                                target: LatLng(_locationData.latitude,_locationData.longitude),
                                zoom: 11.77,
                              ),
                              tiltGesturesEnabled: true,
                              gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>[
                                new Factory<OneSequenceGestureRecognizer>(() => new EagerGestureRecognizer(),),
                              ].toSet(),

                              onTap: (latLng) {
                                placeLocation = latLng;
                                print(latitude);
                                clearOverlay();
                                moveToLocation(latLng);
                              },
                              onMapCreated: (GoogleMapController controller) {
                                _controller.complete(controller);
                              },


                              circles: Set.from([Circle(
                                circleId: CircleId("id"),
                                strokeColor: Colors.blue.withOpacity(.8),
                                strokeWidth: 1,
                                fillColor: Colors.blue.withOpacity(.2),
                                radius: selectedKm.toDouble() *1000,
                                center: LatLng(lat, long),
                              )]),
                            ),

                          ],
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
                    Text("Add Location ",
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
  final Completer<GoogleMapController> mapController = Completer();
  void moveToLocation(LatLng latLng) async{

    _controller.future.then((controller) {
      controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(latLng.latitude, latLng.longitude),
            zoom: 15.0,
          ),
        ),
      );

    });

    try {
      final coordinates = new Coordinates(latLng.latitude, latLng.longitude);
      var addresses = await Geocoder.local.findAddressesFromCoordinates(coordinates);
      var first = addresses.first;
      print("${first.featureName} : ${first.addressLine}");

      if(mounted){
        setState(() {
          http
              .get("https://maps.googleapis.com/maps/api/geocode/json?" +
              "latlng=${latLng.latitude},${latLng.longitude}&" +
              "key=AIzaSyCaccNxbzwR9tMvkppT7bT7zNKjChc_yAw")
              .then((response) {
            if (response.statusCode == 200) {
              var responseJson = jsonDecode(response.body)["results"];
              placeDetail = "${responseJson[0]["formatted_address"]} ";

            }
          }).catchError((error) {
            print(error);
          });

          // place = placeMark[0];
          lat = latLng.latitude;
          long = latLng.longitude;
          placeLocation = LatLng(latLng.latitude,latLng.longitude);
          markers.clear();
          markers.add(Marker(
            position: LatLng(latLng.latitude, latLng.longitude),
            markerId: MarkerId("selected-location"),
          ));

          locationRadius.clear();
        });
      }
    } catch (e) {
      print(e);
    }
    reverseGeocodeLatLng(latLng);
  }
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

  LocationResult locationResult;
  OverlayEntry overlayEntry;

  void clearOverlay() {
    if (this.overlayEntry != null) {
      this.overlayEntry.remove();
      this.overlayEntry = null;
    }
  }

  void reverseGeocodeLatLng(LatLng latLng) {
    http
        .get("https://maps.googleapis.com/maps/api/geocode/json?" +
        "latlng=${latLng.latitude},${latLng.longitude}&" +
        "key=AIzaSyCaccNxbzwR9tMvkppT7bT7zNKjChc_yAw")
        .then((response) {
      if (response.statusCode == 200) {
        Map<String, dynamic> responseJson = jsonDecode(response.body);

        final result = responseJson['results'][0];

        String road = result['address_components'][0]['short_name'];
        String locality = result['address_components'][1]['short_name'];

        setState(() {
          this.locationResult = LocationResult();
          this.locationResult.name = road;
          this.locationResult.locality = locality;
          this.locationResult.latLng = latLng;
          this.locationResult.formattedAddress = result['formatted_address'];
          this.locationResult.placeId = result['place_id'];
        });
      }
    }).catchError((error) {
      print(error);
    });
  }

  Future<bool>_onWillPop() async{
    Navigator.of(context).pop(false);
    return Future.value(false);
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
        body: !isConnected ? NoConnection( notifyParent: locationPermission,) : isLoading ?
       CommonWidgets.progressIndicator(context): mainScreen(context),


      ),
    );
  }

  Future<void> addLocationCall() async{
    Map data = {
      "name": _locationController.text,
      "lat": lat,
      "lon": long,
      "range": selectedKm.toDouble() *1000,
      "place": placeDetail,
    };

    var response = await ApiCall.makePostRequestToken('user/savelocation',paramsData: data);
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

  String name; // or road
  String locality;
  LatLng latLng;
  String formattedAddress;
  String placeId;
}