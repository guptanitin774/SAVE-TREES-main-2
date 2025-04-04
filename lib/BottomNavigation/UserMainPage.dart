import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_swiper_null_safety/flutter_swiper_null_safety.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:location/location.dart';
import 'package:naturesociety_new/BottomNavigation/Filter.dart';
import 'package:naturesociety_new/BottomNavigation/MainSearchPage.dart';
import 'package:naturesociety_new/CaseView/CaseDetailedView.dart';
import 'package:naturesociety_new/SettingsScreen/Locations.dart';
import 'package:naturesociety_new/Utils/LocalPrefManager.dart';
import 'package:naturesociety_new/Utils/MaterialComponets.dart';
import 'package:naturesociety_new/Widgets/CommonFunction.dart';
import 'package:naturesociety_new/Widgets/CommonWidgets.dart';
import 'package:naturesociety_new/Widgets/ShimmerLoading.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Utils/NetworkCall.dart';

class HomePage extends StatefulWidget {
  final hasRefresh;

  HomePage({this.hasRefresh, required UniqueKey key});

  @override
  _HomePage createState() => _HomePage();
}

List<dynamic> myLocationData = [];
List<CaseTileModel> cases = [];
var length = 0;
String selectedChoice = "";
var searchData;

String searchTerm;
String zeroCountMessage;

int currentPageCount = 1, totalIncidentCount = 0;
var myUserId;

class _HomePage extends State<HomePage> {
  List locationId = [];
  bool locationIdValue = false, loader = false;

  @override
  void initState() {
    super.initState();
    showSavedLocations();
    if (selectedChoice == "" ||
        selectedChoice == null ||
        selectedChoice == "Add New" ||
        cases.isEmpty) {
      setState(() => caseListLoading = true);
      incidentGetList("all", 1);
    } else if (selectedChoice == "Near By")
      locationPermission();
    else
      cases = cases;
    incidentCountCheck(selectedChoice);
    Future.delayed(const Duration(seconds: 4), () {
      initDynamicLinks();
    });
  }

