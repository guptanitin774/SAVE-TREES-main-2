import 'dart:async';
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:naturesociety_new/BottomNavigation/BottomNavigation.dart';
import 'package:naturesociety_new/BottomNavigation/UserMainPage.dart';
import 'package:naturesociety_new/Widgets/ShimmerLoading.dart';
import 'package:naturesociety_new/CaseView/CaseDetailedView.dart';
import 'package:naturesociety_new/Utils/LocalPrefManager.dart';
import 'package:naturesociety_new/Utils/MaterialComponets.dart';
import 'package:naturesociety_new/Utils/NetworkCall.dart';
import 'package:naturesociety_new/Widgets/CommonFunction.dart';
import 'package:naturesociety_new/Widgets/CommonWidgets.dart';
import 'package:naturesociety_new/Widgets/NoConnection.dart';

class Watchlist extends StatefulWidget
{
  const Watchlist({Key key}) : super(key: key);
  @override
  _WatchlistState createState() => _WatchlistState();
}
List <CaseTileModel>watchListList =[]; var myUserId;
class _WatchlistState extends State<Watchlist>
{

  @override
  void initState() {
    super.initState();
    getWatchListItems();
  }

  bool isConnected = true;
  bool watchListLoading = false;

  Future<void> getWatchListItems() async{
    watchListList.clear();
    myUserId = await LocalPrefManager.getUserId();
    if(watchListList.isEmpty)
      setState(() =>watchListLoading = true);
    CustomResponse response = await ApiCall.makeGetRequestToken("incident/watchlist/getlist");
    if(response.status == 200)
   { if(json.decode(response.body)["status"])
    {
      if (json.decode(response.body)["incidentlist"].length != watchListList.length) {
        for(int i=0; i< json.decode(response.body)["incidentlist"].length; i++)
          watchListList.add(CaseTileModel(
            id: json.decode(response.body)["incidentlist"][i]["_id"],
            locationName: json.decode(response.body)["incidentlist"][i]["locationname"],
            caseId: json.decode(response.body)["incidentlist"][i]["caseidentifier"].toString() == null? json.decode(response.body)["incidentlist"][i]["caseid"]: json.decode(response.body)["incidentlist"][i]["caseidentifier"],
            userName: json.decode(response.body)["incidentlist"][i]["locationname"],
            distance: json.decode(response.body)["incidentlist"][i]["distance"],
            beenCut: json.decode(response.body)["incidentlist"][i]["beencut"],
            haveBeemCut: json.decode(response.body)["incidentlist"][i]["havebeencut"],
            mightBeCut: json.decode(response.body)["incidentlist"][i]["mightbecut"],
            caseUpdates: json.decode(response.body)["incidentlist"][i]["updates"],
            commentCount: json.decode(response.body)["incidentlist"][i]["commentcount"],
            watchListCount: json.decode(response.body)["incidentlist"][i]["watchcount"],
            reportCount: json.decode(response.body)["incidentlist"][i]["reportcount"],
            photos: json.decode(response.body)["incidentlist"][i]["photos"],
            userDetails: json.decode(response.body)["incidentlist"][i]["addedby"],
            createdDate: json.decode(response.body)["incidentlist"][i]["createddate"],
            isAnonymous: json.decode(response.body)["incidentlist"][i]["isanonymous"],
          ));
        //watchListList = json.decode(response.body)["incidentlist"].reversed.toList();
        watchListLoading = false;
      }
      else {
        watchListList = watchListList;
        watchListLoading = false;
      }
    }
    else
      Fluttertoast.showToast(msg: json.decode(response.body)["msg"]);
   isConnected = true;
   }
    else if(response.status == 403){
      watchListLoading = true;
      CommonWidgets.loginLimit(context);
    }
    else
      {
        isConnected = false;
        watchListLoading = false;
      }
    if(mounted)
      setState(() {});
  }

  Future<void> updateTileDetails(var id, int index) async{
    CustomResponse response = await ApiCall.makeGetRequestToken('incident/get?id=$id');
    if(response.status == 200){
      if(json.decode(response.body)['status']){
        watchListList[index].watchListCount = json.decode(response.body)["data"]["watchcount"];
        watchListList[index].reportCount = json.decode(response.body)["data"]["reportcount"];
        watchListList[index].commentCount = json.decode(response.body)["data"]["commentcount"];
      }
      else{}
    }else{}
    if(mounted)
      setState(() {});

  }


