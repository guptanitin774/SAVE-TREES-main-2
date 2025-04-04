import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper_null_safety/flutter_swiper_null_safety.dart';
import 'package:location/location.dart';
import 'package:naturesociety_new/BottomNavigation/UserMainPage.dart';
import 'package:naturesociety_new/CaseView/CaseDetailedView.dart';
import 'package:naturesociety_new/Utils/LocalPrefManager.dart';
import 'package:naturesociety_new/Utils/NetworkCall.dart';
import 'package:naturesociety_new/Widgets/CommonFunction.dart';
import 'package:naturesociety_new/Widgets/NoConnection.dart';
import 'package:naturesociety_new/Widgets/ShimmerLoading.dart';

class UserPostedCaseDetails extends StatefulWidget {
  final caseArg;

  UserPostedCaseDetails(this.caseArg);

  _UserPostedCaseDetails createState() => _UserPostedCaseDetails();
}

class _UserPostedCaseDetails extends State<UserPostedCaseDetails> {
  @override
  void initState() {
    super.initState();
    getCaseDetails();
  }

  List<CaseTileModel> caseList = [];
  late String errorMsg;
  bool isConnected = true;
  bool loading = true;
  Location location = new Location();
  var myUserId;

  Future<void> getCaseDetails() async {
    myUserId = await LocalPrefManager.getUserId();
    LocationData currentLocation;
    currentLocation = await location.getLocation();
    Map data = {
      "common": widget.caseArg == "posted_by_me"
          ? ["cases posted by me"]
          : widget.caseArg == "updated_by_me"
              ? ["cases updated by me"]
              : ["cases on which i commented"],
      "lat": currentLocation.latitude,
      "lon": currentLocation.longitude
    };
    CustomResponse response =
        await ApiCall.makePostRequestToken("incident/filter", paramsData: data);
    print(json.decode(response.body));
    if (response.status == 200) {
      if (json.decode(response.body)["status"])
        for (int i = 0; i < json.decode(response.body)["data"].length; i++)
          caseList.add(CaseTileModel(
            id: json.decode(response.body)["data"][i]["_id"],
            locationName: json.decode(response.body)["data"][i]["locationname"],
            caseId: json.decode(response.body)["data"][i]["caseidentifier"] ??
                json.decode(response.body)["data"][i]["caseid"].toString(),
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
            isAnonymous: json.decode(response.body)["data"][i]["isanonymous"],
          ));
      //   caseList = json.decode(response.body)["data"];
      else
        errorMsg = json.decode(response.body)["msg"];

      isConnected = true;
    } else
      isConnected = false;

    loading = false;
    if (mounted) setState(() {});
  }

