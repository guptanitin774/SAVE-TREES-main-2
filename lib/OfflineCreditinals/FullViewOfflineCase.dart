import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:location/location.dart' as location_package;
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:flutter_swiper_null_safety/flutter_swiper_null_safety.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper_null_safety/flutter_swiper_null_safety.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:naturesociety_new/SimilarCases/ListSimilarCases.dart';
import 'package:naturesociety_new/Utils/LocalPrefManager.dart';
import 'package:naturesociety_new/Utils/MaterialComponets.dart';
import 'package:naturesociety_new/Utils/NetworkCall.dart';
import 'package:naturesociety_new/Widgets/CommonFunction.dart';
import 'package:naturesociety_new/Widgets/CommonWidgets.dart';
import 'package:naturesociety_new/Widgets/ReadMoreText.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FullViewOfflineCase extends StatefulWidget {
  final offlineCase;

  final removeIndex;
  FullViewOfflineCase(this.offlineCase, this.removeIndex);
  _FullViewOfflineCase createState() => _FullViewOfflineCase();
}

class _FullViewOfflineCase extends State<FullViewOfflineCase> {
  final Set<Marker> markers = Set();
  late Timer timer;
  @override
  void initState() {
    super.initState();
    checkConnection();
    timer = Timer.periodic(Duration(seconds: 3), (timer) => checkConnection());
    getUserName();
    print(widget.offlineCase);
    markers.add(Marker(
      position: LatLng(widget.offlineCase["lat"], widget.offlineCase["lon"]),
      markerId: MarkerId("selected-location"),
    ));

    print(isConnected);

    if(isConnected)
    Future.delayed(const Duration(milliseconds: 20), () async {
      getLocationName(widget.offlineCase["lat"], widget.offlineCase["lon"]);
    });
    else{}
    print(widget.offlineCase["description"].isEmpty);
  }

