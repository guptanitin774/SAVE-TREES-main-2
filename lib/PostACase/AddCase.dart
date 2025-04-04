import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:naturesociety_new/BottomNavigation/BuildCamera.dart';
import 'package:naturesociety_new/ImageGallery/SinglePhotoView.dart';
import 'package:naturesociety_new/SimilarCases/ListSimilarCases.dart';
import 'package:naturesociety_new/Utils/LocalPrefManager.dart';

import 'package:naturesociety_new/Utils/NetworkCall.dart';
import 'package:naturesociety_new/Widgets/CommonWidgets.dart';
import 'package:naturesociety_new/Widgets/Redux.dart';
import 'package:naturesociety_new/Widgets/UploadingLoader.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart' as appHandler;
import 'package:http/http.dart' as http;
import 'package:location/location.dart' as loc;

class AddACase extends StatefulWidget {
  _AddACase createState() => _AddACase();
}

class _AddACase extends State<AddACase> {
  bool isConnected = true, isLoading = true;

  List<TreeCutReasons> reasonsList = [
    TreeCutReasons("1", "Nearby trees have been cut or are being cut", false),
    TreeCutReasons("2", "Construction happening near the tree(s)", false),
    TreeCutReasons("3", "Permit has been issued for cutting the tree(s)", false),
    TreeCutReasons("4", "Other reason", false)
  ];

  @override
  void initState() {
    super.initState();
    checkConnection();
    locationPermission();
  }


  loc.Location location = new loc.Location();
  late bool _serviceEnabled;
  late PermissionStatus _permissionGranted;
  late Position _locationData;

  locationPermission() async {
    await appHandler.Permission.camera.request();
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        Navigator.pop(context);
        return;
      }
    }
    else
      permissionGranted();
  }

  permissionGranted() async {
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
    else{
      _locationData = await Geolocator.getCurrentPosition();
      await checkConnection();
      if(isConnected)
      {
        final coordinates = LatLng(_locationData.latitude, _locationData.longitude);
        var placemarks = await placemarkFromCoordinates(_locationData.latitude, _locationData.longitude);
        var first = placemarks.first;
        print("${first.name} : ${first.street}");
        countryCaseId = first.country;
        print("${first.street} : ${first.country}");
      }
      else{}
      Future.delayed(const Duration(microseconds: 50), () async {
        await initialCameraAction();
        await setDefaultUser();
        isLoading= false;
      });
    }

    // setState(() {});
  }

