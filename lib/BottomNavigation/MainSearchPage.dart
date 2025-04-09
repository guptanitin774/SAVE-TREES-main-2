
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:naturesociety_new/CaseView/CaseDetailedView.dart';
import 'package:naturesociety_new/Utils/MaterialComponets.dart';
import 'package:naturesociety_new/Utils/NetworkCall.dart';
import 'package:naturesociety_new/Widgets/CommonWidgets.dart';
import 'package:naturesociety_new/Widgets/NoConnection.dart';
import 'package:substring_highlight/substring_highlight.dart';

class MainSearchPage extends StatefulWidget{
  _MainSearchPage createState()=> _MainSearchPage();
}

class _MainSearchPage extends State<MainSearchPage>{
   final TextEditingController _searchQuery = new TextEditingController();

bool connectionStatus = true;

  @override
  void initState() {
    super.initState();
    recentSearchSuggestions();
  }
bool containsRecentSearch = false;
  Future <void> recentSearchSuggestions() async{
    CustomResponse response = await ApiCall.makeGetRequestToken("incident/lastsearches");
    if(response.status == 200) {
      if (json.decode(response.body)["status"])
      {
        if(json.decode(response.body)["data"].length > 0)
          containsRecentSearch = true;
        else
          containsRecentSearch = false;
        for (int i = 0; i < json.decode(response.body)["data"].length; i++)
            {
              suggestionBox.add(SearchModel(type: "recent", dataSet: json.decode(response.body)["data"][i],showSuggestion: false, icon: Icons.access_time));
            }}
      connectionStatus = true;
    }
    else if(response.status == 403){
      CommonWidgets.loginLimit(context);
    }
    else
      connectionStatus = false;
    if(mounted)
      setState(() {});
  }

  List <SearchModel> suggestionBox=[
    SearchModel(type: "own", dataSet: "Cases with more than 100 trees affected",showSuggestion: true, icon: Icons.arrow_forward),
    SearchModel(type: "own", dataSet: "Cases on which I commented",showSuggestion: true, icon: Icons.arrow_forward),
    SearchModel(type: "own", dataSet: "Cases posted by me",showSuggestion: true, icon: Icons.arrow_forward),
  ];

 // List <SearchModel> searchResult=[];
  var searchResult;
  FocusNode searchKeyboard = FocusNode();
  int resultLength=0;
  bool emptyResults = false;
  
  Future<void>callSearch(var text) async{
    setState(() {
      searchResult=null;
    });
    if(_searchQuery.text == null || _searchQuery.text == "")
      setState(() {
      //  searchResult.clear();
      });
    else {
      setState(() {
        emptyResults = false;
      });
      CustomResponse response = await ApiCall.makeGetRequestToken("incident/getresults?keyword=${text.toString()}");

      if (response.status == 200){
        if (json.decode(response.body)["status"]){
           searchResult = json.decode(response.body);
           if((searchResult["casesicommented"]==null||searchResult["casesicommented"].isEmpty) && ((searchResult["recentsearch"]==null||searchResult["recentsearch"].isEmpty) || searchResult["recentsearch"] == null) && (searchResult["postedbyme"]==null||searchResult["postedbyme"].isEmpty) && (searchResult["other"]==null||searchResult["other"].isEmpty)) {
          setState(() {
            emptyResults = true;
          });
           }
           else {
           setState(() {
             emptyResults = false;
           });
           }

    }}}
    if(mounted)
      setState(() {});
  }

    returnSearchResult(var text) async{
    setState(() {
      loadingSearch = true;
    });
    CustomResponse response = await ApiCall.makeGetRequestToken("incident/getlist?count=100&page=1&type=all&filter=${text.toString()}");
    print(json.decode(response.body));
     if(response.status == 200)
      if(json.decode(response.body)["status"])
       Navigator.of(context).pop({"searchResult":json.decode(response.body)["data"],"searchTerm":text});
    setState(() {
      loadingSearch = false;
    });
  }

  Future<bool> onWillPop()
  {
    Navigator.of(context).pop({"searchResult":[],"searchTerm":""});
    return Future.value(false);
  }

