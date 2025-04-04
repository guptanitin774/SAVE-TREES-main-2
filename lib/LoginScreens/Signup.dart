import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart' as loc;
import 'package:naturesociety_new/LoginScreens/Newotpverification.dart';
import 'package:naturesociety_new/Utils/LocalPrefManager.dart';
import 'package:naturesociety_new/Utils/MaterialComponets.dart';
import 'package:naturesociety_new/Widgets/CommonWidgets.dart';
import 'package:naturesociety_new/Widgets/NoConnection.dart';
import 'package:permission_handler/permission_handler.dart' as appHandler;
import '../Utils/NetworkCall.dart';

class SignUp extends StatefulWidget {
  final title;
  SignUp(this.title);
  @override
  _SignUp createState() => _SignUp();
}

class CountryCode {
  final code;
  final countryName;
  CountryCode(this.code, this.countryName);
}

class _SignUp extends State<SignUp> {
  late DateTime currentBackPressedTime;
  final formKey = GlobalKey<FormState>();
  var number;
  late CountryCode dropDownValue;
  bool isLoading = true, isConnected = true;

  late Timer timer;

  @override
  void initState() {
    super.initState();
    connectionCheck();
    locationPermission();
    timer = Timer.periodic(Duration(seconds: 3), (timer) => connectionCheck());
  }

  loc.Location location = new loc.Location();
  late bool _serviceEnabled;
  late loc.PermissionStatus _permissionGranted;
  late loc.LocationData _locationData;

