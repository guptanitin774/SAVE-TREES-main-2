import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:naturesociety_new/OfflineCreditinals/FullViewOfflineCase.dart';
import 'package:naturesociety_new/SimilarCases/ListSimilarCases.dart';
import 'package:naturesociety_new/Utils/LocalPrefManager.dart';
import 'package:naturesociety_new/Widgets/CommonFunction.dart';
import 'package:naturesociety_new/Widgets/CommonWidgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class OfflineDataFiles extends StatefulWidget {
  _OfflineDataFiles createState() => _OfflineDataFiles();
}

class _OfflineDataFiles extends State<OfflineDataFiles> {
  @override
  void initState() {
    super.initState();
    checkConnection();
    getUserName();
    Future.delayed(const Duration(milliseconds: 100), () async {
      getOfflineList();
    });
  }

  final fln = FlutterLocalNotificationsPlugin();


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

  var storedValues;
  var offlineDataLength;
  bool listEmpty = false;

  List offlineData = [];
  Future<void> getOfflineList() async {
    fln.cancelAll();
    setState(() {
      isLoading = true;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    storedValues = prefs.getString('offlineList');
    if (storedValues != null) {
      setState(() {
        offlineData = json.decode(storedValues);
        offlineDataLength = json.decode(storedValues).length;
        print(offlineDataLength.toString());
        if (offlineDataLength > 0) {
          listEmpty = false;
          for (int i = 0; i < offlineData.length; i++)
            if (isConnected)
              getLocationName(offlineData[i]["lat"], offlineData[i]["lon"]);
            else
              placeName.add("lat: " + offlineData[i]["lat"].toString() + ", lon: " +
                  offlineData[i]["lon"].toString());
        } else {
          listEmpty = true;
          prefs.remove('offlineList');
        }
      });
    } else
      setState(() {
        listEmpty = true;
      });
    setState(() {
      isLoading = false;
    });
  }

  Position position;
  var lat, lon;


  List placeName = [];
  bool isLoading = false;
  var placeDetail;
  getLocationName(var lat, var lon) async {
    print("geting location");
    setState(() {
      isLoading = true;
    });

    var addresses = await Geocoder.local.findAddressesFromCoordinates(Coordinates(lat, lon));
    var first = addresses.first;
    print("${first.featureName} : ${first.addressLine}");
    //placeMark = await Geolocator().placemarkFromCoordinates(lat, lon);

   var response = await  http
        .get("https://maps.googleapis.com/maps/api/geocode/json?" +
        "latlng=$lat,$lon&" +
        "key=AIzaSyCaccNxbzwR9tMvkppT7bT7zNKjChc_yAw");
    if (response.statusCode == 200) {
      var responseJson = jsonDecode(response.body)["results"];
      placeDetail =  "${responseJson[0]["formatted_address"]} ";

    }
    if (mounted)
      setState(() {
        placeName.add(placeDetail);
        print(placeDetail);
        isLoading = false;
      });
  }

  Future<String>getSingleLocationName(var lat, var lon) async {
    setState(() {
      isLoading = true;
    });
    var placeDetails;

    var addresses = await Geocoder.local.findAddressesFromCoordinates(Coordinates(lat, lon));
    var first = addresses.first;
    print("${first.featureName} : ${first.addressLine}");

    var response = await  http
        .get("https://maps.googleapis.com/maps/api/geocode/json?" +
        "latlng=$lat,$lon&" +
        "key=AIzaSyCaccNxbzwR9tMvkppT7bT7zNKjChc_yAw");
    if (response.statusCode == 200) {
      var responseJson = jsonDecode(response.body)["results"];
      placeDetails =  "${responseJson[0]["formatted_address"]} ";

    }

    if (mounted)
      setState(() {
        isLoading = false;
      });
    print(placeDetails);
    return placeDetails;
  }

  Future<void> removeAllCases() async {
    if (listEmpty)
      Fluttertoast.showToast(msg: "Offline List is Empty.");
    else {
      SharedPreferences prefs2 = await SharedPreferences.getInstance();
      prefs2.remove('offlineList');
      Fluttertoast.showToast(msg: "z cleared Offline List.");
      setState(() {
        listEmpty = true;
      });
    }
  }

  Widget emptyList(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Image.asset(
            "assets/offlineMode.jpg",
            fit: BoxFit.cover,
          ),
          SizedBox(
            height: 10.0,
          ),
          Expanded(
              child: Text(
            "Offline case list is empty!",
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18.0),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          )),
        ],
      ),
    );
  }

  Widget mainScreen(BuildContext context) {
    return SafeArea(
      child: ListView.builder(
          padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
          itemCount: offlineData.length,
          itemBuilder: (context, index) {
            List<Widget> imageList = <Widget>[];
            for (int i = 0; i < offlineData[index]["photos"].length; i++)
              imageList.add(Image.file(
                File(offlineData[index]["photos"][i]["path"]),
                fit: BoxFit.cover,
              ));

            return Dismissible(
              key: Key("index"),
              confirmDismiss: (direction){
                return showDialog<bool>(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                        title: Text('Delete'),
                        content: Text('Are you sure, You want to remove this case? '),
                        actions: <Widget>[
                          FlatButton(
                            child: Text('Cancel'),
                            onPressed: () => Navigator.of(context).pop(false),
                          ),
                          FlatButton(
                              child: Text('Ok'),
                              onPressed: () {
                                removeCase(index);
                                // removeFromWatchList(watchListList[index]['_id']);
                                Navigator.of(context).pop(true);
                              })]);
                  },
                );
              },
              background: Container(
                alignment: AlignmentDirectional.centerEnd,
                color: Colors.redAccent,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(0.0, 0.0, 20.0, 10.0),
                  child: Icon(Icons.delete, color: Colors.white,),
                ),
              ),
              onDismissed: (direction) {
                //Scaffold.of(context).showSnackBar(SnackBar(content: Text("Case has been removed ")));
                Fluttertoast.showToast(msg: "Case has been removed ");
              },
              child: Container(
                margin: EdgeInsets.only(top: 8.0),
                decoration: BoxDecoration(
                    color:   Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                    border: Border.all(color: Colors.black38, width: 1)),

                child: GestureDetector(
                  onTap: () async {
                    bool refresh;
                    refresh = await Navigator.push(context, MaterialPageRoute(
                        builder: (context) => FullViewOfflineCase(offlineData[index], index)));
                    if (refresh) {
                      checkConnection();
                      Future.delayed(const Duration(milliseconds: 20), () async {
                            getOfflineList();
                          });
                    }
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(
                        height: 5.0,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          SizedBox(
                            width: 5.0,
                          ),
                          Expanded(
                            flex: 4,
                            child: Text("Offline Pending Case ${index+1}" , maxLines: 1, overflow: TextOverflow.ellipsis,

                              style: TextStyle(color: Colors.teal, fontWeight: FontWeight.w700, fontSize: 14),
                            ),
                          ),

                          SizedBox(width: 5.0,),

                          Container(
                            decoration: BoxDecoration(color: Colors.white,
                                border: Border.all(color: Colors.black45),
                                borderRadius: BorderRadius.all(Radius.circular(5))),
                            padding:EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            child: Text("${int.parse(offlineData[index]["beencut"]) + int.parse(offlineData[index]["mightbecut"]) +
                                int.parse(offlineData[index]["havebeencut"])}",
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),),
                          ),

                          SizedBox(width: offlineData[index]["beencut"] =="0" ? 0:8,),
                          offlineData[index]["beencut"] == "0" ? SizedBox.shrink(): Container(    decoration: BoxDecoration(color: Colors.red,
                              border: Border.all(color: Colors.red),
                              borderRadius: BorderRadius.all(Radius.circular(5))),
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              child: Text(offlineData[index]["beencut"].toString() ?? "",
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w600),)),

                          SizedBox(width: offlineData[index]["mightbecut"] == "0" ? 0:8,),
                          offlineData[index]["mightbecut"] == "0"? SizedBox.shrink():Container(  decoration: BoxDecoration(color: Colors.orange,
                              border: Border.all(color: Colors.orange),
                              borderRadius: BorderRadius.all(Radius.circular(5))),
                            padding:EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            child: Text(offlineData[index]["mightbecut"].toString() ?? "",
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 14, color: Colors.white,  fontWeight: FontWeight.w600),),),

                          SizedBox(width: offlineData[index]["havebeencut"] == "0" ? 0:8,),

                          offlineData[index]["havebeencut"] == "0" ? SizedBox.shrink() :
                          Container(   decoration: BoxDecoration(color: Colors.grey,
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.all(Radius.circular(5))),
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            child: Text(offlineData[index]["havebeencut"].toString() ?? "", textAlign: TextAlign.center,style:
                            TextStyle(fontSize: 14, fontWeight:FontWeight.w600 ,color: Colors.white),),),

                          SizedBox(width: 8,),

                        ],
                      ),

                      Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Text(placeName.isNotEmpty || placeName.length != 0
                            ? placeName[index] ?? " "
                            : " ", maxLines: 2, overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                        ),
                      ),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          SizedBox(
                            width: 5,
                          ),
                          Text(
                              CommonFunction.timeWithStatus(
                                  offlineData[index]["createddate"]),
                              style: TextStyle(color: Colors.black, fontSize: 11.5,fontWeight: FontWeight.w600 )
                          ),
                          Spacer(),
                          Text(
                            offlineData[index]["isanonymous"] ? "Anonymous" : userName ?? "Anonymous",
                            style:  TextStyle(color: Colors.black, fontSize: 13, fontWeight: FontWeight.w600),
                          ),

                          SizedBox(
                            width: 5,
                          )
                        ],
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      GestureDetector(
                        onTap: () async {
                          bool refresh;
                          refresh = await Navigator.push(context, MaterialPageRoute(
                                    builder: (context) => FullViewOfflineCase(offlineData[index], index)));
                            if (refresh) {
                              checkConnection();
                              Future.delayed(const Duration(milliseconds: 20),
                                  () async {
                                getOfflineList();
                              });
                            }
                        },
                        child: Container(
                          height: 200,
                          width: double.infinity,
                          child: Swiper(
                            itemBuilder: (BuildContext context, int k) {
                              return Image.file(
                                File(offlineData[index]["photos"][k]["path"]),
                                fit: BoxFit.cover,
                              );
                            },
                            itemCount: offlineData[index]["photos"].length,
                            pagination: offlineData[index]["photos"].length > 1
                                ? SwiperPagination()
                                : SwiperPagination(
                                    builder: SwiperPagination.rect),
                            loop: false,
                            autoplay: false,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            );
          }),
    );
  }

  void removeCase(int index) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    storedValues = prefs.getString('offlineList');
    List getList = json.decode(storedValues);
    getList.removeAt(index);
    var newData = json.encode(getList);
    SharedPreferences preference2 = await SharedPreferences.getInstance();
    preference2.setString("offlineList", newData);
    setState(() {});
    getOfflineList();
  }

  Future<bool> onWillPopScope() async {
    Navigator.of(context).pop(true);
    return Future.value(false);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: onWillPopScope,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => onWillPopScope(),
          ),
          iconTheme: IconThemeData(color: Colors.black),
          backgroundColor: Colors.white,
          elevation: 5.0,
          title: Text(
            "Offline Pending Cases",
            style: TextStyle(color: Colors.black),
          ),
          actions: <Widget>[
            PopupMenuButton<int>(
              tooltip: "Options",
              icon: Icon(Icons.more_vert),
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 0,
                  child: Text("Remove all Offline Reported Cases."),
                )
              ],
              onSelected: (value) {
                if (value == 0) removeAllCases();
              },
            )
          ],
        ),
        body: !isLoading
            ? listEmpty ? emptyList(context) : mainScreen(context)
            : Center(child: CommonWidgets.progressIndicator(context),),
      ),
    );
  }


  int removeIndex;
  void setLocalStorage(var data, var postId, var caseDetails) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    storedValues = prefs.getString('offlineList');
    List getList = json.decode(storedValues);

    getList.removeAt(removeIndex);

    var newData = json.encode(getList);
    SharedPreferences preference2 = await SharedPreferences.getInstance();
    preference2.setString("offlineList", newData);

    SharedPreferences prefs2 = await SharedPreferences.getInstance();
    storedValues = prefs2.getString('offlineList');

    Navigator.pop(context);
    Navigator.of(context).pop(true);
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => SimilarCases(postId,
                data["isanonymous"]?? true ? "Anonymous" : "My Identification ", caseDetails)));
  }



  var percent;
}
