

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:naturesociety_new/CaseView/DiscussionForm.dart';
import 'package:naturesociety_new/CaseView/ReportCase.dart';
import 'package:naturesociety_new/ImageGallery/GalleryImageView.dart';
import 'package:naturesociety_new/Utils/LocalPrefManager.dart';
import 'package:naturesociety_new/Utils/NetworkCall.dart';
import 'package:naturesociety_new/Widgets/CommonFunction.dart';
import 'package:naturesociety_new/Widgets/CommonWidgets.dart';
import 'package:naturesociety_new/Widgets/ReadMoreText.dart';
import 'package:naturesociety_new/Widgets/Redux.dart';
import 'package:share/share.dart';
import 'dart:ui' as ui;


class SimilarCaseDetailedView extends StatefulWidget{

  final similarCaseId, postCaseId;
  SimilarCaseDetailedView(this.similarCaseId, this.postCaseId);

  _SimilarCaseDetailedView createState()=> _SimilarCaseDetailedView();
}

class _SimilarCaseDetailedView extends State<SimilarCaseDetailedView>{

  bool isLoading = true;
  Map caseDetails;

  @override
  void initState(){
    super.initState();
    getCaseDetails();

  }

  bool dataLoading = true,  isInWatchlist = false;
  var token;
  Location location = new Location();

  Future<void> getCaseDetails() async{
    token = await LocalPrefManager.getToken();
    LocationData   currentLocation ;
    currentLocation = await location.getLocation();

    CustomResponse response =  await ApiCall.makeGetRequestToken('incident/get?id=${widget.similarCaseId}&lat=${currentLocation.latitude}&lon=${currentLocation.longitude}');
    if(response.status == 200)
      if(json.decode(response.body)["status"])
        setState(() {
          caseDetails = json.decode(response.body)["data"];
          StoreProvider.of<AppState>(context).dispatch(IsInWatchList(caseDetails["isinwatchlist"] ? true : false));
          dataLoading = false;
        });
      else
        setState(() {
          dataLoading = false;
          Fluttertoast.showToast(msg: json.decode(response.body)["msg"]);
        });
    else
    {
      setState(() {
        dataLoading = false;
      });
      Fluttertoast.showToast(msg: response.body);
      Navigator.pop(context);
    }
  }
  Future<void> addToWatchList() async{
    Map data ={
      "id": caseDetails["_id"]
    };
    var response = await ApiCall.makePostRequestToken("incident/watchlist/add", paramsData: data);
    if(json.decode(response.body)["status"])
    {
      StoreProvider.of<AppState>(context).dispatch(IsInWatchList(true));
      Fluttertoast.showToast(msg: "This case has been added to your Watch List");}
    else
      Fluttertoast.showToast(msg: json.decode(response.body)["msg"]);
  }

  Future<void> removeFromWatchList() async{
    Map data ={
      "id": caseDetails["_id"]
    };
    CustomResponse response = await ApiCall.makePostRequestToken("incident/watchlist/remove", paramsData: data);
    if(response.status == 200)
      if(json.decode(response.body)["status"]) {
        StoreProvider.of<AppState>(context).dispatch(IsInWatchList( false));
        Fluttertoast.showToast(msg: "This case has been removed from your Watch List");
      }
      else
        Fluttertoast.showToast(msg: "Sorry! Failed to remove case from Watch List");
  }

