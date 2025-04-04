
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:naturesociety_new/SettingsScreen/EditProfile.dart';
import 'package:naturesociety_new/SettingsScreen/UserPostedCaseDetails.dart';
import 'package:naturesociety_new/Utils/NetworkCall.dart';
import 'package:naturesociety_new/Widgets/CommonFunction.dart';
import 'package:naturesociety_new/Widgets/CommonWidgets.dart';
import 'package:naturesociety_new/Widgets/NoConnection.dart';

class UserProfileActivity extends StatefulWidget{
  _UserProfileActivity createState()=> _UserProfileActivity();

}

class _UserProfileActivity extends State <UserProfileActivity>{

  @override
  void initState(){
    super.initState();
    getProfileDetails();
  }



  final mainHeadingStyle = TextStyle(color: Colors.teal, fontWeight: FontWeight.bold);
  final subHeadingStyle = TextStyle(color: Colors.grey, fontSize: 12.0, fontWeight: FontWeight.w600);
  final normalTextStyle = TextStyle(color: Colors.black, fontWeight: FontWeight.w600);
  final countTextStyle = TextStyle(color: Colors.grey,fontSize: 23.0 ,fontWeight: FontWeight.w600);

  Future<bool> onWillPopScope() async{
    Navigator.of(context).pop(true);
    return  false;
  }

  @override
  Widget build(BuildContext context) {

    return WillPopScope(
      onWillPop: onWillPopScope,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          iconTheme: IconThemeData(color: Colors.black),
          automaticallyImplyLeading: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: ()=>onWillPopScope(),
          ),
          backgroundColor: Colors.white,
          title: Text("User Profile & Activity", style: TextStyle(color: Colors.teal, fontWeight: FontWeight.w800),),
          elevation: 0.0,
        ),

        body: !isConnected ? NoConnection(notifyParent: getProfileDetails,) : !isLoading ? SingleChildScrollView(
          child: AnimationLimiter(
            child: Column(
              children: AnimationConfiguration.toStaggeredList(
                duration: const Duration(milliseconds: 385),
                childAnimationBuilder: (widget) => SlideAnimation(
                  horizontalOffset: 50.0,
                  child: ScaleAnimation(
                    child: widget,
                  ),
                ),
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.all(15.0),
                    color: Colors.grey.withOpacity(.2),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Spacer(),
                        Text("User Details", style: mainHeadingStyle,),
                        Spacer(),
                        GestureDetector(
                          onTap: () async{
                            bool refresh = await Navigator.push(context, MaterialPageRoute(builder: (context)=> ViewProfile()));
                            if(refresh)
                              getProfileDetails();
                          },
                          child: Text("Edit", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),),
                        )
                      ],
                    ),
                  ),

                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        profileDetails["photo"] != null ?CircleAvatar(
                          backgroundColor: Colors.teal,
                          radius: 90.0,
                          backgroundImage:  NetworkImage(ApiCall.imageUrl + profileDetails["photo"]),
                        ): CircleAvatar(
                          backgroundColor: Colors.teal,
                          radius: 90.0,
                        ) ,
                        SizedBox(height: 10.0,),

