

import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:naturesociety_new/NavigatePage.dart';
import 'package:naturesociety_new/Utils/NetworkCall.dart';
import 'package:naturesociety_new/Widgets/CommonWidgets.dart';
import 'package:naturesociety_new/SimilarCases/SimilarCaseDetailedViews.dart';


class SimilarCases extends StatefulWidget{
  final identificationId, userName, caseDetails;
  SimilarCases(this.identificationId, this.userName,this.caseDetails );

  _SimilarCases createState()=> _SimilarCases();
}

class _SimilarCases extends State<SimilarCases>{


  @override
  void initState(){
    super.initState();
    similarCasesList();
  }
  List similarCseDetails =[];
  bool loadingStatus = true;
  Future<void> similarCasesList() async{
    similarCseDetails.clear();

    var result = await ApiCall.makeGetRequestToken('incident/similar?id=${widget.identificationId}');
    if(json.decode(result.body)["status"])
      setState(() {
        similarCseDetails = json.decode(result.body)["data"];
        loadingStatus = false;
      });
    else
    {

      notAnUpdate();
    }

    setState(() {
      loadingStatus = false;
    });
  }


  Future<bool> _onWillPop() async{
    alertBox(context, "Are you sure you want to skip posting this case?");
    // CommonWidgets.alertBox(context, "Are you sure you want to skip from updating the similar cases found?", leaveThatPage: true) ;
    return Future.value(false);
  }
  void alertBox(BuildContext context ,String msg){
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
          content: new Text(msg?? "Server Error"),
          actions: [
            TextButton(
              child: new Text("CANCEL"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: new Text("OK"),
              onPressed: () {
                removeDraft();
                Navigator.of(context).pop();
              },
            ),
          ],
        )
    );
  }
  Future<void> removeDraft() async{
    CustomResponse response = await ApiCall.makeGetRequestToken("incident/removedraft?id=${ widget.caseDetails["_id"]}");
    print(json.decode(response.body));
    CommonWidgets.testingDialog(context);
    Future.delayed(Duration(milliseconds: 5), () {
      Navigator.pushAndRemoveUntil(context, CupertinoPageRoute(builder: (context) => NavigatePage()), (route) => false);
    });

  }
  Future<void> notAnUpdate() async{
    Map data={
      "id": widget.caseDetails["_id"]
    };
    CustomResponse response = await ApiCall.makePostRequestToken("incident/notanupdate", paramsData: data);
    if(response.status == 200){
      if(json.decode(response.body)["status"]){
        CommonWidgets.postingSuccessDialog(context);
        Future.delayed(Duration(milliseconds: 2000), () {
          Navigator.of(context).pop(true);
          CommonWidgets.upDationMarkDialog(context, widget.caseDetails, 'posted');
        });
        // CommonWidgets.testingDialog(context);
        // Future.delayed(Duration(milliseconds: 50), () {
        //   Navigator.of(context).pop(true);
        //   CommonWidgets.testingDialog2(context, widget.caseDetails);
        // });
      }
      else{
        Fluttertoast.showToast(msg: json.decode(response.body)["msg"]);
      }
    }
    else{
      Fluttertoast.showToast(msg: response.body);
    }


  }

  @override
  Widget build(BuildContext context) {

    return WillPopScope(
      onWillPop: _onWillPop,
      child:  similarCseDetails.isEmpty?blankScreen(context):mainScreen(context));
  }

  Widget blankScreen(BuildContext context){
    return Scaffold(body:
    loadingStatus ? CommonWidgets.progressIndicator(context) :
    Container());
  }



  Widget mainScreen(BuildContext context){
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: MaterialButton(
        onPressed: ()=> notAnUpdate(),
        height: 60.0,
        minWidth: double.infinity,
        color: Colors.teal,
        textColor: Colors.white,
        child:
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text("Skip and post as a new case" , style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),),
            Icon(Icons.arrow_forward,color: Colors.white,size: 18,),
          ],
        ),

      ),
      appBar: AppBar(
        leading: IconButton(icon: Icon(Icons.arrow_back), onPressed:()=>_onWillPop(),),
        title: Text("Has this case been posted before?",style: TextStyle(color: Colors.black, fontSize: 18),),
      ),
      body:
      loadingStatus ? CommonWidgets.progressIndicator(context) :
      SafeArea(
        child:  AnimationLimiter(
          child: ListView.builder(
              physics: AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.only(bottom: 50.0, top: 25.0, left: 16.0, right: 16.0),
              itemCount: similarCseDetails.length + 1,
              itemBuilder: (context,index){
                if(index == 0)
                {
                  return Text("Please check the suggested cases below which have been posted at the same location.\n"
                      "If you find the case already posted below, then open the case and click “update”.",
                    style: TextStyle(fontWeight: FontWeight.w500),textAlign: TextAlign.left,);
                }
                else
                  return AnimationConfiguration.staggeredList(
                    position: index,
                    duration: const Duration(milliseconds: 375),
                child: SlideAnimation(
                verticalOffset: 50.0,
                child: FadeInAnimation(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(height:  20.0,),

                    Text("${similarCseDetails[index - 1]["caseidentifier"]==null? similarCseDetails[index - 1]["caseid"]:similarCseDetails[index - 1]["caseidentifier"]}", style: TextStyle(color: Colors.grey,fontWeight: FontWeight.w600),),

                    Container(
                      height: 180.0,
                      width: double.infinity,
                      child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: similarCseDetails[index - 1]["photos"].length,
                          itemBuilder: (BuildContext context,int photoIndex)
                          {
                            return Container(
                              height: 160.0,
                              width: 130.0,
                              margin: EdgeInsets.only(top: 10.0, bottom: 10.0, right: 10.0),
                              padding: EdgeInsets.all(3.0),
                              decoration: BoxDecoration(border: Border.all(color: Colors.grey, width: 1.0),
                                borderRadius: BorderRadius.all(Radius.circular(1.0)),),

                              child:
                              InkWell(
                                  onTap: ()=>
                                      Navigator.push(context, MaterialPageRoute(builder: (context)=>
                                          SimilarCaseDetailedView(similarCseDetails[index - 1]["photos"][photoIndex]['incident'], widget.identificationId))),

                                  child: ClipRRect(
                                      borderRadius: BorderRadius.all(Radius.circular(1.0)),
                                      child: CachedNetworkImage(
                                        imageUrl: ApiCall.imageUrl+similarCseDetails[index - 1]["photos"][photoIndex]["photo"],
                                        fit: BoxFit.cover,
                                        progressIndicatorBuilder: (context, url, progress) => Center(
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            backgroundColor: Colors.white54,
                                            valueColor: new AlwaysStoppedAnimation<Color>(Colors.green),
                                            value: progress.progress,
                                          ),
                                        ))

                                  )),
                            );
                          }),
                    ),
                  ],
                ),
                )));

              }),
        ),
      ),
    );
  }




}