
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart';
import 'package:naturesociety_new/Utils/NetworkCall.dart';
import 'package:naturesociety_new/Widgets/CommonFunction.dart';
import 'package:naturesociety_new/Widgets/CommonWidgets.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:substring_highlight/substring_highlight.dart';

class DiscussionSearch extends StatefulWidget{
  final incidentId; final currentUserId;
  DiscussionSearch(this.incidentId, this.currentUserId);
  _DiscussionSearch createState()=> _DiscussionSearch();

}

class _DiscussionSearch extends State<DiscussionSearch>
{
  bool loading = false;
List  searchResult=[];

@override
void initState(){
  discussionSearch("");
  super.initState();
}

  Future<void>discussionSearch(keyword) async{
    CustomResponse response = await ApiCall.makeGetRequestToken("discussion/search?incident=${widget.incidentId}&keyword=$keyword");
    if(response.status == 200)
      if(json.decode(response.body)['status']){
        searchResult = json.decode(response.body)["data"];
        if(searchResult.length == 0)
          i = -1;
        else
          i = 1;
      }
    else
      i = -1;

    loading = false;
      setState(() {});

  }
  TextEditingController searchController = new TextEditingController();
  final ItemScrollController itemScrollController = ItemScrollController();
  final ItemPositionsListener itemPositionsListener = ItemPositionsListener.create();
  int i= -1;

  Future<bool> _onWillPop() async{
    Navigator.of(context).pop(null);
    return Future.value(false);
  }

