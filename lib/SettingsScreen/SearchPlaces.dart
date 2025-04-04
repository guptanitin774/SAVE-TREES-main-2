import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart' as location_pkg;
import 'package:naturesociety_new/Widgets/CommonWidgets.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart' as appHandler;
import 'package:http/http.dart' as http;

import '../LocationSettings/AddRadiusLocation.dart';


String apiKEY ="AIzaSyCaccNxbzwR9tMvkppT7bT7zNKjChc_yAw";

class MapSample extends StatefulWidget {
  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample> {
  LocationResult? locationResult;
  OverlayEntry? overlayEntry;

  void clearOverlay() {
    if (overlayEntry != null) {
      overlayEntry?.remove();
      overlayEntry = null;
    }
  }

  void reverseGeocodeLatLng(LatLng latLng) {
    http
        .get(("https://maps.googleapis.com/maps/api/geocode/json?" +
        "latlng=${latLng.latitude},${latLng.longitude}&" +
        "key=AIzaSyCaccNxbzwR9tMvkppT7bT7zNKjChc_yAw") as Uri)
        .then((response) {
      if (response.statusCode == 200) {
        Map<String, dynamic> responseJson = jsonDecode(response.body);

        final result = responseJson['results'][0];

        String road = result['address_components'][0]['short_name'];
        String locality = result['address_components'][1]['short_name'];

        setState(() {
          this.locationResult = LocationResult();
          this.locationResult?.name = road;
          this.locationResult?.locality = locality;
          this.locationResult?.latLng = latLng;
          this.locationResult?.formattedAddress = result['formatted_address'];
          this.locationResult?.placeId = result['place_id'];
        });
      }
    }).catchError((error) {
      print(error);
    });
  }

  @override
  void initState() {
    super.initState();
    locationPermission();
  }


  location_pkg.Location location = new location_pkg.Location();
  late bool _serviceEnabled;
  late location_pkg.PermissionStatus _permissionGranted;
  late location_pkg.LocationData _locationData;

  Future<void> locationPermission() async {
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

  permissionGranted() async {
    _permissionGranted = await location.hasPermission();

    if (_permissionGranted == location_pkg.PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != location_pkg.PermissionStatus.granted) {
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
  var latitude = "",
      longitude = "";
  final Set<Marker> markers = Set();
  final Set<Circle> locationRadius = Set();

  bool isLoading = true;
  var placeLocation;


  int valueHolder = 1;
  var lat, long;

  _getAddressFromLatLng() async {
    try {
      if (mounted) {
        setState(() {
          http
              .get(("https://maps.googleapis.com/maps/api/geocode/json?" +
              "latlng=${_locationData.latitude},${_locationData.longitude}&" +
              "key=AIzaSyCaccNxbzwR9tMvkppT7bT7zNKjChc_yAw") as Uri)
              .then((response) {
            if (response.statusCode == 200) {
              var responseJson = jsonDecode(response.body)["results"];


              myPlaceHolder =
              "${responseJson[1]["address_components"][0]["long_name"]} ,${responseJson[2]["address_components"][0]["long_name"]}"
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
          placeLocation =
              LatLng(_locationData.latitude!, _locationData.longitude!);
          markers.add(Marker(
            position: LatLng(_locationData.latitude!, _locationData.longitude!),
            markerId: MarkerId("selected-location"),
          ));
          locationRadius.add(Circle(
            circleId: CircleId("id"),
            strokeColor: Colors.blue.withOpacity(.8),
            strokeWidth: 1,
            fillColor: Colors.blue.withOpacity(.2),
            radius: valueHolder.toDouble() * 1000,
            center: LatLng(_locationData.latitude!, _locationData.longitude!),
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

  late String myPlaceHolder;


  Future<bool> _onWillPop() async {
    Navigator.of(context).pop(null);
    return Future.value(false);
  }

  late LatLng returnLatLon;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: isLoading ? CommonWidgets.progressIndicator(context) : Stack(
          children: <Widget>[
            GoogleMap(
              mapType: MapType.hybrid,
              markers: markers,
              initialCameraPosition: CameraPosition(
                target: LatLng(
                    _locationData.latitude!, _locationData.longitude!),
                zoom: 15.77,
              ),
              tiltGesturesEnabled: true,
              gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>[
                new Factory<
                    OneSequenceGestureRecognizer>(() => new EagerGestureRecognizer(),),
              ].toSet(),
              onTap: (latLng) {
                placeLocation = latLng;
                clearOverlay();
                moveToLocation(latLng);
              },

              onMapCreated: (GoogleMapController controller) {
                _mapController.complete(controller);
              },

              circles: Set.from([Circle(
                circleId: CircleId("id"),
                strokeColor: Colors.blue.withOpacity(.8),
                strokeWidth: 1,
                fillColor: Colors.blue.withOpacity(.2),
                radius: valueHolder.toDouble() * 100,
                center: LatLng(lat, long),
              )
              ]),
            ),
            Positioned(
              top: 60,
              left: MediaQuery
                  .of(context)
                  .size
                  .width * 0.05,
              child: TextFormField(
              initialValue: myPlaceHolder,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                hintText: 'Search location',
              ),
              onChanged: (value) async {
                // Implement place search using Places API directly
                if (value.length > 2) {
                  final response = await http.get(
                    Uri.parse(
                      'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$value&key=$apiKEY',
                    ),
                  );
                  if (response.statusCode == 200) {
                    // Handle place selection
                  }
                }
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
              minWidth: MediaQuery
                  .of(context)
                  .size
                  .width / 2 - 5,
              height: 50,
              color: Colors.teal,
              onPressed: () => Navigator.of(context).pop(null),
              textColor: Colors.white,
              child: Text("Cancel"),
            ),
            MaterialButton(
              minWidth: MediaQuery
                  .of(context)
                  .size
                  .width / 2 - 5,
              height: 50,
              color: Colors.teal,
              onPressed: () => Navigator.of(context).pop(returnLatLon),
              textColor: Colors.white,
              child: Text("Add"),
            ),
          ],
        ),
      ),
    );
  }


  final Completer<GoogleMapController> mapController = Completer();

  void moveToLocation(LatLng latLng) async {
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
      // Existing try block content
      List<Placemark> placemarks = await placemarkFromCoordinates(
          latLng.latitude, latLng.longitude);
      var first = placemarks.first;
      print("${first.administrativeArea} : ${first.street}");
      myPlaceHolder = first.street ?? '';

      setState(() {});

      if (mounted) {
        setState(() {
          lat = latLng.latitude;
          long = latLng.longitude;
          placeLocation = LatLng(latLng.latitude, latLng.longitude);
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
  }
}

class LocationResult {
  String? name; // or road
  String? locality;
  LatLng? latLng;
  String? formattedAddress;
  String? placeId;

  LocationResult({
    this.name,
    this.locality,
    this.latLng,
    this.formattedAddress,
    this.placeId,
  });
}