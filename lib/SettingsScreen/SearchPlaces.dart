import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart';
import 'package:naturesociety_new/Widgets/CommonWidgets.dart';

import 'package:search_map_place/search_map_place.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart' as appHandler;
import 'package:http/http.dart' as http;


String apiKEY ="AIzaSyCaccNxbzwR9tMvkppT7bT7zNKjChc_yAw";

class MapSample extends StatefulWidget {
  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample> {


  @override
  void initState(){
    super.initState();
    locationPermission();
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

  var currentLocation;
  var latitude="",longitude="";
  final Set<Marker> markers = Set();
  final Set<Circle> locationRadius = Set();

  bool isLoading = true;
  var placeLocation ;


  int valueHolder= 1; var lat, long;

   _getAddressFromLatLng() async {
    try {
      if(mounted){
        setState(() {

          http
              .get("https://maps.googleapis.com/maps/api/geocode/json?" +
              "latlng=${_locationData.latitude},${_locationData.longitude}&" +
              "key=AIzaSyCaccNxbzwR9tMvkppT7bT7zNKjChc_yAw")
              .then((response) {
            if (response.statusCode == 200) {
              var responseJson = jsonDecode(response.body)["results"];


              myPlaceHolder = "${responseJson[1]["address_components"][0]["long_name"]} ,${responseJson[2]["address_components"][0]["long_name"]}"
                  "${responseJson[3]["address_components"][0]["long_name"]}, "
                  "${responseJson[4]["address_components"][0]["long_name"]}, "
                  "${responseJson[5]["address_components"][0]["long_name"]}, "
                  "${responseJson[6]["address_components"][0]["long_name"]}, "
                  "${responseJson[7]["address_components"][0]["long_name"]}";
              setState(() {});
            }
          }).catchError((error) {
            print(error);
          });


          lat = _locationData.latitude;
          long = _locationData.longitude;
         // place = placeMark[0];
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
            radius: valueHolder.toDouble() *1000,
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


  Completer<GoogleMapController> _mapController = Completer();

String myPlaceHolder;


Future<bool>_onWillPop() async{
  Navigator.of(context).pop(null);
  return Future.value(false);
}

  LatLng returnLatLon;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        resizeToAvoidBottomPadding: false,
        body: isLoading? CommonWidgets.progressIndicator(context) : Stack(
          children: <Widget>[
            GoogleMap(
              mapType: MapType.hybrid,
              markers: markers,
              initialCameraPosition: CameraPosition(
                target: LatLng(_locationData.latitude,_locationData.longitude),
                zoom: 15.77,
              ),
              tiltGesturesEnabled: true,
              gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>[
                new Factory<OneSequenceGestureRecognizer>(() => new EagerGestureRecognizer(),),
              ].toSet(),
              onTap: (latLng) {
                placeLocation = latLng;
                clearOverlay();
                moveToLocation(latLng);
              },

              onMapCreated: (GoogleMapController controller) {
                _mapController.complete(controller);
              },

              circles:  Set.from([Circle(
                circleId: CircleId("id"),
                strokeColor: Colors.blue.withOpacity(.8),
                strokeWidth: 1,
                fillColor: Colors.blue.withOpacity(.2),
                radius: valueHolder.toDouble() *100,
                center: LatLng(lat, long),
              )]),
            ),
            Positioned(
              top: 60,
              left: MediaQuery.of(context).size.width * 0.05,
              child: SearchMapPlaceWidget(
                placeholder: myPlaceHolder,
                apiKey: apiKEY,

                onSelected: (place) async {
                  final geolocation = await place.geolocation;
                  myPlaceHolder= place.description;
                  print(place.fullJSON);
                  var coordinates = await  Geocoder.local.findAddressesFromQuery(myPlaceHolder);
                  print(coordinates.first.coordinates.latitude);
                  print(coordinates.first.coordinates.longitude);

                  final GoogleMapController controller = await _mapController.future;
                  controller.animateCamera(CameraUpdate.newLatLng(geolocation.coordinates));
                  controller.animateCamera(CameraUpdate.newLatLngBounds(geolocation.bounds, 0));
                  markers.add(Marker(
                    position: LatLng(coordinates.first.coordinates.latitude, coordinates.first.coordinates.longitude),
                    markerId: MarkerId("selected-location"),
                  ));
                  locationRadius.add(Circle(
                    circleId: CircleId("id"),
                    strokeColor: Colors.blue.withOpacity(.8),
                    strokeWidth: 1,
                    fillColor: Colors.blue.withOpacity(.2),
                    radius: valueHolder.toDouble() *10000,
                    center: LatLng(coordinates.first.coordinates.latitude, coordinates.first.coordinates.longitude),
                  ));
                  returnLatLon = LatLng(coordinates.first.coordinates.latitude, coordinates.first.coordinates.longitude);

                  setState(() {});

                },
              ),
            ),
          ],
        ),

        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            MaterialButton(
              minWidth: MediaQuery.of(context).size.width / 2 -5,
              height: 50,
              color: Colors.teal,
              onPressed: ()=> Navigator.of(context).pop(null),
              textColor: Colors.white,
              child: Text("Cancel"),
            ),
            MaterialButton(
              minWidth: MediaQuery.of(context).size.width / 2 -5,
              height: 50,
              color: Colors.teal,
              onPressed: ()=> Navigator.of(context).pop(returnLatLon),
              textColor: Colors.white,
              child: Text("Add"),
            ),
          ],
        ),
      ),
    );
  }


  final Completer<GoogleMapController> mapController = Completer();
  void moveToLocation(LatLng latLng) async{
     this.mapController.future.then((controller) {
      controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: latLng,
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
      myPlaceHolder =   first.addressLine;

       setState(() {});

      if(mounted){
        setState(() {
          lat = latLng.latitude;
          long = latLng.longitude;
          placeLocation = LatLng(latLng.latitude,latLng.longitude);
          markers.clear();
          markers.add(Marker(
            position: LatLng(latLng.latitude, latLng.longitude),
            markerId: MarkerId("selected-location"),
          ));
          returnLatLon = LatLng(latLng.latitude, latLng.longitude);

          locationRadius.clear();
        });
      }
    } catch (e) {
      print(e);
    }
    reverseGeocodeLatLng(latLng);
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

}

class LocationResult {

  String name; // or road
  String locality;
  LatLng latLng;
  String formattedAddress;
  String placeId;
}