  Future<void> updateTileDetails(var id, int index) async {
    CustomResponse response =
        await ApiCall.makeGetRequestToken('incident/get?id=$id');
    if (response.status == 200) {
      if (json.decode(response.body)['status']) {
        caseList[index].watchListCount =
            json.decode(response.body)["data"]["watchcount"];
        caseList[index].reportCount =
            json.decode(response.body)["data"]["reportcount"];
        caseList[index].commentCount =
            json.decode(response.body)["data"]["commentcount"];
      } else {}
    } else {}
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white.withOpacity(0.98),
      appBar: AppBar(
        automaticallyImplyLeading: true,
        iconTheme: IconThemeData(color: Colors.black),
        backgroundColor: Colors.white,
        centerTitle: false,
        title: Text(
          widget.caseArg == "posted_by_me"
              ? "Cases posted by me"
              : widget.caseArg == "updated_by_me"
                  ? "Cases updated by me"
                  : "Cases commented by me",
          style: TextStyle(color: Colors.black),
        ),
        elevation: 5.0,
      ),
      body: !isConnected
          ? NoConnection(notifyParent: getCaseDetails, key: UniqueKey())
          : !loading
              ? SafeArea(
                  child: ListView.builder(
                      physics: ClampingScrollPhysics(),
                      padding:
                          EdgeInsets.symmetric(vertical: 10.0, horizontal: 8.0),
                      itemCount: caseList.length,
                      itemBuilder: (BuildContext context, int index) {
                        return itemBuilderContents(context, index);
                      }),
                )
              : ShimmerLoading.loadingCaseShimmer(context),
    );
  }

  Widget itemBuilderContents(BuildContext context, int index) {
    return Container(
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
                  builder: (context) => CaseDetailedView(caseList[index].id)));
          if (needRefresh) {
            updateTileDetails(caseList[index].id, index);
            setState(() {});
          }
        },
        child: caseList[index].caseUpdates != null
            ? updateTile(context, index)
            : normalTile(context, index),
      ),
    );
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
                "${caseList[index].caseId.toString()} ",
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
                "${caseList[index].caseUpdates[0]["beencut"] + caseList[index].caseUpdates[0]["mightbecut"] + caseList[index].caseUpdates[0]["havebeencut"]}",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),
            SizedBox(
              width: caseList[index].caseUpdates[0]["beencut"] == 0 ? 0 : 8,
            ),
            caseList[index].caseUpdates[0]["beencut"] == 0
                ? SizedBox.shrink()
                : Container(
                    decoration: BoxDecoration(
                        color: Colors.red,
                        border: Border.all(color: Colors.red),
                        borderRadius: BorderRadius.all(Radius.circular(5))),
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Text(
                      caseList[index].caseUpdates[0]["beencut"].toString() ??
                          "",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                          fontWeight: FontWeight.w600),
                    )),
            SizedBox(
              width: caseList[index].caseUpdates[0]["mightbecut"] == 0 ? 0 : 8,
            ),
            caseList[index].caseUpdates[0]["mightbecut"] == 0
                ? SizedBox.shrink()
                : Container(
                    decoration: BoxDecoration(
                        color: Colors.orange,
                        border: Border.all(color: Colors.orange),
                        borderRadius: BorderRadius.all(Radius.circular(5))),
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Text(
                      caseList[index]
                              .caseUpdates[caseList[index].caseUpdates.length -
                                  1]["mightbecut"]
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
              width: caseList[index].caseUpdates[0]["havebeencut"] == 0 ? 0 : 8,
            ),
            caseList[index].caseUpdates[0]["havebeencut"] == 0
                ? SizedBox.shrink()
                : Container(
                    decoration: BoxDecoration(
                        color: Colors.grey,
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.all(Radius.circular(5))),
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Text(
                      caseList[index]
                              .caseUpdates[0]["havebeencut"]
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
              width: 8,
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.all(5.0),
          child: Text(
            caseList[index].caseUpdates[0]["locationname"] ?? " ",
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
            caseList[index].distance == null
                ? SizedBox.shrink()
                : Text(
                    caseList[index].distance.toStringAsFixed(3) + " km, ",
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600),
                  ),
            Expanded(
              flex: 5,
              child: Text(
                CommonFunction.timeCalculation(
                    caseList[index].caseUpdates[0]["createddate"]),
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600),
              ),
            ),
            Expanded(
              flex: 0,
              child: Text(
                caseList[index].caseUpdates[0]["isanonymous"]
                    ? myUserId ==
                            caseList[index].caseUpdates[0]["addedby"]["_id"]
                        ? "You as Anonymous"
                        : "Anonymous"
                    : caseList[index].caseUpdates[0]["addedby"]["name"] == null
                        ? " "
                        : caseList[index].caseUpdates[0]["addedby"]["name"],
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
          onTap: () async {
            bool needRefresh = await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        CaseDetailedView(caseList[index].id)));
            if (needRefresh) {
              updateTileDetails(caseList[index].id, index);
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
                            caseList[index]
                                .caseUpdates[0]["photos"][k]["photo"]
                                .toString()),
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              backgroundColor: Colors.white54,
                              valueColor: new AlwaysStoppedAnimation<Color>(
                                  Colors.green),
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      (loadingProgress.expectedTotalBytes
                                          as num)
                                  : null,
                            ),
                          );
                        });
                  },
                  itemCount: caseList[index].caseUpdates[0]["photos"].length,
                  pagination:
                      caseList[index].caseUpdates[0]["photos"].length > 1
                          ? SwiperPagination()
                          : SwiperPagination(builder: SwiperPagination.rect),
                  loop: false,
                  autoplay: false,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      caseList[index].caseUpdates != null
                          ? Container(
                              padding: EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5.0)),
                                color: Colors.black45,
                              ),
                              child: Text(
                                caseList[index].caseUpdates.length == 1
                                    ? "Update 1"
                                    : "Update ${caseList[index].caseUpdates.length}",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 12),
                              ),
                            )
                          : SizedBox.shrink(),
                      SizedBox(
                        width: caseList[index].caseUpdates == null ? 0 : 8.0,
                      ),
                      caseList[index].watchListCount == 0 ||
                              caseList[index].watchListCount == null
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
                                    caseList[index].watchListCount.toString(),
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                      SizedBox(
                        width: caseList[index].watchListCount == 0 ||
                                caseList[index].watchListCount == null
                            ? 0
                            : 8.0,
                      ),
                      caseList[index].commentCount == 0 ||
                              caseList[index].commentCount == null
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
                                    caseList[index].commentCount.toString(),
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                      Spacer(),
                      caseList[index].reportCount == 0 ||
                              caseList[index].reportCount == null
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
                                        caseList[index].reportCount.toString(),
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
                "${caseList[index].caseId} ",
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
                "${caseList[index].beenCut + caseList[index].mightBeCut + caseList[index].haveBeemCut}",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),
            SizedBox(
              width: caseList[index].beenCut == 0 ? 0 : 8,
            ),
            caseList[index].beenCut == 0
                ? SizedBox.shrink()
                : Container(
                    decoration: BoxDecoration(
                        color: Colors.red,
                        border: Border.all(color: Colors.red),
                        borderRadius: BorderRadius.all(Radius.circular(5))),
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Text(
                      caseList[index].beenCut.toString() ?? "",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                          fontWeight: FontWeight.w600),
                    )),
            SizedBox(
              width: caseList[index].mightBeCut == 0 ? 0 : 8,
            ),
            caseList[index].mightBeCut == 0
                ? SizedBox.shrink()
                : Container(
                    decoration: BoxDecoration(
                        color: Colors.orange,
                        border: Border.all(color: Colors.orange),
                        borderRadius: BorderRadius.all(Radius.circular(5))),
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Text(
                      caseList[index].mightBeCut.toString() ?? "",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
            SizedBox(
              width: caseList[index].haveBeemCut == 0 ? 0 : 8,
            ),
            caseList[index].haveBeemCut == 0
                ? SizedBox.shrink()
                : Container(
                    decoration: BoxDecoration(
                        color: Colors.grey,
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.all(Radius.circular(5))),
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Text(
                      caseList[index].haveBeemCut.toString() ?? "",
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
            caseList[index].locationName ?? " ",
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
            caseList[index].distance == null
                ? SizedBox.shrink()
                : Text(
                    caseList[index].distance.toStringAsFixed(3) + " km, ",
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600),
                  ),
            Expanded(
              flex: 5,
              child: Text(
                CommonFunction.timeCalculation(caseList[index].createdDate),
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600),
              ),
            ),
            Expanded(
              flex: 0,
              child: Text(
                caseList[index].isAnonymous
                    ? myUserId == caseList[index].userDetails["_id"]
                        ? "You as Anonymous"
                        : "Anonymous"
                    : caseList[index].userDetails["name"] == null
                        ? " "
                        : caseList[index].userDetails["name"],
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
          onTap: () async {
            bool needRefresh = await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        CaseDetailedView(caseList[index].id)));
            if (needRefresh) {
              updateTileDetails(caseList[index].id, index);
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
                            caseList[index].photos[k]["photo"].toString()),
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              backgroundColor: Colors.white54,
                              valueColor: new AlwaysStoppedAnimation<Color>(
                                  Colors.green),
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      (loadingProgress.expectedTotalBytes
                                          as num)
                                  : null,
                            ),
                          );
                        });
                  },
                  itemCount: caseList[index].photos.length,
                  pagination: caseList[index].photos.length > 1
                      ? SwiperPagination()
                      : SwiperPagination(builder: SwiperPagination.rect),
                  loop: false,
                  autoplay: false,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      caseList[index].caseUpdates != null
                          ? Container(
                              padding: EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5.0)),
                                color: Colors.black45,
                              ),
                              child: Text(
                                caseList[index].caseUpdates.length == 1
                                    ? "Update 1"
                                    : "Update ${caseList[index].caseUpdates.length}",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 12),
                              ),
                            )
                          : SizedBox.shrink(),
                      SizedBox(
                        width: caseList[index].caseUpdates == null ? 0 : 8.0,
                      ),
                      caseList[index].watchListCount == 0 ||
                              caseList[index].watchListCount == null
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
                                    caseList[index].watchListCount.toString(),
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                      SizedBox(
                        width: caseList[index].watchListCount == 0 ||
                                caseList[index].watchListCount == null
                            ? 0
                            : 8.0,
                      ),
                      caseList[index].commentCount == 0 ||
                              caseList[index].commentCount == null
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
                                    caseList[index].commentCount.toString(),
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                      Spacer(),
                      caseList[index].reportCount == 0 ||
                              caseList[index].reportCount == null
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
                                        caseList[index].reportCount.toString(),
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
}