  void _onShareTap(var linkMessage) {
    int treeCount = caseDetails["mightbecut"]+caseDetails["beencut"]+caseDetails["havebeencut"];
    String text = "Checkout this case about $treeCount "+"${treeCount >1 ?"trees":"tree"} "+" at "+
        caseDetails["locationname"]+" using Save Tress app. (Case ID: ${caseDetails["caseidentifier"]==null?
    caseDetails["caseid"] : caseDetails["caseidentifier"]})";

    final RenderBox box = context.findRenderObject();
    Share.share(text+"\n"+linkMessage,
        sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size);
  }


  @override
  Widget build(BuildContext context) {
    return   StoreConnector<AppState, AppState>(
        converter: (store) => store.state,
        builder: (context, state) {
          return DefaultTabController(
            length: 3,
            child: Scaffold(
              appBar: AppBar(
                iconTheme: IconThemeData(color: Colors.black),
                leading:IconButton(
                  onPressed: ()=> Navigator.pop(context),
                  icon: Icon(Icons.arrow_back,),
                ) ,
                backgroundColor: Colors.white,
                actions: dataLoading ? <Widget>[] : <Widget>[
                  IconButton(
                    iconSize: 20,
                    tooltip: "Add to WatchList",
                    onPressed: ()=> state.isInWatchList ?removeFromWatchList() :addToWatchList(),
                    icon: Icon(Icons.remove_red_eye ,color: state.isInWatchList ? Colors.teal : Colors.black,),
                  ),
                  IconButton(
                    iconSize: 20,
                    tooltip: "Share this Case",
                    onPressed: () async {
                      var link = await CommonFunction.createDynamicLink(caseId: widget.similarCaseId,
                          description: caseDetails["locationname"], title:"Case ID: ${caseDetails["caseidentifier"] == null?
                          caseDetails["caseid"].toString() : caseDetails["caseidentifier"].toString()}",
                          image: caseDetails["photos"][0]["photo"] );
                      if(link !=  null)
                        _onShareTap(link);
                    },
                    icon: Icon(Icons.share),
                  ),

                  PopupMenuButton<int>(
                    tooltip: "More options",
                    icon: Icon(Icons.more_vert),
                    itemBuilder: (context)=>[
                      PopupMenuItem(
                        value: 0,
                        child: Text("Report this case"),
                      ),
                    ],
                    onSelected: (value){
                      if(value == 0)
                        Navigator.push(context, MaterialPageRoute(builder: (context) =>
                            ReportCase(widget.similarCaseId, caseDetails)));
                    },
                  )
                ],
                bottom: TabBar(
                  indicatorColor: Colors.teal,
                  indicatorSize: TabBarIndicatorSize.tab,
                  tabs: [
                    Tab(child: Text('Summary',style: TextStyle(color: Colors.black),)),
                    Tab(child: Text('Discussion',style: TextStyle(color: Colors.black),)),
                    Tab(child: Text('Gallery',style: TextStyle(color: Colors.black),)),
                    //Tab(child: Text('Charges Bill',style: TextStyle(color: Colors.black),)),
                  ],
                ),
                title: Text(dataLoading? "" :'${caseDetails["caseidentifier"]==null? caseDetails["caseid"] :caseDetails["caseidentifier"]}',style: TextStyle(color: Colors.black),),
              ),
              body: !dataLoading ?TabBarView(
                children: [
                  CaseSummary(navigateController,widget.postCaseId,caseDetails),
                  CaseDiscussion(caseDetails, token),
                  CaseGallery(widget.postCaseId,caseDetails),
                ],
              ) : CommonWidgets.progressIndicator(context),
            ),

          );}
    );
  }
  TabController _tabBar ;
  navigateController(){
    _tabBar.animateTo(1);

  }

}


class CaseSummary extends StatefulWidget{
  void Function() navigations;
  final caseId;
  final caseDetails;
  CaseSummary(this.navigations,this.caseId,this.caseDetails);

  _CaseSummary createState()=> _CaseSummary();
}

class _CaseSummary extends State<CaseSummary> {

  Completer<GoogleMapController> _controller = Completer();
  Position position;
  var lat, lon;
  final Set<Marker> markers = Set();
  List <Widget>imageList = <Widget>[];
  var caseChart;
  bool isCaseHasUpdates = false;
  int sliderValue = 0;