  bool isConnected = true;
  Future<void> checkConnection() async {
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

  var userName;
  void getUserName() async {
    userName = await LocalPrefManager.getUserName();
  }

  Future<bool> onWillPopScope() async {
    Navigator.of(context).pop(false);
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: onWillPopScope,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pop(true);
            },
          ),
          elevation: 5.0,
          title: Text("Pending Cases ${widget.removeIndex+1}",),
        ),
        body: SafeArea(
          child: ListView(
            physics: ClampingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
            children: <Widget>[
              Container(
                height: 200,
                width: double.infinity,
                child: Swiper(
                  itemBuilder: (BuildContext context, int k) {
                    return Image.file(
                      File(widget.offlineCase["photos"][k]["path"]),
                      fit: BoxFit.cover,
                    );
                  },
                  itemCount: widget.offlineCase["photos"].length,
                  pagination: widget.offlineCase["photos"].length > 1
                      ? SwiperPagination()
                      : SwiperPagination(builder: SwiperPagination.rect),
                  loop: false,
                  autoplay: false,
                ),
              ),
              SizedBox(
                height: 5,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text( "Posted by:", style: TextStyle(fontSize: 12,),),
                        SizedBox(height: 8.0,),
                        Text(widget.offlineCase["isanonymous"]
                            ? "Anonymous" : userName == null ? " " : userName,
                          style: TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.w800),),
                      ],
                    ),
                  ),

                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            decoration: BoxDecoration(color: Colors.white,
                                border: Border.all(color: Colors.black45),
                                borderRadius: BorderRadius.all(Radius.circular(5))),
                            padding:EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            child: Text("${ int.parse(widget.offlineCase["beencut"]) + int.parse(widget.offlineCase["mightbecut"]) +
                                int.parse(widget.offlineCase["havebeencut"])}",  textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w600),),
                          ),

                          SizedBox(width: widget.offlineCase["beencut"] =="0" ? 0:8,),
                          widget.offlineCase["beencut"] == "0"? SizedBox.shrink():Container(decoration: BoxDecoration(color: Colors.red,
                              border: Border.all(color: Colors.red),
                              borderRadius: BorderRadius.all(Radius.circular(5))),
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              child: Text(widget.offlineCase["beencut"].toString() ?? "",
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w600),)),

                          SizedBox(width: widget.offlineCase["mightbecut"] == "0" ? 0:8,),
                          widget.offlineCase["mightbecut"] == "0"? SizedBox.shrink():
                          Container( decoration: BoxDecoration(color: Colors.orange,
                              border: Border.all(color: Colors.orange),
                              borderRadius: BorderRadius.all(Radius.circular(5))),
                            padding:EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            child: Text(widget.offlineCase["mightbecut"].toString() ?? "", textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w600),),),

                          SizedBox(width: widget.offlineCase["havebeencut"] == "0" ? 0:8,),
                          widget.offlineCase["havebeencut"] == "0" ? SizedBox.shrink() : Container( decoration: BoxDecoration(
                              color: Colors.grey,
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.all(Radius.circular(5))),
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            child: Text(widget.offlineCase["havebeencut"].toString() ?? "", textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w600),),),
                        ],
                      ),
                      SizedBox(height: 8.0,),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(  CommonFunction.timeWithStatus(widget.offlineCase["createddate"]),
                            style: TextStyle(color: Colors.black, fontSize: 11.5),),
                        ],
                      ),
                    ],
                  )),
                ],
              ),

              SizedBox(height: 10,),

              Text("Location", style: TextStyle(color: Colors.black45),),

              Text(placeName ?? widget.offlineCase["lat"].toString() + ", " + widget.offlineCase["lon"].toString(),
                textAlign: TextAlign.left,
                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
              ),

              SizedBox(
                height: 5.0,
              ),
              Container(
                height: 250,
                child: GoogleMap(
                  mapType: MapType.normal,
                  zoomGesturesEnabled: true,
                  tiltGesturesEnabled: false,
                  scrollGesturesEnabled: true,

                  gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>[
                    new Factory<OneSequenceGestureRecognizer>(() => new ScaleGestureRecognizer(),),
                  ].toSet(),
                  initialCameraPosition: CameraPosition(
                    target: LatLng(
                        widget.offlineCase["lat"], widget.offlineCase["lon"]),
                    zoom: 15.77,
                  ),
                  markers: markers,
                ),
              ),
              widget.offlineCase["beencut"] != "0"
                  ? Container(
                      margin: EdgeInsets.symmetric(vertical: 5.0),
                      decoration: BoxDecoration(
                          border: Border.all(
                              width: 1.8,
                              color: Colors.redAccent.withOpacity(.2))),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Expanded(
                            flex: 3,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  vertical: 15.0, horizontal: 10.0),
                              color: Colors.redAccent.withOpacity(.2),
                              width: MediaQuery.of(context).size.width / 2 + 60,
                              child: Row(
                                children: <Widget>[
                                  CircleAvatar(
                                    radius: 8,
                                    backgroundColor: Colors.redAccent,
                                  ),
                                  SizedBox(
                                    width: 5.0,
                                  ),
                                  Expanded(
                                      flex: 3, child: Text("Tree Is Being Cut / Damaged"))
                                ],
                              ),
                            ),
                          ),
                          VerticalDivider(
                            color: Colors.amber,
                            width: 5,
                            thickness: 2.5,
                          ),
                          Expanded(
                            flex: 1,
                            child: Center(
                                child: Text(
                              widget.offlineCase["beencut"].toString() ?? " ",
                              style: TextStyle(fontWeight: FontWeight.w600),
                            )),
                          ),
                        ],
                      ),
                    )
                  : SizedBox.shrink(),
              widget.offlineCase["mightbecut"] != "0"
                  ? Container(
                      margin: EdgeInsets.symmetric(vertical: 5.0),
                      decoration: BoxDecoration(
                          border: Border.all(
                              width: 1.8, color: Colors.amber.withOpacity(.2))),
                      child: Column(
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Expanded(
                                flex: 3,
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 15.0, horizontal: 10.0),
                                  color: Colors.amber.withOpacity(.2),
                                  width: MediaQuery.of(context).size.width / 2 +
                                      60,
                                  child: Row(
                                    children: <Widget>[
                                      CircleAvatar(
                                        radius: 8,
                                        backgroundColor: Colors.orangeAccent,
                                      ),
                                      SizedBox(
                                        width: 5.0,
                                      ),
                                      Expanded(
                                          flex: 3,
                                          child: Text("Tree Might Be Cut / Damaged"))
                                    ],
                                  ),
                                ),
                              ),
                              VerticalDivider(
                                color: Colors.amber,
                                width: 5,
                                thickness: 2.5,
                              ),
                              Expanded(
                                flex: 1,
                                child: Center(
                                    child: Text(
                                  widget.offlineCase["mightbecut"].toString() ??
                                      " ",
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                )),
                              ),
                            ],
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                                vertical: 10.0, horizontal: 10.0),
                            decoration: BoxDecoration(
                                border: Border.all(
                                    width: 1.8,
                                    color: Colors.amber.withOpacity(.2)),
                                color: Colors.amber.withOpacity(.2)),
                            child: widget
                                    .offlineCase["mightbecutreason"].isNotEmpty
                                ? Column(
                                    children: mightBeCutReason(context),
                                  )
                                : SizedBox.shrink(),
                          ),
                        ],
                      ),
                    )
                  : SizedBox.shrink(),
              widget.offlineCase["havebeencut"] != "0"
                  ? Container(
                      margin: EdgeInsets.symmetric(vertical: 5.0),
                      decoration: BoxDecoration(
                          border: Border.all(
                              width: 1.8, color: Colors.grey.withOpacity(.2))),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Expanded(
                            flex: 3,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  vertical: 15.0, horizontal: 10.0),
                              color: Colors.grey.withOpacity(.2),
                              width: MediaQuery.of(context).size.width / 2 + 60,
                              child: Row(
                                children: <Widget>[
                                  CircleAvatar(
                                    radius: 8,
                                    backgroundColor: Colors.grey,
                                  ),
                                  SizedBox(
                                    width: 5.0,
                                  ),
                                  Expanded(
                                      flex: 3, child: Text("Tree Has Been Cut / Damaged"))
                                ],
                              ),
                            ),
                          ),
                          VerticalDivider(
                            color: Colors.amber,
                            width: 5,
                            thickness: 2.5,
                          ),
                          Expanded(
                            flex: 1,
                            child: Center(
                                child: Text(
                              widget.offlineCase["havebeencut"].toString() ?? " ",
                              style: TextStyle(fontWeight: FontWeight.w600),
                            )),
                          ),
                        ],
                      ),
                    )
                  : SizedBox.shrink(),
              SizedBox(height:  widget.offlineCase["description"].isNotEmpty ? 10.0: 0.0,),
              Divider(height:  widget.offlineCase["description"].isNotEmpty  ? 10.0: 0.0,thickness: 1.0,),

              widget.offlineCase["description"].isNotEmpty   ?Text("Description", style: TextStyle(color: Colors.black45), ) : SizedBox.shrink(),
              SizedBox(height:  widget.offlineCase["description"].isNotEmpty    ? 8.0: 0.0,),

              widget.offlineCase["description"].isNotEmpty ?
              Container(
                child: ReadMoreText(
                  widget.offlineCase["description"] ?? "",
                  trimLines: 5,
                  colorClickableText: Colors.teal,
                  trimMode: TrimMode.Line,
                  trimCollapsedText: ' ...  show more',
                  trimExpandedText: '   show less',
                  textAlign: TextAlign.justify,
                  style: TextStyle(color: Colors.black),
                  key: Key('readMoreText'),
                  textDirection: TextDirection.ltr,
                  locale: Locale('en'),
                  textScaleFactor: 1.0,
                  semanticsLabel: 'Read more about the description',
                ),
              )
                  : SizedBox.shrink(),

              SizedBox(
                height: 15.0,
              ),
              MaterialButton(onPressed: ()=> isConnected
                  ? uploadCase()
                  : Fluttertoast.showToast(
                  msg: "Sorry! can't connect to Network."),
                textColor: Colors.white,
                elevation: 5.0,
                height: 50,
                color: MaterialTools.basicColor,
                child: Text( "Upload this Case",),),

              SizedBox(height: 10.0,),


              MaterialButton(onPressed: ()=> alertDialog(context, "Are you sure you want to remove this case?"),
                textColor: Colors.white,
                animationDuration: Duration(seconds: 5),
                height: 50,
                elevation: 5.0,
              color: MaterialTools.deletionColor,
              child: Text( "Remove this Case",),),
            ],
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }

  mightBeCutReason(BuildContext context) {
    final List<Widget> reasonList = <Widget>[];
    for (int i = 0; i < widget.offlineCase["mightbecutreason"].length; i++)
      reasonList.add(Padding(
        padding: const EdgeInsets.only(bottom: 10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Expanded(
              flex: 0,
              child: CircleAvatar(
                radius: 5.0,
                backgroundColor: Colors.white,
              ),
            ),
            SizedBox(
              width: 10.0,
            ),
            Expanded(
              flex: 1,
              child: Text(widget.offlineCase["mightbecutreason"][i]),
            ),
          ],
        ),
      ));
    return reasonList;
  }

  var placeName;
  late Position position;


  Future<void> getLocationName(var lat, var lon) async {
    print("getting Place Location");

    List<Placemark> addresses = await placemarkFromCoordinates(lat, lon);
    var first = addresses.first;
    print("${first.street} : ${first.administrativeArea}");
    // placeMark = await Geolocator().placemarkFromCoordinates(lat, lon);
    var response = await http.get(Uri.parse(
        "https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lon&key=AIzaSyCaccNxbzwR9tMvkppT7bT7zNKjChc_yAw"
    ));
    print("hbkjhghjkghghjghjghjk");
    if (response.statusCode == 200) {
      var responseJson = jsonDecode(response.body)["results"];
      placeName =  "${responseJson[0]["formatted_address"]} ";
      print(placeName);
    }
    if (mounted)
      setState(() {});
  }

  void alertDialog(BuildContext context, String msg) {
    showDialog(
        context: context,
        builder: (context) => Platform.isIOS
            ? new CupertinoAlertDialog(
                content: new Text(msg),
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
                      Navigator.of(context).pop();
                      removeCaseFromList();
                    },
                  ),
                ],
              )
            : new AlertDialog(
                content: new Text(msg),
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
                      Navigator.of(context).pop();
                      removeCaseFromList();
                    },
                  ),
                ],
              ));
  }

  void removeCaseFromList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    storedValues = prefs.getString('offlineList');
    List getList = json.decode(storedValues);
    getList.removeAt(widget.removeIndex);
    var newData = json.encode(getList);
    SharedPreferences preference2 = await SharedPreferences.getInstance();
    preference2.setString("offlineList", newData);
    Navigator.of(context).pop(true);
  }

  Future<void> uploadCase() async {
    print("Uploading");
    if (placeName == null || placeName == "")
      getLocationName(widget.offlineCase["lat"], widget.offlineCase["lon"]);
    getCaseId(widget.offlineCase);
  }

  var caseId, caseIdentifier;
  late LocationData _locationData;
  var countryCaseId;
  location_package.Location location = new location_package.Location();

  Future<void> getCaseId(var data) async {
    _locationData = await location.getLocation();

    List<Placemark> addresses = await placemarkFromCoordinates(_locationData.latitude!, _locationData.longitude!);    var first = addresses.first;
    print("${first.street} : ${first.administrativeArea}");
    //List<Placemark> placeMark = await Geolocator().placemarkFromCoordinates(_locationData.latitude,_locationData.longitude);
    countryCaseId = addresses.first.country;


    CustomResponse response =
        await ApiCall.makeGetRequestToken('incident/getcaseid?country=$countryCaseId');
    if (response.status == 200) if (json.decode(response.body)["status"])
      setState(() {

        caseId = json.decode(response.body)["caseid"];
        caseIdentifier = json.decode(response.body)["caseidentifier"];
        print(caseIdentifier);
        showLoadingDialog(context, data);
      });
    else
      Fluttertoast.showToast(msg: json.decode(response.body)["msg"]);
    else
      Fluttertoast.showToast(msg: response.body);
  }

  late int removeIndex;
  var storedValues;
  void setLocalStorage(var data, var postId, var caseDetails) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    storedValues = prefs.getString('offlineList');
    List getList = json.decode(storedValues);

    getList.removeAt(widget.removeIndex);

    var newData = json.encode(getList);
    SharedPreferences preference2 = await SharedPreferences.getInstance();
    preference2.setString("offlineList", newData);

    SharedPreferences prefs2 = await SharedPreferences.getInstance();
    storedValues = prefs2.getString('offlineList');
    Navigator.of(context).pop(true);
    Navigator.of(context).pop(true);

    Navigator.pushReplacement(context, MaterialPageRoute(
            builder: (context) => SimilarCases(postId,
                data["isanonymous"] ??true ? "Anonymous" : "My Identification ", caseDetails)));
  }

  Future<void> uploadData(var data) async {
    // final coordinates = new Coordinates(1.10, 45.50);
    List<Placemark> addresses = await placemarkFromCoordinates(1.10, 45.50);
    var first = addresses.first;
    print("${first.street} : ${first.administrativeArea}");

   // List<Placemark> placeMark = await Geolocator().placemarkFromCoordinates(_locationData.latitude,_locationData.longitude);

    List <File>uploadPics = [];

    for (int i = 0; i < data["photos"].length; i++)
      uploadPics.add(File(data["photos"][i]["path"]));
    Map uploadData = {
          "isupdate": false,
          "isanonymous": data["isanonymous"],
          "locationname": placeName,
          "lat": data["lat"],
          "lon": data["lon"],
          "caseid":  caseId,
          "description": data["description"],
          "mightbecutreason": data["mightbecutreason"],
          "mightbecut": data["mightbecut"],
          "beencut": data["beencut"],
          "havebeencut": data["havebeencut"],
          "country": first.country,
          "state": first.administrativeArea,
          "city": first.locality,
    };
    CustomResponse response = await ApiCall.makePostRequestToken("incident/adddata", paramsData: uploadData);
    if(response.status == 200){
      if(json.decode(response.body)["status"]){
        fileUpload(id: json.decode(response.body)['id'], photoArray: uploadPics, caseId: json.decode(response.body)['caseid'], data: data );
      }
      else{
        Navigator.pop(context);
        CommonWidgets.alertBox(context, json.decode(response.body)["msg"], leaveThatPage: false);
      }
    }
  }


  //Add Photos
  fileUpload({@required id, @required photoArray, @required caseId, @required data}) async {
    var request = http.MultipartRequest('POST', Uri.parse(ApiCall.webUrl + 'incident/updatephotos'));
    var to = await LocalPrefManager.getToken();

    Map<String,String> data = {'id':id};

    request.headers.addAll({'Content-Type': 'application/form-data', 'x-auth-token': to ?? ''});
    request.fields.addAll(data);


    if (photoArray != null) {
      photoArray.forEach((File file) {
        request.files.add(http.MultipartFile.fromBytes('photos', file.readAsBytesSync(), filename: file.path.split('/').last));
      });
    }
    else{}

    try {
      await http.Response.fromStream(await request.send());
      var returnResponse = await ApiCall.makeGetRequestToken("incident/get?id=$id");
      setLocalStorage(data, id,json.decode(returnResponse.body)["data"]);

    } catch (e) {
      print(e);
      Navigator.pop(context);
      Fluttertoast.showToast(msg: e.toString());
    }
  }


@override
void dispose(){
    timer.cancel();
    super.dispose();
}



  Future<void> showLoadingDialog(BuildContext context, var data) async {
    uploadData(data);
    return showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return new WillPopScope(
              onWillPop: () async => false,
              child: SimpleDialog(
                  backgroundColor: Colors.teal.withOpacity(.7),
                  children: <Widget>[
                    Center(
                      child: Column(children: [
                        CircularProgressIndicator(
                          value: percent,
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          "Please Wait",
                          style: TextStyle(color: Colors.white),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          "Uploading Case Details",
                          style: TextStyle(color: Colors.white),
                        )
                      ]),
                    )
                  ]));
        });
  }

  var percent;
}
