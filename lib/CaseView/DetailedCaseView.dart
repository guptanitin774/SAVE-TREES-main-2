

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
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:naturesociety_new/PostACase/PostCaseUpdate.dart';
import 'package:naturesociety_new/Utils/NetworkCall.dart';
import 'package:naturesociety_new/Widgets/CommonFunction.dart';
import 'package:naturesociety_new/Widgets/ReadMoreText.dart';
import 'package:naturesociety_new/Widgets/Redux.dart';
import 'package:permission_handler/permission_handler.dart'as appHandler;
import 'package:share/share.dart';
import 'dart:ui' as ui;

class CaseView extends StatefulWidget{
  void Function() navigation;
  final caseDetails;
  CaseView(this.navigation, this.caseDetails, {Key key,}) : super(key: key);

  _CaseView createState()=> _CaseView();
}

class _CaseView extends State <CaseView>{


  Completer<GoogleMapController> _controller = Completer();
 // Position position;
  var lat,lon;
  final Set<Marker> markers = Set();
  List <Widget>imageList = <Widget>[];
  var caseChart;
  bool isCaseHasUpdates = false;
  int sliderValue =  0;
  int watchCount, commentCount, updateCount, reportCount;

double distance;
  Uint8List markerIcon;
  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(), targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png)).buffer.asUint8List();
  }

  @override
  void initState(){
    caseChart =widget.caseDetails;
    isCaseHasUpdates = widget.caseDetails["updates"].length > 0 ? true :false;
    watchCount = widget.caseDetails["watchcount"]; commentCount = widget.caseDetails["commentcount"];
    reportCount = widget.caseDetails["reportcount"];
    updateCount = widget.caseDetails["updates"].length == null ? 0 : widget.caseDetails["updates"].length;

    setState(() =>  distance = widget.caseDetails["distance"]==null? 0.0 : widget.caseDetails["distance"].toDouble() );

    if(isCaseHasUpdates)
      setState(() {
        sliderValue =  widget.caseDetails["updates"].length ;
        caseChart = widget.caseDetails["updates"][(widget.caseDetails["updates"].length)-1];
      });

    loadFunctions();
    updateTileDetails();
    super.initState();
  }

  Future<void> updateTileDetails() async{
    CustomResponse response = await ApiCall.makeGetRequestToken('incident/get?id=${widget.caseDetails["_id"]}');
    print(json.decode(response.body));
    if(response.status == 200){
      if(json.decode(response.body)['status']){
        watchCount = json.decode(response.body)["data"]["watchcount"];
        commentCount = json.decode(response.body)["data"]["commentcount"];
        reportCount = json.decode(response.body)["data"]["reportcount"];
        print("hvj");
      }
      else{}
    }else{}
    if(mounted)
      setState(() {});

  }