  @override
  void initState() {
    caseChart = widget.caseDetails;
    isCaseHasUpdates = widget.caseDetails["updates"].length > 0 ? true : false;
    loadFunctions();
    super.initState();
  }
  Uint8List markerIcon;
  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(), targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png)).buffer.asUint8List();
  }
  void loadFunctions() async {
    markers.clear();
    markers.add(Marker(
        position: LatLng(caseChart["location"][1], caseChart["location"][0]),
        markerId: MarkerId("selected-location"),
        //icon: BitmapDescriptor.fromBytes(markerIcon),
        onTap: (){
          CommonFunction.openMap(caseChart["location"][1], caseChart["location"][0]);
        }
    ));
    imageList.clear();

    for (int i = 0; i < caseChart["photos"].length; i++)
      imageList.add(Image.network(
        ApiCall.imageUrl + caseChart["photos"][i]["photo"].toString(),
        cacheWidth: 500, cacheHeight: 500, fit: BoxFit.cover,),);

    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(
        target: LatLng(caseChart["location"][1], caseChart["location"][0]),
        zoom: 15.77,
      ),
    ));
    recentComments = caseChart["comments"];
    setState(() {});
  }
  List recentComments =[];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      floatingActionButton: MaterialButton(
        color: Colors.teal,
        minWidth: double.infinity,
        height: 60.0,
        onPressed: () => markUpdate(),
        child: Text("Post an update", style: TextStyle(
            fontWeight: FontWeight.w600, color: Colors.white, fontSize: 18.0),),
      ),

      body: StoreConnector<AppState, AppState>(
          converter: (store) => store.state,
          builder: (context, state) {
            return SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                physics: ClampingScrollPhysics(),
                child: AnimationLimiter(
                  child: Column(

                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: AnimationConfiguration.toStaggeredList(
                      duration: const Duration(milliseconds: 400),
                      childAnimationBuilder: (widget) => SlideAnimation(
                        horizontalOffset: 50.0,
                        child: SlideAnimation(
                          child: widget,
                        ),
                      ),
                      children: <Widget>[

                        isCaseHasUpdates ? Container(
                          margin: EdgeInsets.only(bottom: 10.0),
                          height: 50.0,
                          decoration: BoxDecoration(color: Colors.teal.withOpacity(0.2),
                              border: Border.all(color: Colors.teal, width: 1.8)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              IconButton(
                                icon: Icon(Icons.arrow_back_ios),
                                color: sliderValue == 0 ? Colors.grey : Colors.teal,
                                onPressed: () =>
                                sliderValue == 0 ? null : {
                                  setState(() {
                                    sliderValue --;
                                    if (sliderValue == 0) {
                                      caseChart = widget.caseDetails;
                                      loadFunctions();
                                    }
                                    else {
                                      caseChart =
                                      widget.caseDetails["updates"][sliderValue - 1];
                                      loadFunctions();
                                    }
                                  }),
                                },
                              ),
                              Spacer(),
                              Text(
                                sliderValue == 0 ? "Original Post" : "Updates ${sliderValue
                                    .toString()}", style: TextStyle(
                                  color: Colors.teal, fontWeight: FontWeight.w600),),
                              SizedBox(width: 5.0,),
                              IconButton(
                                icon: Icon(Icons.arrow_drop_down),
                                color: Colors.grey,
                                onPressed: () {
                                  showUpdateDialog(context);
                                },
                              ),
                              Spacer(),
                              IconButton(
                                icon: Icon(Icons.arrow_forward_ios),
                                onPressed: () =>
                                sliderValue == widget.caseDetails["updates"].length
                                    ? null
                                    : {
                                  setState(() {
                                    sliderValue ++;
                                    if (sliderValue == 0) {
                                      caseChart = widget.caseDetails;
                                      loadFunctions();
                                    }
                                    else {
                                      caseChart =
                                      widget.caseDetails["updates"][sliderValue - 1];
                                      loadFunctions();
                                    }
                                  }),
                                },
                                color: sliderValue == widget.caseDetails["updates"].length
                                    ? Colors.grey
                                    : Colors.teal,
                              ),
                            ],
                          ),
                        ) : SizedBox.shrink(),


                        Container(
                          height: 200, width: double.infinity,
                          child:
                          Swiper(
                            itemBuilder:
                                (BuildContext context,int k){
                              return Image(image: NetworkImage(ApiCall.imageUrl+caseChart["photos"][k]["photo"].toString()) ,fit:  BoxFit.cover,
                                loadingBuilder:(BuildContext context, Widget child,ImageChunkEvent loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Center(
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      backgroundColor: Colors.white54,
                                      valueColor: new AlwaysStoppedAnimation<Color>(Colors.green),
                                      value: loadingProgress.expectedTotalBytes != null ?
                                      loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes
                                          : null,
                                    ),
                                  );
                                },);
                            },
                            itemCount: caseChart["photos"].length,
                            pagination: caseChart["photos"].length > 1 ? SwiperPagination() : SwiperPagination(builder: SwiperPagination.rect),
                            loop: false,
                            autoplay: false,
                          ),
                        ),

                        SizedBox(height: 5,),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(isCaseHasUpdates &&  sliderValue == 0 ?"Posted by:": "Updated by:", style: TextStyle(fontSize: 12,),),
                                  SizedBox(height: 8.0,),
                                  Text(caseChart["isanonymous"]
                                      ? "Anonymous"
                                      : caseChart["addedby"]["name"] == null
                                      ? " "
                                      : caseChart["addedby"]["name"],
                                    style: TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.w800),),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: <Widget>[
                                      SizedBox(width: 5,),
                                      Container(
                                        decoration: BoxDecoration(color: Colors.white,
                                            border: Border.all(color: Colors.black45),
                                            borderRadius: BorderRadius.all(Radius.circular(5))),
                                        padding:EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        child: Text("${caseChart["beencut"]+caseChart["mightbecut"]+
                                            caseChart["havebeencut"]}",  textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w600),),
                                      ),

                                      SizedBox(width: caseChart["beencut"] ==0 ? 0:8,),
                                      caseChart["beencut"] == 0? SizedBox.shrink():Container(decoration: BoxDecoration(color: Colors.red,
                                          border: Border.all(color: Colors.red),
                                          borderRadius: BorderRadius.all(Radius.circular(5))),
                                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          child: Text(caseChart["beencut"].toString() ?? "",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w600),)),

                                      SizedBox(width: caseChart["mightbecut"] == 0 ? 0:8,),
                                      caseChart["mightbecut"] == 0? SizedBox.shrink():
                                      Container( decoration: BoxDecoration(color: Colors.orange,
                                          border: Border.all(color: Colors.orange),
                                          borderRadius: BorderRadius.all(Radius.circular(5))),
                                        padding:EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        child: Text(caseChart["mightbecut"].toString() ?? "", textAlign: TextAlign.center,
                                          style: TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w600),),),

                                      SizedBox(width: caseChart["havebeencut"] == 0 ? 0:8,),
                                      caseChart["havebeencut"] == 0 ? SizedBox.shrink() : Container( decoration: BoxDecoration(
                                          color: Colors.grey,
                                          border: Border.all(color: Colors.grey),
                                          borderRadius: BorderRadius.all(Radius.circular(5))),
                                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        child: Text(caseChart["havebeencut"].toString() ?? "", textAlign: TextAlign.center,
                                          style: TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w600),),),
                                    ],
                                  ),

                                  SizedBox(height: 8.0,),

                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text(CommonFunction.timeWithStatus(caseChart["createddate"]),
                                        style: TextStyle(color: Colors.black, fontSize: 12),),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 10,),
                        Text("Location", style: TextStyle(color: Colors.grey),),
                        Text(caseChart["locationname"]??" ", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),textAlign: TextAlign.left,),
                        SizedBox(height: 5.0,),
                        Container(
                          padding: EdgeInsets.all(5.0),
                          color: Colors.transparent.withOpacity(0.1),
                          width: double.infinity,
                          child: Text("Click on the pin to see navigation options",
                            style: TextStyle(color: Colors.black),
                            textAlign: TextAlign.center,),
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
                              target: LatLng(caseChart["location"][1], caseChart["location"][0]),
                              zoom: 15.77,
                            ),
                            markers:  markers,
                            onMapCreated: (GoogleMapController controller)
                            {
                              _controller.complete(controller);
                            },
                          ),
                        ),


                        caseChart["beencut"] > 0 ? Container(
                          margin: EdgeInsets.symmetric(vertical: 5.0),
                          decoration: BoxDecoration(border: Border.all(
                              width: 1.8, color: Colors.redAccent.withOpacity(.2))),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Expanded(flex: 3,
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 15.0, horizontal: 5.0),
                                  color: Colors.redAccent.withOpacity(.2),
                                  width: MediaQuery.of(context).size.width / 2 + 60,
                                  child: Row(
                                    children: <Widget>[
                                      CircleAvatar(
                                        radius: 8, backgroundColor: Colors.redAccent,),
                                      SizedBox(width: 5.0,),
                                      Text("Tree Is Being Cut / Damaged")
                                    ],
                                  ),
                                ),
                              ),
                              VerticalDivider(
                                color: Colors.amber, width: 5, thickness: 2.5,),
                              Expanded(
                                flex: 1, child: Center(child: Text(caseChart["beencut"]
                                  .toString() ?? " ", style: TextStyle(
                                  fontWeight: FontWeight.w600),)),),
                            ],
                          ),
                        ) : SizedBox.shrink(),

                        caseChart["mightbecut"] > 0 ? Container(
                          margin: EdgeInsets.symmetric(vertical: 5.0),
                          decoration: BoxDecoration(border: Border.all(
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
                                          vertical: 15.0, horizontal: 5.0),
                                      color: Colors.amber.withOpacity(.2),
                                      width: MediaQuery.of(context).size.width / 2 + 60,
                                      child: Row(
                                        children: <Widget>[
                                          CircleAvatar(radius: 8, backgroundColor: Colors.orangeAccent,),
                                          SizedBox(width: 5.0,),
                                          Text("Tree Might Be Cut / Damaged")
                                        ],
                                      ),
                                    ),
                                  ),

                                  VerticalDivider(
                                    color: Colors.amber, width: 5, thickness: 2.5,),
                                  Expanded(flex: 1, child: Center(child: Text(
                                    caseChart["mightbecut"].toString() ?? " ",
                                    style: TextStyle(fontWeight: FontWeight.w600),)),),
                                ],
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(
                                    vertical: 10.0, horizontal: 10.0),
                                decoration: BoxDecoration(
                                  border: Border.all(width: 1.8, color: Colors.amber.withOpacity(.2)),
                                  color: Colors.amber.withOpacity(.2),),

                                child: caseChart["mightbecutreason"].isNotEmpty ? Column(
                                  children: mightBeCutReason(context),) : SizedBox
                                    .shrink(),
                              ),
                            ],
                          ),
                        ) : SizedBox.shrink(),

                        caseChart["havebeencut"] > 0 ? Container(
                          margin: EdgeInsets.symmetric(vertical: 5.0),
                          decoration: BoxDecoration(border: Border.all(
                              width: 1.8, color: Colors.grey.withOpacity(.2))),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,

                            children: <Widget>[
                              Expanded(
                                flex: 3,
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 15.0, horizontal: 5.0),
                                  color: Colors.grey.withOpacity(.2),
                                  width: MediaQuery.of(context).size.width / 2 + 60,
                                  child: Row(
                                    children: <Widget>[
                                      CircleAvatar(
                                        radius: 8, backgroundColor: Colors.grey,),
                                      SizedBox(width: 5.0,),
                                      Text("Tree Has Been Cut / Damaged")
                                    ],
                                  ),
                                ),
                              ),

                              VerticalDivider(
                                color: Colors.amber, width: 5, thickness: 2.5,),
                              Expanded(flex: 1,
                                child: Center(child: Text(caseChart["havebeencut"]
                                    .toString() ?? " ", style: TextStyle(
                                    fontWeight: FontWeight.w600),)),),
                            ],
                          ),
                        ) : SizedBox.shrink(),
                        SizedBox(height: 5.0,),


                        caseChart["description"] != null  ?Container(child:  ReadMoreText(
                          caseChart["description"]?? "",
                          trimLines: 5,
                          colorClickableText: Colors.teal,
                          trimMode: TrimMode.Line,
                          trimCollapsedText: ' ...  show more',
                          trimExpandedText: '   show less',
                          textAlign: TextAlign.justify,
                          style: TextStyle(color: Colors.black),
                        ),

                        ): SizedBox.shrink(),

                        caseChart["description"] != null  ? Divider(thickness:  1.0 , height: 20,):
                        SizedBox.shrink(),

                        recentComments.isEmpty? SizedBox.shrink():
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SizedBox(height: 20,),
                            Text("Latest comments", style: TextStyle(color: Colors.black45),),
                            SizedBox(height: 10.0,),
                            Column(
                              children:recentDiscussion(context),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10.0),
                              child: MaterialButton(
                                elevation: 1.0,
                                minWidth: double.infinity,
                                shape: RoundedRectangleBorder(
                                    side: BorderSide(color: Colors.black45, width: 0.5 )
                                ),
                                onPressed: (){
                                  widget.navigations();
                                },
                                color: Colors.white,
                                child: Text("Go to discussion", style: TextStyle(color: Colors.black45, fontWeight: FontWeight.w600),),
                              ),
                            )
                          ],
                        ),

                        SizedBox(height: 10,),



                        MaterialButton(
                          elevation: 1.0,
                          splashColor: state.isInWatchList? Colors.grey.withOpacity(0.5) : Colors.grey.withOpacity(0.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(1.0),
                            side: BorderSide(color: state.isInWatchList? Colors.teal : Colors.grey, width: 0.5,),
                          ),
                          color: state.isInWatchList? Colors.teal.withOpacity(0.6) :Colors.white,
                          minWidth: double.infinity,
                          height: 50.0,
                          textColor: state.isInWatchList? Colors.white : Colors.black,
                          onPressed: ()=> state.isInWatchList? removeFromWatchList() :addToWatchList(),
                          child: Center(child: Text(state.isInWatchList? "Remove from watchlist": "Add to watchlist")),
                        ),


                        SizedBox(height: 10.0,),
                        MaterialButton(
                          elevation: 1.0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(1.0),
                            side: BorderSide(color: state.isInWatchList? Colors.teal : Colors.grey, width: 0.5,),
                          ),
                          color: Colors.white,
                          minWidth: double.infinity,
                          height: 50.0,
                          onPressed: ()  async {
                            var link  = await CommonFunction.createDynamicLink(
                                caseId: widget.caseDetails["_id"],
                                description: caseChart["locationname"],
                                title: "Case ID: ${caseChart["caseidentifier"] == null?
                                caseChart["caseid"].toString(): caseChart["caseidentifier"].toString()}",
                                image: caseChart["photos"][0]["photo"]
                            );
                            if(link !=  null)
                              _onShareTap(link);
                          },
                          child: Center(child: Text("Share this case")),
                        ),

                        SizedBox(height: 70.0,),
                      ],
                    ),

                  ),
                ),
              ),
            );}
      ),
    );
  }

  // ------ Recent Comments -----------
  recentDiscussion(BuildContext context){
    final List <Widget> comments = <Widget>[];
    for(int i=0; i<caseChart["comments"].length; i++)
      comments.add(Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 15, backgroundColor: Colors.grey,
                backgroundImage: caseChart["comments"][i]["user"]["photo"] !=null? CachedNetworkImageProvider(ApiCall.imageUrl+caseChart["comments"][i]["user"]["photo"] ?? " "):
                null,
              ),
              SizedBox(width: 10.0,),
              Expanded(

                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(caseChart["comments"][i]["user"]["name"] != null ?
                      caseChart["comments"][i]["user"]["name"] : "Anonymous", style:  TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: Colors.black),),
                      SizedBox(height: 8.0,),
                      Text(caseChart["comments"][i]["text"],maxLines: 5, overflow: TextOverflow.ellipsis,),
                    ],
                  ))
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 40),
            child: Text(CommonFunction.timeCalculation(caseChart["comments"][i]["createdAt"]),
              style: TextStyle(color: Colors.grey, fontSize: 11.5,fontWeight: FontWeight.w600 ),),
          ),
          SizedBox(height: 10.0,)
        ],
      ));
    return comments;
  }


  mightBeCutReason(BuildContext context) {
    final List <Widget> reasonList = <Widget>[];
    for (int i = 0; i < caseChart["mightbecutreason"].length; i++)
      reasonList.add(Padding(
        padding: const EdgeInsets.only(bottom: 10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Expanded(flex: 0,
              child: CircleAvatar(radius: 5.0, backgroundColor: Colors.white,),
            ),
            SizedBox(width: 10.0,),
            Expanded(
              flex: 1,
              child: Text(caseChart["mightbecutreason"][i]),
            ),
          ],
        ),
      ));
    return reasonList;
  }

