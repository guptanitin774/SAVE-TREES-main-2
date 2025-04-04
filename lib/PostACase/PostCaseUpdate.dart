import 'dart:convert';
import 'dart:io';

import 'package:circular_check_box/circular_check_box.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:naturesociety_new/BottomNavigation/BuildCamera.dart';
import 'package:naturesociety_new/CaseView/CaseDetailedView.dart';
import 'package:naturesociety_new/ImageGallery/SinglePhotoView.dart';
import 'package:naturesociety_new/Utils/LocalPrefManager.dart';
import 'package:naturesociety_new/Utils/NetworkCall.dart';
import 'package:naturesociety_new/Widgets/CommonWidgets.dart';
import 'package:naturesociety_new/Widgets/Redux.dart';
import 'package:naturesociety_new/Widgets/UploadingLoader.dart';
import 'package:permission_handler/permission_handler.dart' as appHandler;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class PostCaseUpdate extends StatefulWidget {
  final similarCaseId;
  PostCaseUpdate(this.similarCaseId);
  _PostCaseUpdate createState() => _PostCaseUpdate();
}

class _PostCaseUpdate extends State<PostCaseUpdate> {
  bool isConnected = true, isLoading = true;
  List<TreeCutReasons> reasonsList = [];

  @override
  void initState() {
    super.initState();
    locationPermission();
  }

  Location location = new Location();
  bool _serviceEnabled;
  PermissionStatus _permissionGranted;
  LocationData _locationData;

  locationPermission() async {
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
    Future.delayed(const Duration(milliseconds: 100), () async {
      initialCameraAction();
      setDefaultUser();
    });
  }

  initialCameraAction() async {
    StoreProvider.of<AppState>(context).dispatch(CameraPhotosCount(1));
    try {
      fileList = await Navigator.push(context,
          MaterialPageRoute(builder: (context) => TakePictureScreen()));
      if (mounted)
        Future.delayed(const Duration(milliseconds: 500), () async {
          if (fileList.isNotEmpty) {
            for (int i = 0; i < fileList.length; i++) photos.add(fileList[i]);
            setState(() {});
          }
        });
    } catch (e) {
      Fluttertoast.showToast(msg: "Case Post Cancelled");
    }

    if (fileList == null || fileList.isEmpty)
      Navigator.of(context).pop(null);
    else {
      getCaseId();
      getLocationDetails();
      reasonsList.add(TreeCutReasons(
          "1", "Nearby trees have been cut or are being cut", false));
      reasonsList.add(TreeCutReasons(
          "2", "Construction happening near the tree(s)", false));
      reasonsList.add(TreeCutReasons(
          "3", "Permit has been issued for cutting the tree(s)", false));
      reasonsList.add(TreeCutReasons("4", "Other reason", false));
    }
  }

  Map profileDetails;
  var userName = "";

  Future<void> setDefaultUser() async {
    userName = await LocalPrefManager.getUserName();
    bool anonymous = await LocalPrefManager.getAnonymity();
    if (anonymous || anonymous == null)
      selectedUserType = "Anonymous";
    else{
      if(userName == "" || userName == null)
        selectedUserType = "Anonymous";
      else
        selectedUserType = userName;
    }
    setState(() {});
  }

  List postReason = [];
  var photos = [];