  @override
  Widget build(BuildContext context) {

      return WillPopScope(
        onWillPop: _onWillPop,
        child: Scaffold(
          floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
          floatingActionButton: Container(
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.symmetric(horizontal: 10.0),
            color: Colors.teal,
            height: 50,
            margin: EdgeInsets.all(10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Icon(Icons.chrome_reader_mode, color: Colors.white,),
                SizedBox(width: 10.0,),
               searchController.text != "" ?Text( i.toString()=="-1"? "Search result is empty": i.toString()+" of ${searchResult.length}",style: TextStyle(color: Colors.white),):
                SizedBox.shrink(),
                Spacer(),
                IconButton(
                  icon: Icon(Icons.keyboard_arrow_up),
                  color: i==1 || i == -1 ? Colors.grey : Colors.white,
                  onPressed: () => i==1 || i== -1? null :{
                    itemScrollController.scrollTo(index: i, alignment: 0.0,duration: Duration(microseconds: 50),
                    curve: Curves.bounceInOut),
                    i--,
                   setState(() {}),
                  },
                ),
                IconButton(
                  icon: Icon(Icons.keyboard_arrow_down),
                  onPressed: ()=> i == searchResult.length || i == -1 ? null: {
                    itemScrollController.scrollTo(index: i, alignment: 0.0,duration: Duration(microseconds: 50),
                    curve: Curves.bounceInOut),
                   i++,
                  setState(() {}),
                  },
                  color: i == searchResult.length || i == -1 ? Colors.grey : Colors.white,
                ),
              ],
            ),
          ),
         appBar:   AppBar(
             automaticallyImplyLeading: true,
             leading: IconButton(
               icon: Icon(Icons.arrow_back),
               onPressed :()=> _onWillPop(),
             ),
             iconTheme: IconThemeData(color: Colors.black),
             backgroundColor: Colors.white,
             elevation: 5.0,
             title: new TextField(
               autofocus: false,
               controller: searchController,
               onChanged: discussionSearch,
               style: new TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
               decoration: new InputDecoration(
                   border: InputBorder.none,
                   hintText: "Search...",
                   hintStyle: new TextStyle(color: Colors.black87)),
             ),
             actions: <Widget>[
              IconButton(
                icon: Icon(Icons.search),
                color: Colors.black,
                onPressed: ()=>null,
              )
             ]
         ),
         body: loading? CommonWidgets.progressIndicator(context):  SafeArea(
           child: Container(
             color: Colors.grey.withOpacity(.1),
             height: MediaQuery.of(context).size.height -10,
             child:  ScrollablePositionedList.builder(
                 scrollDirection: Axis.vertical,
                padding: EdgeInsets.only(top: 10.0, bottom: 80.0),
                reverse: false,
                physics: ClampingScrollPhysics(),
                 itemScrollController: itemScrollController,
                 itemPositionsListener: itemPositionsListener,
                itemCount: searchResult.length,
                itemBuilder: (BuildContext context, int index) {

               if(widget.currentUserId == searchResult[index]["user"]["_id"] )
                 return  Container(
                   alignment: Alignment.centerRight,
                   child: Row(
                     mainAxisAlignment: MainAxisAlignment.end,
                     crossAxisAlignment: CrossAxisAlignment.center,
                     children: <Widget>[
                       ConstrainedBox(
                         constraints: BoxConstraints(
                           minWidth: 50.0,
                           maxWidth: 300.0,
                         ),
                         child: Card(
                           color: searchController.text!="" && i -1 == index ? Colors.tealAccent.withOpacity(0.6): Colors.white,
                           elevation: 2.0,
                           shape: RoundedRectangleBorder(
                             borderRadius: BorderRadius.circular(5.0),
                             side: BorderSide(color:  Colors.grey, width: 0.2,),
                           ),
                           margin: const EdgeInsets.only(bottom: 10.0, left: 20.0, right: 20.0),
                           child: Padding(
                             padding: const EdgeInsets.all(8.0),
                             child: Column(
                               mainAxisAlignment: MainAxisAlignment.start,
                               crossAxisAlignment: CrossAxisAlignment.end,
                               children: <Widget>[
                                 Wrap(
                                   crossAxisAlignment: WrapCrossAlignment.center,
                                   alignment: WrapAlignment.start,
                                   children: <Widget>[
                                     SizedBox(
                                       height: 20.0,
                                       width: 30.0,
                                       child: PopupMenuButton<int>(
                                         offset: Offset.fromDirection(1),
                                         tooltip: "More options",
                                         icon: Icon(Icons.more_vert, size: 15.0,),
                                         itemBuilder: (context)=>[
                                           PopupMenuItem(
                                             value: 0,
                                             child: Row(
                                               children: <Widget>[
                                                 Icon(Icons.list, size: 15.0,),
                                                 SizedBox(width: 3.0,),
                                                 Text("Goto this in all comments", style: TextStyle(fontSize: 12.0),),
                                               ],
                                             ),
                                           ),
                                         ],
                                         onSelected: (value){
                                           if(value == 0) {
                                             Navigator.of(context).pop(searchResult[index]["_id"]);
                                           }
                                         },
                                       ),
                                     )
                                   ],
                                 ),


                                 searchResult[index]["replyto"] != null ?  Column(
                                   children: <Widget>[
                                     Container(
                                       padding: EdgeInsets.all(2.0),
                                       decoration: BoxDecoration(
                                           color: Colors.grey.withOpacity(0.2),
                                           borderRadius: BorderRadius.circular(5.0),
                                           border: Border.all(color: Colors.grey, width: 0.5)
                                       ),
                                       child: Column(
                                         mainAxisAlignment: MainAxisAlignment.start,
                                         crossAxisAlignment: CrossAxisAlignment.start,
                                         children: <Widget>[
                                           Text(searchResult[index]["replyto"]["user"]["name"] ?? "Anonymous", style: TextStyle(fontWeight: FontWeight.w600),maxLines: 1, overflow: TextOverflow.ellipsis,),
                                           Text(searchResult[index]["replyto"]["text"], maxLines: 1,overflow: TextOverflow.ellipsis,),
                                         ],
                                       ),
                                     ),
                                   ],
                                 ) : SizedBox.shrink(),
                                 searchResult[index]["replyto"]!= null ?  SizedBox(height: 8.0,) : SizedBox.shrink(),
                                 Wrap(
                                   spacing: 10.0,
                                   children: <Widget>[
                                     SubstringHighlight(
                                         text: searchResult[index]["text"], term: searchController.text,
                                       textStyle: TextStyle(color: Colors.black, fontSize: 15.0),
                                       textStyleHighlight: TextStyle(color: Colors.redAccent,fontSize: 15.0, decoration: TextDecoration.underline)),
                                     Transform.translate(
                                         offset: const Offset(0.0, 8.0),
                                         child: Text(CommonFunction.timeFormatter.format(DateTime.parse(searchResult[index]["createdAt"]).toLocal()), style: TextStyle(fontSize: 11.0, color: Colors.grey),
                                           textAlign: TextAlign.end,)
                                     ),
                                   ],
                                 ),
                               ],
                             ),
                           ),
                         ),
                       ),
                     ],
                   ),
                 );
               else if(searchResult[index]["user"]["type"] == "Admin")
                 return SizedBox.shrink();

               return  Container(
                   alignment: Alignment.topLeft,
                   child: ConstrainedBox(
                     constraints: BoxConstraints(
                       minWidth: 50.0,
                       maxWidth: 300.0,
                     ),
                     child: Card(
                       color: searchController.text!="" && i -1 == index ? Colors.tealAccent.withOpacity(0.6): Colors.white,
                       elevation: 2.0,
                       shape: RoundedRectangleBorder(
                         borderRadius: BorderRadius.circular(5.0),
                         side: BorderSide(color:  Colors.grey, width: 0.2,),
                       ),
                       margin: const EdgeInsets.only(bottom: 10.0, left: 20.0, right: 20.0),
                       child: Padding(
                         padding: const EdgeInsets.all(8.0),
                         child: Column(
                           crossAxisAlignment: CrossAxisAlignment.start,
                           children: <Widget>[
                             Wrap(
                               crossAxisAlignment: WrapCrossAlignment.center,
                               alignment: WrapAlignment.start,
                               children: <Widget>[
                                 Text(searchResult[index]["user"]["name"] ?? "Anonymous", style: TextStyle(fontWeight: FontWeight.bold),
                                   maxLines: 1, overflow: TextOverflow.ellipsis,textAlign: TextAlign.left,),
                                 SizedBox(
                                   height: 20.0,
                                   width: 30.0,
                                   child: PopupMenuButton<int>(
                                     offset: Offset.fromDirection(1),
                                     tooltip: "More options",
                                     icon: Icon(Icons.more_vert, size: 15.0,),
                                     itemBuilder: (context)=>[
                                       PopupMenuItem(
                                         value: 0,
                                         child: Row(
                                           children: <Widget>[
                                             Icon(Icons.list, size: 15.0,),
                                             SizedBox(width: 3.0,),
                                             Text("Goto this in all comments", style: TextStyle(fontSize: 12.0),),
                                           ],
                                         ),
                                       ),
                                     ],
                                     onSelected: (value){
                                       if(value == 0) {
                                         Navigator.of(context).pop(searchResult[index]["_id"]);
                                       }
                                     },
                                   ),
                                 )
                               ],
                             ),
                             searchResult[index]["replyto"] != null ?  Container(
                               padding: EdgeInsets.all(2.0),
                               decoration: BoxDecoration(
                                   color: Colors.grey.withOpacity(0.2),
                                   borderRadius: BorderRadius.circular(5.0),
                                   border: Border.all(color: Colors.grey, width: 0.5)
                               ),
                               child: Column(
                                 mainAxisAlignment: MainAxisAlignment.start,
                                 crossAxisAlignment: CrossAxisAlignment.start,
                                 children: <Widget>[
                                   Text(searchResult[index]["replyto"]["user"]["name"] ?? "Anonymous", style: TextStyle(fontWeight: FontWeight.w600),maxLines: 1, overflow: TextOverflow.ellipsis,),
                                   Text(searchResult[index]["replyto"]["text"], maxLines: 1,overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 13),),
                                 ],
                               ),
                             ): SizedBox.shrink(),
                             Wrap(
                               spacing: 10.0,
                               direction: Axis.horizontal,
                               alignment: WrapAlignment.end,
                               children: <Widget>[
                                 SubstringHighlight(
                                     text: searchResult[index]["text"], term: searchController.text,
                                     textStyle: TextStyle(color: Colors.black, fontSize: 15.0),
                                     textStyleHighlight: TextStyle(color: Colors.redAccent,fontSize: 15.0, decoration: TextDecoration.underline)),
                                 Transform.translate(
                                   offset: const Offset(0.0, 5.0),
                                   child: Text(CommonFunction.timeFormatter.format(DateTime.parse(searchResult[index]["createdAt"]).toLocal()),
                                       style: TextStyle(fontSize: 11.0, color: Colors.grey)),
                                 ),
                               ],
                             ),
                           ],
                         ),
                       ),
                     ),
                   ),

               );
             }),
           ),
         ),
     ),
      );
  }

}