                        Text(profileDetails["name"]??'',style: normalTextStyle, textAlign: TextAlign.center,),

                      ],
                    ),
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        width: MediaQuery.of(context).size.width / 2,
                        padding: EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide( //                    <--- top side
                              color: Colors.grey,
                              width: 1.0,
                            ),

                            right: BorderSide( //                    <--- top side
                              color: Colors.grey,
                              width: 1.0,
                            ),
                            bottom: BorderSide( //                    <--- top side
                              color: Colors.grey,
                              width: 1.0,
                            ),
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            FittedBox(
                                fit: BoxFit.cover,
                                child: Text("USER ID", style: subHeadingStyle,textAlign: TextAlign.center)),
                            FittedBox(
                                fit: BoxFit.cover,
                                child: Text(profileDetails["userid"], style: normalTextStyle, maxLines: 2,overflow: TextOverflow.ellipsis,)),
                          ],
                        ),
                      ),

                      Container(
                        width: MediaQuery.of(context).size.width / 2,

                        padding: EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(color: Colors.grey, width: 1.0,),
                            bottom: BorderSide(color: Colors.grey, width: 1.0),
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            FittedBox(
                                fit: BoxFit.cover,
                                child: Text("MOBILE NUMBER", style: subHeadingStyle, textAlign: TextAlign.center,)),
                            FittedBox(
                                fit: BoxFit.cover,
                                child: Text(profileDetails["phone"], style: normalTextStyle,maxLines: 2,overflow: TextOverflow.ellipsis,)),
                          ],
                        ),
                      ),
                    ],
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(

                        width: MediaQuery.of(context).size.width / 2,
                        padding: EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          border: Border(
                            right: BorderSide(color: Colors.grey, width: 1.0),
                            bottom: BorderSide(color: Colors.grey, width: 1.0),
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            FittedBox(
                                fit: BoxFit.cover,
                                child: Text("GENDER", style: subHeadingStyle,textAlign: TextAlign.center)),
                            FittedBox(
                                fit: BoxFit.cover,
                                child: Text(profileDetails["gender"]?? " ", style: normalTextStyle,maxLines: 2, overflow: TextOverflow.ellipsis,)),
                          ],
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width / 2,

                        padding: EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: Colors.grey, width: 1.0,),
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            FittedBox(
                                fit: BoxFit.cover,
                                child: Text("DATE OF BIRTH", style: subHeadingStyle,textAlign: TextAlign.center)),
                            FittedBox(
                                fit: BoxFit.contain,
                                child: profileDetails["dob"] == null ? Text(" ") : Text(CommonFunction.dateFormatter.format(DateTime.parse(profileDetails["dob"].toString())),  style: normalTextStyle,maxLines: 2,overflow: TextOverflow.ellipsis,)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  profileDetails["occupation"]==null?SizedBox.shrink():
                  Container(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      children: <Widget>[
                        FittedBox(
                            fit: BoxFit.cover,
                            child: Text("OCCUPATION", style: subHeadingStyle,)),
                        FittedBox(
                            fit: BoxFit.cover,
                            child: Text(profileDetails["occupation"]??'', style: normalTextStyle,)),
                      ],
                    ),
                  ),


                  Container(
                    color: Colors.grey.withOpacity(.2),
                    padding: EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text("Activity", style: mainHeadingStyle,textAlign: TextAlign.center),
                      ],
                    ),
                  ),

                  SizedBox(height: 10.0,),


                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[

                      Container(
                        padding: EdgeInsets.all(12.0),
                        width: MediaQuery.of(context).size.width / 3,
                        child: GestureDetector(
                          onTap: ()=> incidentCount > 0 ?Navigator.push(context, CupertinoPageRoute(builder: (context)=>UserPostedCaseDetails("posted_by_me"))):
                          null,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Text("Cases I have Posted", textAlign: TextAlign.center, style: subHeadingStyle,),
                              Text(incidentCount.toString(), style: countTextStyle,),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(12.0),
                        width: MediaQuery.of(context).size.width / 3,
                        child: GestureDetector(
                          onTap: ()=> commentsCount >0? Navigator.push(context, CupertinoPageRoute(builder: (context)=>UserPostedCaseDetails("commented_by_me")))
                              : null,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Text("Cases I have Commented", textAlign: TextAlign.center, style: subHeadingStyle,),
                              Text(commentsCount.toString(),  style: countTextStyle,),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(12.0),
                        width: MediaQuery.of(context).size.width / 3,
                        child: GestureDetector(
                          onTap: ()=> updateCount > 0?Navigator.push(context, CupertinoPageRoute(builder: (context)=>UserPostedCaseDetails("updated_by_me"))):
                          null,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Text("Cases I have Updated", textAlign: TextAlign.center, style: subHeadingStyle,),
                              Text(updateCount.toString(), style: countTextStyle,),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

            ),
          ),
        ) : Center(child: CommonWidgets.progressIndicator(context),),
      ),
    );
  }

var profileDetails; bool isLoading = true, isConnected = true;
int incidentCount, updateCount, commentsCount;
  Future<void> getProfileDetails() async{
    CustomResponse response = await ApiCall.makeGetRequestToken("user/profile");
    if(response.status == 200)
     { if(json.decode(response.body)["status"])
        setState(() {
          profileDetails = json.decode(response.body)['data'];
          incidentCount = json.decode(response.body)['incidentcount'];
          updateCount = json.decode(response.body)['updatecount'];
          commentsCount = json.decode(response.body)['commentscount'];
          isLoading = false;
        });
      else
        Fluttertoast.showToast(msg: "Something went worong!");
     isConnected = true;
     }
    else if(response.status == 403){
      isLoading = true;
      CommonWidgets.loginLimit(context);

    }
      else
        { isConnected = false; isLoading = false;}

      if(mounted)
        setState(() {});

  }

}