var countryCaseId;
  initialCameraAction() async {
      StoreProvider.of<AppState>(context).dispatch(CameraPhotosCount(1));
    try {
      fileList = await Navigator.push(context, MaterialPageRoute(builder: (context) => TakePictureScreen()));
      if (mounted)
        Future.delayed(const Duration(milliseconds: 500), () async {
          if (fileList.isNotEmpty) {
            for (int i = 0; i < fileList.length; i++) photos.add(fileList[i]);
            setState(() {});
          }
        });
      await checkConnection();
    } catch (e) {
      Fluttertoast.showToast(msg: "Case Post Cancelled");
    }

    if (fileList == null || fileList.isEmpty)
      Navigator.of(context).pop(null);
    else {
      await checkConnection();
      if (isConnected)
        getCaseId();
      else
       {
         markers.add(Marker(
           position: LatLng(_locationData.latitude, _locationData.longitude),
           markerId: MarkerId("selected-location"),
           // icon: BitmapDescriptor.fromBytes(markerIcon),

         ));
         isConnected = false;
         isLoading = false;
         caseIdLoading = false;
         setState(() {});
       }
    }
  }

  Future<void> checkConnection() async {
    try {
      var result = await InternetAddress.lookup("google.com");
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty)
        if(mounted)
        setState(() {
          isConnected = true;
        });
    } on SocketException catch (_) {
      if(mounted)
      setState(() {
        isConnected = false;
      });
    }
  }

  late Map profileDetails;
  var userName = "";

  Future<void> setDefaultUser() async {
    userName = (await LocalPrefManager.getUserName())!;
    bool? anonymous = await LocalPrefManager.getAnonymity();
    if (anonymous! || anonymous == null)
      selectedUserType = "Anonymous";
    else{
      if(userName == "" || userName == null)
        selectedUserType = "Anonymous";
       else
         selectedUserType = userName;
    }
    setState(() {});
  }

  var lat, lon;
  late List placeMark;
  var country, stateSelected, city;

  final Set<Marker> markers = Set();

  var placeDetail;
  void getLocationDetails() async {
    setState(() {
      isLoading = true;
    });
    if (isConnected) {
      try {
        var placemarks = await placemarkFromCoordinates(_locationData.latitude, _locationData.longitude);
        var first = placemarks.first;
        print("${first.name} : ${first.street}");
        placeDetail = "${first.street}, ${first.locality}";

        markers.add(Marker(
            position: LatLng(_locationData.latitude, _locationData.longitude),
            markerId: MarkerId("selected-location"),
            // icon: BitmapDescriptor.fromBytes(markerIcon),

        ));
        country = first.country;
        stateSelected = first.administrativeArea;
        city = first.locality;

        http.get(("https://maps.googleapis.com/maps/api/geocode/json?" + "latlng=${_locationData.latitude},${_locationData.longitude}&" +
            "key=AIzaSyCaccNxbzwR9tMvkppT7bT7zNKjChc_yAw") as Uri)
            .then((response) {
          if (response.statusCode == 200) {
            var responseJson = jsonDecode(response.body)["results"];
            placeDetail =  "${responseJson[0]["formatted_address"]} ";
            print(placeDetail);
            if(mounted)
              setState(() {});

          }
        }).catchError((error) {
          print(error);
        });
      } on PlatformException catch (e) {
        print(e);
        Fluttertoast.showToast(msg: e.toString());
        Navigator.of(context).pop(null);
      }
    }
    isLoading = false;
    setState(() {});
  }

  Future<bool> _onWillPop() async {
    CommonWidgets.alertBoxWithOption(
        context, "Are you sure you want to cancel posting this Case?",
        leaveThatPage: true);
    return Future.value(false);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            automaticallyImplyLeading: true,
            leading: IconButton(
              onPressed: () => _onWillPop(),
              icon: Icon(Icons.arrow_back),
            ),
            iconTheme: IconThemeData(color: Colors.black),
            title: caseIdLoading
                ? Text(" ")
                : isConnected
                    ? Text(caseIdentifier.toString() ?? " ",
                        style: TextStyle(color: Colors.black),
                      )
                    : Text(
                        "Posting in offline mode",
                        style: TextStyle(color: Colors.black),
                      ),
          ),
          body: !isLoading
              ? mainScreen(context)
              : Center(child: CommonWidgets.progressIndicator(context))),
    );
  }

  Widget mainScreen(BuildContext context) {
    return StoreConnector<AppState, AppState>(
        converter: (store) => store.state,
        builder: (context, state) {
      return SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        scrollDirection: Axis.vertical,
        child: Column(
          children: <Widget>[
            Container(
              padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  casePhotos(context),
                  Divider(
                    height: 15.0,
                    thickness: 1.0,
                  ),
                  locationPlot(context),
                  Divider(
                    height: 15.0,
                    thickness: 1.0,
                  ),
                  optionSelection(context),
                ],
              ),
            ),
            MaterialButton(
              height: 70.0,
              color: Colors.teal,
              onPressed: () {
                bool okStatus = true, zero=true;
                optionSelected.forEach((element) {print(element.name);});
                for (int i = 0; i < optionSelected.length; i++) {
                  if(optionSelected[i].count==0){
                    zero=false;
                    CommonWidgets.alertBox(context, "Selected options must be greater than zero.",
                        leaveThatPage: false);
                    break;
                  }}
                if (fileList.isEmpty)
                  CommonWidgets.alertBox(context,
                      "Sorry, Photos must be added for case verification",
                      leaveThatPage: false);
                else if (fileList.length > 8)
                  CommonWidgets.alertBox(
                      context, "Sorry, Max photos limit to upload is 8",
                      leaveThatPage: false);
                // else if(_locationData==null){
                //   permissionGranted();
                // }
                else if(isConnected&&placeDetail==null){
                  getLocationDetails();
                }
                else if (optionSelected.isEmpty)
                  CommonWidgets.alertBox(context, "Please select the options that best describe the situation.",
                      leaveThatPage: false);
                else if(zero){
                  for (int i = 0; i < optionSelected.length; i++) {
                     if (optionSelected[i].name == "Tree Is Being Cut / Damaged")
                      beenCut = optionSelected[i].count;
                    else if (optionSelected[i].name == "Tree Has Been Cut / Damaged")
                      haveBeenCut = optionSelected[i].count;
                    else if (optionSelected[i].name == "Tree Might Be Cut / Damaged")
                    {  if (selectedReason.isEmpty)
                      okStatus = false;
                    else {
                      for (int j = 0; j < selectedReason.length; j++) {
                        postReason.add(selectedReason[j].reasons);
                      }
                      mightBeCut = optionSelected[i].count;
                      setState(() {
                        okStatus = true;
                      });
                    }}
                  }
                  okStatus ? redirect()
                      : CommonWidgets.alertBox(context, "Please select why you think Tree might be cut!", leaveThatPage: false);
                }
              },
              textColor: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Column(
                    children: [
                      Text("POST CASE ", style: TextStyle(fontWeight: FontWeight.bold),),
                      Text("as " + selectedUserType)
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );}
    );
  }

  List postReason = [];
  List<File> photos = [];
  List fileList = [];

  Widget casePhotos(BuildContext context) {
    return  StoreConnector<AppState, AppState>(
        converter: (store) => store.state,
        builder: (context, state) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text("Photos (${fileList.length})", style: TextStyle(color: Colors.black54, fontSize: 16),
          ),
          SizedBox(
            height: 10.0,
          ),
          GridView.builder(
              physics: NeverScrollableScrollPhysics(),
              itemCount: fileList.length + 1,
              shrinkWrap: true,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  mainAxisSpacing: 8.0, crossAxisSpacing: 8.0, crossAxisCount: 3),
              itemBuilder: (BuildContext context, index) {
                if (index == fileList.length) {
                  return fileList.length < 8
                      ? Container(
                          height: 200,
                          width: 200,
                          padding: const EdgeInsets.all(3.0),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.blueGrey),
                            borderRadius: BorderRadius.all(Radius.circular(5.0)),
                          ),
                          child: InkWell(
                            onTap: () async {
                              List<dynamic> returnFileList = [];
                              try {
                                returnFileList = await Navigator.push(context,
                                    MaterialPageRoute(builder: (context) => TakePictureScreen()));
                                if (returnFileList.isNotEmpty) if (mounted)
                                  for (int i = 0; i < returnFileList.length; i++) {
                                    fileList.add(returnFileList[i]);
                                    photos.add(returnFileList[i]);
                                  }
                                setState(() {});
                              } catch (e) {
                                Fluttertoast.showToast(msg: e.toString());
                              }
                            },
                            child: ClipRRect(
                              borderRadius: BorderRadius.all(Radius.circular(5.0)),
                              child: Stack(
                                alignment: Alignment.center,
                                children: <Widget>[
                                  Opacity(
                                      opacity: 1,
                                      child: Icon(Icons.photo_camera, color: Colors.grey, size: 50,)),
                                  Align(
                                    alignment: Alignment.center,
                                    child: CircleAvatar(
                                      radius: 10,
                                      backgroundColor: Colors.blue,
                                      child: Icon(Icons.add, color: Colors.white, size: 20,),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      : SizedBox.shrink();
                }
                return Stack(
                  children: <Widget>[
                    GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(
                              builder: (context) => SinglePhotoView(fileList, initialIndex: index,))),
                      child: Container(
                          height: double.infinity,
                          width: double.infinity,
                          padding: const EdgeInsets.all(3.0),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.blueGrey),
                            borderRadius: BorderRadius.all(Radius.circular(5.0)),
                          ),
                          child: ClipRRect(
                              borderRadius: BorderRadius.all(Radius.circular(5.0)),
                              child: Image.file(fileList[index], fit: BoxFit.cover,))),
                    ),
                    Align(
                      alignment: Alignment.topRight,
                      child: GestureDetector(
                        onTap: () {
                          StoreProvider.of<AppState>(context).dispatch(CameraPhotosCount(state.cameraPhotosCount -1));
                          fileList.removeAt(index);
                          photos.removeAt(index);
                          setState(() {});
                        },
                        child: CircleAvatar(
                          radius: 15.0,
                          backgroundColor: Colors.white,
                          child: Icon(Icons.cancel, color: Colors.teal,),
                        ),
                      ),
                    ),

                  ],
                );
              }),
          !isConnected
              ? SizedBox(
                  height: 8.0,
                )
              : SizedBox.shrink(),
          !isConnected
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Icon(Icons.info, color: Colors.redAccent, size: 12.0,),
                    SizedBox(width: 5.0,),
                    Text("Note:", style: TextStyle(color: Colors.black54, fontSize: 11.5, fontWeight: FontWeight.bold),),
                    SizedBox(width: 5.0,),

                    Expanded(flex: 3,
                        child: Text(
                          "Case will be saved locally. You can upload the case from the More button when you have an internet connection.",
//                          "Case will be saved locally. Minimise the photos to avoid using more phone storage.",
                          style: TextStyle(color: Colors.black54, fontSize: 11.5), maxLines: 3, overflow: TextOverflow.ellipsis,
                        )),
                  ],
                )
              : SizedBox.shrink()
        ],
      );}
    );
  }

  Widget locationPlot(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text("Location", style: TextStyle(color: Colors.black54, fontSize: 16),),

        SizedBox(height: 5.0,),

        isConnected ? Text(placeDetail ?? " ", style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),) : SizedBox.shrink(),
        SizedBox(
          height: 8.0,
        ),
        Container(
          height: 300,
          width: MediaQuery.of(context).size.width,
          child: GoogleMap(
            mapType: MapType.normal,
            zoomGesturesEnabled: true,
            tiltGesturesEnabled: false,
            scrollGesturesEnabled: true,
            markers: markers,
            gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>[
              new Factory<OneSequenceGestureRecognizer>(() => new ScaleGestureRecognizer(),),
            ].toSet(),

            initialCameraPosition: CameraPosition(
              target: LatLng(_locationData.latitude, _locationData.longitude),
              zoom: 15.77,
            ),
          ),
        ),
      ],
    );
  }

  bool descriptionEnabled = false;
  var description;

  TextEditingController nameHolder = TextEditingController();

  bool beeCut = false, mightCut = false, hasCut = false;
  int beingCutCount = 1, mightCutCount = 1, hasCutCount = 1;

  Widget optionSelection(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          "Please select the options that best describe the situation:",
          style: TextStyle( fontWeight: FontWeight.w600, color: Colors.black54, fontSize: 16),
          textAlign: TextAlign.left,
        ),
        SizedBox(
          height: 10.0,
        ),
        Column(
          children: _cutOptionsBuilder(context),
        ),
        SizedBox(
          height: 15.0,
        ),
        descriptionEnabled
            ? Align(
                alignment: Alignment.topRight,
                child: GestureDetector(
                  onTap: () {
                    descriptionEnabled = false;
                    nameHolder.clear();
                    setState(() {});
                  },
                  child: Icon(Icons.cancel, size: 25.0,),
                ))
            : SizedBox.shrink(),

        !descriptionEnabled
            ? Center(
                child: MaterialButton(
                  shape: RoundedRectangleBorder(
                    side: BorderSide(width: 2, color: Colors.teal)
                  ),
                  onPressed: () {
                    setState(() {
                      descriptionEnabled = true;
                    });
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Icon(Icons.add, color: Colors.teal,size: 18,),
                      Text(" Add a description", style: TextStyle(color: Colors.teal, fontWeight: FontWeight.w600),),
                    ],
                  ),
                  elevation: 0.0,
                  height: 50,
                  color: Colors.teal.withOpacity(0.2),
                ),
              )
            : TextField(
                decoration: new InputDecoration(focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black, width: 1.0)),
                    enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black, width: 1.0)),
                    labelText: 'Enter a short Description',
                    labelStyle: TextStyle(color: Color(0xff3c908d))),
                controller: nameHolder,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                textCapitalization: TextCapitalization.sentences,
              ),


        userName == "" || userName == null ?
        SizedBox.shrink():
        Divider(height: 20.0, thickness: 2.0,),

        SizedBox(height: 15.0,),
        userName == "" || userName == null ?
        SizedBox.shrink():
        Center(child: Text("I want to post this case as:", textAlign:  TextAlign.center, style: TextStyle(fontSize: 16),)),


        userName == "" || userName == null ?
        SizedBox.shrink() :
        Center(
          child: Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: <Widget>[

              userName == "" || userName == null ? SizedBox.shrink() :Radio(
                value: userName,
                groupValue: selectedUserType,
                onChanged: (String? value) {
                  if (value != null) radioButtonChanges(value);
                },
              ),
              userName == "" || userName == null ? SizedBox.shrink() :GestureDetector(
                onTap: ()=>radioButtonChanges(userName),
                child: Text(
                  userName, maxLines: 3, overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(height: 8.0,),
              Radio(
                value: 'Anonymous',
                groupValue: selectedUserType,
                onChanged: (String? value) {
                  if (value != null) radioButtonChanges(value);
                },
              ),
              GestureDetector(
                onTap: ()=>radioButtonChanges("Anonymous"),
                child: Text("Anonymous", maxLines: 3,overflow: TextOverflow.ellipsis,),
              ),

            ],
          ),
        ),
      ],
    );
  }

  late String choice;
  void radioButtonChanges(String value) async{
    SharedPreferences preference = await SharedPreferences.getInstance();
    setState(() {
      selectedUserType = value;
      switch (value) {
        case 'anonymous':
          choice = value;
          preference.setBool("anonymous",true);
          break;
        case 'name':
          choice = value;
          preference.setBool("anonymous",false);
          break;
        default:
          choice = '';
          preference.setBool("anonymous",true);
      }
      debugPrint(choice); //Debug the choice in console
    });
  }

  List selectedReason = [];
  _builder(BuildContext context) {
    final List<Widget> listItems = <Widget>[];
    for (int i = 0; i < reasonsList.length; i++)
      listItems.add(Row(
        children: <Widget>[
          Checkbox(
            value: reasonsList[i].selected,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            onChanged: (bool? val) {
              setState(() {
                if (reasonsList[i].selected)
                  reasonsList[i].setter(false);
                else
                  reasonsList[i].setter(true);
                val == true ? selectedReason.add(reasonsList[i]) : selectedReason.remove(reasonsList[i]);
              });
            },
          ),
          SizedBox(
            width: 5.0,
          ),
          Expanded(
              child: InkWell(
                onTap: (){
                  setState(() {
                    reasonsList[i].selected = !reasonsList[i].selected;
                    reasonsList[i].selected ? selectedReason.add(reasonsList[i]) : selectedReason.remove(reasonsList[i]);
                  });
                },
                child: Text(
            reasonsList[i].reasons,
            style: TextStyle(fontWeight: reasonsList[i].selected ? FontWeight.bold : FontWeight.normal),
          ),
              )),
        ],
      ));
    return listItems;
  }



   late String selectedUserType;


  List treeCutOptions = [
    TreeCutOptions(Colors.redAccent, "Tree Is Being Cut / Damaged", 0, false),
    TreeCutOptions(Colors.orangeAccent, "Tree Might Be Cut / Damaged", 0, false),
    TreeCutOptions(Color(0xffC3C3C3), "Tree Has Been Cut / Damaged", 0, false),
  ];

  List optionSelected = [];

  _cutOptionsBuilder(BuildContext context) {
    bool subMenuEnable = false;
    List<TextEditingController> cutCount = <TextEditingController>[];
    List<Widget> cutOptionListItem = <Widget>[];
    for (int i = 0; i < treeCutOptions.length; i++) {
      cutCount.add(TextEditingController());
      cutOptionListItem.add(Column(
        children: <Widget>[
          InkWell(
            onTap: () {
              FocusScope.of(context).unfocus();
              treeCutOptions[i].count = 1;
              cutCount[i].text = (treeCutOptions[i].count).toString();
              treeCutOptions[i].selected = !treeCutOptions[i].selected;
              if(!treeCutOptions[i].selected){
                treeCutOptions[i].count = 0;
              }

              if (treeCutOptions[i].selected) {
                optionSelected.add(treeCutOptions[i]);
                if (i == 1) subMenuEnable = subMenuEnable ? false : true;
              } else
                optionSelected.remove(treeCutOptions[i]);
              setState(() {});
            },
            child: Container(
              padding: EdgeInsets.all(0.0),
              margin: EdgeInsets.symmetric(vertical: 8.0),
              decoration: BoxDecoration(
                  border: Border.all(width: 1,
                      color: treeCutOptions[i].selected ?
                      treeCutOptions[i].name==
                          'Tree Is Being Cut / Damaged'?
                      Color(0xffE25151):
                      treeCutOptions[i].name==
                          'Tree Might Be Cut / Damaged'?
                      Color(0xffFC9941):
                      Colors.amber : Colors.black)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    flex: 2,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          vertical: 20.0, horizontal: 5.0),
                      color: treeCutOptions[i].selected
                          ?
                      treeCutOptions[i].name==
                      'Tree Is Being Cut / Damaged'?
                      Color(0xffE25151).withOpacity(0.1)
                          :
                      treeCutOptions[i].name==
                          'Tree Might Be Cut / Damaged'?
                      Color(0xffFC9941).withOpacity(0.1):
                      treeCutOptions[i].name==
                          'Tree Has Been Cut / Damaged'?
                      Colors.orangeAccent.withOpacity(.1):
                          Colors.white:
                      Colors.white,
                      // width: MediaQuery.of(context).size.width / 2,
                      child: Row(
                        children: <Widget>[
                          CircleAvatar(
                            radius: 8,
                            backgroundColor: treeCutOptions[i].activeColor,
                          ),
                          SizedBox(
                            width: 5.0,
                          ),
                          Expanded(
                              flex: 1,
                              child: Text(treeCutOptions[i].name, style: TextStyle(fontSize: 12),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis)),
                        ],
                      ),
                    ),
                  ),



                  Expanded(
                    flex: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        IconButton(

                          icon: Icon(
                            Icons.remove,
                            size: 25,
                            color: Colors.grey,
                          ),
                          onPressed: () {
                            FocusScope.of(context).unfocus();
                            if (treeCutOptions[i].count >= 1) {
                              cutCount[i].text =
                                  treeCutOptions[i].count.toString();
                              treeCutOptions[i].count--;
                              cutCount[i].text =
                                  (treeCutOptions[i].count).toString();
                              if (treeCutOptions[i].count == 0) {
                                treeCutOptions[i].selected = !treeCutOptions[i].selected;
                                optionSelected.remove(treeCutOptions[i]);
                              }
                              setState(() {});
                            }

                          },
                        ),
                        Center(
                          child: FittedBox(
                            fit:  BoxFit.fitWidth,
                            child: SizedBox(
                              width: 35,
                              child: IgnorePointer(
                               ignoring:   treeCutOptions[i].selected ? false : true,

                                child: TextFormField(
                                  textAlign: TextAlign.center,
                                  textAlignVertical: TextAlignVertical.center,

                                  controller: cutCount[i],
                                  maxLength: 4,
                                  maxLengthEnforcement: MaxLengthEnforcement.none,
                                  decoration: InputDecoration(
                                      //contentPadding: EdgeInsets.all(5),
                                      enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white),),
                                      focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white),),
                                      contentPadding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 0.0),
                                      fillColor: Colors.white,
                                      hintText: treeCutOptions[i].count.toString(),
                                      hintStyle: TextStyle(color: Colors.black)).copyWith(
                                    counter: Container()
                                  ),
                                  style: TextStyle(color: Colors.black, fontSize: 12),
                                  onChanged: (val) {
                                      treeCutOptions[i].count = int.parse(val.toString());
                                      cutCount[i].text = treeCutOptions[i].count;
                                      setState(() {});

                                  },
                                  keyboardType: TextInputType.numberWithOptions(
                                    decimal: false,
                                    signed: true,
                                  ),
                                  maxLines: 1,

                                ),
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          alignment: Alignment.center ,
                          icon: Icon(
                            Icons.add,
                            size: 25,
                            color: Colors.grey,
                          ),
                          onPressed: treeCutOptions[i].selected?  () {
                            FocusScope.of(context).unfocus();
                            cutCount[i].text =
                                treeCutOptions[i].count.toString();
                            treeCutOptions[i].count++;
                            cutCount[i].text =
                                (treeCutOptions[i].count).toString();
                            setState(() {});
                          } : null,
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
          treeCutOptions[1].selected && i == 1
              ? Column(
                  children: <Widget>[
                    SizedBox(
                      height: 10.0,
                    ),
                    Text(
                        "Select at least one reason why you think trees might be cut"),
                    SizedBox(
                      height: 5.0,
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                          vertical: 15.0, horizontal: 10.0),
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey, width: 0.5)),
                      child: Column(children: _builder(context)),
                    ),
                  ],
                )
              : SizedBox.shrink()
        ],
      ));
    }
    return cutOptionListItem;
  }

  var caseId, caseIdentifier;
  bool caseIdLoading = true;
  Future<void> getCaseId() async {
    setState(() {
      caseIdLoading = true;
    });


    CustomResponse response =
        await ApiCall.makeGetRequestToken('incident/getcaseid?country=$countryCaseId');
    if (response.status == 200) if (json.decode(response.body)["status"]) {
      caseId = json.decode(response.body)["caseid"];
      caseIdentifier = json.decode(response.body)["caseidentifier"];
      caseIdLoading = false;
      isConnected = true;
    } else {
      isConnected = true;
      Fluttertoast.showToast(msg: json.decode(response.body)["msg"]);
    }
    else {
      isConnected = false;
      caseIdLoading = false;
      Fluttertoast.showToast(msg: response.body);
    }
    if (mounted) setState(() {});

    if (isConnected) getLocationDetails();
  }

  int mightBeCut = 0, beenCut = 0, haveBeenCut = 0;

  void uploadIncident() async {

    try {
      Map data ={
        "isupdate": false,
        "isanonymous": selectedUserType == "Anonymous" ? true : false,
        "locationname": placeDetail,
        "lat": _locationData.latitude,
        "lon": _locationData.longitude,
        "caseid": caseId,
        "description": descriptionEnabled? nameHolder.text :"",
        "mightbecutreason": postReason,
        "mightbecut": mightBeCut.toString() ?? "0",
        "beencut": beenCut.toString() ?? "0",
        "havebeencut": haveBeenCut.toString() ?? "0",
        "country": country,
        "state": stateSelected,
        "city": city,
      };
      print(data.toString());

      CustomResponse response =  await ApiCall.makePostRequestToken("incident/adddata", paramsData: data);
      print(json.decode(response.body));
      returnResponse = json.decode(response.body)["data"];


      if (json.decode(response.body)['status'])
       await  addSinglePhoto(id: json.decode(response.body)["id"], photoArray: fileList, caseDetails:  json.decode(response.body)["data"] );
      else {
        Navigator.pop(context);
        CommonWidgets.alertBox(context, json.decode(response.body)['msg'],
            leaveThatPage: false);
      }
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
      Navigator.pop(context);
      print(e);
    }
  }
