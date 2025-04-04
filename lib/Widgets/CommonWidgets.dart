import 'dart:core';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:naturesociety_new/BottomNavigation/BottomNavigation.dart';
import 'package:naturesociety_new/BottomNavigation/UserMainPage.dart';
import 'package:naturesociety_new/CaseView/CaseDetailedView.dart';
import 'package:naturesociety_new/SettingsScreen/Feedback.dart';
import 'package:naturesociety_new/SplashScreen.dart';
import 'package:naturesociety_new/Utils/LocalPrefManager.dart';
import 'package:naturesociety_new/Utils/MaterialComponets.dart';
import 'package:naturesociety_new/Utils/NetworkCall.dart';
import 'package:naturesociety_new/Widgets/CommonFunction.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:permission_handler/permission_handler.dart' as appHandler;

class CommonWidgets {
  static newAlertBox(BuildContext context, String msg, String title,
      {required bool leaveThatPage}) async {
    return showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return WillPopScope(
            onWillPop: () async => true,
            child: SimpleDialog(
              backgroundColor: Colors.white,
              children: <Widget>[
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          SizedBox(
                            height: 20,
                          ),
                          Icon(
                            Icons.info_outline,
                            color: Color(0xff006837),
                            size: 30,
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          Text(
                            title ?? '',
                            style: TextStyle(
                                color: Color(0xff006837),
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: new Text(msg ?? "Server Error"),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: TextButton(
                        style: TextButton.styleFrom(
                          minimumSize: Size.fromHeight(50),
                          backgroundColor: MaterialTools.basicColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            side: BorderSide(
                              color: MaterialTools.basicColor,
                              width: 1,
                            ),
                            borderRadius:
                                BorderRadius.all(Radius.circular(5.0)),
                          ),
                        ),
                        child: Text(
                          "Okay",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        onPressed: () {
                          if (leaveThatPage) {
                            Navigator.of(context).pop();
                            Navigator.of(context).pop();
                          } else {
                            Navigator.of(context).pop();
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        });
  }

  // -------- Alert Dialog ----------
  static void alertBox(BuildContext context, String msg,
      {required bool leaveThatPage}) {
    showDialog(
        context: context,
        builder: (context) => Platform.isIOS
            ? new CupertinoAlertDialog(
                content: new Text(msg),
                actions: <Widget>[
                  CupertinoDialogAction(
                    isDefaultAction: true,
                    child: Text("OK"),
                    onPressed: () {
                      if (leaveThatPage) {
                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
                      } else
                        Navigator.of(context).pop();
                    },
                  ),
                ],
              )
            : new AlertDialog(
                content: new Text(msg ?? "Server Error"),
                actions: [
                  TextButton(
                    child: new Text("OK"),
                    onPressed: () {
                      if (leaveThatPage) {
                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
                      } else
                        Navigator.of(context).pop();
                    },
                  ),
                ],
              ));
  }

  // ------- Alert Dialog with Options -----------
  static void alertBoxWithOption(BuildContext context, String msg,
      {required bool leaveThatPage}) {
    showDialog(
        context: context,
        builder: (context) => Platform.isIOS
            ? new CupertinoAlertDialog(
                content: new Text(msg),
                actions: <Widget>[
                  CupertinoDialogAction(
                    child: Text("CANCEL"),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  CupertinoDialogAction(
                    isDefaultAction: true,
                    child: Text("OK"),
                    onPressed: () {
                      if (leaveThatPage) {
                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
                      } else
                        Navigator.of(context).pop();
                    },
                  ),
                ],
              )
            : new AlertDialog(
                content: new Text(msg),
                actions: [
                  TextButton(
                    child: new Text("CANCEL"),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  TextButton(
                    child: new Text("OK"),
                    onPressed: () {
                      if (leaveThatPage) {
                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
                      } else
                        Navigator.of(context).pop();
                    },
                  ),
                ],
              ));
  }

  //  ---- Progress Indicator ------
  static progressIndicator(BuildContext context) {
    return Platform.isIOS
        ? Center(child: CupertinoActivityIndicator())
        : Center(
            child: Image(
              image: AssetImage("assets/loader.gif"),
              height: 100,
              width: 100,
            ),
          );
  }

  static var dialogBoxStyle = TextStyle(color: Colors.black, fontSize: 14);

  //----- Updation Success Dialog -----------

  static testingDialog(BuildContext context) async {
    return showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return new WillPopScope(
              onWillPop: () async => false,
              child: SimpleDialog(
                  backgroundColor: Colors.white,
                  children: <Widget>[
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                          horizontal: 10.0, vertical: 15.0),
                      child: Center(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              CircleAvatar(
                                radius: 40.0,
                                backgroundColor: Colors.green,
                                child: Icon(
                                  Icons.check,
                                  size: 60,
                                ),
                              ),
                              SizedBox(
                                height: 30.0,
                              ),
                              Text(
                                "Case has been successfully posted",
                                style: TextStyle(
                                    color: Colors.black, fontSize: 20),
                                textAlign: TextAlign.center,
                              ),
                            ]),
                      ),
                    )
                  ]));
        });
  }

  //----- Post Success Dialog -----------

  static testingDialog2(BuildContext context, var caseDetails) async {
    void _onShareTap(var linkMessage) async {
      int treeCount = await caseDetails["mightbecut"] +
          caseDetails["beencut"] +
          caseDetails["havebeencut"];
      String text = "Checkout this case about $treeCount " +
          "${treeCount > 1 ? "trees" : "tree"}" +
          " at " +
          caseDetails["locationname"] +
          ", using Save Tress app. (Case ID: ${caseDetails["caseidentifier"] == null ? caseDetails["caseid"] : caseDetails["caseidentifier"]})";

      final RenderBox box = context.findRenderObject() as RenderBox;
      Share.share(text + "\n" + linkMessage,
          sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size);
    }

    return showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return WillPopScope(
            onWillPop: () async => false,
            child: Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0)),
              elevation: 0.0,
              backgroundColor: Colors.transparent,
              child: Container(
                decoration:
                    BoxDecoration(borderRadius: BorderRadius.circular(8)),
                margin: EdgeInsets.only(left: 0.0, right: 0.0),
                child: Stack(
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.only(
                        top: 18.0,
                      ),
                      margin: EdgeInsets.only(top: 23.0, right: 8.0),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.circular(8.0),
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 0.0,
                              offset: Offset(0.0, 0.0),
                            ),
                          ]),
                      child: SingleChildScrollView(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(
                              horizontal: 10.0, vertical: 15.0),
                          child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                SizedBox(
                                  height: 30.0,
                                ),
                                Text(
                                  "Case has been successfully posted",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontWeight: FontWeight.w400),
                                ),
                                Text(
                                  "Case ID: ",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14),
                                  textAlign: TextAlign.center,
                                ),
                                Text(
                                  caseDetails["caseidentifier"].toString() ??
                                      " ",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 17),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(
                                  height: 10.0,
                                ),
                                Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.all(5.0),
                                  color: Colors.teal.withOpacity(0.1),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: <Widget>[
                                      Text(
                                        "Steps you can take now",
                                        style: TextStyle(
                                            fontWeight: FontWeight.w600),
                                      ),
                                      SizedBox(
                                        height: 8.0,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          // CircleAvatar(radius: 3.0,backgroundColor: Colors.black54,),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 6),
                                            child: Icon(
                                              Icons.circle,
                                              size: 10,
                                              color: Colors.grey,
                                            ),
                                          ),
                                          SizedBox(
                                            width: 10.0,
                                          ),
                                          Expanded(
                                              flex: 1,
                                              child: Text(
                                                "Check online for contact details of the authorities and environment NGOs and share the case with them.",
                                                style: dialogBoxStyle,
                                              )),
                                        ],
                                      ),
                                      SizedBox(
                                        height: 8.0,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          // CircleAvatar(radius: 3.0,backgroundColor: Colors.black54,),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 6),
                                            child: Icon(
                                              Icons.circle,
                                              size: 10,
                                              color: Colors.grey,
                                            ),
                                          ),
                                          SizedBox(
                                            width: 10.0,
                                          ),
                                          Expanded(
                                              flex: 1,
                                              child: Text(
                                                "Check if the people cutting the tree have a permission.",
                                                style: dialogBoxStyle,
                                              )),
                                        ],
                                      ),
                                      SizedBox(
                                        height: 8.0,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          // CircleAvatar(radius: 3.0,backgroundColor: Colors.black54,),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 6),
                                            child: Icon(
                                              Icons.circle,
                                              size: 10,
                                              color: Colors.grey,
                                            ),
                                          ),
                                          SizedBox(
                                            width: 10.0,
                                          ),
                                          Expanded(
                                              flex: 1,
                                              child: Text(
                                                "Look for solutions on discussion pages of nearby cases.",
                                                style: dialogBoxStyle,
                                              )),
                                        ],
                                      ),
                                      SizedBox(
                                        height: 8.0,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          // CircleAvatar(radius: 3.0,backgroundColor: Colors.black54,),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 6),
                                            child: Icon(
                                              Icons.circle,
                                              size: 10,
                                              color: Colors.grey,
                                            ),
                                          ),
                                          SizedBox(
                                            width: 10.0,
                                          ),
                                          Expanded(
                                              flex: 1,
                                              child: Text(
                                                "Research online for the local laws for trees.",
                                                style: dialogBoxStyle,
                                              )),
                                        ],
                                      ),
                                      SizedBox(
                                        height: 8.0,
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: 8.0,
                                ),
                                MaterialButton(
                                  shape: MaterialTools.materialButtonShape,
                                  minWidth: double.infinity,
                                  height: 50,
                                  padding: EdgeInsets.all(3.0),
                                  onPressed: () {
                                    Navigator.pop(context);
                                    Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                FeedbackForm("Case")));
                                  },
                                  color: Colors.white,
                                  textColor: MaterialTools.basicColor,
                                  child: Column(
                                    children: <Widget>[
                                      Text(
                                        "Give Feedback",
                                        style: TextStyle(
                                            fontWeight: FontWeight.w600),
                                      ),
                                      Text(
                                        "Make the app better by sharing your inputs",
                                        style: TextStyle(fontSize: 12.0),
                                        maxLines: 1,
                                        overflow: TextOverflow.fade,
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: 8.0,
                                ),
                                Divider(),
                                SizedBox(
                                  height: 8.0,
                                ),
                                TextButton.icon(
                                  style: TextButton.styleFrom(
                                    minimumSize: Size.fromHeight(50),
                                    shape: RoundedRectangleBorder(
                                        side: BorderSide(
                                            color: MaterialTools.basicColor,
                                            width: 1),
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(5.0))),
                                    backgroundColor: MaterialTools.basicColor,
                                    foregroundColor: Colors.teal,
                                  ),
                                  icon: Icon(
                                    Icons.share_outlined,
                                    color: Colors.white,
                                  ),
                                  onPressed: () async {
                                    var link =
                                        await CommonFunction.createDynamicLink(
                                            caseId: caseDetails["_id"],
                                            description:
                                                caseDetails["locationname"],
                                            title:
                                                "Case ID: ${caseDetails["caseidentifier"] == null ? caseDetails["caseid"].toString() : caseDetails["caseidentifier"].toString()}",
                                            image: caseDetails["photos"][0]
                                                ["photo"]);
                                    if (link != null) _onShareTap(link);
                                  },
                                  label: Text(
                                    " Share this case",
                                    style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white),
                                  ),
                                ),
                              ]),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 0.0,
                      right: 0.0,
                      left: 0.0,
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.white,
                          child: CircleAvatar(
                            radius: 30.0,
                            backgroundColor: Color(0xFF2F9F62),
                            child: Icon(
                              Icons.done_rounded,
                              color: Colors.white,
                              size: 40,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 0.0,
                      top: 10,
                      child: GestureDetector(
                        onTap: () {
                          currentPageCount = 1;
                          totalIncidentCount = 0;
                          cases.clear();
                          myLocationData.clear();
                          Navigator.pop(context);
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => BottomNavPage()));
                        },
                        child: Align(
                          alignment: Alignment.topRight,
                          child: CircleAvatar(
                            backgroundColor: Colors.grey,
                            radius: 21,
                            child: CircleAvatar(
                              radius: 20.0,
                              backgroundColor: Colors.white,
                              child: Icon(Icons.close, color: Colors.grey),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }

  static postingSuccessDialog(BuildContext context) async {
    return showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return new WillPopScope(
              onWillPop: () async => false,
              child: SimpleDialog(
                  backgroundColor: Colors.white,
                  children: <Widget>[
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                          horizontal: 10.0, vertical: 15.0),
                      child: Center(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              CircleAvatar(
                                radius: 40.0,
                                backgroundColor: Colors.green,
                                child: Icon(
                                  Icons.check,
                                  size: 60,
                                ),
                              ),
                              SizedBox(
                                height: 30.0,
                              ),
                              Text(
                                "Case has been successfully posted",
                                style: TextStyle(
                                    color: Colors.black, fontSize: 20),
                                textAlign: TextAlign.center,
                              ),
                            ]),
                      ),
                    )
                  ]));
        });
  }

  //----- Updation Success Dialog -----------

  static updationSuccessDialog(BuildContext context) async {
    return showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return new WillPopScope(
              onWillPop: () async => false,
              child: SimpleDialog(
                  backgroundColor: Colors.white,
                  children: <Widget>[
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                          horizontal: 10.0, vertical: 15.0),
                      child: Center(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              CircleAvatar(
                                radius: 40.0,
                                backgroundColor: Colors.green,
                                child: Icon(
                                  Icons.check,
                                  size: 60,
                                ),
                              ),
                              SizedBox(
                                height: 30.0,
                              ),
                              Text(
                                "Case has been successfully updated",
                                style: TextStyle(
                                    color: Colors.black, fontSize: 20),
                                textAlign: TextAlign.center,
                              ),
                            ]),
                      ),
                    )
                  ]));
        });
  }

  //----- Updation Success Dialog -----------
  static upDationMarkDialog(BuildContext context, var caseDetails, type) async {
    void _onShareTap(var linkMessage) async {
      int treeCount = await caseDetails["mightbecut"] +
          caseDetails["beencut"] +
          caseDetails["havebeencut"];
      String text = "Checkout this case about $treeCount " +
          "${treeCount > 1 ? "trees" : "tree"}" +
          " at " +
          caseDetails["locationname"] +
          ", using Save Tress app. (Case ID: ${caseDetails["caseidentifier"] == null ? caseDetails["caseid"] : caseDetails["caseidentifier"]})";

      final RenderBox box = context.findRenderObject() as RenderBox;
      Share.share(text + "\n" + linkMessage,
          sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size);
    }

    return showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return WillPopScope(
            onWillPop: () async => false,
            child: Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0)),
              elevation: 0.0,
              backgroundColor: Colors.transparent,
              child: Container(
                margin: EdgeInsets.only(left: 0.0, right: 0.0),
                child: Stack(
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.only(
                        top: 18.0,
                      ),
                      margin: EdgeInsets.only(top: 23.0, right: 8.0),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.circular(8.0),
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 0.0,
                              offset: Offset(0.0, 0.0),
                            ),
                          ]),
                      child: SingleChildScrollView(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(
                              horizontal: 10.0, vertical: 15.0),
                          child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                SizedBox(
                                  height: 30.0,
                                ),
                                Text(
                                  "Case has been successfully $type",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontWeight: FontWeight.w400),
                                ),
                                Text(
                                  "Case ID: ",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14),
                                  textAlign: TextAlign.center,
                                ),
                                Text(
                                  caseDetails["caseidentifier"].toString() ??
                                      " ",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 17),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(
                                  height: 10.0,
                                ),
                                Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.all(5.0),
                                  color: Colors.teal.withOpacity(0.1),
                                  child: Column(
                                    children: <Widget>[
                                      Text(
                                        "Steps you can take now",
                                        style: TextStyle(
                                            fontWeight: FontWeight.w600),
                                      ),
                                      SizedBox(
                                        height: 8.0,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          // CircleAvatar(radius: 3.0,backgroundColor: Colors.black54,),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 6),
                                            child: Icon(
                                              Icons.circle,
                                              size: 10,
                                              color: Colors.grey,
                                            ),
                                          ),
                                          SizedBox(
                                            width: 10.0,
                                          ),
                                          Expanded(
                                              flex: 1,
                                              child: Text(
                                                "Check online for contact details of the authorities and environment NGOs and share the case with them.",
                                                style: dialogBoxStyle,
                                              )),
                                        ],
                                      ),
                                      SizedBox(
                                        height: 8.0,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          // CircleAvatar(radius: 3.0,backgroundColor: Colors.black54,),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 6),
                                            child: Icon(
                                              Icons.circle,
                                              size: 10,
                                              color: Colors.grey,
                                            ),
                                          ),
                                          SizedBox(
                                            width: 10.0,
                                          ),
                                          Expanded(
                                              flex: 1,
                                              child: Text(
                                                "Check if the people cutting the tree have a permission.",
                                                style: dialogBoxStyle,
                                              )),
                                        ],
                                      ),
                                      SizedBox(
                                        height: 8.0,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          // CircleAvatar(radius: 3.0,backgroundColor: Colors.black54,),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 6),
                                            child: Icon(
                                              Icons.circle,
                                              size: 10,
                                              color: Colors.grey,
                                            ),
                                          ),
                                          SizedBox(
                                            width: 10.0,
                                          ),
                                          Expanded(
                                              flex: 1,
                                              child: Text(
                                                "Look for solutions on discussion pages of nearby cases.",
                                                style: dialogBoxStyle,
                                              )),
                                        ],
                                      ),
                                      SizedBox(
                                        height: 8.0,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          // CircleAvatar(radius: 3.0,backgroundColor: Colors.black54,),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 6),
                                            child: Icon(
                                              Icons.circle,
                                              size: 10,
                                              color: Colors.grey,
                                            ),
                                          ),
                                          SizedBox(
                                            width: 10.0,
                                          ),
                                          Expanded(
                                              flex: 1,
                                              child: Text(
                                                "Research online for the local laws for trees.",
                                                style: dialogBoxStyle,
                                              )),
                                        ],
                                      ),
                                      SizedBox(
                                        height: 8.0,
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: 8.0,
                                ),
                                MaterialButton(
                                  shape: MaterialTools.materialButtonShape,
                                  minWidth: double.infinity,
                                  height: 50,
                                  padding: EdgeInsets.all(3.0),
                                  onPressed: () {
                                    Navigator.pop(context);
                                    Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                FeedbackForm("Update")));
                                  },
                                  color: Colors.white,
                                  textColor: MaterialTools.basicColor,
                                  child: Column(
                                    children: <Widget>[
                                      Text(
                                        "Give Feedback",
                                        style: TextStyle(
                                            fontWeight: FontWeight.w600),
                                      ),
                                      Text(
                                        "Make the app better by sharing your inputs",
                                        style: TextStyle(fontSize: 12.0),
                                        maxLines: 1,
                                        overflow: TextOverflow.fade,
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: 8.0,
                                ),
                                Divider(),
                                SizedBox(
                                  height: 8.0,
                                ),
                                TextButton.icon(
                                  style: TextButton.styleFrom(
                                    minimumSize:
                                        Size.fromWidth(double.infinity),
                                    fixedSize: Size.fromHeight(50),
                                    shape: RoundedRectangleBorder(
                                        side: BorderSide(
                                            color: MaterialTools.basicColor,
                                            width: 1),
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(5.0))),
                                    backgroundColor: MaterialTools.basicColor,
                                    foregroundColor: Colors.teal,
                                  ),
                                  icon: Icon(
                                    Icons.share_outlined,
                                    color: Colors.white,
                                  ),
                                  onPressed: () async {
                                    var link =
                                        await CommonFunction.createDynamicLink(
                                            caseId: caseDetails["_id"],
                                            description:
                                                caseDetails["locationname"],
                                            title:
                                                "Case ID: ${caseDetails["caseidentifier"] == null ? caseDetails["caseid"].toString() : caseDetails["caseidentifier"].toString()}",
                                            image: caseDetails["photos"][0]
                                                ["photo"]);
                                    if (link != null) _onShareTap(link);
                                  },
                                  label: Text(
                                    " Share this case",
                                    style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white),
                                  ),
                                ),
                              ]),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 0.0,
                      right: 0.0,
                      left: 0.0,
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.white,
                          child: CircleAvatar(
                            radius: 30.0,
                            backgroundColor: Color(0xFF2F9F62),
                            child: Icon(
                              Icons.done_rounded,
                              color: Colors.white,
                              size: 40,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 0.0,
                      top: 10,
                      child: GestureDetector(
                        onTap: () {
                          currentPageCount = 1;
                          totalIncidentCount = 0;
                          cases.clear();
                          myLocationData.clear();
                          Navigator.pop(context);
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => BottomNavPage()));
                        },
                        child: Align(
                          alignment: Alignment.topRight,
                          child: CircleAvatar(
                            radius: 21.0,
                            backgroundColor: Colors.grey,
                            child: CircleAvatar(
                              radius: 20.0,
                              backgroundColor: Colors.white,
                              child: Icon(Icons.close, color: Colors.grey),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }

  // ------- Updation Success Within Case-------------
  static updationMarkDialogCase(
      BuildContext context, var caseDetails, var navigateCase) async {
    void _onShareTap(var linkMessage) async {
      int treeCount = await caseDetails["mightbecut"] +
          caseDetails["beencut"] +
          caseDetails["havebeencut"];
      String text = "Checkout this case about $treeCount " +
          "${treeCount > 1 ? "trees" : "tree"}" +
          " at " +
          caseDetails["locationname"] +
          ", using Save Tress app. (Case ID: ${caseDetails["caseidentifier"] == null ? caseDetails["caseid"] : caseDetails["caseidentifier"]})";

      final RenderBox box = context.findRenderObject() as RenderBox;
      Share.share(text + "\n" + linkMessage,
          sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size);
    }

    return showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return WillPopScope(
            onWillPop: () async => false,
            child: Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0)),
              elevation: 0.0,
              backgroundColor: Colors.transparent,
              child: Container(
                margin: EdgeInsets.only(left: 0.0, right: 0.0),
                child: Stack(
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.only(
                        top: 18.0,
                      ),
                      margin: EdgeInsets.only(top: 23.0, right: 8.0),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.circular(8.0),
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 0.0,
                              offset: Offset(0.0, 0.0),
                            ),
                          ]),
                      child: SingleChildScrollView(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(
                              horizontal: 10.0, vertical: 15.0),
                          child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                SizedBox(
                                  height: 30.0,
                                ),
                                Text(
                                  "Case has been successfully updated",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontWeight: FontWeight.w400),
                                ),
                                Text(
                                  "Case ID: ",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14),
                                  textAlign: TextAlign.center,
                                ),
                                Text(
                                  caseDetails["caseidentifier"].toString() ??
                                      " ",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 17),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(
                                  height: 10.0,
                                ),
                                Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.all(5.0),
                                  color: Colors.teal.withOpacity(0.1),
                                  child: Column(
                                    children: <Widget>[
                                      Text(
                                        "Steps you can take now",
                                        style: TextStyle(
                                            fontWeight: FontWeight.w600),
                                      ),
                                      SizedBox(
                                        height: 8.0,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          // CircleAvatar(radius: 3.0,backgroundColor: Colors.black54,),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 6),
                                            child: Icon(
                                              Icons.circle,
                                              size: 10,
                                              color: Colors.grey,
                                            ),
                                          ),
                                          SizedBox(
                                            width: 10.0,
                                          ),
                                          Expanded(
                                              flex: 1,
                                              child: Text(
                                                "Check online for contact details of the authorities and environment NGOs and share the case with them.",
                                                style: dialogBoxStyle,
                                              )),
                                        ],
                                      ),
                                      SizedBox(
                                        height: 8.0,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          // CircleAvatar(radius: 3.0,backgroundColor: Colors.black54,),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 6),
                                            child: Icon(
                                              Icons.circle,
                                              size: 10,
                                              color: Colors.grey,
                                            ),
                                          ),
                                          SizedBox(
                                            width: 10.0,
                                          ),
                                          Expanded(
                                              flex: 1,
                                              child: Text(
                                                "Check if the people cutting the tree have a permission.",
                                                style: dialogBoxStyle,
                                              )),
                                        ],
                                      ),
                                      SizedBox(
                                        height: 8.0,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          // CircleAvatar(radius: 3.0,backgroundColor: Colors.black54,),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 6),
                                            child: Icon(
                                              Icons.circle,
                                              size: 10,
                                              color: Colors.grey,
                                            ),
                                          ),
                                          SizedBox(
                                            width: 10.0,
                                          ),
                                          Expanded(
                                              flex: 1,
                                              child: Text(
                                                "Look for solutions on discussion pages of nearby cases.",
                                                style: dialogBoxStyle,
                                              )),
                                        ],
                                      ),
                                      SizedBox(
                                        height: 8.0,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          // CircleAvatar(radius: 3.0,backgroundColor: Colors.black54,),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 6),
                                            child: Icon(
                                              Icons.circle,
                                              size: 10,
                                              color: Colors.grey,
                                            ),
                                          ),
                                          SizedBox(
                                            width: 10.0,
                                          ),
                                          Expanded(
                                              flex: 1,
                                              child: Text(
                                                "Research online for the local laws for trees.",
                                                style: dialogBoxStyle,
                                              )),
                                        ],
                                      ),
                                      SizedBox(
                                        height: 8.0,
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: 8.0,
                                ),
                                MaterialButton(
                                  shape: MaterialTools.materialButtonShape,
                                  minWidth: double.infinity,
                                  height: 50,
                                  padding: EdgeInsets.all(3.0),
                                  onPressed: () {
                                    Navigator.pop(context);
                                    Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                FeedbackForm("Update")));
                                  },
                                  color: Colors.white,
                                  textColor: MaterialTools.basicColor,
                                  child: Column(
                                    children: <Widget>[
                                      Text(
                                        "Give Feedback",
                                        style: TextStyle(
                                            fontWeight: FontWeight.w600),
                                      ),
                                      Text(
                                        "Make the app better by sharing your inputs",
                                        style: TextStyle(fontSize: 12.0),
                                        maxLines: 1,
                                        overflow: TextOverflow.fade,
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: 8.0,
                                ),
                                Divider(),
                                SizedBox(
                                  height: 8.0,
                                ),
                                TextButton.icon(
                                  style: TextButton.styleFrom(
                                    minimumSize: Size.fromHeight(50),
                                    backgroundColor: MaterialTools.basicColor,
                                    foregroundColor: Colors.teal,
                                    shape: RoundedRectangleBorder(
                                      side: BorderSide(
                                        color: MaterialTools.basicColor,
                                        width: 1,
                                      ),
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(5.0)),
                                    ),
                                  ),
                                  icon: Icon(
                                    Icons.share_outlined,
                                    color: Colors.white,
                                  ),
                                  onPressed: () async {
                                    var link =
                                        await CommonFunction.createDynamicLink(
                                            caseId: caseDetails["_id"],
                                            description:
                                                caseDetails["locationname"],
                                            title:
                                                "Case ID: ${caseDetails["caseidentifier"] == null ? caseDetails["caseid"].toString() : caseDetails["caseidentifier"].toString()}",
                                            image: caseDetails["photos"][0]
                                                ["photo"]);
                                    if (link != null) _onShareTap(link);
                                  },
                                  label: Text(
                                    " Share this case",
                                    style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white),
                                  ),
                                ),
                              ]),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 0.0,
                      right: 0.0,
                      left: 0.0,
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.white,
                          child: CircleAvatar(
                            radius: 30.0,
                            backgroundColor: Color(0xFF2F9F62),
                            child: Icon(
                              Icons.done_rounded,
                              color: Colors.white,
                              size: 40,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 0.0,
                      top: 10,
                      child: GestureDetector(
                        onTap: () {
                          // currentPageCount = 1; totalIncidentCount =0;
                          // selectedChoice= null; cases.clear();myLocationData.clear();
                          Navigator.pop(context);
                          Navigator.pop(context);
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      CaseDetailedView(navigateCase)));
                          //  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> BottomNavPage()));
                        },
                        child: Align(
                          alignment: Alignment.topRight,
                          child: CircleAvatar(
                            radius: 21,
                            backgroundColor: Colors.grey,
                            child: CircleAvatar(
                              radius: 20.0,
                              backgroundColor: Colors.white,
                              child: Icon(Icons.close, color: Colors.grey),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }

//-------------- LogOut User Message --------------------------
  static loginLimit(BuildContext context) async {
    return showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return new WillPopScope(
              onWillPop: () async => false,
              child: SimpleDialog(
                  backgroundColor: Colors.white,
                  children: <Widget>[
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                          horizontal: 10.0, vertical: 15.0),
                      child: Center(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              CircleAvatar(
                                radius: 40.0,
                                backgroundColor: Colors.redAccent,
                                child: Icon(
                                  Icons.lock,
                                  size: 60,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(
                                height: 30.0,
                              ),
                              Text(
                                "Login Limit",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold),
                              ),
                              SizedBox(
                                height: 8.0,
                              ),
                              Text(
                                "Multiple Login of this number is detected",
                                style: TextStyle(color: Colors.black),
                              ),
                              SizedBox(
                                height: 10.0,
                              ),
                              MaterialButton(
                                height: 50.0,
                                minWidth: double.infinity,
                                color: MaterialTools.deletionColor,
                                onPressed: () {
                                  ApiCall.clearLocalStorage();
                                  Navigator.pop(context);
                                  Navigator.pushAndRemoveUntil(
                                      context,
                                      CupertinoPageRoute(
                                          builder: (context) => SplashScreen()),
                                      (route) => false);
                                },
                                child: Text("Logout from this device"),
                                textColor: Colors.white,
                              )
                            ]),
                      ),
                    )
                  ]));
        });
  }

  // ----------- App Update Dialog ---------------
  static Future<void> showVersionDialog(BuildContext context) async {
    return showDialog<void>(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return new WillPopScope(
              onWillPop: () async {
                LocalPrefManager.clearLocalFeedbackTime();
                await LocalPrefManager.setMainLaunch(false);
                Navigator.pop(context);
                return Future.value(true);
              },
              child: SimpleDialog(
                  backgroundColor: Colors.white,
                  children: <Widget>[
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(horizontal: 10.0),
                      child: Center(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                "New Version of App is Available!",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16),
                              ),
                              Divider(
                                color: Colors.grey,
                                height: 20.0,
                              ),
                              Text(
                                  "${MaterialTools.appTitle} recommends you to update to the latest version, to feel the improved stable version of app."),
                              SizedBox(
                                height: 15.0,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  TextButton(
                                    onPressed: () async {
                                      LocalPrefManager.clearLocalFeedbackTime();
                                      await LocalPrefManager.setMainLaunch(
                                          false);
                                      Navigator.pop(context);
                                    },
                                    child: Text(
                                      "No, Thanks",
                                      style: TextStyle(fontSize: 12.0),
                                    ),
                                  ),
                                  Spacer(),
                                  MaterialButton(
                                    textColor: Colors.white,
                                    color: Colors.teal,
                                    minWidth: 50,
                                    onPressed: () async {
                                      const url =
                                          'https://play.google.com/store/apps/details?id=ndns.save_trees';
                                      if (await canLaunch(url)) {
                                        await launch(url);
                                      } else {
                                        throw 'Could not launch $url';
                                      }
                                      Navigator.pop(context);
                                    },
                                    child: Text(
                                      "Update App",
                                      style: TextStyle(fontSize: 12.0),
                                    ),
                                  ),
                                ],
                              ),
                            ]),
                      ),
                    )
                  ]));
        });
  }

  static Future<void> permissionDialog({
    required BuildContext context,
    required String type,
  }) async {
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
                      padding: EdgeInsets.symmetric(
                          horizontal: 10.0, vertical: 15.0),
                      child: Center(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              CircleAvatar(
                                radius: 25.0,
                                backgroundColor: Colors.redAccent,
                                child: Icon(
                                  Icons.app_settings_alt_outlined,
                                  size: 50,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(
                                height: 30.0,
                              ),
                              Text(
                                "Premission Required",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold),
                              ),
                              SizedBox(
                                height: 8.0,
                              ),
                              Text(
                                "$type permission is required for this action to perform. Please allow $type Permission by going to Phone Settings"
                                "-> App Permission -> Save Trees",
                                style: TextStyle(color: Colors.black),
                              ),
                              SizedBox(
                                height: 10.0,
                              ),
                              MaterialButton(
                                height: 50.0,
                                minWidth: double.infinity,
                                color: MaterialTools.basicColor,
                                onPressed: () {
                                  Navigator.pop(context);
                                  appHandler.openAppSettings();
                                },
                                child: Text("Goto App Settings"),
                                textColor: Colors.white,
                              ),
                              SizedBox(
                                height: 10.0,
                              ),
                              MaterialButton(
                                shape: MaterialTools.materialButtonShape,
                                height: 50.0,
                                minWidth: double.infinity,
                                color: Colors.white,
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text("Cancel"),
                                textColor: MaterialTools.basicColor,
                              )
                            ]),
                      ),
                    )
                  ]));
        });
  }
}
