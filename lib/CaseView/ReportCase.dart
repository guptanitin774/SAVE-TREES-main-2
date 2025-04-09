import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:naturesociety_new/Utils/LocalPrefManager.dart';
import 'package:naturesociety_new/Utils/MaterialComponets.dart';
import 'package:naturesociety_new/Utils/NetworkCall.dart';
import 'package:naturesociety_new/Widgets/CommonWidgets.dart';
import 'package:naturesociety_new/Widgets/UploadingLoader.dart';

class ReportCase extends StatefulWidget {
  final incidentId, incidentDetails;

  ReportCase(this.incidentId, this.incidentDetails);

  _ReportCase createState() => _ReportCase();
}

class _ReportCase extends State<ReportCase> {
  List<PhotoDetails> casePhotos = [];

  @override
  void initState() {
    super.initState();
    setDefaultUser();
    casePhotos.clear();
    for (int i = 0; i < widget.incidentDetails["photos"].length; i++)
      casePhotos.add(PhotoDetails(widget.incidentDetails["photos"][i]["_id"],
          widget.incidentDetails["photos"][i]["photo"], false));

    if (widget.incidentDetails["updates"].isNotEmpty)
      for (int j = 0; j < widget.incidentDetails["updates"].length; j++)
        for (int k = 0;
            k < widget.incidentDetails["updates"][j]["photos"].length;
            k++)
          casePhotos.add(PhotoDetails(
              widget.incidentDetails["updates"][j]["photos"][k]["_id"],
              widget.incidentDetails["updates"][j]["photos"][k]["photo"],
              false));
  }

  var userName = "";
  late String selectedUserType;

  Future<void> setDefaultUser() async {
    userName = (await LocalPrefManager.getUserName())!;
    bool? anonymous = await LocalPrefManager.getAnonymity();
    if (anonymous! || anonymous == null)
      selectedUserType = "Anonymous";
    else {
      if (userName == "" || userName == null)
        selectedUserType = "Anonymous";
      else
        selectedUserType = userName;
    }
    setState(() {});
  }

  TextEditingController _descriptionController = TextEditingController();

  bool isSpamContent = false,
      isViolence = false,
      isInappropriateLanguage = false,
      isNoTreePicture = false,
      isOthers = false;

