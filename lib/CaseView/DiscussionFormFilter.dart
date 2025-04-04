
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:naturesociety_new/Utils/NetworkCall.dart';
import 'package:naturesociety_new/Widgets/CommonWidgets.dart';

class DiscussionFormFilter extends StatefulWidget{
  final isInFilter; final caseId;
  final filterType, selectedFilterList, commentSelected;
  DiscussionFormFilter(this.caseId,this.filterType, this.selectedFilterList, this.commentSelected, { @required this.isInFilter});
  _DiscussionFormFilter createState()=> _DiscussionFormFilter();
}


List <ValuePair>commonDiscussionFilters  =[
  ValuePair("posted by me", "Posted by me", false),
  ValuePair("posted by admin", "Posted by Admin", false),
  ValuePair("mentioning me", "Mentioning Me", false),
 // ValuePair("with attachments", "With Attachments", false),
];

class _DiscussionFormFilter extends State<DiscussionFormFilter>{

  bool isLoading = false;

  @override
  void initState(){
    super.initState();
    // if(!widget.isInFilter) {
    //   for (int i = 0; i < commonDiscussionFilters.length; i++)
    //     commonDiscussionFilters[i].selected = false;
    //   selectedDiscussionFilters.clear();
    // }
    selectedDiscussionFilters=widget.selectedFilterList;
    filterType=widget.filterType;
  }


  List selectedDiscussionFilters=[];
  bool filterType=false;

  Future<bool> onWillPop()
  {
    if(selectedDiscussionFilters.isEmpty){
      filterType=false;
    }
    else{
      filterType=true;
    }
    Navigator.of(context).pop(json.encode({"filterData":[], "filterType":filterType, 'types':selectedDiscussionFilters, "filterCount":selectedDiscussionFilters.length}));
    return Future.value(false);
  }

  @override
  Widget build(BuildContext context) {

    return WillPopScope(
      onWillPop: onWillPop,
      child: Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.black),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: ()=>onWillPop(),
          ),
          backgroundColor: Colors.white,
          title: Text("Discussion Filters", style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: isLoading? CommonWidgets.progressIndicator(context):  MaterialButton(
          height: 60.0,
          color: Colors.teal.withOpacity(1),
          minWidth: double.infinity,
          textColor: Colors.white,
          onPressed: () async{
            setState(() {
              isLoading = true;
            });
            Map data ={
              "incident" : widget.caseId,
              "filter": selectedDiscussionFilters
            };
            CustomResponse response;
            if(widget.commentSelected=='Top Comments'){
              response = await ApiCall.makePostRequestToken("discussion/searchtopcomments", paramsData: data);
            }
            else
            response = await ApiCall.makePostRequestToken("discussion/search", paramsData: data);
            if(response.status == 200)
              if(json.decode(response.body)["status"]){
                setState(() {
                  isLoading = false;
                });
                if(selectedDiscussionFilters.isEmpty){
                  filterType=false;
                }
                else{
                  filterType=true;
                }
                Navigator.of(context).pop(json.encode({"filterCount": selectedDiscussionFilters.length, "filterType":filterType, 'types':selectedDiscussionFilters, "filterData":json.decode(response.body)["data"]}));
              }
            else
                Fluttertoast.showToast(msg: json.decode(response.body)["msg"]);

            else
              Fluttertoast.showToast(msg: response.body);
            setState(() {
              isLoading = false;
            });
          },
          child: Text("APPLY", style: TextStyle(fontWeight: FontWeight.w600),),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text("Comments...", style: TextStyle(fontWeight: FontWeight.w600),),
               SizedBox(height: 15.0,),
                Wrap(
                  children: commonFiltersWidget(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  commonFiltersWidget(BuildContext context){
    final List <Widget> loopList = <Widget>[];
    for(int i=0; i< commonDiscussionFilters.length; i++)
      loopList.add(
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: RaisedButton(
            elevation: 8.0,
            color: commonDiscussionFilters[i].selected? Colors.teal : Colors.white,
            child: Text(commonDiscussionFilters[i].value, style: TextStyle(color: commonDiscussionFilters[i].selected? Colors.white : Colors.black),),
            onPressed: () async{
              selectedItem(commonDiscussionFilters[i]);
              setState(() {
                commonDiscussionFilters[i].selected? selectedDiscussionFilters.add(commonDiscussionFilters[i].key) : selectedDiscussionFilters.remove(commonDiscussionFilters[i].key);
              });
            },
          ),
        ),
      );
    return loopList;
  }
  void selectedItem(item){
    setState(() {
      if(item.selected)
        item.setter(false);
      else
        item.setter(true);
    });
  }
}

class ValuePair{
  var key;
  var value;
  bool selected;
  setter(selected){
    this.selected = selected;
  }
  ValuePair(this.key, this.value, this.selected);
}