  void initDynamicLinks() async {
    final PendingDynamicLinkData? data =
        await FirebaseDynamicLinks.instance.getInitialLink();
    final Uri? deepLink = data?.link;

    if (deepLink != null) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  CaseDetailedView(deepLink.path.substring(1))));
    }

    FirebaseDynamicLinks.instance.onLink;
  }

  bool hasNewUpdate = false;

  Future<void> incidentCountCheck(var val) async {
    CustomResponse response =
        await ApiCall.makeGetRequestToken("incident/getlist?type=$val");
    if (response.status == 200) {
      if (json.decode(response.body)["status"]) if (json
              .decode(response.body)["totalcount"] as int !=
          totalIncidentCount)
        hasNewUpdate = true;
      else
        hasNewUpdate = false;
    } else if (response.status == 403) {
      caseListLoading = true;
      CommonWidgets.loginLimit(context);
    } else {}

    if (mounted) setState(() {});
  }

  Future<void> showSavedLocations() async {
    myUserId = await LocalPrefManager.getUserId();
    CustomResponse response =
        await ApiCall.makeGetRequestToken("user/mylocations");
    if (response.status == 200) if (json.decode(response.body)["status"]) {
      if (json.decode(response.body)["data"].length + 2 !=
          myLocationData.length) {
        loader = true;
        myLocationData.clear();
        for (int i = 0; i < json.decode(response.body)["data"].length; i++)
          myLocationData.add(json.decode(response.body)["data"][i]);
        myLocationData.add({"_id": "Near By", "name": "Near By"});
        myLocationData.add({"_id": "Add New", "name": "+ Add"});
        selectedChoice = await myLocationData[0]["name"];
        isConnected = true;
        loader = false;
      }
    } else
      Fluttertoast.showToast(
          msg: "Something went wrong! Unable to get Locations.");
    else {
      isConnected = false;
      //  Scaffold.of(context).showSnackBar(snackBar);
      getLocallySaved();
    }
    if (mounted) setState(() {});
  }

  bool caseListLoading = false;

  Future<void> incidentGetList(var val, int count, {sort}) async {
    if (count == 1) if (mounted)
      setState(() {
        caseListLoading = true;
      });
    if (_locationData == null) await locationPermission();
    if (await location.serviceEnabled() &&
        _permissionGranted == PermissionStatus.granted) {
      _locationData = await location.getLocation();
      print(_locationData.latitude);
    }
    //  currentLocation =await Geolocator.getCurrentPosition();
    else {}
    print('dfg');

    CustomResponse response = await ApiCall.makeGetRequestToken(
        "incident/getlist?sort=$sort&type=$val&count=15&page=$currentPageCount"
        "${_locationData == null ? "" : "&lat=${_locationData.latitude}&lon=${_locationData.longitude}"}");
    if (response.status == 200) {
      if (json.decode(response.body)["status"]) {
        totalIncidentCount = json.decode(response.body)["totalcount"] as int;
        var responseData = json.decode(response.body)["data"];

        for (int i = 0; i < responseData.length; i++)
          cases.add(CaseTileModel(
            id: responseData[i]["_id"],
            locationName: responseData[i]["locationname"],
            caseId: responseData[i]["caseidentifier"] ??
                responseData[i]["caseid"].toString(),
            //json.decode(response.body)["data"][i]["caseidentifier"],
            userName: responseData[i]["locationname"],
            distance: responseData[i]["distance"] ?? 0.0,
            beenCut: responseData[i]["beencut"],
            haveBeemCut: responseData[i]["havebeencut"],
            mightBeCut: responseData[i]["mightbecut"],
            caseUpdates: responseData[i]["updates"],
            commentCount: responseData[i]["commentcount"],
            watchListCount: responseData[i]["watchcount"],
            reportCount: responseData[i]["reportcount"],
            photos: responseData[i]["photos"],
            userDetails: responseData[i]["addedby"],
            createdDate: responseData[i]["createddate"],
            isAnonymous: responseData[i]["isanonymous"], time: '',
          ));

        length = cases.length;
        currentPageCount++;
        paginationLoading = false;
      } else {
        length = 0;
        zeroCountMessage = val == "all"
            ? "No case has been posted yet!"
            : "No case has been found in this location!";
      }
      caseListLoading = false;
    } else if (response.status == 403) {
      caseListLoading = true;
      CommonWidgets.loginLimit(context);
    } else {
      caseListLoading = false;
      isConnected = false;
      getLocallySaved();
    }

    if (mounted) setState(() {});
  }

  Location location = new Location();
  late bool _serviceEnabled;
  late PermissionStatus _permissionGranted;
  late LocationData _locationData;

  locationPermission() async {
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        length = 0;
        zeroCountMessage = "Sorry! Location service is not enabled";
        caseListLoading = false;
        setState(() {});
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
        length = 0;
        zeroCountMessage = "Sorry! Location service is not enabled";
        caseListLoading = false;
        setState(() {});
        await location.hasPermission();
        CommonWidgets.permissionDialog(context: context, type: "Location");
        // appHandler.openAppSettings();
        return;
      }
    }
    _locationData = await location.getLocation();
    Future.delayed(const Duration(microseconds: 10), () async {
      getNearByCases();
    });
  }

  void getNearByCases() async {
    setState(() {
      caseListLoading = true;
    });
    CustomResponse response = await ApiCall.makeGetRequestToken(
        'incident/nearby?lat=${_locationData.latitude}&lon=${_locationData.longitude}');
    if (response.status == 200) {
      if (json.decode(response.body)["status"]) {
        var responseData = json.decode(response.body)["data"];
        cases.clear();
        for (int i = 0; i < responseData.length; i++)
          cases.add(CaseTileModel(
            id: responseData[i]["_id"],
            locationName: responseData[i]["locationname"],
            caseId: responseData[i]["caseidentifier"] ??
                responseData[i]["caseid"].toString(),
            //json.decode(response.body)["data"][i]["caseidentifier"],
            userName: responseData[i]["locationname"],
            distance: responseData[i]["distance"],
            beenCut: responseData[i]["beencut"],
            haveBeemCut: responseData[i]["havebeencut"],
            mightBeCut: responseData[i]["mightbecut"],
            caseUpdates: responseData[i]["updates"],
            commentCount: responseData[i]["commentcount"],
            watchListCount: responseData[i]["watchcount"],
            reportCount: responseData[i]["reportcount"],
            photos: responseData[i]["photos"],
            userDetails: responseData[i]["addedby"],
            createdDate: responseData[i]["createddate"],
            isAnonymous: responseData[i]["isanonymous"], time: '',
          ));
        length = cases.length;
        totalIncidentCount = length;
      } else {
        length = 0;
        zeroCountMessage = "No case has been reported in your area!";
      }
    } else if (response.status == 403) {
      caseListLoading = true;
      CommonWidgets.loginLimit(context);
    } else {
      isConnected = false;
      caseListLoading = false;
      getLocallySaved();
    }
    caseListLoading = false;
    if (mounted) setState(() {});
  }

  var offlineCredentials;

  void getLocallySaved() async {
    SharedPreferences prefs2 = await SharedPreferences.getInstance();
    offlineCredentials = prefs2.getString('offlineCaseList');
    if (offlineCredentials != null) {
      offlineCredentials = json.decode(offlineCredentials);
    }
  }

  bool isConnected = true;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: onWillPop,
      child: Scaffold(
        backgroundColor: Colors.white.withOpacity(0.05),
        body: SafeArea(
            child: !isConnected
                ? offlineCaseList(context)
                : !loader
                    ? mainBody(context)
                    : CommonWidgets.progressIndicator(context)),
      ),
    );
  }

  late Map filtersData;
  int filtersCount = 0;
  bool isFiltersEnabled = false, isSearchEnabled = false;

  Widget appBarCustom(BuildContext context) {
    return Container(
      color: Colors.grey.withOpacity(.02),
      height: isSearchEnabled ? 150 : 90,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          isSearchEnabled ? searchEnabledAppBar(context) : SizedBox.shrink(),
          Container(
            height: 53.0,
            padding: EdgeInsets.only(bottom: 8.0),
            child: Row(
              children: <Widget>[
                isSearchEnabled
                    ? SizedBox.shrink()
                    : IconButton(
                        icon: Icon(Icons.search),
                        onPressed: () async {
                          var returnData;
                          returnData = await Navigator.push(
                              context,
                              CupertinoPageRoute(
                                  builder: (context) => MainSearchPage()));
                          searchData = returnData["searchResult"];
                          if (returnData["searchTerm"] ==
                              'cases with more than 100 trees affected') {
                            searchTerm =
                                'Cases with more than 100 trees affected';
                          } else if (returnData["searchTerm"] ==
                              'cases on which i commented') {
                            searchTerm = 'Cases on which I commented';
                          } else if (returnData["searchTerm"] ==
                              'cases posted by me') {
                            searchTerm = 'Cases posted by me';
                          }
                          //searchTerm=returnData["searchTerm"][0].toUpperCase() + returnData["searchTerm"].substring(1);
                          else {
                            searchTerm = returnData["searchTerm"];
                          }
                          if (searchTerm.isNotEmpty || searchTerm != "")
                            setState(() {
                              isSearchEnabled = true;
                              currentPageCount = 1;
                              cases.clear();
                              length = searchData.length;
                              totalIncidentCount = length;

                              for (int i = 0; i < searchData.length; i++)
                                cases.add(CaseTileModel(
                                  id: searchData[i]["_id"],
                                  locationName: searchData[i]["locationname"],
                                  caseId: searchData[i]["caseidentifier"]
                                              .toString() ==
                                          null
                                      ? searchData[i]["caseid"]
                                      : searchData[i]["caseidentifier"],
                                  userName: searchData[i]["locationname"],
                                  distance: searchData[i]["distance"],
                                  beenCut: searchData[i]["beencut"],
                                  haveBeemCut: searchData[i]["havebeencut"],
                                  mightBeCut: searchData[i]["mightbecut"],
                                  caseUpdates: searchData[i]["updates"],
                                  commentCount: searchData[i]["commentcount"],
                                  watchListCount: searchData[i]["watchcount"],
                                  reportCount: searchData[i]["reportcount"],
                                  photos: searchData[i]["photos"],
                                  userDetails: searchData[i]["addedby"],
                                  createdDate: searchData[i]["createddate"],
                                  isAnonymous: searchData[i]["isanonymous"], time: '',
                                ));
                              //cases = searchData;
                            });
                          else
                            setState(() {
                              isSearchEnabled = false;
                            });
                        },
                      ),
                Container(
                  height: 53.0,
                  width: isSearchEnabled
                      ? MediaQuery.of(context).size.width - 20
                      : MediaQuery.of(context).size.width - 50,
                  child: AnimationLimiter(
                    child: ListView.builder(
                      physics: BouncingScrollPhysics(),
                      padding: EdgeInsets.symmetric(
                          horizontal: isSearchEnabled ? 8.0 : 0.0),
                      itemCount: myLocationData.length,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) {
                        return AnimationConfiguration.staggeredList(
                          position: index,
                          duration: const Duration(milliseconds: 375),
                          child: SlideAnimation(
                            verticalOffset: 50.0,
                            child: FadeInAnimation(
                              child: Row(
                                children: <Widget>[
                                  loader
                                      ? Text(" ")
                                      : FilterChip(
                                          showCheckmark: false,
                                          elevation: 1.0,
                                          backgroundColor: myLocationData[index]
                                                      ["_id"] ==
                                                  "Add New"
                                              ? MaterialTools.basicColor
                                              : Colors.white,
                                          label: Text(
                                            myLocationData[index]["name"],
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              color: myLocationData[index]
                                                          ["_id"] ==
                                                      "Add New"
                                                  ? Colors.white
                                                  : selectedChoice ==
                                                          myLocationData[index]
                                                              ["_id"]
                                                      ? MaterialTools.basicColor
                                                      : Colors.black,
                                            ),
                                          ),
                                          selectedColor: Colors.white,
                                          padding: EdgeInsets.all(4.0),
                                          shape: StadiumBorder(
                                              side: BorderSide(
                                                  width: selectedChoice ==
                                                          myLocationData[index]
                                                              ["_id"]
                                                      ? 2.0
                                                      : 1.0,
                                                  color: myLocationData[index]
                                                              ["_id"] ==
                                                          "Add New"
                                                      ? MaterialTools.basicColor
                                                      : selectedChoice ==
                                                              myLocationData[
                                                                  index]["_id"]
                                                          ? MaterialTools
                                                              .basicColor
                                                          : Colors.black12)),
                                          selected: selectedChoice ==
                                              myLocationData[index]["_id"],
                                          onSelected: (selected) async {
                                            selectedChoice =
                                                myLocationData[index]["_id"];
                                            if (selectedChoice == "Near By") {
                                              setState(() {
                                                caseListLoading = true;
                                              });
                                              locationPermission();
                                            } else if (selectedChoice ==
                                                "Add New") {
                                              bool needRefresh =
                                                  await Navigator.push(
                                                      context,
                                                      CupertinoPageRoute(
                                                          builder: (context) =>
                                                              Locations()));
                                              if (needRefresh) {
                                                selectedChoice = null;
                                                showSavedLocations();
                                              } else {
                                                selectedChoice =
                                                    myLocationData[0]["name"];
                                                if (mounted) setState(() {});
                                              }
                                            } else {
                                              setState(() {
                                                caseListLoading = true;
                                              });
                                              currentPageCount = 1;
                                              cases.clear();
                                              incidentGetList(
                                                  selectedChoice, 1);
                                            }
                                          },
                                        ),
                                  SizedBox(
                                    width: 10.0,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          !caseListLoading ? filtersBar(context) : SizedBox.shrink(),
        ],
      ),
    );
  }

  Widget filtersBar(BuildContext context) {
    return Container(
      decoration:
          BoxDecoration(border: Border.all(width: 1.0, color: Colors.black12)),
      height: 35.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          InkWell(
            onTap: () => _settingModalBottomSheet(context),
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  right: BorderSide(
                    color: Colors.black12,
                    width: 1.0,
                  ),
                ),
              ),
              width: MediaQuery.of(context).size.width - 110,
              padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              child: LimitedBox(
                maxWidth: MediaQuery.of(context).size.width - 110,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.sort,
                      size: 20,
                    ),
                    SizedBox(
                      width: 5.0,
                    ),
                    FittedBox(
                      fit: BoxFit.cover,
                      child: Text(
                        "$choice",
                        textAlign: TextAlign.left,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          InkWell(
            onTap: () async {
              var returnData;
              returnData = await Navigator.push(
                  context,
                  CupertinoPageRoute(
                      builder: (context) => Filter(
                            isFilterOn: isFiltersEnabled ? true : false,
                          )));
              filtersData = json.decode(returnData.toString())["filter"] as Map;
              filtersCount = json.decode(returnData)["length"];
              if (filtersCount > 0) {
                isFiltersEnabled = true;
                applyFilters(filtersData);
              } else {
                filtersCount = 0;
                setState(() {
                  caseListLoading = true;
                });
                isFiltersEnabled = false;
                currentPageCount = 1;
                myLocationData.clear();
                showSavedLocations();
                cases.clear();
                length = 0;
                incidentGetList("all", 1);
              }
            },
            child: Container(
              width: 100,
              padding:
                  EdgeInsets.only(right: 8.0, left: 8.0, top: 4.0, bottom: 4.0),
              child: LimitedBox(
                maxWidth: 100,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Icon(
                      Icons.filter_alt_outlined,
                      size: 20,
                    ),
                    SizedBox(
                      width: 5.0,
                    ),
                    FittedBox(
                        fit: BoxFit.cover,
                        //
                        child: Text(
                          "Filters",
                          textAlign: TextAlign.left,
                          overflow: TextOverflow.fade,
                          maxLines: 1,
                        )),
                    isFiltersEnabled && filtersCount != 0
                        ? Text(
                            "(${appliedFilterLength.toString()})",
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              color: Colors.teal,
                            ),
                          )
                        : SizedBox.shrink(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget searchEnabledAppBar(BuildContext context) {
    return Container(
      height: 50,
      margin: EdgeInsets.only(bottom: 8.0, left: 8.0, right: 8.0),
      width: double.infinity,
      padding: EdgeInsets.all(8.0),
      decoration: BoxDecoration(
          border: Border.all(color: Colors.grey, width: 1.0),
          borderRadius: BorderRadius.all(Radius.circular(4.0))),
      child: GestureDetector(
        onTap: () async {
          var returnData;
          returnData = await Navigator.push(context,
              CupertinoPageRoute(builder: (context) => MainSearchPage()));
          searchData = returnData["searchResult"];
          if (returnData["searchTerm"] ==
              'cases with more than 100 trees affected') {
            searchTerm = 'Cases with more than 100 trees affected';
          } else if (returnData["searchTerm"] == 'cases on which i commented') {
            searchTerm = 'Cases on which I commented';
          } else if (returnData["searchTerm"] == 'cases posted by me') {
            searchTerm = 'Cases posted by me';
          }
          //searchTerm=returnData["searchTerm"][0].toUpperCase() + returnData["searchTerm"].substring(1);
          else {
            searchTerm = returnData["searchTerm"];
          }
          print(searchTerm);
          if (searchTerm.isNotEmpty || searchTerm != "")
            setState(() {
              // currentPageCount =1;
              // searchTerm = returnData["searchTerm"];
              // isSearchEnabled = true;
              // cases.clear();
              // length = searchData.length;
              // totalIncidentCount = length;
              // cases = searchData.toList();
              isSearchEnabled = true;
              currentPageCount = 1;
              cases.clear();
              length = searchData.length;
              totalIncidentCount = length;

              for (int i = 0; i < searchData.length; i++)
                cases.add(CaseTileModel(
                  id: searchData[i]["_id"],
                  locationName: searchData[i]["locationname"],
                  caseId: searchData[i]["caseidentifier"].toString() == null
                      ? searchData[i]["caseid"]
                      : searchData[i]["caseidentifier"],
                  userName: searchData[i]["locationname"],
                  distance: searchData[i]["distance"],
                  beenCut: searchData[i]["beencut"],
                  haveBeemCut: searchData[i]["havebeencut"],
                  mightBeCut: searchData[i]["mightbecut"],
                  caseUpdates: searchData[i]["updates"],
                  commentCount: searchData[i]["commentcount"],
                  watchListCount: searchData[i]["watchcount"],
                  reportCount: searchData[i]["reportcount"],
                  photos: searchData[i]["photos"],
                  userDetails: searchData[i]["addedby"],
                  createdDate: searchData[i]["createddate"],
                  isAnonymous: searchData[i]["isanonymous"], time: '',
                ));
            });
          else
            setState(() {
              isSearchEnabled = false;
            });
          // setState(() {
          //   length = 0;
          //   isSearchEnabled =true;
          //   zeroCountMessage = "No search result found";
          // });
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Icon(
              Icons.search,
              color: Colors.grey,
            ),
            SizedBox(
              width: 5.0,
            ),
            Expanded(
                child: Text(
              searchTerm ?? " ",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            )),
            IconButton(
              onPressed: () {
                setState(() {
                  isSearchEnabled = false;
                  currentPageCount = 1;
                  cases.clear();
                  length = 0;
                  incidentGetList("all", 1);
                });
              },
              color: Colors.grey,
              icon: Icon(Icons.cancel),
            ),
          ],
        ),
      ),
    );
  }

  Widget mainBody(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        SizedBox(
          height: 10,
        ),
        appBarCustom(context),
        Expanded(
          child: caseListLoading
              ? Container(
                  height: MediaQuery.of(context).size.height - 200,
                  width: double.infinity,
                  child: ShimmerLoading.loadingCaseShimmer(context),
                )
              : length > 0
                  ? caseTileList(context)
                  : Container(
                      height: MediaQuery.of(context).size.height - 180,
                      width: double.infinity,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Text(zeroCountMessage ?? " ",
                              style: MaterialTools.errorMessageStyle),
                        ],
                      ),
                    ),
        )
      ],
    );
  }

  bool paginationLoading = false;

  Widget caseTileList(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8.0),
        height: isSearchEnabled
            ? MediaQuery.of(context).size.height - 235
            : MediaQuery.of(context).size.height - 180,
        width: double.infinity,
        child: Stack(
          children: <Widget>[
            NotificationListener<ScrollNotification>(
              onNotification: (ScrollNotification scrollInfo) {
                if (!paginationLoading &&
                    scrollInfo.metrics.pixels ==
                        scrollInfo.metrics.maxScrollExtent) {
                  if (cases.length < totalIncidentCount) {
                    paginationLoading = true;
                    setState(() {});
                    incidentGetList(selectedChoice ?? "all", 2);
                  } else
                    paginationLoading = false;
                }
                return true;
              },
              child: RefreshIndicator(
                onRefresh: () async {
                  await Future.delayed(Duration(seconds: 2));
                  if (isSearchEnabled || filtersCount != 0) {
                    hasNewUpdate = false;
                  } else {
                    setState(() {
                      isSearchEnabled = false;
                      filtersCount = 0;
                      isFiltersEnabled = !isFiltersEnabled;
                      hasNewUpdate = false;
                      _radioValue =
                          "most recent"; //Initial definition of radio button value
                      choice = "Sorted by most recent";
                    });
                    showSavedLocations();
                    if (selectedChoice == "Near By")
                      locationPermission();
                    else {
                      currentPageCount = 1;
                      cases.clear();
                      length = 0;
                      incidentGetList(selectedChoice, 1);
                    }
                  }
                },
                child: AnimationLimiter(
                  child: ListView.builder(
                      scrollDirection: Axis.vertical,
                      // physics: ClampingScrollPhysics(),
                      itemCount: length,
                      itemBuilder: (BuildContext context, int index) {
                        return itemBuilderContents(context, index);
                      }),
                ),
              ),
            ),
            hasNewUpdate && !isFiltersEnabled && !isSearchEnabled
                ? Align(
                    alignment: Alignment.topCenter,
                    child: LimitedBox(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          elevation: 8.5,
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18.0),
                              side: BorderSide(color: Colors.white)),
                        ),
                        onPressed: () {
                          setState(() {
                            caseListLoading = true;
                          });
                          hasNewUpdate = false;
                          currentPageCount = 1;
                          cases.clear();
                          length = 0;
                          incidentGetList(selectedChoice, 1);
                        },
                        child: Text("New Updates",
                            style: TextStyle(
                                color: Colors.teal,
                                fontWeight: FontWeight.w600)),
                      ),
                    ),
                  )
                : SizedBox.shrink(),
          ],
        ),
      ),
    );
  }

  Widget itemBuilderContents(BuildContext context, int index) {
    return Column(
      children: <Widget>[
        Container(
          margin: EdgeInsets.only(top: 8.0),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(5.0)),
              border: Border.all(color: Colors.black38, width: 1)),
          child: GestureDetector(
            onTap: () async {
              bool needRefresh = await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => CaseDetailedView(
                            cases[index].id,
                            isSearch: isSearchEnabled,
                          )));
              if (needRefresh) {
                updateTileDetails(cases[index].id, index);
                setState(() {});
              }
            },
            child: cases[index].caseUpdates != null
                ? updateTile(context, index)
                : normalTile(context, index),
          ),
        ),
        index != totalIncidentCount - 1 && index == cases.length - 1
            ? SizedBox(
                height: 100.0,
                child: paginationLoading
                    ? Center(
                        child: CommonWidgets.progressIndicator(context),
                      )
                    : SizedBox.shrink())
            : SizedBox.shrink(),
      ],
    );
  }

  Future<void> updateTileDetails(var id, int index) async {
    CustomResponse response =
        await ApiCall.makeGetRequestToken('incident/get?id=$id');
    if (response.status == 200) {
      if (json.decode(response.body)['status']) {
        cases[index].watchListCount =
            json.decode(response.body)["data"]["watchcount"];
        cases[index].reportCount =
            json.decode(response.body)["data"]["reportcount"];
        cases[index].commentCount =
            json.decode(response.body)["data"]["commentcount"];
      } else {}
    } else {}
    if (mounted) setState(() {});
  }

  Widget updateTile(BuildContext context, int index) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(height: 5),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              width: 5,
            ),
            Expanded(
              flex: 4,
              child: Text(
                "${cases[index].caseId.toString()} ",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    color: Colors.teal,
                    fontWeight: FontWeight.w700,
                    fontSize: 14),
              ),
            ),
            SizedBox(
              width: 5,
            ),
            Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.black45),
                  borderRadius: BorderRadius.all(Radius.circular(5))),
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Text(
                "${cases[index].caseUpdates[0]["beencut"] + cases[index].caseUpdates[0]["mightbecut"] + cases[index].caseUpdates[0]["havebeencut"]}",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),
            SizedBox(
              width: cases[index].caseUpdates[0]["beencut"] == 0 ? 0 : 8,
            ),
            cases[index].caseUpdates[0]["beencut"] == 0
                ? SizedBox.shrink()
                : Container(
                    decoration: BoxDecoration(
                        color: Colors.red,
                        border: Border.all(color: Colors.red),
                        borderRadius: BorderRadius.all(Radius.circular(5))),
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Text(
                      cases[index].caseUpdates[0]["beencut"].toString() ?? "",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                          fontWeight: FontWeight.w600),
                    )),
            SizedBox(
              width: cases[index].caseUpdates[0]["mightbecut"] == 0 ? 0 : 8,
            ),
            cases[index].caseUpdates[0]["mightbecut"] == 0
                ? SizedBox.shrink()
                : Container(
                    decoration: BoxDecoration(
                        color: Colors.orange,
                        border: Border.all(color: Colors.orange),
                        borderRadius: BorderRadius.all(Radius.circular(5))),
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Text(
                      cases[index]
                              .caseUpdates[cases[index].caseUpdates.length - 1]
                                  ["mightbecut"]
                              .toString() ??
                          "",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
            SizedBox(
              width: cases[index].caseUpdates[0]["havebeencut"] == 0 ? 0 : 8,
            ),
            cases[index].caseUpdates[0]["havebeencut"] == 0
                ? SizedBox.shrink()
                : Container(
                    decoration: BoxDecoration(
                        color: Colors.grey,
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.all(Radius.circular(5))),
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Text(
                      cases[index].caseUpdates[0]["havebeencut"].toString() ??
                          "",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white),
                    ),
                  ),
            SizedBox(
              width: 8,
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.all(5.0),
          child: Text(
            cases[index].caseUpdates[0]["locationname"] ?? " ",
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            SizedBox(
              width: 5,
            ),
            cases[index].distance == null
                ? SizedBox.shrink()
                : Text(
                    cases[index].distance.toStringAsFixed(3) + " km, ",
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600),
                  ),
            Expanded(
              flex: 5,
              child: Text(
                CommonFunction.timeCalculation(
                    cases[index].caseUpdates[0]["createddate"]),
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600),
              ),
            ),
            Expanded(
              flex: 0,
              child: Text(
                cases[index].caseUpdates[0]["isanonymous"]
                    ? myUserId == cases[index].caseUpdates[0]["addedby"]["_id"]
                        ? "You as Anonymous"
                        : "Anonymous"
                    : cases[index].caseUpdates[0]["addedby"]["name"] == null
                        ? " "
                        : cases[index].caseUpdates[0]["addedby"]["name"],
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 12,
                    fontWeight: FontWeight.w600),
              ),
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
            bool needRefresh = await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => CaseDetailedView(
                          cases[index].id,
                          isSearch: isSearchEnabled,
                        )));
            if (needRefresh) {
              updateTileDetails(cases[index].id, index);
              setState(() {});
            }
          },
          child: Container(
            height: 200,
            width: double.infinity,
            child: Stack(
              children: [
                Swiper(
                  itemBuilder: (BuildContext context, int k) {
                    return Image(
                      image: CachedNetworkImageProvider(ApiCall.imageUrl +
                          cases[index]
                              .caseUpdates[0]["photos"][k]["photo"]
                              .toString()),
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            backgroundColor: Colors.white54,
                            valueColor:
                                new AlwaysStoppedAnimation<Color>(Colors.green),
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    (loadingProgress.expectedTotalBytes as num)
                                : null,
                          ),
                        );
                      },
                    );
                  },
                  itemCount: cases[index].caseUpdates[0]["photos"].length,
                  pagination: cases[index].caseUpdates[0]["photos"].length > 1
                      ? SwiperPagination()
                      : SwiperPagination(builder: SwiperPagination.rect),
                  loop: false,
                  autoplay: false,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      cases[index].caseUpdates != null
                          ? Container(
                              padding: EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5.0)),
                                color: Colors.black45,
                              ),
                              child: Text(
                                cases[index].caseUpdates.length == 1
                                    ? "Update 1"
                                    : "Update ${cases[index].caseUpdates.length}",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 12),
                              ),
                            )
                          : SizedBox.shrink(),
                      SizedBox(
                        width: cases[index].caseUpdates == null ? 0 : 8.0,
                      ),
                      cases[index].watchListCount == 0 ||
                              cases[index].watchListCount == null
                          ? SizedBox.shrink()
                          : Container(
                              padding: EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.black45,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5.0)),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.remove_red_eye,
                                    color: Colors.white,
                                    size: 12,
                                  ),
                                  SizedBox(
                                    width: 4.0,
                                  ),
                                  Text(
                                    cases[index].watchListCount.toString(),
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                      SizedBox(
                        width: cases[index].watchListCount == 0 ||
                                cases[index].watchListCount == null
                            ? 0
                            : 8.0,
                      ),
                      cases[index].commentCount == 0 ||
                              cases[index].commentCount == null
                          ? SizedBox.shrink()
                          : Container(
                              padding: EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.black45,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5.0)),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.message,
                                    color: Colors.white,
                                    size: 12,
                                  ),
                                  SizedBox(
                                    width: 4.0,
                                  ),
                                  Text(
                                    cases[index].commentCount.toString(),
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                      Spacer(),
                      cases[index].reportCount == 0 ||
                              cases[index].reportCount == null
                          ? SizedBox.shrink()
                          : Container(
                              padding: EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.deepOrange.withOpacity(0.7),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5.0)),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.warning,
                                    color: Colors.white,
                                    size: 12,
                                  ),
                                  SizedBox(
                                    width: 4.0,
                                  ),
                                  Text(
                                    "Reported by " +
                                        cases[index].reportCount.toString(),
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget normalTile(BuildContext context, int index) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(height: 5),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              width: 5,
            ),
            Expanded(
              flex: 4,
              child: Text(
                "${cases[index].caseId} ",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    color: Colors.teal,
                    fontWeight: FontWeight.w700,
                    fontSize: 14),
              ),
            ),
            SizedBox(
              width: 5,
            ),
            Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.black45),
                  borderRadius: BorderRadius.all(Radius.circular(5))),
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Text(
                "${cases[index].beenCut + cases[index].mightBeCut + cases[index].haveBeemCut}",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),
            SizedBox(
              width: cases[index].beenCut == 0 ? 0 : 8,
            ),
            cases[index].beenCut == 0
                ? SizedBox.shrink()
                : Container(
                    decoration: BoxDecoration(
                        color: Colors.red,
                        border: Border.all(color: Colors.red),
                        borderRadius: BorderRadius.all(Radius.circular(5))),
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Text(
                      cases[index].beenCut.toString() ?? "",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                          fontWeight: FontWeight.w600),
                    )),
            SizedBox(
              width: cases[index].mightBeCut == 0 ? 0 : 8,
            ),
            cases[index].mightBeCut == 0
                ? SizedBox.shrink()
                : Container(
                    decoration: BoxDecoration(
                        color: Colors.orange,
                        border: Border.all(color: Colors.orange),
                        borderRadius: BorderRadius.all(Radius.circular(5))),
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Text(
                      cases[index].mightBeCut.toString() ?? "",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
            SizedBox(
              width: cases[index].haveBeemCut == 0 ? 0 : 8,
            ),
            cases[index].haveBeemCut == 0
                ? SizedBox.shrink()
                : Container(
                    decoration: BoxDecoration(
                        color: Colors.grey,
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.all(Radius.circular(5))),
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Text(
                      cases[index].haveBeemCut.toString() ?? "",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white),
                    ),
                  ),
            SizedBox(
              width: 8,
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.all(5.0),
          child: Text(
            cases[index].locationName ?? " ",
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            SizedBox(
              width: 5,
            ),
            cases[index].distance == null
                ? SizedBox.shrink()
                : Text(
                    cases[index].distance.toStringAsFixed(3) + " km, ",
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600),
                  ),
            Expanded(
              flex: 5,
              child: Text(
                CommonFunction.timeCalculation(cases[index].createdDate),
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600),
              ),
            ),
            Expanded(
              flex: 0,
              child: Text(
                cases[index].isAnonymous
                    ? myUserId == cases[index].userDetails["_id"]
                        ? "You as Anonymous"
                        : "Anonymous"
                    : cases[index].userDetails["name"] == null
                        ? " "
                        : cases[index].userDetails["name"],
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 12,
                    fontWeight: FontWeight.w600),
              ),
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
            bool needRefresh = await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => CaseDetailedView(
                          cases[index].id,
                          isSearch: isSearchEnabled,
                        )));
            if (needRefresh) {
              updateTileDetails(cases[index].id, index);
            }
          },
          child: Container(
            height: 200,
            width: double.infinity,
            child: Stack(
              children: [
                Swiper(
                  itemBuilder: (BuildContext context, int k) {
                    return Image(
                      image: CachedNetworkImageProvider(ApiCall.imageUrl +
                          cases[index].photos[k]["photo"].toString()),
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            backgroundColor: Colors.white54,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.green),
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    (loadingProgress.expectedTotalBytes as num)
                                : null,
                          ),
                        );
                      },
                    );
                  },
                  itemCount: cases[index].photos.length,
                  pagination: cases[index].photos.length > 1
                      ? SwiperPagination()
                      : SwiperPagination(builder: SwiperPagination.rect),
                  loop: false,
                  autoplay: false,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      cases[index].caseUpdates != null
                          ? Container(
                              padding: EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5.0)),
                                color: Colors.black45,
                              ),
                              child: Text(
                                cases[index].caseUpdates.length == 1
                                    ? "Update 1"
                                    : "Update ${cases[index].caseUpdates.length}",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 12),
                              ),
                            )
                          : SizedBox.shrink(),
                      SizedBox(
                        width: cases[index].caseUpdates == null ? 0 : 8.0,
                      ),
                      cases[index].watchListCount == 0 ||
                              cases[index].watchListCount == null
                          ? SizedBox.shrink()
                          : Container(
                              padding: EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.black45,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5.0)),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.remove_red_eye,
                                    color: Colors.white,
                                    size: 12,
                                  ),
                                  SizedBox(
                                    width: 4.0,
                                  ),
                                  Text(
                                    cases[index].watchListCount.toString(),
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                      SizedBox(
                        width: cases[index].watchListCount == 0 ||
                                cases[index].watchListCount == null
                            ? 0
                            : 8.0,
                      ),
                      cases[index].commentCount == 0 ||
                              cases[index].commentCount == null
                          ? SizedBox.shrink()
                          : Container(
                              padding: EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.black45,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5.0)),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.message,
                                    color: Colors.white,
                                    size: 12,
                                  ),
                                  SizedBox(
                                    width: 4.0,
                                  ),
                                  Text(
                                    cases[index].commentCount.toString(),
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                      Spacer(),
                      cases[index].reportCount == 0 ||
                              cases[index].reportCount == null
                          ? SizedBox.shrink()
                          : Container(
                              padding: EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.deepOrange.withOpacity(0.7),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5.0)),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.warning,
                                    color: Colors.white,
                                    size: 12,
                                  ),
                                  SizedBox(
                                    width: 4.0,
                                  ),
                                  Text(
                                    "Reported by " +
                                        cases[index].reportCount.toString(),
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  //Offline Widget
  Widget offlineCaseList(BuildContext context) {
    return SingleChildScrollView(
      physics: NeverScrollableScrollPhysics(),
      padding: EdgeInsets.only(left: 8, right: 8.0, top: 10.0, bottom: 0.0),
      child: Column(
        children: <Widget>[
          Container(
            height: 50,
            child: Container(
              padding: EdgeInsets.only(bottom: 10.0, left: 10.0),
              child: ListView.builder(
                itemCount: 1,
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  return Row(
                    children: <Widget>[
                      loader
                          ? Text(" ")
                          : FilterChip(
                              showCheckmark: false,
                              elevation: 1.0,
                              selectedColor: Colors.white,
                              padding: EdgeInsets.all(4.0),
                              shape: StadiumBorder(
                                  side: BorderSide(
                                      width: 2.0,
                                      color: MaterialTools.basicColor)),
                              onSelected: (v) {},
                              backgroundColor: Colors.white,
                              label: Text(
                                "All",
                                style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                    color: MaterialTools.basicColor),
                              ),
                            ),
                      SizedBox(
                        width: 10.0,
                      )
                    ],
                  );
                },
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.all(Radius.circular(5.0)),
                border: Border.all(color: Colors.grey, width: 0.8)),
            padding: EdgeInsets.all(8.0),
            child: Column(
              children: AnimationConfiguration.toStaggeredList(
                duration: const Duration(milliseconds: 375),
                childAnimationBuilder: (widget) => FadeInAnimation(
                  // horizontalOffset: 50.0,
                  child: ScaleAnimation(
                    child: widget,
                  ),
                ),
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                          child: Text(
                        "You are offline. Please connect to internet ",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontWeight: FontWeight.w600, color: Colors.white),
                      )),
                      Icon(
                        Icons.report_problem,
                        color: Colors.red,
                      ),
                    ],
                  ),
                  Text(
                    "Swipe down to refresh",
                    style: TextStyle(fontSize: 10.0, color: Colors.white),
                  )
                ],
              ),
            ),
          ),
          offlineCredentials != null && offlineCredentials.length > 0
              ? offlineListing(context)
              : Center(
                  child: Text("No Case has been posted yet."),
                ),
        ],
      ),
    );
  }

  Widget offlineListing(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height - 160,
      width: double.infinity,
      child: RefreshIndicator(
        onRefresh: () async {
          await Future.delayed(Duration(seconds: 2));
          myLocationData.clear();
          showSavedLocations();
          hasNewUpdate = false;
          currentPageCount = 1;
          totalIncidentCount = 0;
          _radioValue =
              "most recent"; //Initial definition of radio button value
          choice = "Sorted by most recent";
          incidentGetList("all", 1);
        },
        child: ListView.builder(
            //    physics: ClampingScrollPhysics(),
            shrinkWrap: false,
            itemCount: offlineCredentials.length,
            itemBuilder: (BuildContext context, int index) {
              List<Widget> imageList = <Widget>[];
              for (int i = 0;
                  i < offlineCredentials[index]["photos"].length;
                  i++)
                imageList.add(
                    Image(
                      image: FileImage(File(offlineCredentials[index]["photos"][i]["path"].toString())),
                      fit: BoxFit.cover,
                      loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            backgroundColor: Colors.white54,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.teal),
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!.toDouble()
                                : null,
                          ),
                        );
                      },
                    ),
                );

              return Column(
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(top: 8.0),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(5.0)),
                        border: Border.all(color: Colors.black, width: 0.8)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        SizedBox(
                          height: 5,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            SizedBox(
                              width: 5,
                            ),
                            Expanded(
                              flex: 4,
                              child: Text(
                                offlineCredentials[index]["caseId"]
                                        .toString() ??
                                    " ",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    color: Colors.teal,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14),
                              ),
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Container(
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(color: Colors.black45),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(5))),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              child: Text(
                                "${offlineCredentials[index]["beencut"] + offlineCredentials[index]["mightbecut"] + offlineCredentials[index]["havebeencut"]}",
                                style: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.w600),
                              ),
                            ),
                            SizedBox(
                              width: 8,
                            ),
                            offlineCredentials[index]["beencut"] == 0
                                ? SizedBox.shrink()
                                : Container(
                                    decoration: BoxDecoration(
                                        color: Colors.red,
                                        border: Border.all(color: Colors.red),
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(5))),
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    child: Text(
                                      offlineCredentials[index]["beencut"]
                                              .toString() ??
                                          "",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600),
                                    )),
                            SizedBox(
                              width: offlineCredentials[index]["beencut"] == 0
                                  ? 0
                                  : 8,
                            ),
                            offlineCredentials[index]["mightbecut"] == 0
                                ? SizedBox.shrink()
                                : Container(
                                    decoration: BoxDecoration(
                                        color: Colors.orange,
                                        border:
                                            Border.all(color: Colors.orange),
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(5))),
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    child: Text(
                                      offlineCredentials[index]["mightbecut"]
                                              .toString() ??
                                          "",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ),
                            SizedBox(
                              width:
                                  offlineCredentials[index]["mightbecut"] == 0
                                      ? 0
                                      : 8,
                            ),
                            offlineCredentials[index]["havebeencut"] == 0
                                ? SizedBox.shrink()
                                : Container(
                                    decoration: BoxDecoration(
                                        color: Colors.grey,
                                        border: Border.all(color: Colors.grey),
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(5))),
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    child: Text(
                                      offlineCredentials[index]["havebeencut"]
                                              .toString() ??
                                          "",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white),
                                    ),
                                  ),
                            SizedBox(
                              width:
                                  offlineCredentials[index]["havebeencut"] == 0
                                      ? 0
                                      : 8,
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Text(
                            offlineCredentials[index]["placeName"] ?? " ",
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            SizedBox(
                              width: 5,
                            ),
                            Expanded(
                              flex: 5,
                              child: Text(
                                offlineCredentials[index]["time"],
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                            Expanded(
                              flex: 0,
                              child: Text(
                                offlineCredentials[index]["userName"],
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600),
                              ),
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
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => CaseDetailedView(
                                      offlineCredentials[index]["caseId"]))),
                          child: Container(
                            height: 200,
                            width: double.infinity,
                            child: Swiper(
                              itemBuilder: (BuildContext context, int k) {
                                return Image(
                                  image: FileImage(File(
                                      offlineCredentials[index]["photos"][k]
                                      ["path"]
                                          .toString())),
                                  fit: BoxFit.cover,
                                  loadingBuilder: (BuildContext context,
                                      Widget child,
                                      ImageChunkEvent? loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Center(
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        backgroundColor: Colors.white54,
                                        valueColor:
                                        AlwaysStoppedAnimation<Color>(
                                            Colors.green),
                                        value: loadingProgress.expectedTotalBytes != null
                                            ? loadingProgress.cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!.toDouble()
                                            : null,
                                      ),
                                    );
                                  },
                                );
                              },
                              itemCount:
                                  offlineCredentials[index]["photos"].length,
                              pagination:
                                  offlineCredentials[index]["photos"].length > 1
                                      ? SwiperPagination()
                                      : SwiperPagination(
                                          builder: SwiperPagination.rect),
                              loop: false,
                              autoplay: false,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  index == offlineCredentials.length - 1
                      ? SizedBox(
                          height: 100,
                          width: double.infinity,
                          child: Center(
                            child: Icon(
                              Icons.signal_cellular_connected_no_internet_4_bar,
                              color: MaterialTools.basicColor,
                              size: 40,
                            ),
                          ))
                      : SizedBox.shrink()
                ],
              );
            }),
      ),
    );
  }

  Future<void> applyFilters(Map data) async {
    setState(() {
      caseListLoading = true;
    });
    CustomResponse response =
        await ApiCall.makePostRequestToken("incident/filter", paramsData: data);
    print(json.decode(response.body));
    if (response.status == 200) {
      if (json.decode(response.body)["status"]) {
        cases.clear();
        currentPageCount = 1;
        for (int i = 0; i < json.decode(response.body)["data"].length; i++)
          cases.add(CaseTileModel(
            id: json.decode(response.body)["data"][i]["_id"],
            locationName: json.decode(response.body)["data"][i]["locationname"],
            caseId: json
                        .decode(response.body)["data"][i]["caseidentifier"]
                        .toString() ==
                    null
                ? json.decode(response.body)["data"][i]["caseid"]
                : json.decode(response.body)["data"][i]["caseidentifier"],
            userName: json.decode(response.body)["data"][i]["locationname"],
            distance: json.decode(response.body)["data"][i]["distance"],
            beenCut: json.decode(response.body)["data"][i]["beencut"],
            haveBeemCut: json.decode(response.body)["data"][i]["havebeencut"],
            mightBeCut: json.decode(response.body)["data"][i]["mightbecut"],
            caseUpdates: json.decode(response.body)["data"][i]["updates"],
            commentCount: json.decode(response.body)["data"][i]["commentcount"],
            watchListCount: json.decode(response.body)["data"][i]["watchcount"],
            reportCount: json.decode(response.body)["data"][i]["reportcount"],
            photos: json.decode(response.body)["data"][i]["photos"],
            userDetails: json.decode(response.body)["data"][i]["addedby"],
            createdDate: json.decode(response.body)["data"][i]["createddate"],
            isAnonymous: json.decode(response.body)["data"][i]["isanonymous"], time: '',
          ));
        length = cases.length;
        totalIncidentCount = length;
      } else {
        length = 0;
        zeroCountMessage = "No case list found in applied filters";
      }
      caseListLoading = false;
    } else if (response.status == 403) {
      caseListLoading = true;
      CommonWidgets.loginLimit(context);
    } else {
      caseListLoading = false;
      Fluttertoast.showToast(msg: response.body);
    }
    if (mounted) setState(() {});
  }

  late DateTime currentBackPressedTime;

  Future<bool> onWillPop() {
    if (isFiltersEnabled || isSearchEnabled) {
      setState(
        () => caseListLoading = true,
      );
      isFiltersEnabled = false;
      isSearchEnabled = false;
      filtersCount = 0;
      cases.clear();
      length = 0;
      incidentGetList("all", 1);
      return Future.value(false);
    } else {
      DateTime now = DateTime.now();
      if (currentBackPressedTime == null ||
          now.difference(currentBackPressedTime) > Duration(seconds: 3)) {
        currentBackPressedTime = now;
        Fluttertoast.showToast(msg: "Press again to exit the app");
        return Future.value(false);
      } else {
        SystemNavigator.pop();
        return Future.value(false);
      }
    }
  }

  //Bottom sheet Controller

  String _radioValue = "most recent"; //Initial definition of radio button value
  String choice = "Sorted by most recent";

  void _settingModalBottomSheet(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return Container(
            padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "SORT BY",
                    style: TextStyle(
                        color: Colors.grey, fontFamily: "OpenSans-Italic"),
                  ),
                  new Wrap(
                    children: <Widget>[
                      InkWell(
                        onTap: () => radioButtonChanges("most recent"),
                        child: new Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Expanded(
                              flex: 1,
                              child: Text(
                                "Most recent",
                                maxLines: 2,
                                overflow: TextOverflow.fade,
                              ),
                            ),
                            Expanded(
                              flex: 0,
                              child: Radio(
                                value: 'most recent',
                                groupValue: _radioValue,
                                onChanged: (String? value) {
                                  if (value != null) radioButtonChanges(value);
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      InkWell(
                        onTap: () =>
                            radioButtonChanges("most number of trees affected"),
                        child: new Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Expanded(
                              flex: 1,
                              child: Text(
                                "Most number of trees affected",
                                maxLines: 2,
                                overflow: TextOverflow.fade,
                              ),
                            ),
                            Expanded(
                              flex: 0,
                              child: Radio(
                                value: 'most number of trees affected',
                                groupValue: _radioValue,
                                onChanged: (String? value) {
                                  if (value != null) radioButtonChanges(value);
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      InkWell(
                        onTap: () => radioButtonChanges(
                            "most number of people watching"),
                        child: new Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Expanded(
                              flex: 1,
                              child: Text(
                                "Most number of people watching",
                                maxLines: 2,
                                overflow: TextOverflow.fade,
                              ),
                            ),
                            Expanded(
                              flex: 0,
                              child: Radio(
                                value: 'most number of people watching',
                                groupValue: _radioValue,
                                onChanged: (String? value) {
                                  if (value != null) radioButtonChanges(value);
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      InkWell(
                        onTap: () =>
                            radioButtonChanges("most number of comments"),
                        child: new Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Expanded(
                              flex: 1,
                              child: Text(
                                "Most number of comments",
                                maxLines: 2,
                                overflow: TextOverflow.fade,
                              ),
                            ),
                            Expanded(
                              flex: 0,
                              child: Radio(
                                value: 'most number of comments',
                                groupValue: _radioValue,
                                onChanged: (String? value) {
                                  if (value != null) radioButtonChanges(value);
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        });
  }

  void radioButtonChanges(String value) async {
    SharedPreferences preference = await SharedPreferences.getInstance();
    setState(() {
      _radioValue = value;
      switch (value) {
        case 'most recent':
          choice = "Sorted by most recent";
          currentPageCount = 1;
          cases.clear();
          length = 0;
          incidentGetList("all", 1, sort: "");
          Navigator.pop(context);
          break;
        case 'most number of trees affected':
          choice = "Sorted by no. of trees";
          currentPageCount = 1;
          cases.clear();
          length = 0;
          incidentGetList("all", 1, sort: 1);
          Navigator.pop(context);
          break;
        case 'most number of people watching':
          choice = "Sorted by no. of watchers";
          currentPageCount = 1;
          cases.clear();
          length = 0;
          incidentGetList("all", 1, sort: 2);
          Navigator.pop(context);
          break;
        case 'most number of comments':
          choice = "Sorted by no. of comments";
          currentPageCount = 1;
          cases.clear();
          length = 0;
          incidentGetList("all", 1, sort: 3);
          Navigator.pop(context);
          break;
        default:
          choice = null;
          preference.setBool("anonymous", true);
      }
      debugPrint(choice); //Debug the choice in console
    });
  }

  @override
  void dispose() {
    super.dispose();
  }
}

class CaseTileModel {
  String locationName;
  String id;
  String caseId;
  String userName;
  var distance;
  String time;
  int beenCut;
  int mightBeCut;
  int haveBeemCut;
  int updateCount;
  int watchListCount;
  int commentCount;
  int reportCount;
  List caseUpdates;
  List photos;
  String createdDate;
  bool isAnonymous;
  var userDetails;

  CaseTileModel({
    required this.id,
    required this.locationName,
    required this.caseId,
    required this.userName,
    this.distance,
    required this.time,
    this.beenCut = 0,
    this.mightBeCut = 0,
    this.haveBeemCut = 0,
    this.watchListCount = 0,
    required this.caseUpdates,
    required this.photos,
    required this.createdDate,
    this.isAnonymous = false,
    this.userDetails,
    this.updateCount = 0,
    this.commentCount = 0,
    this.reportCount = 0,
  });
}