  locationPermission() async {
    await LocalPrefManager.setInitialLaunch(true);
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
    print(_permissionGranted);
    if (_permissionGranted == loc.PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != loc.PermissionStatus.granted) {
        Fluttertoast.showToast(msg: "Location permission not granted");
        Navigator.pop(context);
        await location.hasPermission();
        appHandler.openAppSettings();
        return;
      }
    }
    _locationData = await location.getLocation();
    _getCurrentLocation();
  }

  var placeLocation;

  late Position position;
  var country, state, city;

  _getCurrentLocation() async {
    try {
      if (mounted) {
        final coordinates = geocoding.Location(
            latitude: _locationData.latitude!,
            longitude: _locationData.longitude!, timestamp: DateTime.timestamp());
        var addresses = await geocoding.placemarkFromCoordinates(
            coordinates.latitude, coordinates.longitude);
        var first = addresses.first;
        print("${first.name} : ${first.street}");
        placeLocation = first.country;
        country = first.country;
        state = first.administrativeArea;
        city = first.locality;
      }
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
      setState(() {
        isLoading = false;
      });
    }
    setState(() {
      isLoading = false;
    });
    callCountry();
  }

  var mobileNumber;

  Future<void> connectionCheck() async {
    try {
      var result = await InternetAddress.lookup("google.com");
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty)
        setState(() {
          isConnected = true;
        });
    } on SocketException catch (_) {
      setState(() {
        isConnected = false;
      });
    }
  }

  Widget myBody(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
            top: 40, left: 15.0, right: 15.0, bottom: 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: SizedBox(
                height: 80,
                child: DropdownSearch<CountryCode>(
                  decoratorProps: DropDownDecoratorProps(
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.all(8.0),
                      labelStyle: MaterialTools.labelStyle,
                      labelText: "COUNTRY",
                      hintText: 'COUNTRY',
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(MaterialTools.borderRadius),
                        borderSide: BorderSide(width: 1, color: Colors.black),
                      ),
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black, width: 1.0),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(MaterialTools.borderRadius),
                        borderSide: BorderSide(
                          width: MaterialTools.borderWidth,
                          style: BorderStyle.none,
                          color: MaterialTools.borderColor,
                        ),
                      ),
                    ),
                  ),
                  popupProps: PopupProps.menu(
                    showSearchBox: true,
                  ),
                  items: (filter, infiniteScrollProps) => countryArray,
                  itemAsString: (CountryCode u) => u.countryName,
                  selectedItem: dropDownValue,
                  onChanged: (CountryCode? data) {
                    setState(() {
                      dropDownValue = data!; // safely update dropDownValue with nullable type
                    });
                  },
                ),
              ),
            ),
            SizedBox(height: 20,),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Form(
                key: formKey,
                child: Column(
                  children: <Widget>[
                    TextFormField(
                      autofocus: true,
                      onSaved: (val) {
                        number = val;
                      },
                      obscureText: false,
                      keyboardType: TextInputType.phone,
                      validator: (number1) {
                        if (number1 == null || number1.isEmpty)
                          return "Please enter your Phone number";
                        else if (!_isNumeric(number1))
                          return "Please enter a valid Phone Number";
                        else if (number1.length < 5 || number1.length > 12)
                          return "Please enter a valid Phone Number";
                        else
                          return null;
                      },
                      decoration: InputDecoration(
                        enabledBorder: const OutlineInputBorder(
                            borderSide: const BorderSide(
                                color: Colors.black, width: 1.0)),
                        contentPadding: new EdgeInsets.only(
                            left: 10, right: 10, top: 25, bottom: 25),
                        labelText: "PHONE NUMBER",
                        hintText: "PHONE NUMBER",
                        hintStyle: TextStyle(color: Colors.black),
                        labelStyle: MaterialTools.labelStyle,
                        prefix: Text(dropDownValue.code + " - "),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                                MaterialTools.borderRadius),
                            borderSide: BorderSide(
                                width: MaterialTools.borderWidth,
                                style: BorderStyle.none,
                                color: MaterialTools.borderColor)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20,),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: RichText(
                text: TextSpan(
                    text: "By choosing to ${widget.title ?? " "}, you agree to the ",
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.normal,
                        fontSize: 16),
                    children: <TextSpan>[
                      TextSpan(
                        text: "Terms and Conditions ",
                        style: TextStyle(
                            color: Colors.teal,
                            fontWeight: FontWeight.w800,
                            fontSize: 16),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () async {
                            //await ApiCalls.launchInBrowser("http://leopardtechlabs.com/termsandconditions.html");
                          },
                      ),
                      TextSpan(
                        text: "and ",
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.normal,
                            fontSize: 16),
                      ),
                      TextSpan(
                        text: "Privacy Policy.",
                        style: TextStyle(
                            color: Colors.teal,
                            fontWeight: FontWeight.w800,
                            fontSize: 16),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () async {
                            //await ApiCalls.launchInBrowser("http://leopardtechlabs.com/termsandconditions.html");
                          },
                      ),
                    ]),
                textAlign: TextAlign.center,
                maxLines: 5,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(height: 30,),
            MaterialButton(
              shape: MaterialTools.materialButtonShape,
              minWidth: double.infinity,
              height: 70,
              onPressed: () => validate(),
              textColor: Colors.white,
              color: MaterialTools.basicColor,
              child: Text(
                "Continue",
                style: TextStyle(
                    fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _isNumeric(String result) {
    if (result == null) {
      return false;
    }
    return double.tryParse(result) != null;
  }

  var userId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          elevation: 0.0,
          centerTitle: true,
          title: Text(
            widget.title ?? " ",
            style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 20,
                color: Colors.teal),
          ),
        ),
        body: !isConnected
            ? NoConnection(notifyParent: connectionCheck,)
            : isLoading
            ? CommonWidgets.progressIndicator(context)
            : myBody(context));
  }

  void validate() {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => NewOtp(
                phoneNumber: number,
                prefix: dropDownValue.code,
                countryName: country,
                state: state,
                city: city,
              )));
    }
  }

  List<CountryCode> countryArray = [];

  void callCountry() async {
    setState(() {
      isLoading = true;
    });
    CustomResponse response = await ApiCall.makeGetRequestToken("country/getlist");
    if (response.status == 200) {
      if (json.decode(response.body)["status"]) {
        for (int i = 0; i < json.decode(response.body)["data"].length; i++) {
          countryArray.add(CountryCode(
              json.decode(response.body)["data"][i]["dialcode"],
              json.decode(response.body)["data"][i]["country"]));
        }
        dropDownValue = countryArray[0];
        for (int i = 0; i < countryArray.length; i++) {
          if (countryArray[i].countryName == placeLocation.toString()) {
            dropDownValue = countryArray[i];
            break;
          } else
            dropDownValue = countryArray[0];
        }
      }
    } else {
      Fluttertoast.showToast(msg: response.body);
      Navigator.pop(context);
    }

    if (mounted)
      setState(() {
        isLoading = false;
      });
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }
}