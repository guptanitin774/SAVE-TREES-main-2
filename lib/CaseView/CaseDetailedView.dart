import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:naturesociety_new/CaseView/DetailedCaseView.dart';
import 'package:naturesociety_new/CaseView/DiscussionForm.dart';
import 'package:naturesociety_new/CaseView/ReportCase.dart';
import 'package:naturesociety_new/ImageGallery/GalleryImageView.dart';
import 'package:naturesociety_new/Utils/LocalPrefManager.dart';
import 'package:naturesociety_new/Utils/NetworkCall.dart';
import 'package:naturesociety_new/Widgets/CommonFunction.dart';
import 'package:naturesociety_new/Widgets/CommonWidgets.dart';
import 'package:naturesociety_new/Widgets/Redux.dart';
import 'package:share/share.dart';

class CaseDetailedView extends StatefulWidget {
  final caseId;
  final tabValue;
  final bool isSearch;

  CaseDetailedView(this.caseId, {required this.isSearch, this.tabValue});

  _CaseDetailedView createState() => _CaseDetailedView();
}

String commentTypeFinalSelected = '';

class _CaseDetailedView extends State<CaseDetailedView>
    with
        SingleTickerProviderStateMixin,
        AutomaticKeepAliveClientMixin<CaseDetailedView> {
  @override
  bool get wantKeepAlive => true;
  late Map caseDetails;

  int initialIndexTab = 0;
  late TabController _tabBar;

  navigateController() {
    _tabBar.animateTo(1);
  }

  @override
  void initState() {
    super.initState();
    _tabBar = new TabController(length: 3, vsync: this);
    print(widget.caseId);
    getIncidentFullView();
    if (widget.tabValue != null)
      _tabBar.animateTo(widget.tabValue, duration: Duration(microseconds: 20));
    //initialIndexTab = widget.tabValue;
    commentTypeFinalSelected = '';
  }

  late bool _serviceEnabled;
  late LocationData _locationData;

  locationPermission() async {
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
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
        setState(() {});
        await location.hasPermission();
        CommonWidgets.permissionDialog(context: context, type: "Location");
        // appHandler.openAppSettings();
        return;
      }
    }
    _locationData = await location.getLocation();
  }

  bool dataLoading = true, authError = false;
  var samList, token;
  late PermissionStatus _permissionGranted;
  Location location = new Location();

  Future<void> getIncidentFullView() async {
    var t = await LocalPrefManager.getToken();
    print(t);

    if (_locationData == null) await locationPermission();
    if (await location.serviceEnabled() &&
        _permissionGranted == PermissionStatus.granted)
      _locationData = await location.getLocation();
    else {}
    token = await LocalPrefManager.getToken();

    CustomResponse response = await ApiCall.makeGetRequestToken(
        'incident/get?id=${widget.caseId}&issearch=${widget.isSearch ?? false}'
        '${_locationData == null ? "" : "&lat=${_locationData.latitude}&lon=${_locationData.longitude}"}');
    if (response.status == 200) {
      if (json.decode(response.body)["status"]) {
        caseDetails = json.decode(response.body)["data"];
        dataLoading = false;
        StoreProvider.of<AppState>(context).dispatch(
            IsInWatchList(caseDetails["isinwatchlist"] ? true : false));
      } else
        CommonWidgets.alertBox(context, json.decode(response.body)["msg"],
            leaveThatPage: true);
      isConnected = true;
    } else if (response.status == 403) {
      dataLoading = true;
      authError = true;
      CommonWidgets.loginLimit(context);
    } else
      isConnected = false;
    if (mounted) setState(() {});
  }

  Future<void> addToWatchList() async {
    Map data = {"id": widget.caseId};
    CustomResponse response = await ApiCall.makePostRequestToken(
        "incident/watchlist/add",
        paramsData: data);
    if (response.status == 200) if (json.decode(response.body)["status"]) {
      StoreProvider.of<AppState>(context).dispatch(IsInWatchList(true));
      Fluttertoast.showToast(msg: "Added to Watchlist");
    } else
      Fluttertoast.showToast(msg: "Sorry! Failed to add case to Watch List");
  }

  Future<void> removeFromWatchList() async {
    Map data = {"id": widget.caseId};
    CustomResponse response = await ApiCall.makePostRequestToken(
        "incident/watchlist/remove",
        paramsData: data);
    if (response.status == 200) if (json.decode(response.body)["status"]) {
      StoreProvider.of<AppState>(context).dispatch(IsInWatchList(false));
      Fluttertoast.showToast(msg: "Removed from Watchlist");
    } else
      Fluttertoast.showToast(
          msg: "Sorry! Failed to remove case from Watch List");
  }

  void _onShareTap(var linkMessage) async {
    int treeCount = await caseDetails["mightbecut"] +
        caseDetails["beencut"] +
        caseDetails["havebeencut"];
    String text = "Checkout this case about $treeCount " +
        "${treeCount > 1 ? "trees" : "tree"}" +
        " at " +
        caseDetails["locationname"] +
        ", using Save Tress app. (Case ID: ${caseDetails["caseidentifier"] == null ? caseDetails["caseid"] : caseDetails["caseidentifier"]})";
    final RenderBox? box = context.findRenderObject() as RenderBox?;
    Share.share(
      text + "\n" + linkMessage,
      sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
    );
  }

  bool isConnected = true;

  Widget noConnectionMessage(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Image(
                image: AssetImage("assets/noconnection.png"),
              ),
              Text(
                "Opps !",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 32.0),
              ),
              SizedBox(
                height: 10,
              ),
              Text("Failed to establish connection"),
              SizedBox(
                height: 10,
              ),
              Text("Please Connect to WiFi or Mobile Data "),
              SizedBox(
                height: 25.0,
              ),
              FloatingActionButton.extended(
                onPressed: () {
                  getIncidentFullView();
                  if (widget.tabValue != null)
                    initialIndexTab = widget.tabValue;
                },
                label: Text("Refresh"),
                icon: Icon(Icons.refresh),
                heroTag: "refreshbtn",
                foregroundColor: Colors.white,
                backgroundColor: Colors.teal,
                splashColor: Colors.transparent,
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                "You can still post cases in Offline - Mode",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              SizedBox(
                height: 10.0,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    Icons.star,
                    size: 10.0,
                    color: Colors.red,
                  ),
                  SizedBox(
                    width: 5.0,
                  ),
                  Text(
                    "The Cases will be Uploaded only when you are connected to a Network",
                    style: TextStyle(fontSize: 11.5),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
              SizedBox(
                height: 10.0,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> _onWillPop() async {
    allComments.clear();
    cacheChatList.clear();
    chatList.clear();
    Navigator.of(context).pop(true);
    // Navigator.pop(context);
    return Future.value(false);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: StoreConnector<AppState, AppState>(
          converter: (store) => store.state,
          builder: (context, state) {
            return DefaultTabController(
              initialIndex: initialIndexTab,
              length: 3,
              child: Scaffold(
                appBar: AppBar(
                  elevation: 5.5,
                  iconTheme: IconThemeData(color: Colors.black),
                  backgroundColor: Colors.white,
                  actions: dataLoading || !isConnected
                      ? <Widget>[]
                      : <Widget>[
                          IconButton(
                            iconSize: 20,
                            tooltip: "Add to watchList",
                            onPressed: () => state.isInWatchList
                                ? removeFromWatchList()
                                : addToWatchList(),
                            icon: Icon(Icons.remove_red_eye,
                                color: state.isInWatchList
                                    ? Colors.teal
                                    : Colors.black),
                          ),
                          IconButton(
                            iconSize: 20,
                            tooltip: "Share this Case",
                            onPressed: () async {
                              var link = await CommonFunction.createDynamicLink(
                                  caseId: "${widget.caseId}",
                                  description: caseDetails["locationname"],
                                  title:
                                      "Case ID: ${caseDetails["caseidentifier"] == null ? caseDetails["caseid"].toString() : caseDetails["caseidentifier"].toString()}",
                                  image: caseDetails["photos"][0]["photo"]);
                              if (link != null) _onShareTap(link);
                            },
                            icon: Icon(Icons.share),
                          ),
                          PopupMenuButton<int>(
                            tooltip: "More options",
                            icon: Icon(
                              Icons.more_vert,
                            ),
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                value: 0,
                                child: Text("Report this case"),
                              ),
                            ],
                            onSelected: (value) {
                              if (value == 0 && isConnected)
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => ReportCase(
                                            widget.caseId, caseDetails)));
                            },
                          )
                        ],
                  bottom: TabBar(
                    isScrollable: false,
                    indicatorColor: Colors.teal,
                    controller: _tabBar,
                    tabs: <Tab>[
                      Tab(
                          child: Text(
                        'Summary',
                        style: TextStyle(color: Colors.black),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      )),
                      Tab(
                          child: Text(
                        'Discussion',
                        style: TextStyle(
                          color: Colors.black,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      )),
                      Tab(
                          child: Text(
                        'Gallery',
                        style: TextStyle(
                          color: Colors.black,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      )),
                    ],
                  ),
                  title: Text(
                    dataLoading
                        ? ""
                        : '${caseDetails["caseidentifier"] == null ? caseDetails["caseid"].toString() : caseDetails["caseidentifier"].toString()}',
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                ),
                body: !isConnected
                    ? noConnectionMessage(context)
                    : !dataLoading
                        ? TabBarView(
                            physics: NeverScrollableScrollPhysics(),
                            controller: _tabBar,
                            children: [
                              CaseView(
                                navigateController,
                                caseDetails,
                                key: PageStorageKey('summary'),
                              ),
                              CaseDiscussion(
                                caseDetails,
                                token,
                                key: PageStorageKey('discussion'),
                              ),
                              CaseGallery(
                                caseDetails,
                                key: PageStorageKey('gallery'),
                              ),
                            ],
                          )
                        : authError
                            ? Container()
                            : CommonWidgets.progressIndicator(context),
              ),
            );
          }),
    );
  }
}

