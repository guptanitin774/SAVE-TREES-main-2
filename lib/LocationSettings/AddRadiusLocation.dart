import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_location_picker/google_maps_location_picker.dart';
import 'package:location/location.dart';
import 'package:naturesociety_new/SettingsScreen/SearchPlaces.dart'; // Import for SearchMapPlaceWidget
import 'package:naturesociety_new/Utils/MaterialComponets.dart';
import 'package:naturesociety_new/Utils/NetworkCall.dart';
import 'package:naturesociety_new/Widgets/CommonWidgets.dart';
import 'package:naturesociety_new/Widgets/NoConnection.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart' as appHandler;
import 'package:location/location.dart' hide Location;
import 'package:naturesociety_new/SettingsScreen/SearchPlaces.dart';
import 'package:location/location.dart' as loc;

import '../BottomNavigation/UserMainPage.dart';

// API key constant - should be moved to a config file in production
const String apiKEY = "AIzaSyCaccNxbzwR9tMvkppT7bT7zNKjChc_yAw";

class AddCurrentLocation extends StatefulWidget {
  AddCurrentLocation({Key? key}) : super(key: key);

  static final kInitialPosition = LatLng(-33.8567844, 151.213108);

  @override
  _AddCurrentLocation createState() => _AddCurrentLocation();
}

class _AddCurrentLocation extends State<AddCurrentLocation> {
  String selectedChoice = "";
  final Completer<GoogleMapController> _controller = Completer();
  var currentLocation;
  String latitude = "", longitude = "";
  final Set<Marker> markers = {};
  final Set<Circle> locationRadius = {};

  // Location variables
  loc.Location location = loc.Location();
  bool _serviceEnabled = false;
  PermissionStatus _permissionGranted = PermissionStatus.denied;
  late LocationData _locationData;

  bool isLoading = true;
  LatLng? placeLocation;
  String? placeDetail;
  late Timer timer;
  bool isConnected = true;
  double lat = 0.0, long = 0.0;

  TextEditingController _locationController = TextEditingController();

  List<int> radiusKm = [1, 5, 10, 20, 50];
  int selectedKm = 1;

  LocationResult? locationResult;
  OverlayEntry? overlayEntry;

  PickResult? selectedPlace;

  @override
  void initState() {
    super.initState();
    checkConnection();
    locationPermission();
    timer = Timer.periodic(Duration(seconds: 10), (timer) => checkConnection());
  }