//------- Case Update Dialog------------
  Future<void> showUpdateDialog(BuildContext context) async {
    return showDialog<void>(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return new WillPopScope(
              onWillPop: () async => true,
              child: SimpleDialog(
                  backgroundColor: Colors.white,
                  children: <Widget>[
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(horizontal: 10.0),
                      child: Center(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: <Widget>[
                                  Text("Choose an Update", style: TextStyle(color: Colors.grey,fontSize: 12, fontWeight: FontWeight.w600),),
                                  Spacer(),
                                  GestureDetector(
                                    onTap: () => Navigator.pop(context),
                                    child: CircleAvatar(
                                      radius: 15.0,
                                      backgroundColor: Colors.white,
                                      child: Icon(
                                        Icons.clear, color: Colors.teal,),
                                    ),
                                  )
                                ],
                              ),
                              Column(children: updateRenderList(context),),
                            ]),
                      ),
                    )
                  ]));
        });
  }


  //-------- Case Update Silder -------------
  updateRenderList(BuildContext context) {
    final List <Widget> updateList = <Widget>[];
    for (int i = 0; i < widget.caseDetails["updates"].length; i++)
      updateList.add(GestureDetector(
        onTap: () {
          setState(() {
            sliderValue = i + 1;
            caseChart = widget.caseDetails["updates"][i];
            loadFunctions();
            Navigator.pop(context);
          });
        },
        child: Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Divider(),
              SizedBox(height: 10,),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[

                  Expanded(
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.5,
                      child: Text("Update ${i + 1}",
                        style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold,fontSize: 14),
                      ),
                    ),
                  ),

                  SizedBox(width: 5,),
                  Text("${widget.caseDetails["updates"][i]["beencut"] +
                      widget.caseDetails["updates"][i]["mightbecut"] +
                      widget.caseDetails["updates"][i]["havebeencut"]}",
                    style: TextStyle(fontWeight: FontWeight.w600),),
                  SizedBox(width: 5,),



                  FittedBox(
                    fit: BoxFit.contain,
                    child: Container(height: 20, width: 20, decoration: BoxDecoration(
                      color: Colors.red,

                    ), padding: EdgeInsets.all(2.5),
                      child: FittedBox(
                          fit: BoxFit.contain,
                          alignment: Alignment.center,
                          child: Text(widget.caseDetails["updates"][i]["beencut"].toString() ?? "", style: TextStyle(fontSize: 16, color: Colors.white),)),),
                  ),
                  SizedBox(width: 8,),
                  FittedBox(
                    fit: BoxFit.contain,
                    child: Container(height: 20, width: 20, decoration: BoxDecoration(
                      color: Colors.orange,
                    ), padding: EdgeInsets.all(2.5),
                      child: FittedBox(
                          fit: BoxFit.contain,
                          alignment: Alignment.center,
                          child: Text(widget.caseDetails["updates"][i]["mightbecut"].toString() ?? "", style: TextStyle(fontSize: 16, color: Colors.white),)),),
                  ),
                  SizedBox(width: 8,),
                  FittedBox(
                    fit: BoxFit.contain,
                    child: Container(height: 20, width: 20, decoration: BoxDecoration(color: Colors.grey,),
                      padding: EdgeInsets.all(2.5),
                      child: FittedBox(
                          fit: BoxFit.contain,
                          alignment: Alignment.center,
                          child: Text(widget.caseDetails["updates"][i]["havebeencut"].toString() ?? "", style: TextStyle(fontSize: 16, color: Colors.white),)),),
                  ),

                ],
              ),
              SizedBox(height: 5,),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    flex: 1,
                    child: Text(widget.caseDetails["updates"][i]["isanonymous"]
                        ? "Anonymous"
                        : widget.caseDetails["updates"][i]["addedby"]["name"] ==
                        null ? " " : widget
                        .caseDetails["updates"][i]["addedby"]["name"],
                      style: TextStyle(color: Colors.black, fontSize: 14),),
                  ),

                  Expanded(
                    flex: 0,
                    child: Text(CommonFunction.timeWithStatus(
                        widget.caseDetails["updates"][i]["createddate"]),
                      style: TextStyle(color: Colors.black, fontSize: 14),),
                  ),
                  SizedBox(width: 5,)
                ],
              ),
              SizedBox(height: 5,),
              widget.caseDetails["updates"][i]["description"] != null ? Text(
                widget.caseDetails["updates"][i]["description"] ?? "",
                maxLines: 1, overflow: TextOverflow.ellipsis,) :
              SizedBox.shrink(),
            ],
          ),
        ),
      ));
    return updateList.reversed.toList();
  }

  Future<void> addToWatchList() async {
    Map data = {
      "id": widget.caseDetails["_id"]
    };
    CustomResponse response = await ApiCall.makePostRequestToken(
        "incident/watchlist/add", paramsData: data);
    if (response.status == 200)
      if (json.decode(response.body)["status"]) {

        StoreProvider.of<AppState>(context)
            .dispatch(IsInWatchList(true));
        Fluttertoast.showToast(
            msg: "This case has been added to your Watch List");
      }
      else
        Fluttertoast.showToast(msg: "Sorry! Failed to add case to Watch List");
  }

  Future<void> removeFromWatchList() async {
    Map data = {
      "id": widget.caseDetails["_id"]
    };
    CustomResponse response = await ApiCall.makePostRequestToken(
        "incident/watchlist/remove", paramsData: data);
    if (response.status == 200)
      if (json.decode(response.body)["status"]) {
        StoreProvider.of<AppState>(context).dispatch(IsInWatchList(  false));
        Fluttertoast.showToast(
            msg: "This case has been removed from your Watch List");
      }
      else
        Fluttertoast.showToast(
            msg: "Sorry! Failed to remove case from Watch List");
  }

  void _onShareTap(var linkMessage) {
    int treeCount = widget.caseDetails["mightbecut"]+widget.caseDetails["beencut"]+widget.caseDetails["havebeencut"];
    String text = "Checkout this case about $treeCount "+"${treeCount >1? "trees" : "tree"}"+" at "+
        widget.caseDetails["locationname"]+" using Save Tress app. (Case ID: ${widget.caseDetails["caseidentifier"] == null?
    widget.caseDetails["caseid"].toString(): widget.caseDetails["caseidentifier"]})";

    final RenderBox box = context.findRenderObject();
    Share.share(text+"\n"+linkMessage,
        sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size);
  }



  Future<void> markUpdate() async {
    Map data={
      "id": widget.caseId,
      "similarcaseid": widget.caseDetails["_id"],
    };

    var response = await ApiCall.makePostRequestToken('incident/markasupdate', paramsData: data);
    if(json.decode(response.body)["status"])
    {
      CommonWidgets.updationSuccessDialog(context);
      Future.delayed(Duration(milliseconds: 2000), () {
        Navigator.of(context).pop(true);
        CommonWidgets.upDationMarkDialog(context, widget.caseDetails, 'updated');
      });
    }
    else
      Fluttertoast.showToast(msg: json.decode(response.body)["msg"]);

  }

}