List recentComments =[];

  void loadFunctions() async{
    markerIcon =  await getBytesFromAsset('assets/TreeIdentifier.png', 100);

    markers.clear();
    markers.add(Marker(
      position: LatLng(caseChart["location"][1], caseChart["location"][0]),
      markerId: MarkerId("selected-location"),
        // icon: BitmapDescriptor.fromBytes(markerIcon),
      // onTap: (){
      //   CommonFunction.openMap(caseChart["location"][1], caseChart["location"][0]);
      // }
    ));
    imageList.clear();

    for(int i=0; i< caseChart["photos"].length; i++)
      imageList.add(Image.network(ApiCall.imageUrl+caseChart["photos"][i]["photo"].toString() ,cacheWidth:500, cacheHeight : 500,fit: BoxFit.cover,),);

    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(
        target: LatLng(caseChart["location"][1], caseChart["location"][0]),
        zoom: 15.77,
      ),
    ));

    //Recent Comments
    recentComments = caseChart["comments"];
    setState(() {});
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(


      body: StoreConnector<AppState, AppState>(
          converter: (store) => store.state,
          builder: (context, state) {
       return SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 8.0),
            physics: ClampingScrollPhysics(),
            child: AnimationLimiter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: AnimationConfiguration.toStaggeredList(
                  duration: const Duration(milliseconds: 375),
                  childAnimationBuilder: (widget) => SlideAnimation(
                  horizontalOffset: 50.0,
                  child: FadeInAnimation(
                  child: widget,
                  ),
                   ),
                  children: <Widget>[

                    isCaseHasUpdates ? Container(
                      margin: EdgeInsets.only(bottom: 10.0),
                      height: 50.0,
                      decoration: BoxDecoration(color: Colors.teal.withOpacity(0.3),border:  Border.all(color: Colors.teal, width: 1.8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.4),
                            spreadRadius: 3,
                            blurRadius: 10,
                            offset: Offset(0, 5), // changes position of shadow
                          ),
                        ],),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          IconButton(
                            icon: Icon(Icons.arrow_back_ios),
                            color: sliderValue == 0? Colors.grey : Colors.teal,
                            onPressed: ()=> sliderValue == 0? null: {
                              setState(() {
                                sliderValue -- ;
                                if(sliderValue == 0) {
                                  caseChart = widget.caseDetails;
                                  loadFunctions();
                                }
                                else {
                                  caseChart = widget.caseDetails["updates"][sliderValue - 1];
                                  loadFunctions();
                                }
                              }),
                            },
                          ),
                          Spacer(),
                          Text(sliderValue == 0 ? "Original Post":"Update ${(sliderValue).toString()}",style: TextStyle(color: Colors.teal, fontWeight: FontWeight.w600),),
                          SizedBox(width: 5.0,),
                          IconButton(
                            icon: Icon(Icons.arrow_drop_down),
                            color: Colors.grey,
                            onPressed: (){showUpdateDialog(context);},
                          ),
                          Spacer(),
                          IconButton(
                            icon: Icon(Icons.arrow_forward_ios),
                            onPressed: ()=> sliderValue   == widget.caseDetails["updates"].length? null:{
                              setState(() {
                                sliderValue ++ ;
                                if(sliderValue == 0) {
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
                            color:  sliderValue   ==  widget.caseDetails["updates"].length? Colors.grey : Colors.teal,
                          ),
                        ],
                      ),
                    ): SizedBox.shrink(),


                    Container(
                      height: 200, width: double.infinity,
                      child :  Stack(
                        children: [
                          Swiper(
                            itemBuilder:
                                (BuildContext context,int k){
                              return InteractiveViewer(
                                child: Image(image: CachedNetworkImageProvider(ApiCall.imageUrl+caseChart["photos"][k]["photo"].toString()) ,fit:  BoxFit.cover,
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
                                  },),
                              );
                            },
                            itemCount: caseChart["photos"].length,
                            pagination: caseChart["photos"].length > 1 ? SwiperPagination() : SwiperPagination(builder: SwiperPagination.rect),
                            loop: false,
                            autoplay: false,

                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                updateCount != 0 ?  Container(
                                  padding: EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                                    color: Colors.black45,
                                  ),
                                  child: Text(
                                    updateCount == 1 ? "1 Update":
                                    "$updateCount Updates"
                                    , style: TextStyle(color: Colors.white, fontSize: 12),),
                                ) : SizedBox.shrink(),
                                SizedBox(width: updateCount == null? 0: 8.0,),
                                watchCount == 0? SizedBox.shrink(): Container(
                                  padding: EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.black45,
                                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                                  ),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Icon(Icons.remove_red_eye, color: Colors.white, size: 12,),
                                      SizedBox(width: 4.0,),
                                      Text(watchCount.toString(), style: TextStyle(color: Colors.white, fontSize: 12),),
                                    ],
                                  ),
                                ),
                                SizedBox(width: watchCount == 0? 0: 8.0,),
                                commentCount == 0 ? SizedBox.shrink():
                                Container(
                                  padding: EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.black45,
                                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                                  ),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Icon(Icons.message, color: Colors.white, size: 12,),
                                      SizedBox(width: 4.0,),
                                      Text(commentCount.toString(), style: TextStyle(color: Colors.white, fontSize: 12),),
                                    ],
                                  ),
                                ),

                                Spacer(),
                                reportCount == 0 || reportCount == null? SizedBox.shrink():
                                Container(
                                  padding: EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.deepOrange.withOpacity(0.7),
                                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                                  ),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Icon(Icons.warning, color: Colors.white, size: 12,),
                                      SizedBox(width: 4.0,),
                                      Text("Reported by "+reportCount.toString(), style: TextStyle(color: Colors.white, fontSize: 12),),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                        ],
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
                              Text( sliderValue == 0 ?"Posted by:": "Updated by:", style: TextStyle(fontSize: 12,),),
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
                          flex: 2,
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
                                  Text(distance.toStringAsFixed(3) +" km, ",
                                    style: TextStyle(color: Colors.black, fontSize: 12),),

                                  Text(CommonFunction.timeWithStatus(caseChart["createddate"]),
                                    style: TextStyle(color: Colors.black, fontSize: 12),),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 10.0,),

                    Text("Location",style: TextStyle(color: Colors.grey,),),
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


                    caseChart["beencut"] >0 ? Container(
                      margin: EdgeInsets.symmetric(vertical: 5.0),
                      decoration: BoxDecoration(border: Border.all(width: 1.8, color: Colors.redAccent.withOpacity(.2) )),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Expanded(flex: 3,
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 5.0),
                              color:  Colors.redAccent.withOpacity(.2) ,
                              width: MediaQuery.of(context).size.width / 2 + 60,
                              child: Row(
                                children: <Widget>[
                                  CircleAvatar(radius: 8, backgroundColor: Colors.redAccent,),
                                  SizedBox(width: 5.0,),
                                  Expanded(
                                      flex: 2,
                                      child: Text("Tree Is Being Cut / Damaged"))
                                ],
                              ),
                            ),
                          ),
                          VerticalDivider(color: Colors.amber, width: 5, thickness: 2.5,),
                          Expanded(flex: 1, child: Center(child: Text( caseChart["beencut"].toString() ?? " ", style: TextStyle(fontWeight: FontWeight.w600),)),) ,
                        ],
                      ),
                    ): SizedBox.shrink(),

                    caseChart["mightbecut"] >0  ? Container(
                      margin: EdgeInsets.symmetric(vertical: 5.0),
                      decoration: BoxDecoration(border: Border.all(width: 1.8, color: Colors.amber.withOpacity(.2) )),
                      child: Column(
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,

                            children: <Widget>[
                              Expanded(
                                flex: 3,
                                child: Container(
                                  padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 5.0),
                                  color:  Colors.amber.withOpacity(.2),
                                  width: MediaQuery.of(context).size.width / 2 + 60,
                                  child: Row(
                                    children: <Widget>[
                                      CircleAvatar(radius: 8, backgroundColor: Colors.orangeAccent,),
                                      SizedBox(width: 5.0,),
                                      Expanded(
                                          flex: 2,
                                          child: Text("Tree Might Be Cut / Damaged"))
                                    ],
                                  ),
                                ),
                              ),

                              VerticalDivider(color: Colors.amber, width: 5, thickness: 2.5,),
                              Expanded(flex: 1, child: Center(child: Text(caseChart["mightbecut"].toString() ?? " ", style: TextStyle(fontWeight: FontWeight.w600),)),) ,
                            ],
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(vertical: 10.0,horizontal: 10.0),
                            decoration: BoxDecoration(border: Border.all(width: 1.8, color: Colors.amber.withOpacity(.2) ),
                              color:  Colors.amber.withOpacity(.2),

                            ),

                            child: caseChart["mightbecutreason"].isNotEmpty ? Column(children: mightBeCutReason(context),) : SizedBox.shrink(),
                          ),
                        ],
                      ),
                    ): SizedBox.shrink(),

                    caseChart["havebeencut"] >0 ? Container(
                      margin: EdgeInsets.symmetric(vertical: 5.0),
                      decoration: BoxDecoration(border: Border.all(width: 1.8, color: Colors.grey.withOpacity(.2) )),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,

                        children: <Widget>[
                          Expanded(
                            flex: 3,
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 5.0),
                              color:  Colors.grey.withOpacity(.2),
                              width: MediaQuery.of(context).size.width / 2 + 60,
                              child: Row(
                                children: <Widget>[
                                  CircleAvatar(radius: 8, backgroundColor: Colors.grey,),
                                  SizedBox(width: 5.0,),
                                  Expanded(
                                      flex: 2,
                                      child: Text("Tree Has Been Cut / Damaged"))
                                ],
                              ),
                            ),
                          ),

                          VerticalDivider(color: Colors.amber, width: 5, thickness: 2.5,),
                          Expanded(flex: 1, child: Center(child: Text( caseChart["havebeencut"].toString() ?? " ", style: TextStyle(fontWeight: FontWeight.w600),)),) ,
                        ],
                      ),
                    ): SizedBox.shrink(),

                    SizedBox(height: 10.0,),

                    caseChart["description"] != null  ? Text("Description", style: TextStyle(color: Colors.black45),):
                    SizedBox.shrink(),
                    SizedBox(height: caseChart["description"] != null  ?  10.0 :  0.0,),
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
                            elevation: 3.0,
                            minWidth: double.infinity,
                            shape: RoundedRectangleBorder(
                                side: BorderSide(color: Colors.black45, width: 1.0 )
                            ),
                            onPressed: (){
                              widget.navigation();
                            },
                            color: Colors.white,
                            child: Text("Go to discussion", style: TextStyle(color: Colors.black45, fontWeight: FontWeight.w600),),
                          ),
                        )
                      ],
                    ),

                    SizedBox(height: 10,),

                    MaterialButton(
                      elevation: 2.0,
                      splashColor: state.isInWatchList? Colors.grey.withOpacity(0.5) : Colors.grey.withOpacity(0.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(1.0),
                        side: BorderSide(color: state.isInWatchList? Colors.teal : Colors.grey,  width:0.5, style: BorderStyle.solid),
                      ),
                      color: state.isInWatchList? Colors.teal.withOpacity(0.6) :Colors.white,
                      minWidth: double.infinity,
                      height: 60.0,
                      textColor: state.isInWatchList? Colors.white : Colors.black,
                      onPressed: ()=> state.isInWatchList? removeFromWatchList() :addToWatchList(),
                      child: Center(child: Text(state.isInWatchList? "Remove from watchlist": "Add to watchlist")),
                    ),
                    SizedBox(height: 10.0,),

                    loadActionButton? Center(child: CircularProgressIndicator(strokeWidth: 2.0,)):  MaterialButton(
                      onPressed: ()=> locationPermission(),
                      color: Colors.white,
                      minWidth: double.infinity,
                      height: 60.0,
                      elevation: 2.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(1.0),
                        side: BorderSide(color:  Colors.grey, width:0.5, style: BorderStyle.solid),
                      ),
                      child: Text("Update this case"),
                    ),

                    SizedBox(height: 70.0,),
                  ],
                ),

              ),
            ),
          ),
        );}
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      floatingActionButton:  MaterialButton(
        color: Colors.teal,
        minWidth: double.infinity,
        height: 60.0,
        onPressed: () async {
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
        child: Text("Share this case", style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white,fontSize: 16.0),),
      ),
    );
  }
  
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
                backgroundImage:
                caseChart["comments"][i]['isanonymous']?AssetImage('assets/natureicon.png'):
                caseChart["comments"][i]["user"]["photo"] !=null? CachedNetworkImageProvider(ApiCall.imageUrl+caseChart["comments"][i]["user"]["photo"] ?? " "):
                null,
              ),
              SizedBox(width: 10.0,),
              Expanded(

                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        caseChart["comments"][i]['isanonymous']?caseChart["comments"][i]['anonymousname']??'Anonymous':
                        caseChart["comments"][i]["user"]["name"] != null ?
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
    for(int i=0; i<caseChart["mightbecutreason"].length; i++)
      reasonList.add(Padding(
        padding: const EdgeInsets.only(bottom: 10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Expanded(flex: 0,
              child: CircleAvatar(radius: 5.0,backgroundColor: Colors.white,),
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
                              Text("Choose an Update",style: TextStyle(color: Colors.grey,fontSize: 12, fontWeight: FontWeight.w600),),
                              Spacer(),
                              GestureDetector(
                                onTap: ()=> Navigator.pop(context),
                                child: CircleAvatar(
                                  radius: 15.0,
                                  backgroundColor: Colors.white,
                                  child: Icon(Icons.clear, color: Colors.teal,),
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


  updateRenderList(BuildContext context) {
    final List <Widget> updateList = <Widget>[];
    updateList.add(GestureDetector(
      onTap: (){
        setState(() {
          sliderValue = 0;
          caseChart = widget.caseDetails;
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
                    width: MediaQuery.of(context).size.width*0.5,
                    child: Text("Original Post", style: TextStyle(color: Colors.black, fontSize:14, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),

                SizedBox(width: 5,),
                Container(  decoration: BoxDecoration(color: Colors.white,
                    border: Border.all(color: Colors.black45),
                    borderRadius: BorderRadius.all(Radius.circular(5))),
                  padding:EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  child: Text("${widget.caseDetails["beencut"]+widget.caseDetails["mightbecut"]+
                      widget.caseDetails["havebeencut"]}", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),),
                ),
                SizedBox(width: 5,),

                widget.caseDetails["beencut"] == 0 ?
                SizedBox.shrink():
                Container(  decoration: BoxDecoration(color: Colors.red,
                    border: Border.all(color: Colors.red),
                    borderRadius: BorderRadius.all(Radius.circular(5))),
                  padding:EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  child: Text(widget.caseDetails["beencut"].toString() ?? "",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12,fontWeight: FontWeight.w600, color: Colors.white),),),


                SizedBox(width:widget.caseDetails["beencut"] ==0 ? 0: 8,),
                widget.caseDetails["mightbecut"] ==0 ?
                SizedBox.shrink() :
                Container(  decoration: BoxDecoration(color: Colors.orange,
                    border: Border.all(color: Colors.orange),
                    borderRadius: BorderRadius.all(Radius.circular(5))),
                  padding:EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  child: Text(widget.caseDetails["mightbecut"].toString() ?? "",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12,fontWeight: FontWeight.w600, color: Colors.white),),),


                SizedBox(width:widget.caseDetails["mightbecut"] == 0 ? 0: 8,),

                widget.caseDetails["havebeencut"] ==0 ?
                SizedBox.shrink():
                Container(  decoration: BoxDecoration(color: Colors.grey,
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.all(Radius.circular(5))),
                  padding:EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  child: Text(widget.caseDetails["havebeencut"].toString() ?? "",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12,fontWeight: FontWeight.w600, color: Colors.white),),),


              ],
            ),
            SizedBox(height: 5,),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: Text(widget.caseDetails["isanonymous"] ? "Anonymous" : widget.caseDetails["addedby"]["name"] == null ? " " : widget.caseDetails["addedby"]["name"] ,
                    style: TextStyle(color: Colors.black, fontSize: 12),),
                ),
                Expanded(
                  flex: 0,
                  child: Text(CommonFunction.timeWithStatus(widget.caseDetails["createddate"]),
                    style: TextStyle(color: Colors.black, fontSize: 11.5),),
                ),
                SizedBox(width: 5,)
              ],
            ),
            SizedBox(height: 5,),
            widget.caseDetails["description"] !=null ?Text(widget.caseDetails["description"]?? "", maxLines: 2,overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 14),):
            SizedBox.shrink(),
          ],
        ),
      ),
    ));

    for(int i=0; i<widget.caseDetails["updates"].length; i++)
      updateList.add(GestureDetector(
        onTap: (){
          setState(() {
            sliderValue = i+1;
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
                      width: MediaQuery.of(context).size.width*0.5,
                      child: Text("Update ${i+1}", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold,fontSize: 14),
                      ),
                    ),
                  ),

                  SizedBox(width: 5,),
                  Container(
                    decoration: BoxDecoration(color: Colors.white,
                        border: Border.all(color: Colors.black45),
                        borderRadius: BorderRadius.all(Radius.circular(5))),
                    padding:EdgeInsets.symmetric(horizontal: 8, vertical: 2),

                    child: Text("${widget.caseDetails["updates"][i]["beencut"]+widget.caseDetails["updates"][i]["mightbecut"]+
                        widget.caseDetails["updates"][i]["havebeencut"]}",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.w600,fontSize: 12),),
                  ),
                  SizedBox(width: 5,),
                  widget.caseDetails["updates"][i]["beencut"] == 0?
                  SizedBox.shrink():
                  Container(  decoration: BoxDecoration(color: Colors.red,
                      border: Border.all(color: Colors.red),
                      borderRadius: BorderRadius.all(Radius.circular(5))),
                    padding:EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    child: Text(widget.caseDetails["updates"][i]["beencut"].toString() ?? "",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white),),),
                  SizedBox(width: widget.caseDetails["updates"][i]["beencut"]==0 ? 0 :8,),


                  widget.caseDetails["updates"][i]["mightbecut"]== 0 ?
                  SizedBox.shrink():
                  Container(  decoration: BoxDecoration(color: Colors.orange,
                      border: Border.all(color: Colors.orange),
                      borderRadius: BorderRadius.all(Radius.circular(5))),
                    padding:EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    child: Text(widget.caseDetails["updates"][i]["mightbecut"].toString() ?? "",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12,fontWeight: FontWeight.w600, color: Colors.white),),),
                  SizedBox(width: widget.caseDetails["updates"][i]["mightbecut"] ==0 ? 0 : 8,),


                  widget.caseDetails["updates"][i]["havebeencut"] == 0?
                  SizedBox.shrink():
                  Container(  decoration: BoxDecoration(color: Colors.grey,
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.all(Radius.circular(5))),
                    padding:EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    child: Text(widget.caseDetails["updates"][i]["havebeencut"].toString() ?? "",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white),),),

                ],
              ),
              SizedBox(height: 5,),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[

                  Expanded(
                    flex: 1,
                    child: Text(widget.caseDetails["updates"][i]["isanonymous"] ? "Anonymous" : widget.caseDetails["updates"][i]["addedby"]["name"] == null ? " " : widget.caseDetails["updates"][i]["addedby"]["name"] ,
                      style: TextStyle(color: Colors.black, fontSize: 12.0),),
                  ),

                  Expanded(
                    flex: 0,
                    child: Text(CommonFunction.timeWithStatus(widget.caseDetails["updates"][i]["createddate"]),
                      style: TextStyle(color: Colors.black, fontSize: 11.5),),
                  ),
                  SizedBox(width: 5,)
                ],
              ),
              SizedBox(height: 5,),
              widget.caseDetails["updates"][i]["description"] !=null ?Text(widget.caseDetails["updates"][i]["description"]?? "", maxLines: 2,overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 14),textAlign: TextAlign.left,):
              SizedBox.shrink(),


            ],
          ),
        ),
      ));


     return updateList.reversed.toList();
  }

  Future<void> addToWatchList() async{
    Map data ={
      "id": widget.caseDetails["_id"]
    };
    CustomResponse response = await ApiCall.makePostRequestToken("incident/watchlist/add", paramsData: data);
    if(response.status == 200)
      if(json.decode(response.body)["status"]) {

        StoreProvider.of<AppState>(context).dispatch(IsInWatchList(true));
        Fluttertoast.showToast(msg: "Added to Watchlist");
      }
      else
        Fluttertoast.showToast(msg: "Sorry! Failed to add case to Watch List");
  }

  Future<void> removeFromWatchList() async{
    Map data ={
      "id": widget.caseDetails["_id"]
    };
    CustomResponse response = await ApiCall.makePostRequestToken("incident/watchlist/remove", paramsData: data);
    if(response.status == 200)
      if(json.decode(response.body)["status"]) {

        StoreProvider.of<AppState>(context).dispatch(IsInWatchList(  false));
        Fluttertoast.showToast(msg: "Removed from Watchlist");
      }
      else
        Fluttertoast.showToast(msg: "Sorry! Failed to remove case from Watch List");
  }

  void _onShareTap(var linkMessage)async {
    int treeCount =await  widget.caseDetails["mightbecut"]+widget.caseDetails["beencut"]+widget.caseDetails["havebeencut"];
    String text = "Checkout this case about $treeCount "+"${treeCount >1 ?"trees":"tree"}"+" at "+
        widget.caseDetails["locationname"]+", using Save Tress app. (Case ID: ${widget.caseDetails["caseidentifier"] == null?
    widget.caseDetails["caseid"] :widget.caseDetails["caseidentifier"]})";

    final RenderBox box = context.findRenderObject();
    Share.share(text+"\n"+linkMessage,
        sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size);
  }
  Location location = new Location();
  bool _serviceEnabled;
  PermissionStatus _permissionGranted;
  LocationData _locationData;

  locationPermission() async{

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
  permissionGranted() async{
    loadActionButton = true;
    setState(() {});
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
    await location.changeSettings(accuracy: LocationAccuracy.high);
    _locationData = await location.getLocation();

    if(mounted)
      checkOnLocation();
  }

  bool loadActionButton = false;

  Future<void>checkOnLocation() async{
    setState(() {
      loadActionButton = true;
    });
     CustomResponse response = await ApiCall.makeGetRequestToken("incident/isinlocation?lon=${_locationData.longitude}&lat=${_locationData.latitude}&id=${widget.caseDetails["_id"]}");
    if(response.status == 200)
      if(json.decode(response.body)["status"])
        {
          loadActionButton = false;
          Navigator.push(context, MaterialPageRoute(builder: (context)=> PostCaseUpdate(widget.caseDetails["_id"])));
        }
    else
      Fluttertoast.showToast(msg: json.decode(response.body)["msg"]);
    else
      {
        Fluttertoast.showToast(msg: response.body);
        Navigator.pop(context);
      }
     loadActionButton = false;
     setState(() {});
  }
}