  Future<bool> _onWillPop() async {
    CommonWidgets.alertBoxWithOption(
        context, "Are you sure to cancel posting update?",
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
            icon: Icon(Icons.arrow_back),
            onPressed: () => _onWillPop(),
          ),
          iconTheme: IconThemeData(color: Colors.black),
          title:  Text("Update Case", style: TextStyle(color: Colors.black),),

        ),
        body: !isLoading
            ? StoreConnector<AppState, AppState>(
            converter: (store) => store.state,
            builder: (context, state) {
              return SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  scrollDirection: Axis.vertical,
                  child: Column(
                    children: <Widget>[
                      Container(
                        padding:
                            EdgeInsets.symmetric(vertical: 10.0, horizontal: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            casePhotos(context),
                            Divider(
                              height: 20.0,
                              thickness: 1.0,
                            ),
                            locationPlot(context),
                            Divider(
                              height: 20.0,
                              thickness: 1.0,
                            ),
                            optionSelection(context),
                          ],
                        ),
                      ),
                      MaterialButton(
                        height: 70.0,
                        color: Colors.teal,
                        onPressed: () async {
                          bool okStatus = true;
                          if (fileList.isEmpty)
                            CommonWidgets.alertBox(context,
                                "Sorry, Photos must be added for case verification",
                                leaveThatPage: false);
                          else if (fileList.length > 8)
                            CommonWidgets.alertBox(
                                context, "Sorry, Max photos limit to upload is 8",
                                leaveThatPage: false);
                          else if (optionSelected.isEmpty)
                            CommonWidgets.alertBox(
                                context, "Please choose the option",
                                leaveThatPage: false);
                          else {
                            for (int i = 0; i < optionSelected.length; i++) {
                              if (optionSelected[i].name == "Tree Is Being Cut / Damaged")
                                beenCut = optionSelected[i].count;
                              else if (optionSelected[i].name ==
                                  "Tree Has Been Cut / Damaged")
                                haveBeenCut = optionSelected[i].count;
                              else if (optionSelected[i].name == "Tree Might Be Cut / Damaged")
                           {     if (selectedReason.isEmpty)
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

                            okStatus
                              //  ? Fluttertoast.showToast(msg: "Sucess")
                                ? redirect()
                                : CommonWidgets.alertBox(context,
                                    "Please select why you think Tree might be cut!",
                                    leaveThatPage: false);
                          }
                        },
                        textColor: Colors.white,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              "UPDATE CASE ",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text("as " + selectedUserType)
                          ],
                        ),
                      ),
                    ],
                  ),
                );}
            )
            : Center(
                child: CircularProgressIndicator(),
              ),
      ),
    );
  }

  List<File> fileList = new List();

  Widget casePhotos(BuildContext context) {
    return  StoreConnector<AppState, AppState>(
        converter: (store) => store.state,
        builder: (context, state) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            "Photos (${fileList.length})",
            style: TextStyle(color: Colors.black54, fontSize: 14),
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
              itemBuilder: (context, index) {
                if (index == fileList.length) {
                  return Container(
                    height: 200,
                    width: 200,
                    padding: const EdgeInsets.all(3.0),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.blueGrey),
                      borderRadius: BorderRadius.all(Radius.circular(5.0)),
                    ),
                    child: InkWell(
                      onTap: () async {
                        List<File> returnFileList = new List();
                        try {
                          returnFileList = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => TakePictureScreen()));
                          if (returnFileList.isNotEmpty) if (mounted)
                            for (int i = 0; i < returnFileList.length; i++) {
                              fileList.add(returnFileList[i]);
                              photos.add(returnFileList[i]);
                            }
                          setState(() {});
                        } catch (e) {
                          Fluttertoast.showToast(msg: e);
                        }
                      },
                      child: Stack(
                        alignment: Alignment.center,
                        children: <Widget>[
                          Opacity(
                              opacity: 1,
                              child: Icon(
                                Icons.photo_camera,
                                color: Colors.grey,
                                size: 50,
                              )),
                          Align(
                            alignment: Alignment.center,
                            child: CircleAvatar(
                              radius: 10,
                              backgroundColor: Colors.blue,
                              child: Icon(
                                Icons.add,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return Stack(
                  children: <Widget>[
                    GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(
                          builder: (context) =>
                                  SinglePhotoView(fileList, initialIndex: index,))),
                      child: Container(
                          padding: const EdgeInsets.all(3.0),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.blueGrey),
                            borderRadius: BorderRadius.all(Radius.circular(5.0)),
                          ),
                          height: double.infinity,
                          width: double.infinity,
                          child: ClipRRect(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(5.0)),
                              child: Image.file(
                                fileList[index],
                                fit: BoxFit.cover,
                              ))),
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
                          child: Icon(
                            Icons.cancel,
                            color: Colors.teal,
                          ),
                        ),
                      ),
                    )
                  ],
                );
              }),
        ],
      );}
    );
  }

  var lat, lon;
   var placeDetails;
  final Set<Marker> markers = Set();

  void getLocationDetails() async {
    setState(() {
      isLoading = true;
    });
    try {

      markers.add(Marker(
        position: LatLng(_locationData.latitude, _locationData.longitude),
        markerId: MarkerId("selected-location"),));

      http
          .get("https://maps.googleapis.com/maps/api/geocode/json?" +
          "latlng=${_locationData.latitude},${_locationData.longitude}&" +
          "key=AIzaSyCaccNxbzwR9tMvkppT7bT7zNKjChc_yAw")
          .then((response) {
        if (response.statusCode == 200) {
          var responseJson = jsonDecode(response.body)["results"];

          placeDetails =  "${responseJson[0]["formatted_address"]} ";
          if(mounted)
            setState(() {});

          print(placeDetails);
        }
      }).catchError((error) {
        print(error);
      });
    } on PlatformException catch (e) {
      print(e);
      Fluttertoast.showToast(msg: "Failed to fetch your location");
      Navigator.of(context).pop(null);
    }
    isLoading = false;
    setState(() {});
  }

  Widget locationPlot(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text("Location", style: TextStyle(color: Colors.black54, fontSize: 14)),

        SizedBox(
          height: 3.0,
        ),
        isConnected
            ? Text(placeDetails ?? " ", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600), )
            : SizedBox.shrink(),
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
  final nameHolder = TextEditingController();

  Widget optionSelection(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          "Please select the options that best describe the situation:",
          style: TextStyle( fontWeight: FontWeight.w600, color: Colors.black54, fontSize: 14),
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
                    setState(() {});
                  },
                  child: Icon(
                    Icons.cancel,
                    size: 25.0,
                  ),
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
                  child:Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Icon(Icons.add, color: Colors.teal,size: 18,),
                      Text(
                        " Add a description",
                        style: TextStyle(color: Colors.teal, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  elevation: 0.0,
                  height: 50,
                  color: Colors.teal.withOpacity(0.2),
                ),
              )
            : TextFormField(
                decoration: new InputDecoration(
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black, width: 1.0),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black, width: 1.0),
                    ),
                    labelText: 'Enter a short Description',
                    labelStyle: TextStyle(
                      color: Color(0xff3c908d),
                    )),
                controller: nameHolder,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                textCapitalization: TextCapitalization.sentences,
              ),

        userName == "" || userName == null ?
        SizedBox.shrink():
        Divider(height: 20.0, thickness: 2.0,),

        SizedBox(height: userName == "" || userName == null ?
       0.0 : 15.0,),
        userName == "" || userName == null ?
        SizedBox.shrink():
        Center(child: Text("I want to post this case as:", textAlign:  TextAlign.center, style: TextStyle(fontSize: 14),)),


        userName == "" || userName == null ? SizedBox.shrink(): Center(
          child: Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: <Widget>[

              userName == "" || userName == null ? SizedBox.shrink():  Radio(
                value: userName,
                groupValue: selectedUserType,
                onChanged: radioButtonChanges,
              ),
              userName == "" || userName == null ? SizedBox.shrink(): GestureDetector(
                onTap: () => radioButtonChanges(userName),
                child: Text(
                  userName, maxLines: 3, overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(height: 8.0,),
              Radio(
                value: 'Anonymous',
                groupValue: selectedUserType,
                onChanged: radioButtonChanges,
              ),
              GestureDetector(
                onTap: ()=> radioButtonChanges("Anonymous"),
                child: Text(
                  "Anonymous", maxLines: 3,overflow: TextOverflow.ellipsis,
                ),
              ),

            ],
          ),
        ),
      ],
    );
  }
  String choice;
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
          choice = null;
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
          CircularCheckBox(
            value: reasonsList[i].selected,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            onChanged: (bool val) {
              setState(() {
                if (reasonsList[i].selected)
                  reasonsList[i].setter(false);
                else
                  reasonsList[i].setter(true);

                val
                    ? selectedReason.add(reasonsList[i])
                    : selectedReason.remove(reasonsList[i]);
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
                    reasonsList[i].selected = ! reasonsList[i].selected;
                    reasonsList[i].selected
                        ? selectedReason.add(reasonsList[i])
                        : selectedReason.remove(reasonsList[i]);
                  });
                },
                child: Text(
            reasonsList[i].reasons,
            style: TextStyle(fontWeight: reasonsList[i].selected ? FontWeight.bold : FontWeight.normal, fontSize: 12),
          ),
              )),
        ],
      ));
    return listItems;
  }

  List postUserType = [];
  String selectedUserType;



  List treeCutOptions = [
    TreeCutOptions(Colors.redAccent, "Tree Is Being Cut / Damaged", 0, false),
    TreeCutOptions(Colors.orangeAccent, "Tree Might Be Cut / Damaged", 0, false),
    TreeCutOptions(Colors.black54, "Tree Has Been Cut / Damaged", 0, false),
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
              margin: EdgeInsets.symmetric(vertical: 10.0),
              decoration: BoxDecoration(
                  border: Border.all(
                      width: 1,
                      color: treeCutOptions[i].selected
                          ? Colors.amber
                          : Colors.black)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    flex: 3,
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(vertical: 20.0, horizontal: 5.0),
                      color: treeCutOptions[i].selected
                          ? Colors.orangeAccent.withOpacity(.5)
                          : Colors.white,
                      //width: MediaQuery.of(context).size.width / 2  ,
                      child: Row(
                        children: <Widget>[
                          CircleAvatar(
                            radius: 8,
                            backgroundColor: treeCutOptions[i].activeColor,
                          ),
                          SizedBox(
                            width: 10.0,
                          ),

                              Expanded(
                                flex: 1,
                                child: Text(treeCutOptions[i].name, maxLines: 2,style: TextStyle(fontSize: 12),
                                    overflow: TextOverflow.ellipsis),
                              )
//                          )
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
                                  size: 20,
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
                              FittedBox(
                                fit:  BoxFit.fitWidth,
                                child: SizedBox(
                                  width: 30,
                                 child: IgnorePointer(
                                    ignoring:   treeCutOptions[i].selected ? false : true,

                                    child: TextFormField(
                                      textAlign: TextAlign.center,
                                      textAlignVertical: TextAlignVertical.center,

                                      controller: cutCount[i],
                                      maxLength: 4,
                                      maxLengthEnforced: true,
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
                                        treeCutOptions[i].count =
                                            int.parse(val.toString());
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
                              IconButton(
                                icon: Icon(
                                  Icons.add,
                                  size: 20,
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
                      child: Column(
                        children: _builder(context),
                      ),
                    ),
                  ],
                )
              : SizedBox.shrink()
        ],
      ));
    }

    return cutOptionListItem;
  }

  var caseId;
  bool caseIdLoading = true;
  Future<void> getCaseId() async {
    CustomResponse response =
        await ApiCall.makeGetRequestToken('incident/getcaseid');
    if (response.status == 200) if (json.decode(response.body)["status"])
      setState(() {
        caseId = json.decode(response.body)["caseid"];
        caseIdLoading = false;
      });
    else
      Fluttertoast.showToast(msg: "Something went wrong!");
    else {
      Fluttertoast.showToast(msg: "No Network Connection");
      Navigator.of(context).pop(false);
    }
  }

  int mightBeCut = 0, beenCut = 0, haveBeenCut = 0;

  void uploadIncident() async {

    Map data={
          "isupdate": false,
          "isanonymous": selectedUserType == "Anonymous" ? true : false,
          "locationname": placeDetails,
          "lat": _locationData.latitude,
          "lon": _locationData.longitude,
          "caseid": caseId,
          "description": nameHolder.text,
          "mightbecutreason": postReason,
          "mightbecut": mightBeCut.toString() ?? "0",
          "beencut": beenCut.toString() ?? "0",
          "havebeencut": haveBeenCut.toString() ?? "0",
    };
    print(data.toString());


    CustomResponse response = await ApiCall.makePostRequestToken("incident/adddata", paramsData: data);
    if(response.status ==200){
      if(json.decode( response.body)["status"]){
        uploadFiles(id: json.decode(response.body)["id"], photoArray: fileList, caseId:  json.decode(response.body)["data"]['caseid'] );
      }
      else{
        Navigator.pop(context);
        CommonWidgets.alertBox(context, json.decode(response.body)['msg'],
            leaveThatPage: false);
      }
    }
    else{
      Navigator.pop(context);
      CommonWidgets.alertBox(context, response.body, leaveThatPage: false);
    }

  }

  uploadFiles({@required id, @required photoArray, @required caseId}) async {
    var request = http.MultipartRequest('POST', Uri.parse(ApiCall.webUrl + 'incident/updatephotos'));
    var to = await LocalPrefManager.getToken();

    Map<String,String> data = {
      'id':id,
    };
    request.headers.addAll({'Content-Type': 'application/form-data', 'x-auth-token': to});
    request.fields.addAll(data);

    if (photoArray != null) {
      photoArray.forEach((File file) {
        request.files.add(http.MultipartFile.fromBytes('photos', file.readAsBytesSync(), filename: file.path.split('/').last));
      });
    }
    else{}

    try {
     var  photoRequest =
      await http.Response.fromStream(await request.send());
     print(json.decode(photoRequest.body));
      if(json.decode(photoRequest.body)["status"]){
         passData = json.decode(photoRequest.body)["data"];
        postUpdate(id);
      }
      else{
        Navigator.pop(context);
        CommonWidgets.alertBox(context, json.decode(photoRequest.body)["msg"], leaveThatPage: false);
      }

    } catch (e) {
      print(e);
      Navigator.pop(context);
      Fluttertoast.showToast(msg: e.toString());
    }
  }

  var passData;


  Future<void> postUpdate(var newCaseId) async {
    Map data = {"id": newCaseId, "similarcaseid": widget.similarCaseId};
    var response = await ApiCall.makePostRequestToken("incident/markasupdate",
        paramsData: data);
    if (json.decode(response.body)['status']) {
       Navigator.pop(context);
   //   Fluttertoast.showToast(msg: 'Successfully posted your Update.');
   //    Navigator.pop(context);
   //   await CommonWidgets.updationSuccessDialog(context);
      await  CommonWidgets.updationMarkDialogCase(context, passData,widget.similarCaseId );

      // Navigator.pushReplacement(
      //     context,
      //     MaterialPageRoute(
      //         builder: (context) => CaseDetailedView(widget.similarCaseId)));
    } else {
      Navigator.pop(context);
      Fluttertoast.showToast(msg: 'Failed to Update this Case');
    }
  }
  void redirect() async{
    UploadingLoader.progressLoader(context: context, message: "Updating Case");
    uploadIncident();

  }


  var percent;
  @override
  void dispose() {
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