  _getAddressFromLatLng() async {
    try {
      final placemarks = await placemarkFromCoordinates(
        _locationData.latitude!,
        _locationData.longitude!,
      );

      var first = placemarks.first;
      print("${first.name} : ${first.street}, ${first.locality}");

      if (mounted) {
        await http
            .get(Uri.parse("https://maps.googleapis.com/maps/api/geocode/json?" +
                "latlng=${_locationData.latitude},${_locationData.longitude}&" +
                "key=$apiKEY"))
            .then((response) {
          if (response.statusCode == 200) {
            var responseJson = jsonDecode(response.body)["results"];
            if (responseJson.isNotEmpty) {
              placeDetail = "${responseJson[0]["formatted_address"]} ";
              print(placeDetail);
              if (mounted) setState(() {});
            }
          }
        }).catchError((error) {
          print(error);
        });

        setState(() {
          lat = _locationData.latitude ?? 0.0;
          long = _locationData.longitude ?? 0.0;

          placeLocation = LatLng(lat, long);
          markers.add(Marker(
            position: LatLng(lat, long),
            markerId: const MarkerId("selected-location"),
          ));
          locationRadius.add(Circle(
            circleId: const CircleId("id"),
            strokeColor: Colors.blue.withOpacity(.8),
            strokeWidth: 1,
            fillColor: Colors.blue.withOpacity(.2),
            radius: selectedKm.toDouble() * 1000,
            center: LatLng(lat, long),
          ));
        });
      }
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
      Navigator.of(context).pop(false);
    }

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> locationPermission() async {
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        Navigator.pop(context);
        return;
      }
    }
    await permissionGranted();
  }

  Future<void> permissionGranted() async {
    _permissionGranted = await location.hasPermission();

    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        Fluttertoast.showToast(msg: "Location permission not granted");
        Navigator.of(context).pop(false);
        await location.hasPermission();
        await appHandler.openAppSettings();
        return;
      }
    }

    _locationData = await location.getLocation();
    _getAddressFromLatLng();
  }

  Future<void> checkConnection() async {
    try {
      var result = await InternetAddress.lookup("google.com");
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        if (mounted) {
          setState(() {
            isConnected = true;
          });
        }
      }
    } on SocketException catch (_) {
      if (mounted) {
        setState(() {
          isConnected = false;
        });
      }
    }
  }

  List<Widget> radiusBox(BuildContext context) {
    List<Widget> items = <Widget>[];
    for (var element in radiusKm) {
      items.add(InkWell(
        onTap: () {
          setState(() {
            selectedKm = element;

            // Update circle radius when selection changes
            if (placeLocation != null) {
              locationRadius.clear();
              locationRadius.add(Circle(
                circleId: const CircleId("id"),
                strokeColor: Colors.blue.withOpacity(.8),
                strokeWidth: 1,
                fillColor: Colors.blue.withOpacity(.2),
                radius: selectedKm.toDouble() * 1000,
                center: placeLocation!,
              ));
            }
          });
        },
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 3.0),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10.0),
          decoration: BoxDecoration(
              color: selectedKm == element
                  ? MaterialTools.basicColor.withOpacity(0.5)
                  : Colors.white,
              border: Border.all(
                  color: selectedKm == element
                      ? MaterialTools.basicColor.withOpacity(0.5)
                      : Colors.black45,
                  width: 1.0)),
          child: Text(
            "${element.toString()} Km",
            style: const TextStyle(
                color: Colors.black, fontWeight: FontWeight.w700, fontSize: 14),
          ),
        ),
      ));
    }

    return items;
  }

  Widget mainScreen(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 5,
            child: SingleChildScrollView(
              child: Padding(
                padding:
                    const EdgeInsets.only(left: 10.0, right: 10.0, top: 10.0),
                child: Column(
                  children: <Widget>[
                    LocationPicker(
                      resizeToAvoidBottomInset: false,
                      // only works in page mode, less flickery
                      apiKey: apiKEY,
                      hintText: "Find a place ...",
                      searchingText: "Please wait ...",
                      selectText: "Select place",
                      outsideOfPickAreaText: "Place not in area",
                      // initialPosition: HomePage.kInitialPosition,
                      useCurrentLocation: true,
                      selectInitialPosition: true,
                      usePinPointingSearch: true,
                      usePlaceDetailSearch: true,
                      zoomGesturesEnabled: true,
                      zoomControlsEnabled: true,
                      ignoreLocationPermissionErrors: true,
                      onMapCreated: (GoogleMapController controller) {
                        print("Map created");
                      },
                      onPlacePicked: (PickResult result) {
                        print("Place picked: ${result.formattedAddress}");
                        setState(() {
                          selectedPlace = result;
                          Navigator.of(context).pop();
                        });
                      },
                      onMapTypeChanged: (MapType mapType) {
                        print("Map type changed to ${mapType.toString()}");
                      },
                      initialPosition: AddCurrentLocation.kInitialPosition,
                    ),
                    const SizedBox(height: 10),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Notification Radius:"),
                        const SizedBox(height: 8),
                        Wrap(
                          children: radiusBox(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.45,
                      child: Stack(
                        children: [
                          GoogleMap(
                            mapType: MapType.normal,
                            myLocationEnabled: true,
                            myLocationButtonEnabled: true,
                            markers: markers,
                            initialCameraPosition: CameraPosition(
                              target: LatLng(lat, long),
                              zoom: 11.77,
                            ),
                            // For google_maps_flutter: ^2.12.1
                            gestureRecognizers: <Factory<
                                OneSequenceGestureRecognizer>>{
                              Factory<OneSequenceGestureRecognizer>(
                                () => EagerGestureRecognizer(),
                              ),
                            },
                            onTap: (latLng) {
                              placeLocation = latLng;
                              clearOverlay();
                              moveToLocation(latLng);
                            },
                            onMapCreated: (GoogleMapController controller) {
                              _controller.complete(controller);
                            },
                            circles: locationRadius,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text("Save location as "),
                        Icon(Icons.star, size: 15, color: Colors.red),
                      ],
                    ),
                    TextFormField(
                      decoration: const InputDecoration(
                        hintText: 'Ex: Home, Office, etc',
                      ),
                      textCapitalization: TextCapitalization.sentences,
                      keyboardType: TextInputType.text,
                      maxLines: 1,
                      controller: _locationController,
                    ),
                    const SizedBox(height: 10.0),
                  ],
                ),
              ),
            ),
          ),
          MaterialButton(
            height: 60,
            minWidth: double.infinity,
            color: const Color(0xff3c908d),
            onPressed: () {
              if (_locationController.text.isEmpty) {
                CommonWidgets.alertBox(
                    context, "Please enter the location named to be saved",
                    leaveThatPage: false);
              } else {
                addLocationCall();
              }
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text(
                  "Add Location ",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                Icon(Icons.arrow_forward, color: Colors.white),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Move Marker to Location
  void moveToLocation(LatLng latLng) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(latLng.latitude, latLng.longitude),
          zoom: 15.0,
        ),
      ),
    );

    try {
      final placemarks = await placemarkFromCoordinates(
        latLng.latitude,
        latLng.longitude,
      );

      var first = placemarks.first;
      print("${first.name} : ${first.thoroughfare}, ${first.locality}");

      if (mounted) {
        await http
            .get(Uri.parse(
                "https://maps.googleapis.com/maps/api/geocode/json?" +
                    "latlng=${latLng.latitude},${latLng.longitude}&" +
                    "key=$apiKEY"))
            .then((response) {
          if (response.statusCode == 200) {
            var responseJson = jsonDecode(response.body)["results"];
            if (responseJson.isNotEmpty) {
              placeDetail = "${responseJson[0]["formatted_address"]} ";
              if (mounted) setState(() {});
            }
          }
        }).catchError((error) {
          print(error);
        });

        setState(() {
          lat = latLng.latitude;
          long = latLng.longitude;
          placeLocation = LatLng(latLng.latitude, latLng.longitude);
          markers.clear();
          markers.add(Marker(
            position: LatLng(latLng.latitude, latLng.longitude),
            markerId: const MarkerId("selected-location"),
          ));

          locationRadius.clear();
          locationRadius.add(Circle(
            circleId: const CircleId("id"),
            strokeColor: Colors.blue.withOpacity(.8),
            strokeWidth: 1,
            fillColor: Colors.blue.withOpacity(.2),
            radius: selectedKm.toDouble() * 1000,
            center: latLng,
          ));
        });
      }
    } catch (e) {
      print(e);
    }
    reverseGeocodeLatLng(latLng);
  }

  void clearOverlay() {
    if (overlayEntry != null) {
      overlayEntry!.remove();
      overlayEntry = null;
    }
  }

  void reverseGeocodeLatLng(LatLng latLng) {
    http
        .get(Uri.parse("https://maps.googleapis.com/maps/api/geocode/json?" +
            "latlng=${latLng.latitude},${latLng.longitude}&" +
            "key=$apiKEY"))
        .then((response) {
      if (response.statusCode == 200) {
        Map<String, dynamic> responseJson = jsonDecode(response.body);

        if (responseJson['results'].isNotEmpty) {
          final result = responseJson['results'][0];

          String road = '';
          String locality = '';

          if (result['address_components'].isNotEmpty) {
            road = result['address_components'][0]['short_name'] ?? '';
            if (result['address_components'].length > 1) {
              locality = result['address_components'][1]['short_name'] ?? '';
            }
          }

          if (mounted) {
            setState(() {
              locationResult = LocationResult(
                name: road,
                locality: locality,
                latLng: latLng,
                formattedAddress: result['formatted_address'] ?? '',
                placeId: result['place_id'] ?? '',
              );
            });
          }
        }
      }
    }).catchError((error) {
      print(error);
    });
  }

  Future<bool> _onWillPop() async {
    Navigator.of(context).pop(false);
    return Future.value(false);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          iconTheme: const IconThemeData(color: Colors.black),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => _onWillPop(),
          ),
          title: const Text(
            "Add a location from map",
            style: TextStyle(color: Colors.teal, fontWeight: FontWeight.w600),
          ),
          elevation: 5.0,
        ),
        body: !isConnected
            ? NoConnection(notifyParent: locationPermission, key: UniqueKey())
            : isLoading
                ? CommonWidgets.progressIndicator(context)
                : mainScreen(context),
      ),
    );
  }

  Future<void> addLocationCall() async {
    Map<String, dynamic> data = {
      "name": _locationController.text,
      "lat": lat,
      "lon": long,
      "range": selectedKm.toDouble() * 1000,
      "place": placeDetail ?? '',
    };

    var response = await ApiCall.makePostRequestToken('user/savelocation',
        paramsData: data);
    var responseBody = json.decode(response.body);

    if (responseBody["status"]) {
      Navigator.of(context).pop(true);
    } else {
      Fluttertoast.showToast(
          msg: responseBody["msg"] ?? "Error saving location");
    }
  }

  @override
  void dispose() {
    timer.cancel();
    _locationController.dispose();
    super.dispose();
  }
}

// Updated LocationResult class
class LocationResult {
  final String name; // or road
  final String locality;
  final LatLng latLng;
  final String formattedAddress;
  final String placeId;

  LocationResult({
    required this.name,
    required this.locality,
    required this.latLng,
    required this.formattedAddress,
    required this.placeId,
  });
}