class Controller {
  late Future<void> Function() selection;
  var key;
}

class CaseGallery extends StatefulWidget {
  final caseDetails;

  CaseGallery(
    this.caseDetails, {
    required Key key,
  }) : super(key: key);

  _CaseGallery createState() => _CaseGallery();
}

class _CaseGallery extends State<CaseGallery> {
  final highLightName =
      TextStyle(color: Colors.black, fontWeight: FontWeight.w600);
  final dateStyle = TextStyle(color: Colors.grey, fontWeight: FontWeight.w600);
  var dateFormatter = new DateFormat('dd-MMM-yyyy');

  Future<bool> onWillPop() {
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) =>
                CaseDetailedView(widget.caseDetails["_id"], isSearch: true)));
    return Future.value(false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.all(15.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            widget.caseDetails["updates"].isNotEmpty
                ? Column(
                    children: _updatedCasePhoto(context),
                  )
                : SizedBox.shrink(),
            SizedBox(
              height: 15.0,
            ),
            Wrap(
              alignment: WrapAlignment.start,
              crossAxisAlignment: WrapCrossAlignment.start,
              children: <Widget>[
                Text(
                  dateFormatter.format(
                      DateTime.parse(widget.caseDetails["createddate"])),
                  style: dateStyle,
                ),
                SizedBox(
                  width: 5.0,
                ),
                Text(
                  widget.caseDetails["isanonymous"]
                      ? "Initiated by Anonymous"
                      : "Initiated by ${widget.caseDetails["addedby"]["name"]}",
                  style: highLightName,
                ),
                SizedBox(
                  width: 5.0,
                ),
                Text(
                  "(${widget.caseDetails["photos"].length})",
                  style: highLightName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
            SizedBox(
              height: 5.0,
            ),
            AnimationLimiter(
                child: GridView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: widget.caseDetails["photos"].length,
                    shrinkWrap: true,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                        crossAxisCount: 3),
                    itemBuilder: (context, index) {
                      return AnimationConfiguration.staggeredGrid(
                          position: index,
                          duration: const Duration(milliseconds: 400),
                          columnCount: 3,
                          child: ScaleAnimation(
                              child: FadeInAnimation(
                            child: InkWell(
                              onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => GalleryImageView(
                                          widget.caseDetails["photos"],
                                          index,
                                          widget.caseDetails))),
                              child: Container(
                                  padding: const EdgeInsets.all(2.0),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.blueGrey),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(5.0)),
                                  ),
                                  height: 200,
                                  width: 200,
                                  child: ClipRRect(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(5.0)),
                                      child: Image(
                                        image: NetworkImage(ApiCall.imageUrl +
                                            widget.caseDetails["photos"][index]
                                                ["photo"]),
                                        fit: BoxFit.cover,
                                        loadingBuilder: (BuildContext context,
                                            Widget child,
                                            ImageChunkEvent? loadingProgress) {
                                          if (loadingProgress == null)
                                            return child;
                                          return Center(
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              backgroundColor: Colors.white54,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                      Colors.green),
                                              value: loadingProgress
                                                          .expectedTotalBytes !=
                                                      null
                                                  ? loadingProgress
                                                          .cumulativeBytesLoaded /
                                                      (loadingProgress
                                                              .expectedTotalBytes ??
                                                          1)
                                                  : null,
                                            ),
                                          );
                                        },
                                      ))),
                            ),
                          )));
                    })),
            SizedBox(
              height: 5.0,
            ),
          ],
        ),
      ),
    );
  }

  _updatedCasePhoto(BuildContext context) {
    List<Widget> updatesDetails = <Widget>[];
    for (int i = widget.caseDetails["updates"].length - 1; i >= 0; i--)
      updatesDetails.add(Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            height: 15.0,
          ),
          Wrap(
            alignment: WrapAlignment.start,
            crossAxisAlignment: WrapCrossAlignment.start,
            children: <Widget>[
              Text(
                dateFormatter.format(DateTime.parse(
                    widget.caseDetails["updates"][i]["createddate"])),
                style: dateStyle,
              ),
              SizedBox(
                width: 5.0,
              ),
              Text(
                widget.caseDetails["updates"][i]["isanonymous"]
                    ? "Updated by anonymous"
                    : "Updated by ${widget.caseDetails["updates"][i]["addedby"]["name"]}",
                style: highLightName,
              ),
              SizedBox(
                width: 5.0,
              ),
              Text(
                "(${widget.caseDetails["updates"][i]["photos"].length})",
                style: highLightName,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          SizedBox(
            height: 10.0,
          ),
          AnimationLimiter(
            child: GridView.builder(
                physics: NeverScrollableScrollPhysics(),
                itemCount: widget.caseDetails["updates"][i]["photos"].length,
                shrinkWrap: true,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisSpacing: 8, mainAxisSpacing: 8, crossAxisCount: 3),
                itemBuilder: (context, index) {
                  return AnimationConfiguration.staggeredGrid(
                      position: index,
                      duration: const Duration(milliseconds: 400),
                      columnCount: 3,
                      child: ScaleAnimation(
                          child: FadeInAnimation(
                        child: InkWell(
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => GalleryImageView(
                                      widget.caseDetails["updates"][i]
                                          ["photos"],
                                      index,
                                      widget.caseDetails["updates"][i]))),
                          child: Container(
                              padding: const EdgeInsets.all(2.0),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.blueGrey),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5.0)),
                              ),
                              height: 200,
                              width: 200,
                              child: ClipRRect(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5.0)),
                                child: Image(
                                  image: NetworkImage(ApiCall.imageUrl +
                                      widget.caseDetails["updates"][i]["photos"]
                                          [index]["photo"]),
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
                                        value: loadingProgress
                                                    .expectedTotalBytes !=
                                                null
                                            ? loadingProgress
                                                    .cumulativeBytesLoaded /
                                                (loadingProgress
                                                        .expectedTotalBytes ??
                                                    1)
                                            : null,
                                      ),
                                    );
                                  },
                                ),
                              )),
                        ),
                      )));
                }),
          ),
        ],
      ));

    return updatesDetails;
  }
}