class CaseGallery extends StatefulWidget{
  final caseId;
  final caseDetails;
  CaseGallery(this.caseId, this.caseDetails);

  _CaseGallery createState()=> _CaseGallery();
}

class _CaseGallery extends State<CaseGallery>{

  final highLightName = TextStyle(color: Colors.black, fontWeight: FontWeight.w600);
  final dateStyle = TextStyle(color: Colors.grey, fontWeight: FontWeight.w600);
  var dateFormatter = new DateFormat('dd-MMM-yyyy');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.all(15.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            widget.caseDetails["updates"].isNotEmpty ?Column(children: _updatedCasePhoto(context),): SizedBox.shrink(),

            SizedBox(height: 15.0,),

            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Expanded(flex: 0, child: Text(dateFormatter.format(DateTime.parse(widget.caseDetails["createddate"])), style: dateStyle,)),
                SizedBox(width: 5.0,),
                Expanded(flex: 0, child: Text(  widget.caseDetails["isanonymous"] ? "Initiated by anonymous" : "Initiated by ${widget.caseDetails["addedby"]["name"]}" , style: highLightName,)),
                SizedBox(width: 5.0,),
                Expanded(flex: 0, child: Text(  "(${widget.caseDetails["photos"].length})", style: highLightName,)),
              ],
            ),
            SizedBox(height: 5.0,),
            AnimationLimiter(
              child: GridView.builder(
                  physics: NeverScrollableScrollPhysics (),
                  itemCount: widget.caseDetails["photos"].length,
                  shrinkWrap: true,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisSpacing: 8, mainAxisSpacing:8, crossAxisCount: 3),

                  itemBuilder: (context, index) {
                    return
                      AnimationConfiguration.staggeredGrid(
                          position: index,
                          duration: const Duration(milliseconds: 400),
                          columnCount: 3,
                          child: ScaleAnimation(
                              child: FadeInAnimation(
                                child:  Container(
                                    padding: const EdgeInsets.all(3.0),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.blueGrey),
                                      borderRadius: BorderRadius.all(Radius.circular(8.0)),
                                    ),

                                    height: 200,width: 200,
                                    child: InkWell(
                                        onTap: ()=> Navigator.push(context, MaterialPageRoute(builder: (context)=> GalleryImageView(widget.caseDetails["photos"],index,  widget.caseDetails))),
                                        child: Image(image: CachedNetworkImageProvider(ApiCall.imageUrl + widget.caseDetails["photos"][index]["photo"])
                                          ,fit:  BoxFit.cover,
                                          loadingBuilder:(BuildContext context, Widget child,ImageChunkEvent loadingProgress) {
                                            if (loadingProgress == null) return child;
                                            return Center(
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                backgroundColor: Colors.white54,
                                                valueColor: new AlwaysStoppedAnimation<Color>(Colors.green),
                                                value: loadingProgress.expectedTotalBytes != null ?
                                                loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes
                                                    : null,
                                              ),
                                            );
                                          },)
                                     )
                                ),
                              )));
                  }),
            ),
            SizedBox(height: 5.0,),

          ],
        ),
      ),
    );
  }

  _updatedCasePhoto(BuildContext context) {

    List <Widget> updatesDetails = <Widget>[];
    for (int i = widget.caseDetails["updates"].length - 1; i >= 0; i--)

      updatesDetails.add(Column(
        children: <Widget>[
          SizedBox(height: 15.0,),

          Row(
            children: <Widget>[
              Expanded(flex: 0,
                  child: Text(dateFormatter.format(DateTime.parse(
                      widget.caseDetails["updates"][i]["createddate"])),
                    style: dateStyle,)),
              SizedBox(width: 5.0,),
              Expanded(flex: 0,
                  child: Text(widget.caseDetails["updates"][i]["isanonymous"]
                      ? "Updated by anonymous"
                      : "Updated by ${widget.caseDetails["updates"][i]["addedby"]["name"]}", style: highLightName,)),
              SizedBox(width: 5.0,),
              Expanded(flex: 0,
                  child: Text(
                    "(${widget.caseDetails["updates"][i]["photos"].length})",
                    style: highLightName,)),
            ],
          ),
          SizedBox(height: 10.0,),
          AnimationLimiter(
            child: GridView.builder(
                physics: NeverScrollableScrollPhysics(),
                itemCount: widget.caseDetails["updates"][i]["photos"].length,
                shrinkWrap: true,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisSpacing: 8, mainAxisSpacing: 8, crossAxisCount: 3),

                itemBuilder: (context, index) {
                  return
                    AnimationConfiguration.staggeredGrid(
                        position: index,
                        duration: const Duration(milliseconds: 400),
                        columnCount: 3,
                        child: ScaleAnimation(
                            child: FadeInAnimation(
                              child: Container(
                                  padding: const EdgeInsets.all(3.0),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.blueGrey),
                                    borderRadius: BorderRadius.all(Radius.circular(8.0)),
                                  ),
                                  height: 200, width: 200,
                                  child: InkWell(
                                      onTap: () => Navigator.push(context, MaterialPageRoute(
                                          builder: (context) =>
                                              GalleryImageView(widget.caseDetails["updates"][i]["photos"], index,
                                                  widget.caseDetails["updates"][i]))),
                                      child: Image(image: NetworkImage(ApiCall.imageUrl + widget.caseDetails["updates"][i]["photos"][index]["photo"]),
                                        fit: BoxFit.cover,)))
                            )));

                }),
          ),

        ],
      ));


    return updatesDetails;

  }


}