var returnResponse;
  Future<void> addSinglePhoto({@required id, @required photoArray, @required caseDetails}) async {
    print("Adding photo");
    var request = http.MultipartRequest('POST', Uri.parse(ApiCall.webUrl + 'incident/updatephotos'));
    var to = await LocalPrefManager.getToken();
    print(to);
    Map<String,String> data = {'id':id,};
    request.headers.addAll({'Content-Type': 'application/form-data', 'x-auth-token': to ?? ''});
    request.fields.addAll(data);
    if (photoArray != null) {
     await photoArray.forEach((File file)async {
         request.files.add( http.MultipartFile.fromBytes( 'photos', file.readAsBytesSync(), filename: file.path.split('/').last));
      });
      print(request.files);
      print(request.fields);
    }
    else{}
    try {
      var photoRequest=  await http.Response.fromStream(await request.send());
      print(json.decode(photoRequest.body)["data"]);
      var passData = json.decode(photoRequest.body)["data"];
      Navigator.pop(context);
      Navigator.pushReplacement(context, MaterialPageRoute(
              builder: (context) => SimilarCases(id, selectedUserType, passData)));
    } catch (e) {
      print(e);
      Navigator.pop(context);
      Fluttertoast.showToast(msg: e.toString());
    }
  }

  var storedValues;
  List addData = [];
  List retrievedList = [];

  Future<String> saveImage(var filePath) async {


    String aa = filePath;
    var ab = (aa.split('/'));
    final directory = await getApplicationDocumentsDirectory();
    final String path = directory.path;
    final File localImage = await File(filePath).copy('$path/${ab[ab.length - 1]}');
    print(localImage);
    return  localImage.path;
  }

  Future<void> saveLocally() async {
    List photoList = [];
    for (int i = 0; i < fileList.length; i++) {
      Map photoData = {"path": await saveImage(fileList[i].path)};
      photoList.add(photoData);
    }

    Map data = {
      "photos": photoList,
      "isupdate": false,
      "isanonymous": selectedUserType == "Anonymous" ? true : false,
      "locationname": '',
      "lat": _locationData.latitude,
      "lon": _locationData.longitude,
      "caseid": " ",
      "description":descriptionEnabled? nameHolder.text :"",
      "mightbecutreason": postReason,
      "mightbecut": mightBeCut.toString() ?? "0",
      "beencut": beenCut.toString() ?? "0",
      "havebeencut": haveBeenCut.toString() ?? "0",
      "country": country,
      "state": stateSelected,
      "city": city,
      "createddate": DateTime.now().toIso8601String(),
    };

    SharedPreferences prefs = await SharedPreferences.getInstance();
    storedValues = prefs.getString('offlineList');
    if (storedValues != null)
      retrievedList = json.decode(storedValues);
    retrievedList.add(data);

    var locallySaveData = json.encode(retrievedList);
    SharedPreferences preference2 = await SharedPreferences.getInstance();
    preference2.setString("offlineList", locallySaveData);

    SharedPreferences prefs2 = await SharedPreferences.getInstance();
    storedValues = prefs2.getString('offlineList');

    Navigator.pop(context);
    Navigator.of(context).pop(true);
    CommonWidgets.alertBox(context,
       // "Case has been saved locally. You can upload case when connected to Network from Settings.",
        "The case has been saved on your device. When you are connected to the internet, you can upload the case from the More menu.",
        leaveThatPage: false);
  }

  Future<void> redirect()async{
    UploadingLoader.progressLoader(context: context, message: "Uploading Case Details");
    await checkConnection();
    isConnected?  uploadIncident() : saveLocally();
  }



  var percent;
  @override
  void dispose() {
//    timer.cancel();
    nameHolder.dispose();
    super.dispose();
  }
}

class TreeCutReasons {
  final id;
  final reasons;
  bool selected;
  setter(selected) {
    this.selected = selected;
  }

  TreeCutReasons(this.id, this.reasons, this.selected);
}

class TreeCutOptions {
  var activeColor;
  final name;
  var count;
  bool selected;

  setter(selected) {
    this.selected = selected;
  }

  TreeCutOptions(this.activeColor, this.name, this.count, this.selected);
}