  bool loadingSearch =false;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: onWillPop,
      child: new Scaffold(
        appBar: buildBar(context),
        body: !connectionStatus? NoConnection(notifyParent:  recentSearchSuggestions, key: UniqueKey()): !loadingSearch?  SafeArea(
            child: _searchQuery.text.length == 0 ? Container(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(vertical: 10.0,horizontal: 16.0),
                itemCount:  suggestionBox.length,
                 reverse: true,
                shrinkWrap: true,
                physics: ClampingScrollPhysics(),
                itemBuilder: (context, index){

                  return Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[

                      containsRecentSearch && index == suggestionBox.length -1 ? Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Recent Searches", textAlign: TextAlign.left,),
                        ],
                      ): SizedBox.shrink(),
                      SizedBox(
                        height: 50.0,
                        child: GestureDetector(
                          onTap: () async{
                            suggestionBox[index].type == 'own' ?
                            returnSearchResult(suggestionBox[index].dataSet.toLowerCase()):
                            Navigator.push(context, MaterialPageRoute(builder: (context)=> CaseDetailedView(suggestionBox[index].dataSet["_id"], isSearch: true)));
                          },
                          child: Row(
                            children: <Widget>[
                              Icon(suggestionBox[index].icon),
                              SizedBox(width: 5.0,),
                              Expanded(
                                  flex: 4,
                                  child: Text(suggestionBox[index].type == "own" ?suggestionBox[index].dataSet :
                                  suggestionBox[index].type == "recent"?suggestionBox[index].dataSet["keyword"] : " "

                                    , maxLines: 2,overflow: TextOverflow.ellipsis, style: TextStyle(fontWeight: FontWeight.w600, color: MaterialTools.basicColor),)),
                            ],
                          ),
                        ),
                      ),
                      index == 3 ? Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Divider(height: 10.0,thickness: 1.5,color: Colors.grey,),
                          Text("Common searches"),
                        ],
                      ): SizedBox.shrink(),

                    ],
                  );
                    // return Column(
                    //   children: commonFiltersWidget(context),
                    // );
                },
              ),
            ):
            searchResult==null ? Center(child:  CircularProgressIndicator(),):
                ListView.builder(
                    padding: EdgeInsets.symmetric(vertical: 10.0,horizontal: 16.0),
                    itemCount: 1,
                    itemBuilder: (BuildContext context, int index){
                  return
                    emptyResults ? Center(
                      child: Column(
                        children: [
                          Image.asset("assets/noSearchResult.png"),
                          SizedBox(height: 10.0,),
                          Text("No Search Results",style: MaterialTools.errorMessageStyle),
                        ],
                      ),
                    ):
                    Column(
                    children: [
                      searchResult["recentsearch"] == null ? SizedBox.shrink():
                          Column(
                            children: recentSearchItems(context),
                          ),

                      searchResult["postedbyme"] == null? SizedBox.shrink():
                          Column(children: postedByMeItems(context),),


                      searchResult["casesicommented"] == null ? SizedBox.shrink():
                      Column(children: commentedItems(context),),

                      searchResult["other"] == null ? SizedBox.shrink():
                      Column(children: otherItems(context),)
                    ],
                  );
                })
        ) : CommonWidgets.progressIndicator(context),
      ) ,
    );
  }


  recentSearchItems(BuildContext context) {
    List <Widget> items = [];
    for(int i=0; i< searchResult["recentsearch"].length; i++)
      items.add(
        InkWell(
          onTap:() {
            Navigator.push(context, MaterialPageRoute(builder: (context)=> CaseDetailedView(searchResult["recentsearch"][i]["_id"], isSearch: true,)));
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Row(
                children: [
                  SubstringHighlight(
                    text:  searchResult["recentsearch"][i]["caseidentifier"] == null?searchResult["recentsearch"][i]["caseid"].toString():searchResult["recentsearch"][i]["caseidentifier"].toString(),
                    term: _searchQuery.text,
                    textStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: Colors.black),
                    textStyleHighlight: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: Colors.redAccent),

                  ),
                ],
              ),

              Padding(
                padding: const EdgeInsets.only(left: 10.0, top: 8.0),
                child: Wrap(
                  alignment: WrapAlignment.start,
                  textDirection: TextDirection.ltr,
                  children: [
                    SubstringHighlight(
                      text: searchResult["recentsearch"][i]["locationname"],
                      term: _searchQuery.text,
                      textStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: Colors.black),
                      textStyleHighlight: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: Colors.redAccent),
                    ),
                    Text(" in Recent search"),
                  ],
                ),
              ),
            ],
          ),
        ),
      );

    return items;
  }

  postedByMeItems(BuildContext context) {
    List <Widget> items = [];
    for(int i=0; i< searchResult["postedbyme"].length; i++)
      items.add(
        InkWell(
          onTap:() {
            Navigator.push(context, MaterialPageRoute(builder: (context)=> CaseDetailedView(searchResult["postedbyme"][i]["_id"], isSearch: true,)));
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10.0,),
              Row(
                children: [
                  SubstringHighlight(
                    text: searchResult["postedbyme"][i]["caseidentifier"]!=null? searchResult["postedbyme"][i]["caseidentifier"]: searchResult["postedbyme"][i]["caseid"].toString(),
                    term: _searchQuery.text,
                    textStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: Colors.black),
                    textStyleHighlight: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: Colors.redAccent),

                  ),
                ],
              ),

              Padding(
                padding: const EdgeInsets.only(left: 10.0, top: 8.0),
                child: Wrap(
                  alignment: WrapAlignment.start,
                  textDirection: TextDirection.ltr,
                  children: [
                    SubstringHighlight(
                      text: searchResult["postedbyme"][i]["locationname"],
                      term: _searchQuery.text,
                      textStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: Colors.black),
                      textStyleHighlight: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: Colors.redAccent),
                    ),
                    Text(" in Cases posted by me"),
                  ],
                ),
              ),
            ],
          ),
        ),
      );

    return items;
  }


  commentedItems(BuildContext context) {
    List <Widget> items = [];
    for(int i=0; i<  searchResult["casesicommented"].length; i++)
      items.add(
        InkWell(
          onTap:() {
            Navigator.push(context, MaterialPageRoute(builder: (context)=> CaseDetailedView(searchResult["casesicommented"][i]["_id"], isSearch: true,)));
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10.0,),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SubstringHighlight(
                    text:  searchResult["casesicommented"][i]["caseidentifier"] !=null ? searchResult["casesicommented"][i]["caseidentifier"] : searchResult["casesicommented"][i]["caseid"].toString(),
                    term: _searchQuery.text,
                    textStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: Colors.black),
                    textStyleHighlight: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: Colors.redAccent),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10.0, top: 8.0),
                child: Wrap(
                  alignment: WrapAlignment.start,
                  textDirection: TextDirection.ltr,
                  children: [
                    SubstringHighlight(
                      text: searchResult["casesicommented"][i]["locationname"],
                      term: _searchQuery.text,
                      textStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: Colors.black),
                      textStyleHighlight: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: Colors.redAccent),
                    ),
                    Text(" in Cases in which I have commented"),
                  ],
                ),
              ),
            ],
          ),
        ),
      );

    return items;
  }


  otherItems(BuildContext context) {
    List <Widget> items = [];
    for(int i=0; i<  searchResult["other"].length; i++)
      items.add(
        InkWell(
          onTap:() {
            Navigator.push(context, MaterialPageRoute(builder: (context)=> CaseDetailedView(searchResult["other"][i]["_id"], isSearch: true,)));
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10.0,),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SubstringHighlight(
                    text:  searchResult["other"][i]["caseidentifier"] !=null ? searchResult["other"][i]["caseidentifier"] : searchResult["other"][i]["caseid"].toString(),
                    term: _searchQuery.text,
                    textStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: Colors.black),
                    textStyleHighlight: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: Colors.redAccent),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10.0, top: 8.0),
                child: Wrap(
                  alignment: WrapAlignment.start,
                  textDirection: TextDirection.ltr,
                  children: [
                    SubstringHighlight(
                      text: searchResult["other"][i]["locationname"],
                      term: _searchQuery.text,
                      textStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: Colors.black),
                      textStyleHighlight: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: Colors.redAccent),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    return items;
  }

   PreferredSizeWidget buildBar(BuildContext context) {
     return AppBar(
       centerTitle: true,
       automaticallyImplyLeading: false,
       elevation: 1.0,
       backgroundColor: Colors.white,
       title: Row(
         children: [
           IconButton(icon: Icon(Icons.arrow_back), onPressed: (){
             Navigator.pop(context);
           },),
           Icon(Icons.search, color: Colors.black),
           SizedBox(width: 10,),
           Expanded(
             child: TextField(
               focusNode: searchKeyboard,
               controller: _searchQuery,
               style: new TextStyle(color: Colors.black),
               onChanged: callSearch,
               decoration: new InputDecoration(
                   border: InputBorder.none,
                   hintText: "Type Location / CaseId",
                   hintStyle: new TextStyle(color: Colors.grey)
               ),
               onSubmitted: onSearchSubmitted,
             ),
           ),
         ],
       ),
     );
   }

  Future<void> onSearchSubmitted(var text) async{
    setState(() {
      loadingSearch = true;
    });
    CustomResponse response = await ApiCall.makeGetRequestToken("incident/getlist?count=100&page=1&type=all&keyword=${text.toString()}");
    if(response.status == 200)
      if(json.decode(response.body)["status"])
        Navigator.of(context).pop({"searchResult":json.decode(response.body)["data"],"searchTerm":text});
    setState(() {
      loadingSearch = false;
    });
  }
}

class SearchModel{
  IconData icon;
  String type;
  var dataSet;
  bool showSuggestion;
  SearchModel({required this.type, this.dataSet, required this.showSuggestion, required this.icon});
}