  @override
  Widget build(BuildContext context) {
    bool keyboardIsOpened = MediaQuery.of(context).viewInsets.bottom != 0.0;
    return Scaffold(
        appBar: AppBar(
          title: Text("REPORT THIS CASE"),
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
          physics: ClampingScrollPhysics(),
          child: AnimationLimiter(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: AnimationConfiguration.toStaggeredList(
                duration: const Duration(milliseconds: 400),
                childAnimationBuilder: (widget) => SlideAnimation(
                  horizontalOffset: 100.0,
                  child: FadeInAnimation(
                    child: widget,
                  ),
                ),
                children: [
                  Text(
                    "Reason:",
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  GestureDetector(
                    onTap: () {
                      isSpamContent = !isSpamContent;
                      setState(() {});
                    },
                    child: Row(
                      children: <Widget>[
                        Checkbox(
                            value: isSpamContent,
                            onChanged: (value) {
                              isSpamContent = !isSpamContent;
                              setState(() {});
                            }),
                        SizedBox(
                          width: 5.0,
                        ),
                        Expanded(
                          child: Text(
                            "Spam content ( ads, memes etc)",
                            style: TextStyle(
                                fontWeight: isSpamContent
                                    ? FontWeight.w800
                                    : FontWeight.normal),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      isViolence = !isViolence;
                      setState(() {});
                    },
                    child: Row(
                      children: <Widget>[
                        Checkbox(
                            value: isViolence,
                            onChanged: (value) {
                              isViolence = !isViolence;
                              setState(() {});
                            }),
                        SizedBox(
                          width: 5.0,
                        ),
                        Expanded(
                          child: Text(
                            "Graphic images, violence etc",
                            style: TextStyle(
                                fontWeight: isViolence
                                    ? FontWeight.w800
                                    : FontWeight.normal),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      isInappropriateLanguage = !isInappropriateLanguage;
                      setState(() {});
                    },
                    child: Row(
                      children: <Widget>[
                        Checkbox(
                            value: isInappropriateLanguage,
                            onChanged: (value) {
                              isInappropriateLanguage =
                                  !isInappropriateLanguage;
                              setState(() {});
                            }),
                        SizedBox(
                          width: 5.0,
                        ),
                        Expanded(
                          child: Text(
                            "Inappropriate language",
                            style: TextStyle(
                                fontWeight: isInappropriateLanguage
                                    ? FontWeight.w800
                                    : FontWeight.normal),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      isNoTreePicture = !isNoTreePicture;
                      setState(() {});
                    },
                    child: Row(
                      children: <Widget>[
                        Checkbox(
                            value: isNoTreePicture,
                            onChanged: (value) {
                              isNoTreePicture = !isNoTreePicture;
                              setState(() {});
                            }),
                        SizedBox(
                          width: 5.0,
                        ),
                        Expanded(
                          child: Text(
                            "No picture of trees",
                            style: TextStyle(
                                fontWeight: isNoTreePicture
                                    ? FontWeight.w800
                                    : FontWeight.normal),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      isOthers = !isOthers;
                      setState(() {});
                    },
                    child: Row(
                      children: <Widget>[
                        Checkbox(
                            value: isOthers,
                            onChanged: (value) {
                              isOthers = !isOthers;
                              setState(() {});
                            }),
                        SizedBox(
                          width: 5.0,
                        ),
                        Expanded(
                          child: Text(
                            "Other",
                            style: TextStyle(
                                fontWeight: isOthers
                                    ? FontWeight.w800
                                    : FontWeight.normal),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  TextFormField(
                      controller: _descriptionController,
                      maxLines: 5,
                      decoration: InputDecoration(
                        labelText: "Write a description here…(optional)",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                                MaterialTools.borderRadius),
                            borderSide: BorderSide(
                                width: MaterialTools.borderWidth,
                                style: BorderStyle.none,
                                color: MaterialTools.borderColor)),
                      )),
                  SizedBox(
                    height: 10.0,
                  ),
                  Text(
                    "Select the inappropriate pictures",
                    style: TextStyle(color: Colors.black54),
                  ),
                  SizedBox(
                    height: 8.0,
                  ),
                  _photoBuilder(context),
                  Divider(
                    height: 20.0,
                    thickness: 1.0,
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  Text(
                      "Your report will be sent for review, if your reasons are valid we will take action accordingly."),
                  SizedBox(
                    height: 20.0,
                  ),
                  userName == "" || userName == null
                      ? SizedBox.shrink()
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [Text("I want to report this case as:")],
                        ),
                  userName == "" || userName == null
                      ? SizedBox.shrink()
                      : Center(
                          child: Wrap(
                            alignment: WrapAlignment.center,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: <Widget>[
                              userName == "" || userName == null
                                  ? SizedBox.shrink()
                                  : Radio(
                                      value: userName,
                                      groupValue: selectedUserType,
                                      onChanged: radioButtonChanges,
                                    ),
                              userName == "" || userName == null
                                  ? SizedBox.shrink()
                                  : Text(
                                      userName,
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                              SizedBox(
                                height: 8.0,
                              ),
                              Radio(
                                value: 'Anonymous',
                                groupValue: selectedUserType,
                                onChanged: radioButtonChanges,
                              ),
                              Text("Anonymous",
                                  maxLines: 3, overflow: TextOverflow.ellipsis),
                            ],
                          ),
                        ),
                  SizedBox(
                    height: 70.0,
                  ),
                ],
              ),
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: Opacity(
          opacity: keyboardIsOpened ? 0 : 1,
          child: MaterialButton(
            height: 60.0,
            minWidth: double.infinity,
            onPressed: () {
              if (!isSpamContent &&
                  !isViolence &&
                  !isInappropriateLanguage &&
                  !isNoTreePicture &&
                  !isOthers) {
                CommonWidgets.alertBox(context, "Please Choose the reason",
                    leaveThatPage: false);
              } else
                reportFalseAlarm();
            },
            color: MaterialTools.basicColor,
            textColor: Colors.white,
            child: Wrap(
              alignment: WrapAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "REPORT CASE",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Icon(
                      Icons.arrow_forward,
                      color: Colors.white,
                    )
                  ],
                ),
                Text("as " + selectedUserType.toString()),
              ],
            ),
          ),
        ));
  }

  late String choice;

  void radioButtonChanges(String? value) async {
    setState(() {
      selectedUserType = value!;
      switch (value) {
        case 'anonymous':
          choice = value;
          break;
        case 'name':
          choice = value;
          break;
        default:
          choice = '';
      }
      debugPrint(choice); // Debug the choice in console
    });
  }

  List selectedImageList = [];

  _photoBuilder(BuildContext context) {
    return GridView.builder(
        physics: NeverScrollableScrollPhysics(),
        itemCount: casePhotos.length,
        shrinkWrap: true,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisSpacing: 8, mainAxisSpacing: 8, crossAxisCount: 3),
        itemBuilder: (context, index) {
          return Stack(
            children: <Widget>[
              GestureDetector(
                onTap: () {
                  setState(() {
                    if (casePhotos[index].selected)
                      casePhotos[index].setter(false);
                    else
                      casePhotos[index].setter(true);
                    casePhotos[index].selected
                        ? selectedImageList.add(casePhotos[index].imageId)
                        : selectedImageList.remove(casePhotos[index].imageId);
                  });
                },
                child: Container(
                    padding: const EdgeInsets.all(3.0),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.blueGrey),
                      borderRadius: BorderRadius.all(Radius.circular(1.0)),
                    ),
                    height: 200,
                    width: 200,
                    child: ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(1.0)),
                      child: Image(
                          image: NetworkImage(
                              ApiCall.imageUrl + casePhotos[index].imageName),
                          fit: BoxFit.cover,
                          loadingBuilder: (BuildContext context, Widget child,
                              ImageChunkEvent? loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                backgroundColor: Colors.white54,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.green),
                                value: loadingProgress.expectedTotalBytes !=
                                        null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        (loadingProgress.expectedTotalBytes ??
                                            1)
                                    : null,
                              ),
                            );
                          }),
                    )),
              ),
              casePhotos[index].selected
                  ? Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CircleAvatar(
                          radius: 15.0,
                          backgroundColor: Colors.white,
                          child: Icon(
                            Icons.check,
                            color: Colors.teal,
                          ),
                        ),
                      ),
                    )
                  : SizedBox.shrink()
            ],
          );
        });
  }

  Future<void> reportFalseAlarm() async {
    UploadingLoader.progressLoader(context: context, message: "Sending Report");

    Map data = {
      "isanonymous": selectedUserType == "Anonymous" ? true : false,
      "incident": widget.incidentId,
      "images": selectedImageList,
      "reason": _descriptionController.text,
      "spam": isSpamContent,
      "graphic": isViolence,
      "inappropriate": isInappropriateLanguage,
      "nopicture": isNoTreePicture,
      "other": isOthers
    };
    CustomResponse response = await ApiCall.makePostRequestToken(
        "incident/falsealarm/add",
        paramsData: data);
    if (response.status == 200) {
      if (json.decode(response.body)["status"]) {
        Fluttertoast.showToast(msg: "Case has been reported");
        Navigator.pop(context);
        Navigator.of(context).pop(true);
      } else {
        Navigator.pop(context);
        CommonWidgets.alertBox(context, json.decode(response.body)["msg"],
            leaveThatPage: false);
      }
    } else {
      Navigator.pop(context);
      Fluttertoast.showToast(msg: response.body);
    }

    if (mounted) setState(() {});
  }
}

class PhotoDetails {
  final imageId, imageName;
  bool selected;

  setter(selected) {
    this.selected = selected;
  }

  PhotoDetails(this.imageId, this.imageName, this.selected);
}