  Future<void> removeFromWatchList(var id) async{
   Map data={
     "id" : id,
   };
    var response = await ApiCall.makePostRequestToken("incident/watchlist/remove", paramsData: data);
    if(json.decode(response.body)['status'])
      Fluttertoast.showToast(msg: "Case has been removed from WatchList");
   getWatchListItems();
  }

   Widget mainScreen (BuildContext context){

    return  watchListList.length >0 ? RefreshIndicator(
      onRefresh: () async {
        await Future.delayed(Duration(seconds: 2));
        getWatchListItems();
       },
      child: ListView.builder(
          physics: ClampingScrollPhysics(),

          itemCount: watchListList.length,
          itemBuilder: (BuildContext context,int index)
          {
             return Dismissible(
              key: Key(watchListList[index].id),
              confirmDismiss: (direction){
                return showDialog<bool>(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                        content: Text('Are you sure, You want to remove this case from WatchList ?'),
                        actions: <Widget>[
                          FlatButton(
                            child: Text('Cancel'),
                            onPressed: () => Navigator.of(context).pop(false),
                          ),
                          FlatButton(
                              child: Text('Ok'),
                              onPressed: () {
                                removeFromWatchList(watchListList[index].id);
                                Navigator.of(context).pop(true);
                              })]);
                  },
                );
              },
              background: Container(
                alignment: AlignmentDirectional.centerEnd,
                color: Colors.red,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(0.0, 0.0, 20.0, 10.0),
                  child: Icon(Icons.delete, color: Colors.white,),
                ),
              ),
              onDismissed: (direction) {
                //Scaffold.of(context).showSnackBar(SnackBar(content: Text("Case has been removed from your WatchList")));
              },

              child: ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 0.0),
                title: Container(
                  margin: EdgeInsets.only(top: 8.0),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(5.0)),
                      border: Border.all(color: Colors.black38, width: 1)),
                  child: GestureDetector(
                    onTap: ()async{
                      bool needRefresh = await Navigator.push(context, MaterialPageRoute(builder: (context)=> CaseDetailedView(watchListList[index].id)));
                      print(index);
                      print(watchListList[index].id);
                      if(needRefresh){
                        updateTileDetails(watchListList[index].id, index);
                      }
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        SizedBox(height: 5,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            SizedBox(width: 5,),
                            Expanded(
                              flex: 4,

                              child: Text("${watchListList[index].caseId.toString()}", maxLines: 1, overflow: TextOverflow.ellipsis,
                                style: TextStyle(color: Colors.teal, fontWeight: FontWeight.w700, fontSize: 14),
                              ),
                            ),

                            SizedBox(width: 5,),
                            Container(
                              decoration: BoxDecoration(color: Colors.white,
                                  border: Border.all(color: Colors.black45),
                                  borderRadius: BorderRadius.all(Radius.circular(5))),
                              padding:EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              child: Text("${watchListList[index].beenCut+watchListList[index].mightBeCut+
                                  watchListList[index].haveBeemCut}",  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),),
                            ),
                            SizedBox(width:watchListList[index].beenCut == 0? 0: 8,),
                            watchListList[index].beenCut == 0?
                            SizedBox.shrink():
                            Container(  decoration: BoxDecoration(color: Colors.red,
                                border: Border.all(color: Colors.red),
                                borderRadius: BorderRadius.all(Radius.circular(5))),
                                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                child: Text(watchListList[index].beenCut.toString() ?? "",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w600),)),



                            SizedBox(width: watchListList[index].mightBeCut == 0? 0: 8,),
                            watchListList[index].mightBeCut ==0 ?
                            SizedBox.shrink():
                            Container( decoration: BoxDecoration(color: Colors.orange,
                                border: Border.all(color: Colors.orange),
                                borderRadius: BorderRadius.all(Radius.circular(5))),
                              padding:EdgeInsets.symmetric(horizontal: 8, vertical: 4),

                              child: Text(watchListList[index].mightBeCut.toString() ?? "",
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 14,  fontWeight:FontWeight.w600, color: Colors.white),),),


                            SizedBox(width: watchListList[index].haveBeemCut == 0 ?0:  8,),

                            watchListList[index].haveBeemCut == 0?
                            SizedBox.shrink():
                            Container(  decoration: BoxDecoration(color: Colors.grey,
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.all(Radius.circular(5))),

                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              child: Text(watchListList[index].haveBeemCut.toString() ?? "",
                                textAlign: TextAlign.center,
                               style: TextStyle(fontSize: 14, fontWeight:FontWeight.w600 ,color: Colors.white),),),

                            SizedBox(width: 8,),

                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Text(watchListList[index].locationName??" ", maxLines: 2, overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            SizedBox(width: 5,),
                            Expanded(
                              flex: 5,
                              child: Text(CommonFunction.timeCalculation(watchListList[index].createdDate),
                                style: TextStyle(color: Colors.black, fontSize: 11.5,fontWeight: FontWeight.w600 ),),
                            ),
                            Expanded(
                              flex: 0,
                              child: Text(watchListList[index].isAnonymous ? myUserId == watchListList[index].userDetails["_id"]?"You as Anonymous": "Anonymous" : watchListList[index].userDetails["name"] == null ? " " : watchListList[index].userDetails["name"],
                                style: TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.w600),),
                            ),

                            SizedBox(width: 5,)
                          ],
                        ),
                        SizedBox(height: 10,),

                        GestureDetector(
                          onTap: ()async{
                            bool needRefresh = await Navigator.push(context, MaterialPageRoute(builder: (context)=> CaseDetailedView(watchListList[index].id)));
                            if(needRefresh){
                              updateTileDetails(watchListList[index].id, index);
                            }
                          },
                          child: Container(
                            height: 200, width: double.infinity,
                            child :  Stack(
                              children: [
                                Swiper(
                                  itemBuilder:
                                      (BuildContext context,int k){
                                    return

                                    Image(image: CachedNetworkImageProvider(ApiCall.imageUrl+watchListList[index].photos[k]["photo"].toString())
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
                                      },);
                                  },
                                  itemCount: watchListList[index].photos.length,
                                  pagination: watchListList[index].photos.length > 1 ? SwiperPagination(): SwiperPagination(builder: SwiperPagination.rect),
                                  loop: false,
                                  autoplay: false,
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    children: [
                                      watchListList[index].caseUpdates!= null ?  Container(
                                        padding: EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.all(Radius.circular(5.0)),
                                          color: Colors.black45,
                                        ),
                                        child: Text(
                                          watchListList[index].caseUpdates.length == 1 ? "Update 1":
                                          "Update ${watchListList[index].caseUpdates.length}"
                                          , style: TextStyle(color: Colors.white, fontSize: 12),),
                                      ) : SizedBox.shrink(),
                                      SizedBox(width: watchListList[index].caseUpdates == null? 0: 8.0,),
                                      watchListList[index].watchListCount == 0 || watchListList[index].watchListCount == null? SizedBox.shrink(): Container(
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
                                            Text(watchListList[index].watchListCount.toString(), style: TextStyle(color: Colors.white, fontSize: 12),),
                                          ],
                                        ),
                                      ),
                                      SizedBox(width:watchListList[index].watchListCount == 0 || watchListList[index].watchListCount == null? 0: 8.0,),
                                      watchListList[index].commentCount == 0 || watchListList[index].commentCount == null? SizedBox.shrink():
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
                                            Text(watchListList[index].commentCount.toString(), style: TextStyle(color: Colors.white, fontSize: 12),),
                                          ],
                                        ),
                                      ),
                                      Spacer(),
                                      watchListList[index].reportCount == 0 || watchListList[index].reportCount== null? SizedBox.shrink():
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
                                            Text("Reported by "+watchListList[index].reportCount.toString(), style: TextStyle(color: Colors.white, fontSize: 12),),
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
                    ),
                  ),
                ),
              ),
            );
          }),
    ) :
    Center(child: Text("Watchlist is empty", style: MaterialTools.errorMessageStyle));
  }

  Future<bool> _willPopScope() async{
    Navigator.pushAndRemoveUntil(context, CupertinoPageRoute(builder: (context) => BottomNavPage()), (route) => false);
    return Future.value(false);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _willPopScope,
      child:  Scaffold(
          backgroundColor: Colors.white,
            appBar: AppBar(
              automaticallyImplyLeading: false,
              iconTheme: IconThemeData(color: Colors.grey,),
              backgroundColor: Colors.grey.withOpacity(.04),
              centerTitle: true,
              title: Text("WATCHLIST", style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold),),
              elevation: 0.0,
            ),

        body: isConnected ? SafeArea(
          child: watchListLoading ? ShimmerLoading.loadingCaseShimmer(context) : mainScreen(context)
        ) : NoConnection(
          notifyParent: getWatchListItems,
        )
      ) ,
    );
  }
}