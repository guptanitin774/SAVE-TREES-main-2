import 'dart:async';
import 'dart:convert';

import 'package:audioplayers/src/source.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_parsed_text/flutter_parsed_text.dart';
import 'package:flutter_swiper_null_safety/flutter_swiper_null_safety.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:naturesociety_new/CaseView/CaseDetailedView.dart';
import 'package:naturesociety_new/CaseView/CaseViewInDiscussion.dart';
import 'package:naturesociety_new/CaseView/DiscussionFormFilter.dart';
import 'package:naturesociety_new/CaseView/DiscussionSearch.dart';
import 'package:naturesociety_new/Users/UsersProfile.dart';
import 'package:naturesociety_new/Utils/LocalPrefManager.dart';
import 'package:naturesociety_new/Utils/MaterialComponets.dart';
import 'package:naturesociety_new/Utils/NetworkCall.dart';
import 'package:naturesociety_new/Widgets/CommonFunction.dart';
import 'package:naturesociety_new/Widgets/CommonWidgets.dart';
import 'package:naturesociety_new/Widgets/ReadMoreText.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:share/share.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class CaseDiscussion extends StatefulWidget {
  final caseDetails;
  final token;

  CaseDiscussion(
    this.caseDetails,
    this.token, {
    required Key key,
  }) : super(key: key);

  _CaseDiscussion createState() => _CaseDiscussion();
}

List<ChatModel> chatList = [];
List cacheChatList = [];
List<ChatModel> allComments = [];
late IO.Socket socketIO;

var currentUserId;

List<AnimationController> _animationController = <AnimationController>[];

class _CaseDiscussion extends State<CaseDiscussion>
    with TickerProviderStateMixin {
  late double height, width;
  TextEditingController textController = new TextEditingController();

  ScrollController scrollController = new ScrollController();
  bool isVisible = true;
  bool chatLoad = true;
  var incidentId;
  bool scrollPositionAtEnd = false;

  bool filterType = false;
  var selectedFilterList = [];

  @override
  void initState() {
    super.initState();
    getFullChatList();
    print(widget.caseDetails["_id"]);
    for (int i = 0; i < commonDiscussionFilters.length; i++)
      commonDiscussionFilters[i].selected = false;
    incidentId = widget.caseDetails["_id"];
    // socketIO = SocketIOManager().createSocketIO(ApiCall.socketUrl, '/' ,socketStatusCallback: _socketStatus);
    // socketIO.init();
    // socketIO.unSubscribesAll();
    // Future.delayed(const Duration(seconds: 1), () {
    //   socketIO.sendMessage('auth', json.encode({'token':widget.token,'incident':incidentId.toString()}),
    //       _onSocketInfo);
    // });
    // connect();
    // socketIO.connect();
  }

  // @override
  // void dispose() {
  //   socketIO?.disconnect();
  //   socketIO?.destroy();
  //   nameHolder.dispose();
  //   keyboardOne.dispose();
  //   super.dispose();
  // }

  bool typingWidgetOn = false;
  var typingWidgetNames;
  bool newMsgArrive = false;
  int newMsgCount = 0;

  //Socket Function
//   void connect() async{
//
//     //Typing hinting Socket
//     socketIO.subscribe('typing', (jsonData) {
//       if(json.decode(jsonData)["id"] != currentUserId)
//         setState(() {
//           typingWidgetOn = true;  typingWidgetNames = json.decode(jsonData)["name"];
//         });
//       Future.delayed(const Duration(seconds: 4), () {
//         typingWidgetOn = false;
//         typingWidgetNames = "";
//         setState(() {});
//       });
//     });
//
//     //New Messages Socket
//     socketIO.subscribe('new_comment', (jsonData) {
//         if(currentUserId != json.decode(jsonData)["user"]["_id"])
//           {
//             allComments.add(ChatModel(
//                 json.decode(jsonData)["_id"],
//                 json.decode(jsonData)["isanonymous"],
//                 json.decode(jsonData)["anonymousname"],
//                 json.decode(jsonData)["messagetype"],
//                 json.decode(jsonData)["media"],
//                 json.decode(jsonData)["hash"],
//                 json.decode(jsonData)["refer"],
//                 json.decode(jsonData)["text"],
//                 json.decode(jsonData)["user"],
//                 json.decode(jsonData)["replyto"],
//                 json.decode(jsonData)["createdAt"],
//                 json.decode(jsonData)["isUpVoted"],
//                 json.decode(jsonData)["upvotecount"],
//                 json.decode(jsonData)["downvotecount"],
//                 json.decode(jsonData)["isDownVoted"],false));
//             _animationController.add(AnimationController(vsync: this, duration: Duration(seconds: 1)));
//             _animationController[allComments.length -1].addListener(() {if(mounted)setState(() {});});
//             TickerFuture tickerFuture = _animationController[allComments.length -1].repeat();
//             tickerFuture.timeout(Duration(seconds:  0), onTimeout:  () {
//               _animationController[allComments.length -1].reverse(from: 1);
//               _animationController[allComments.length -1].stop(canceled: true);
//             });
//             if(allComments.length > 12){
//             newMsgCount ++;
//             newMsgArrive = true;}
//             else
//               itemScrollController.scrollTo(index: allComments.length, alignment: 0.0,duration: Duration(microseconds: 50),
//                   curve: Curves.bounceInOut);
//           }
//         if(commentsSelected == "All Comments")
//            { chatList = allComments;
//            print("chat list updated");
//            }
//         setState(() {});
//     });
//
// // Real Time Reaction
//     socketIO.subscribe('new_vote', (jsonData) {
//       var updatedId = json.decode(jsonData)["_id"];
//       chatList.forEach((element) {
//         if(element.id == updatedId){
//           element.upVoteCount = json.decode(jsonData)["upvotecount"];
//           element.downVoteCount = json.decode(jsonData)["downvotecount"];
//         }
//         else{}
//         if(mounted)
//           setState(() {});
//       });
//     });
//   }
//    _socketStatus(dynamic data) {
//     print("Socket status: " + data);
//   }
  _onSocketInfo(dynamic data) {
    print("Socket info: " + data);
  }

  // Check for top Comments
  bool containsTopComments = false;

  Future<void> checkTopComments() async {
    CustomResponse response = await ApiCall.makeSocketGetRequestToken(
        "discussion/topcomments?incident=" + widget.caseDetails['_id']);
    if (response.status == 200) {
      if (json.decode(response.body)["status"]) {
        if (json.decode(response.body)["data"].length > 0)
          containsTopComments = true;
        else
          containsTopComments = false;
      }
    }
    if (mounted) setState(() {});
  }

  Future<void> getFullChatList() async {
    if (commentTypeFinalSelected != null) {
      commentsSelected = commentTypeFinalSelected;
    }
    if (chatList.isEmpty ||
        allComments.isEmpty ||
        _animationController.isEmpty) {
      setState(() {
        chatLoad = true;
      });
      currentUserId = await LocalPrefManager.getUserId();
      CustomResponse response = await ApiCall.makeSocketGetRequestToken(
          "discussion/getlist?incident=" + widget.caseDetails['_id']);
      if (response.status == 200) if (json.decode(response.body)['status']) {
        allComments.clear();
        _animationController.clear();
        cacheChatList = json.decode(response.body)["data"] as List;
        for (int i = 0; i < cacheChatList.length; i++) {
          allComments.add(ChatModel(
              cacheChatList[i]["_id"],
              cacheChatList[i]["isanonymous"],
              cacheChatList[i]["anonymousname"],
              cacheChatList[i]["messagetype"],
              cacheChatList[i]["media"],
              cacheChatList[i]["hash"],
              cacheChatList[i]["refer"],
              cacheChatList[i]["text"],
              cacheChatList[i]["user"],
              cacheChatList[i]["replyto"],
              cacheChatList[i]["createdAt"],
              cacheChatList[i]["isUpVoted"],
              cacheChatList[i]["upvotecount"],
              cacheChatList[i]["downvotecount"],
              cacheChatList[i]["isDownVoted"],
              false,
              relatedUser: cacheChatList[i]["relateduser"]));
          _animationController.add(
              AnimationController(vsync: this, duration: Duration(seconds: 1)));
          _animationController[i].addListener(() {
            if (mounted) setState(() {});
          });
          TickerFuture tickerFuture = _animationController[i].repeat();
          tickerFuture.timeout(Duration(seconds: 0), onTimeout: () {
            _animationController[i].reverse(from: 1);
            _animationController[i].stop(canceled: true);
          });
        }
        chatList = allComments;
        await checkTopComments();
      } else
        CommonWidgets.alertBox(context, json.decode(response.body)["msg"],
            leaveThatPage: true);
      else
        Fluttertoast.showToast(msg: response.body);
      chatLoad = false;
      if (mounted) setState(() {});
    } else {
      chatLoad = false;
      print("Contains;;;;;;;;;;;;");
      chatList = chatList;
      allComments = allComments;
      await checkTopComments();
      _animationController = _animationController;
      if (mounted) setState(() {});
    }
  }

  List<ChatModel> topComments = [];

  Future<void> getTopComments() async {
    chatLoad = true;
    topComments.clear();
    setState(() {});
    CustomResponse response = await ApiCall.makeSocketGetRequestToken(
        "discussion/topcomments?incident=" + widget.caseDetails['_id']);
    if (response.status == 200) if (json.decode(response.body)['status']) {
      for (int i = 0; i < json.decode(response.body)["data"].length; i++)
        if (json.decode(response.body)["data"][i]["totalvotes"] > 0)
          topComments.add(ChatModel(
              json.decode(response.body)["data"][i]["_id"],
              json.decode(response.body)["data"][i]["isanonymous"],
              json.decode(response.body)["data"][i]["anonymousname"],
              json.decode(response.body)["data"][i]["messagetype"],
              json.decode(response.body)["data"][i]["media"],
              json.decode(response.body)["data"][i]["hash"],
              json.decode(response.body)["data"][i]["refer"],
              json.decode(response.body)["data"][i]["text"],
              json.decode(response.body)["data"][i]["user"],
              json.decode(response.body)["data"][i]["replyto"],
              json.decode(response.body)["data"][i]["createdAt"],
              json.decode(response.body)["data"][i]["isUpVoted"],
              json.decode(response.body)["data"][i]["upvotecount"],
              json.decode(response.body)["data"][i]["downvotecount"],
              json.decode(response.body)["data"][i]["isDownVoted"],
              false));
      chatList = topComments;
    } else
      Fluttertoast.showToast(msg: json.decode(response.body)["msg"]);
    else
      Fluttertoast.showToast(msg: response.body);
    chatLoad = false;
    setState(() {});
  }

// Sending Message
  bool isMsgOnAir = false;

  Future<void> sendMessage() async {
    bool? isAnonymous = await LocalPrefManager.getAnonymity();
    setState(() {
      isMsgOnAir = true;
    });
    Map data = {
      "isanonymous": isAnonymous,
      "incident": widget.caseDetails['_id'],
      "text": nameHolder.text,
      "replyto": requestForReply && selectedMsg != null ? selectedMsg.id : "",
    };
    CustomResponse response =
        await ApiCall.makePostRequestToken("discussion/add", paramsData: data);
    //   print(json.decode(response.body));
    if (response.status == 200) {
      if (json.decode(response.body)['status']) {
        allComments.add(ChatModel(
            json.decode(response.body)["data"]["_id"],
            json.decode(response.body)["data"]["isanonymous"],
            json.decode(response.body)["data"]["anonymousname"],
            json.decode(response.body)["data"]["messagetype"],
            json.decode(response.body)["data"]["media"],
            json.decode(response.body)["data"]["hash"],
            json.decode(response.body)["data"]["refer"],
            json.decode(response.body)["data"]["text"],
            json.decode(response.body)["data"]["user"],
            json.decode(response.body)["data"]["replyto"],
            json.decode(response.body)["data"]["createdAt"],
            json.decode(response.body)["data"]["isUpVoted"],
            json.decode(response.body)["data"]["upvotecount"],
            json.decode(response.body)["data"]["downvotecount"],
            json.decode(response.body)["data"]["isDownVoted"],
            false));

        chatList = allComments;
        isMsgOnAir = false;
        requestForReply = false;
        selectedMsg = null;
        nameHolder.clear();
        _animationController.add(
            AnimationController(vsync: this, duration: Duration(seconds: 1)));
        _animationController[allComments.length - 1].addListener(() {
          if (mounted) setState(() {});
        });
        TickerFuture tickerFuture =
            _animationController[allComments.length - 1].repeat();
        tickerFuture.timeout(Duration(seconds: 0), onTimeout: () {
          _animationController[allComments.length - 1].reverse(from: 1);
          _animationController[allComments.length - 1].stop(canceled: true);
        });
        itemScrollController.scrollTo(
            index: allComments.length,
            alignment: 0.0,
            duration: Duration(microseconds: 50),
            curve: Curves.bounceInOut);
      } else {
        Fluttertoast.showToast(msg: "Cannot Send Message");
        isMsgOnAir = false;
        nameHolder.clear();
      }
    } else {
      Fluttertoast.showToast(msg: response.body);
      isMsgOnAir = false;
      nameHolder.clear();
    }
    if (mounted) setState(() {});
  }

  //Message Searching
  late Timer searchOnStopTyping;

  callSearchFun(text) {
    const duration = Duration(milliseconds: 300);
    if (searchOnStopTyping != null) {
      setState(() {
        searchOnStopTyping.cancel();
      });
    }
    setState(() {
      searchOnStopTyping = new Timer(duration, () {
        if (personSuggestion) getUsersList(text);
        if (hashTag) getHashList(text);
      });
    });
  }

  // Mentioning Route
  List usersList = [];
  var toBeSortText;

  Future<void> getUsersList(text) async {
    var sendText;
    usersList.clear();
    if (text != "@" && text != "") {
      sendText = text.substring(1);
      toBeSortText = sendText;
      var response = await ApiCall.makeGetRequestToken(
          "user/search?keyword=$sendText&incident=${widget.caseDetails['_id']}");
      if (response.status == 200) if (json
          .decode(response.body)["status"]) if (mounted)
        setState(() {
          usersList = json.decode(response.body)["data"];
          usersList.addAll(json.decode(response.body)["anonymousdata"] ?? []);
        });
    }
  }

// Hash Tag Mentioning
  List hashList = [];

  Future<void> getHashList(text) async {
    var sendText;
    hashList.clear();
    if (text != "#" && text != "") {
      sendText = text.substring(1);
      toBeSortText = sendText;
      var response = await ApiCall.makeGetRequestToken(
          "incident/search?keyword=$sendText");
      if (response.status == 200) if (json
          .decode(response.body)["status"]) if (mounted)
        setState(() {
          hashList = json.decode(response.body)["data"];
        });
    }
  }

  var selectedMsg;
  bool requestForReply = false;
  late AnimationController animationController;
  late Animation<double> animation;

  // Main Body
  Future<bool> onWillPop() async {
    if (goToCommentEnabled)
      setState(() {
        goToCommentEnabled = false;
      });
    else if (filterOn)
      setState(() {
        filterOn = false;
        filterCount = 0;
        chatLoad = true;
        getFullChatList();
      });
    else
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => CaseDetailedView(
                    widget.caseDetails["_id"],
                    isSearch: true,
                  )));
    return Future.value(false);
  }

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.grey.withOpacity(.03),
      body: SafeArea(
        maintainBottomViewPadding: true,
        child: NotificationListener<ScrollNotification>(
          onNotification: (ScrollNotification scrollInfo) {
            var metrics = scrollInfo.metrics;
            if (metrics.atEdge) {
              if (metrics.pixels == metrics.maxScrollExtent) {
                scrollPositionAtEnd = false;
              } else {
                scrollPositionAtEnd = true;
              }
              setState(() {});
            } else {
              scrollPositionAtEnd = true;
            }
            return true;
          },
          child: Stack(
            children: <Widget>[
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  customAppBar(context),
                  buildMessageList(),
                  personSuggestion && usersList.length > 0
                      ? Container(
                          height: 50.0,
                          child: ListView.builder(
                            physics: ClampingScrollPhysics(),
                            itemCount: usersList.length,
                            scrollDirection: Axis.horizontal,
                            itemBuilder: (BuildContext context, int index) {
                              return InkWell(
                                onTap: () {
                                  var selectedPerson =
                                      "(" + usersList[index]["name"] + ")";
                                  nameHolder.text = nameHolder.text.substring(
                                          0,
                                          (nameHolder.text.length -
                                              toBeSortText.length) as int?) +
                                      selectedPerson;
                                  personSuggestion = false;
                                  hashTag = false;
                                  nameHolder.selection =
                                      TextSelection.fromPosition(TextPosition(
                                          offset: nameHolder.text.length));
                                  setState(() {});
                                },
                                child: Card(
                                    elevation: 2.0,
                                    color: Colors.teal.withOpacity(0.8),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15.0),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Center(
                                          child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          usersList[index]["photo"] != null
                                              ? CircleAvatar(
                                                  backgroundColor: Colors.grey,
                                                  radius: 10,
                                                  backgroundImage: NetworkImage(
                                                      ApiCall.imageUrl +
                                                          usersList[index]
                                                              ["photo"]),
                                                )
                                              : CircleAvatar(
                                                  backgroundColor: Colors.grey,
                                                  radius: 10,
                                                ),
                                          SizedBox(
                                            width: 5.0,
                                          ),
                                          Text(
                                            "@${usersList[index]["name"]}",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 11.5),
                                          ),
                                        ],
                                      )),
                                    )),
                              );
                            },
                          ),
                        )
                      : hashTag && hashList.length > 0
                          ? Container(
                              height: 35.0,
                              child: ListView.builder(
                                itemCount: hashList.length,
                                scrollDirection: Axis.horizontal,
                                itemBuilder: (BuildContext context, int index) {
                                  return InkWell(
                                    onTap: () {
                                      nameHolder.text = nameHolder.text +
                                          (hashList[index]["caseidentifier"] ==
                                                      null
                                                  ? hashList[index]["caseid"]
                                                  : hashList[index]
                                                          ["caseidentifier"]
                                                      .toString()
                                                      .substring(
                                                          toBeSortText.length))
                                              .toString();
                                      personSuggestion = false;
                                      hashTag = false;
                                      nameHolder.selection =
                                          TextSelection.fromPosition(
                                              TextPosition(
                                                  offset:
                                                      nameHolder.text.length));
                                      setState(() {});
                                    },
                                    child: Card(
                                        elevation: 2.0,
                                        margin: EdgeInsets.symmetric(
                                            vertical: 5.0, horizontal: 5.0),
                                        color: Colors.grey.withOpacity(0.8),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(2.0),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(5.0),
                                          child: Center(
                                              child: Text(
                                            "${hashList[index]["caseidentifier"] == null ? hashList[index]["caseid"] : hashList[index]["caseidentifier"]}",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w700),
                                          )),
                                        )),
                                  );
                                },
                              ),
                            )
                          : SizedBox.shrink(),
                  SingleChildScrollView(child: buildInputArea()),
                  SizedBox(
                    height: 1.3,
                  ),
                ],
              ),
              typingWidgetOn
                  ? Align(
                      alignment: Alignment.topCenter,
                      child: LimitedBox(
                          child: Container(
                              color: Colors.teal.withOpacity(0.8),
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                typingWidgetNames == null
                                    ? "Someone is typing..."
                                    : typingWidgetNames + " is typing...",
                                style: TextStyle(color: Colors.white),
                              ))),
                    )
                  : SizedBox.shrink(),
              newMsgCount == 0 && scrollPositionAtEnd
                  ? Positioned(
                      bottom: 100,
                      right: 5,
                      child: Align(
                          alignment: Alignment.bottomRight,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              CircleAvatar(
                                child: IconButton(
                                  icon: Icon(
                                    Icons.expand_more,
                                  ),
                                  onPressed: () {
                                    newMsgArrive = false;
                                    newMsgCount = 0;
                                    itemScrollController.scrollTo(
                                        index: allComments.length,
                                        alignment: 0.0,
                                        duration: Duration(microseconds: 50),
                                        curve: Curves.bounceInOut);
                                    setState(() {});
                                  },
                                  color: Colors.white,
                                  tooltip: "New Messages",
                                ),
                              ),
                            ],
                          )),
                    )
                  : SizedBox.shrink(),
              newMsgArrive && newMsgCount > 0
                  ? Positioned(
                      bottom: 100,
                      right: 5,
                      child: Align(
                          alignment: Alignment.bottomRight,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              CircleAvatar(
                                backgroundColor: Colors.green.withOpacity(0.9),
                                radius: 15.0,
                                child: Center(
                                    child: Text(
                                  newMsgCount > 50
                                      ? newMsgCount.toString() + "+"
                                      : newMsgCount.toString(),
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 11.0),
                                )),
                              ),
                              CircleAvatar(
                                child: IconButton(
                                  icon: Icon(
                                    Icons.expand_more,
                                  ),
                                  onPressed: () {
                                    newMsgArrive = false;
                                    newMsgCount = 0;
                                    itemScrollController.scrollTo(
                                        index: allComments.length,
                                        alignment: 0.0,
                                        duration: Duration(microseconds: 50),
                                        curve: Curves.bounceInOut);
                                    setState(() {});
                                  },
                                  color: Colors.white,
                                  tooltip: "New Messages",
                                ),
                              ),
                            ],
                          )),
                    )
                  : SizedBox.shrink(),
            ],
          ),
        ),
      ),
    );
  }

  // Setting Messages
  Widget buildSingleMessage(BuildContext context, int index) {
    List<MatchText> highlightList = [];
    //HighLight HashTag
    for (int i = 0; i < chatList[index].hash.length; i++) {
      highlightList.add(
        MatchText(
            pattern: "#" + chatList[index].hash[i],
            style: MaterialTools.hashTagHighlight,
            onTap: (url) {
              getIncidentFullView(chatList[index].hash[i]);
              //   Navigator.push(context, CupertinoPageRoute(builder: (context)=>CaseViewInDiscussion(caseId: chatList[index].hash[i],)));
            }),
      );
    }
    //HighLight UserTag
    for (int i = 0; i < chatList[index].refer.length; i++) {
      highlightList.add(
        MatchText(
            pattern: "\\@\\(${chatList[index].refer[i]["name"]}\\)",
            style: MaterialTools.userTagHighlight,
            onTap: (url) {
              if (chatList[index].refer == null ||
                  chatList[index].refer.isEmpty) {
              } else
                Navigator.push(
                    context,
                    CupertinoPageRoute(
                        builder: (context) => UsersProfile(
                              userDetails: chatList[index].refer[i],
                            )));
            }),
      );
    }

    for (int i = 0; i < chatList[index].text.length; i++) {
      highlightList.add(
        MatchText(
            pattern: "\\@\\(${"Anonymous +[0-9]+(\)"}\\)",
            style: MaterialTools.userTagHighlight,
            onTap: (url) {}),
      );
    }

    if (currentUserId == chatList[index].user["_id"])
      return FadeTransition(
        opacity: _animationController[index],
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: 100.0,
            maxWidth: 300.0,
          ),
          child: Container(
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
                  child: GestureDetector(
                    onTap: () => _showSelfCustomMenu(
                        index: index,
                        isTopComment:
                            commentsSelected == "Top Comments" ? true : false),
                    onLongPress: () {
                      HapticFeedback.vibrate();
                      _showSelfCustomMenu(
                          index: index,
                          isTopComment: commentsSelected == "Top Comments"
                              ? true
                              : false);
                    },
                    onTapDown: _storePosition,
                    onTapUp: _storePosition2,
                    child: Card(
                      elevation: 2.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0),
                        side: BorderSide(
                          color: Colors.grey,
                          width: 0.2,
                        ),
                      ),
                      margin: const EdgeInsets.only(
                          bottom: 10.0, left: 20.0, right: 20.0),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Wrap(
                              children: [
                                ConstrainedBox(
                                  constraints: BoxConstraints(
                                    minWidth: 50.0,
                                    maxWidth: 150.0,
                                  ),
                                  child: chatList[index].anonymous &&
                                          chatList[index].anonymousName != null
                                      ? index == 0
                                          ? Text(
                                              "You as " +
                                                      chatList[index]
                                                          .anonymousName ??
                                                  "Anonymous",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            )
                                          : chatList[index].anonymousName !=
                                                  chatList[index - 1]
                                                      .anonymousName
                                              ? Text(
                                                  "You as " +
                                                          chatList[index]
                                                              .anonymousName ??
                                                      "Anonymous",
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                )
                                              : SizedBox.shrink()
                                      : index == 0
                                          ? Text(
                                              "You as " +
                                                      chatList[index]
                                                          .user["name"] ??
                                                  "Anonymous",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            )
                                          : chatList[index].user["name"] !=
                                                  chatList[index - 1]
                                                      .user["name"]
                                              ? Text(
                                                  "You as " +
                                                          chatList[index]
                                                              .user["name"] ??
                                                      "Anonymous",
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                )
                                              : SizedBox.shrink(),
                                ),
                                (chatList[index].upVoteCount == null ||
                                            chatList[index].upVoteCount == 0) &&
                                        (chatList[index].downVoteCount ==
                                                null ||
                                            chatList[index].downVoteCount == 0)
                                    ? SizedBox.shrink()
                                    : showMsgOptions(context, index),
                              ],
                            ),
                            chatList[index].replyTo != null
                                ? ConstrainedBox(
                                    constraints: BoxConstraints(
                                      minWidth: 180.0,
                                      maxWidth: 300.0,
                                    ),
                                    child: Container(
                                      padding: EdgeInsets.all(2.0),
                                      decoration: BoxDecoration(
                                          color: Colors.grey.withOpacity(0.2),
                                          borderRadius:
                                              BorderRadius.circular(5.0),
                                          border: Border.all(
                                              color: Colors.grey, width: 0.5)),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Text(
                                            // chatList[index].anonymous?"Anonymous":
                                            chatList[index]
                                                    .replyTo['isanonymous']
                                                ? chatList[index].replyTo[
                                                        'anonymousname'] ??
                                                    'Anonymous'
                                                : chatList[index]
                                                            .replyTo["user"]
                                                        ["name"] ??
                                                    "Anonymous",
                                            style: TextStyle(
                                                fontWeight: FontWeight.w600),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Text(
                                            chatList[index].replyTo["text"],
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                : SizedBox.shrink(),
                            chatList[index].replyTo != null
                                ? SizedBox(
                                    height: 8.0,
                                  )
                                : SizedBox.shrink(),
                            Wrap(
                              spacing: 10.0,
                              children: <Widget>[
                                // chatList[index].hash.isNotEmpty ?

                                ParsedText(
                                  alignment: TextAlign.start,
                                  text: chatList[index].text,
                                  parse: highlightList,
                                  style: TextStyle(
                                    color: Colors.black,
                                  ),
                                ),

                                Transform.translate(
                                    offset: const Offset(0.0, 8.0),
                                    child: Text(
                                      CommonFunction.timeFormatter.format(
                                          DateTime.parse(
                                                  chatList[index].createTime)
                                              .toLocal()),
                                      style: TextStyle(
                                          fontSize: 11.0, color: Colors.grey),
                                      textAlign: TextAlign.end,
                                    )),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                msgDeleteBtn && chatList[index].id != "00"
                    ? IconButton(
                        icon: Icon(Icons.delete),
                        color: Colors.redAccent,
                        onPressed: () {
                          deleteMyMsg(chatList[index].id, index);
                        },
                      )
                    : SizedBox.shrink(),
              ],
            ),
          ),
        ),
      );
    else if (chatList[index].user["type"] == "Admin" &&
        chatList[index].messageType == "SYSTEM")
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Wrap(
              alignment: WrapAlignment.start,
              spacing: 10,
              children: <Widget>[
                Text(
                  chatList[index].relatedUser != null
                      ? chatList[index].relatedUser["name"] ?? "Anonymous"
                      : "Anonymous",
                  style: TextStyle(fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  " updated the case",
                  style: TextStyle(color: Colors.grey),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Align(
                    alignment: Alignment.topRight,
                    child: Text(
                      CommonFunction.timeFormatter.format(
                          DateTime.parse(chatList[index].createTime).toLocal()),
                      style: TextStyle(color: Colors.grey, fontSize: 11.5),
                    )),
              ],
            ),
            chatList[index].text == null || chatList[index].text == ""
                ? SizedBox.shrink()
                : ReadMoreText(
                    widget.caseDetails["description"] ?? "",
                    trimLines: 2,
                    colorClickableText: Colors.teal,
                    trimMode: TrimMode.Line,
                    trimCollapsedText: ' ...  show more',
                    trimExpandedText: '   show less',
                    textAlign: TextAlign.justify,
                    style: TextStyle(color: Colors.black),
                    key: Key('readMoreText'),
                    textDirection: TextDirection.ltr,
                    locale: Locale('en'),
                    textScaleFactor: 1.0,
                    semanticsLabel: 'Read more text',
                  ),
            Divider(
              height: chatList[index].text == null || chatList[index].text == ""
                  ? 5.0
                  : 10.0,
            ),
          ],
        ),
      );
    else if (chatList[index].user["type"] == "Admin" &&
        chatList[index].messageType == "Manual")
      return GestureDetector(
        onLongPress: () {
          HapticFeedback.vibrate();
          _showCustomMenu(
              index: index,
              isTopComment: commentsSelected == "Top Comments" ? true : false);
        },
        onTap: () => _showCustomSubMenu(index),

        // Have to remember it on tap-down.
        onTapDown: _storePosition,
        onTapUp: _storePosition2,

        child: FadeTransition(
          opacity: _animationController[index],
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: 50.0,
              maxWidth: 300.0,
            ),
            child: Container(
              alignment: Alignment.centerLeft,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: 50.0,
                  maxWidth: 300.0,
                ),
                child: Card(
                  elevation: 2.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0),
                    side: BorderSide(
                      color: Colors.grey,
                      width: 0.2,
                    ),
                  ),
                  margin: const EdgeInsets.only(
                      bottom: 10.0, left: 20.0, right: 20.0, top: 0.0),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: <Widget>[
                            ConstrainedBox(
                              constraints: BoxConstraints(
                                minWidth: 50.0,
                                maxWidth: 100.0,
                              ),
                              child: Text(
                                "Admin",
                                style: TextStyle(fontWeight: FontWeight.bold),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            (chatList[index].upVoteCount == null ||
                                        chatList[index].upVoteCount == 0) &&
                                    (chatList[index].downVoteCount == null ||
                                        chatList[index].downVoteCount == 0)
                                ? SizedBox.shrink()
                                : showMsgOptions(context, index),
                          ],
                        ),
                        chatList[index].replyTo != null
                            ? Container(
                                width: double.infinity,
                                padding: EdgeInsets.all(2.0),
                                decoration: BoxDecoration(
                                    color: Colors.grey.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(5.0),
                                    border: Border.all(
                                        color: Colors.grey, width: 0.5)),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      chatList[index].anonymous
                                          ? "Anonymous"
                                          : chatList[index].replyTo["user"]
                                                  ["name"] ??
                                              "Anonymous",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w600),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      chatList[index].replyTo["text"],
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(fontSize: 13),
                                    ),
                                  ],
                                ),
                              )
                            : SizedBox.shrink(),
                        Wrap(
                          spacing: 10.0,
                          direction: Axis.horizontal,
                          alignment: WrapAlignment.end,
                          children: <Widget>[
                            ParsedText(
                              alignment: TextAlign.start,
                              text: chatList[index].text,
                              parse: highlightList,
                              style: TextStyle(
                                color: Colors.black,
                              ),
                            ),
                            Transform.translate(
                              offset: const Offset(0.0, 5.0),
                              child: Text(
                                  CommonFunction.timeFormatter.format(
                                      DateTime.parse(chatList[index].createTime)
                                          .toLocal()),
                                  style: TextStyle(
                                      fontSize: 11.0, color: Colors.grey)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

    return GestureDetector(
      onLongPress: () {
        HapticFeedback.vibrate();
        _showCustomMenu(
            index: index,
            isTopComment: commentsSelected == "Top Comments" ? true : false);
      },
      onTap: () => _showCustomSubMenu(index),

      // Have to remember it on tap-down.
      onTapDown: _storePosition,
      onTapUp: _storePosition2,

      child: FadeTransition(
        opacity: _animationController[index],
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: 50.0,
            maxWidth: 300.0,
          ),
          child: Container(
            alignment: Alignment.centerLeft,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: 50.0,
                maxWidth: 300.0,
              ),
              child: Card(
                elevation: 2.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.0),
                  side: BorderSide(
                    color: Colors.grey,
                    width: 0.2,
                  ),
                ),
                margin: const EdgeInsets.only(
                    bottom: 10.0, left: 20.0, right: 20.0, top: 0.0),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: <Widget>[
                          ConstrainedBox(
                            constraints: BoxConstraints(
                              minWidth: 50.0,
                              maxWidth: 100.0,
                            ),
                            child: chatList[index].anonymous &&
                                    chatList[index].anonymousName != null
                                ? index == 0
                                    ? Text(
                                        chatList[index].anonymousName ??
                                            "Anonymous",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      )
                                    : chatList[index].anonymousName !=
                                            chatList[index - 1].anonymousName
                                        ? Text(
                                            chatList[index].anonymousName ??
                                                "Anonymous",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          )
                                        : SizedBox.shrink()
                                : index == 0
                                    ? Text(
                                        chatList[index].user["name"] ??
                                            "Anonymous",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      )
                                    : chatList[index].user["name"] !=
                                            chatList[index - 1].user["name"]
                                        ? Text(
                                            chatList[index].user["name"] ??
                                                "Anonymous",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          )
                                        : SizedBox.shrink(),
                          ),
                          (chatList[index].upVoteCount == null ||
                                      chatList[index].upVoteCount == 0) &&
                                  (chatList[index].downVoteCount == null ||
                                      chatList[index].downVoteCount == 0)
                              ? SizedBox.shrink()
                              : showMsgOptions(context, index),
                        ],
                      ),
                      chatList[index].replyTo != null
                          ? Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(2.0),
                              decoration: BoxDecoration(
                                  color: Colors.grey.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(5.0),
                                  border: Border.all(
                                      color: Colors.grey, width: 0.5)),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    //  chatList[index].anonymous?"Anonymous":
                                    chatList[index].replyTo['isanonymous']
                                        ? chatList[index]
                                                .replyTo['anonymousname'] ??
                                            'Anonymous'
                                        : chatList[index].replyTo["user"]
                                                ["name"] ??
                                            "Anonymous",
                                    style:
                                        TextStyle(fontWeight: FontWeight.w600),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    chatList[index].replyTo["text"],
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(fontSize: 13),
                                  ),
                                ],
                              ),
                            )
                          : SizedBox.shrink(),
                      Wrap(
                        spacing: 10.0,
                        direction: Axis.horizontal,
                        alignment: WrapAlignment.end,
                        children: <Widget>[
                          ParsedText(
                            alignment: TextAlign.start,
                            text: chatList[index].text,
                            parse: highlightList,
                            style: TextStyle(
                              color: Colors.black,
                            ),
                          ),
                          Transform.translate(
                            offset: const Offset(0.0, 5.0),
                            child: Text(
                                CommonFunction.timeFormatter.format(
                                    DateTime.parse(chatList[index].createTime)
                                        .toLocal()),
                                style: TextStyle(
                                    fontSize: 11.0, color: Colors.grey)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  var _count = 0;
  var _tapPosition;

  void _showCustomMenu({required int index, required bool isTopComment}) {
    // Unfocus any focused input fields
    FocusScope.of(context).unfocus();

    // Get the overlay render object with proper null safety
    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox?;
    if (overlay == null || _tapPosition == null) return;

    // Calculate menu position with proper bounds checking
    final menuPosition = RelativeRect.fromRect(
      Rect.fromPoints(
        _tapPosition!,
        _tapPosition!.translate(1, 1), // Small offset to ensure visibility
      ),
      Offset.zero & overlay.size,
    );

    showMenu<int>(
      context: context,
      items: [
        ReactionMenu(
          key: ValueKey('reaction_menu_$index'), // More efficient than UniqueKey
          index: index,
          notifyParent: refresh,
          isTopComment: isTopComment, // Use the passed parameter
          gotoComment: (id) => _handleGotoComment(id),
          replySelfComment: (idx) => _handleReply(idx),
          selfReply: true,
        ),
      ],
      position: menuPosition,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      color: Theme.of(context).cardColor,
    ).then((delta) {
      if (delta != null && mounted) {
        setState(() => _count += delta);
      }
    });
  }

// Example handler methods
  void _handleGotoComment(String id) {
    // Implement navigation to comment
  }

  void _handleReply(int index) {
    // Implement reply functionality
  }

  void _showSelfCustomMenu({required int index, required bool isTopComment}) {
    // Unfocus any focused fields first
    FocusScope.of(context).unfocus();

    // Safely get overlay with type casting
    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox?;
    if (overlay == null || _tapPosition == null) return;

    // Calculate position with proper bounds
    final menuPosition = RelativeRect.fromRect(
      Rect.fromPoints(
        _tapPosition!,
        _tapPosition!.translate(1, 1), // Small offset to ensure visibility
      ),
      Offset.zero & overlay.size,
    );

    showMenu<int>(
      context: context,
      items: [
        ReactionMenu(
          key: ValueKey('self_menu_$index'), // More efficient key
          index: index,
          notifyParent: refresh,
          isTopComment: isTopComment,
          gotoComment: (id) => _handleGoToComment(id),
          replySelfComment: (idx) => _handleReplyToComment(idx),
          selfReply: true,
        ),
      ],
      position: menuPosition,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      color: Theme.of(context).cardColor,
    ).then((delta) {
      if (delta != null && mounted) {
        setState(() => _count += delta);
      }
    });
  }

// Handler methods
  void _handleGoToComment(String commentId) {
    // Implement comment navigation logic
    goToCommentsInChat(commentId);
  }

  void _handleReplyToComment(int commentIndex) {
    // Implement reply logic
    replyToComment(commentIndex);
  }
  //SubMenu
  void _showCustomSubMenu(int index) {
    // Unfocus any focused fields first
    FocusScope.of(context).unfocus();

    // Safely get overlay with type casting and null check
    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox?;
    if (overlay == null || _tapPosition == null) return;

    // Calculate position with proper bounds and minimum size
    final menuPosition = RelativeRect.fromRect(
      Rect.fromPoints(
        _tapPosition!,
        _tapPosition!.translate(80, 80), // Custom size for submenu
      ),
      Offset.zero & overlay.size,
    );

    showMenu<int>(
      context: context,
      items: [
        MenuOptions(
          index: index,
          notifyParent: refresh,
          replyToComment: (idx) {
            // Handle reply with proper index
            replyToComment(idx);
            // Additional analytics or tracking could be added here
          },
        ),
      ],
      position: menuPosition,
      elevation: 4, // Added elevation for better visibility
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      color: Theme.of(context).cardColor, // Match app theme
      constraints: const BoxConstraints(
        minWidth: 200, // Ensure minimum width for better touch targets
        maxWidth: 300, // Reasonable maximum width
      ),
    ).then((delta) {
      if (delta != null && mounted) {
        setState(() => _count += delta);
      }
    });
  }

  void _storePosition(TapDownDetails details) {
    _tapPosition = details.globalPosition;
  }

  void _storePosition2(TapUpDetails details) {
    _tapPosition = details.globalPosition;
  }

  Widget showMsgOptions(BuildContext context, int index) {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.end,
      children: <Widget>[
        SizedBox(
          width: 5.0,
        ),
        chatList[index].upVoteCount != null && chatList[index].upVoteCount != 0
            ? Icon(
                Icons.thumb_up,
                size: chatList[index].isUpVoted != null
                    ? chatList[index].isUpVoted
                        ? 20
                        : 15
                    : 15,
                //color:  chatList[index].isUpVoted !=null ?  chatList[index].isUpVoted? Colors.blueAccent : Colors.black : Colors.black,
                color: Colors.blueAccent,
              )
            : SizedBox.shrink(),
        chatList[index].upVoteCount != null && chatList[index].upVoteCount != 0
            ? SizedBox(
                width: 2.0,
              )
            : SizedBox.shrink(),
        chatList[index].upVoteCount != null && chatList[index].upVoteCount != 0
            ? Text(chatList[index].upVoteCount != null
                ? chatList[index].upVoteCount.toString()
                : "0")
            : SizedBox.shrink(),
        SizedBox(
          width: 8.0,
        ),
        chatList[index].downVoteCount != null &&
                chatList[index].downVoteCount != 0
            ? Icon(
                Icons.sentiment_dissatisfied,
                size: chatList[index].isDownVoted != null
                    ? chatList[index].isDownVoted
                        ? 20
                        : 15
                    : 15,
                //  color:  chatList[index].isDownVoted != null ?chatList[index].isDownVoted? Colors.redAccent : Colors.black :Colors.black,
                color: Colors.red,
              )
            : SizedBox.shrink(),
        chatList[index].downVoteCount != null &&
                chatList[index].downVoteCount != 0
            ? SizedBox(
                width: 2.0,
              )
            : SizedBox.shrink(),
        chatList[index].downVoteCount != null &&
                chatList[index].downVoteCount != 0
            ? Text(chatList[index].downVoteCount != null
                ? chatList[index].downVoteCount.toString()
                : "0")
            : SizedBox.shrink(),
      ],
    );
  }

  bool msgDeleteBtn = false;

  void upVote(var msgId, bool upVoteStatus, index) async {
    Map data = {
      "id": msgId,
      "status": upVoteStatus != null
          ? upVoteStatus
              ? false
              : true
          : true,
    };
    CustomResponse response = await ApiCall.makePostRequestToken(
        "discussion/upvote",
        paramsData: data);
    print(index);
    if (response.status == 200) if (json.decode(response.body)["status"]) {
      setState(() {
        chatList[index].isUpVoted = upVoteStatus != null
            ? upVoteStatus
                ? false
                : true
            : true;
        chatList[index].upVoteCount = upVoteStatus != null
            ? upVoteStatus
                ? chatList[index].upVoteCount - 1
                : chatList[index].upVoteCount + 1
            : 1;
      });
    } else
      Fluttertoast.showToast(msg: "Failed to post your reaction");
    else
      Fluttertoast.showToast(msg: "Something went wrong");
  }

  void downVote(var msgId, bool downVoteStatus, index) async {
    Map data = {
      "id": msgId,
      "status": downVoteStatus != null
          ? downVoteStatus
              ? false
              : true
          : true,
    };
    CustomResponse response = await ApiCall.makePostRequestToken(
        "discussion/downvote",
        paramsData: data);
    print(index);
    if (response.status == 200) if (json.decode(response.body)["status"]) {
      setState(() {
        chatList[index].isDownVoted = downVoteStatus != null
            ? downVoteStatus
                ? false
                : true
            : true;
        chatList[index].downVoteCount = downVoteStatus != null
            ? downVoteStatus
                ? chatList[index].downVoteCount - 1
                : chatList[index].downVoteCount + 1
            : 1;
      });
    } else
      Fluttertoast.showToast(msg: "Failed to post your Reaction!");
    else
      Fluttertoast.showToast(msg: "Something went wrong");
  }

  void deleteMyMsg(var msgId, int index) async {
    Map data = {"id": msgId};
    CustomResponse response = await ApiCall.makePostRequestToken(
        "discussion/remove",
        paramsData: data);
    if (response.status == 200) if (json.decode(response.body)["status"])
      setState(() {
        chatList.removeAt(index);
        CommonFunction.player
            .play(CommonFunction.messageReply as Source, volume: 0.1);
      });
    else
      Fluttertoast.showToast(msg: "Failed to remove message");
    else
      Fluttertoast.showToast(msg: "Something went wrong");
  }

  List commentCat = ["All Comments", "Top Comments"];
  String commentsSelected = "All Comments";

  commentButtons(BuildContext context) {
    final List<Widget> commentList = <Widget>[];
    for (int i = 0; i < commentCat.length; i++)
      commentList.add(ChoiceChip(
        label: Text(
          commentCat[i],
          style: TextStyle(fontSize: 12),
        ),
        backgroundColor: Colors.grey[100],
        selectedColor: Colors.teal.withOpacity(.3),
        padding: EdgeInsets.all(10.0),
        shadowColor: Colors.greenAccent,
        selected: commentsSelected == commentCat[i],
        onSelected: (selected) async {
          filterCount = 0;
          selectedFilterList.clear();
          for (int i = 0; i < commonDiscussionFilters.length; i++)
            commonDiscussionFilters[i].selected = false;
          commentsSelected = commentCat[i];
          commentTypeFinalSelected = commentCat[i];
          if (commentsSelected == "Top Comments")
            getTopComments();
          else {
            chatList.clear();
            await getFullChatList();
//              chatList = allComments;
            Future.delayed(const Duration(milliseconds: 400), () {
              itemScrollController.jumpTo(
                index: allComments.length,
                alignment: 0.0,
              );
            });
          }
          setState(() {});
        },
      ));
    return commentList;
  }

  bool filterOn = false;
  int filterCount = 0;

  Widget buildMessageList() {
    return Expanded(
      child: Container(
        color: Colors.grey.withOpacity(.02),
        height: requestForReply
            ? MediaQuery.of(context).size.height - 295
            : MediaQuery.of(context).size.height - 300,
        width: width,
        child: AnimatedContainer(
          duration: Duration(milliseconds: 600),
          height: isVisible
              ? MediaQuery.of(context).size.height - 310
              : MediaQuery.of(context).size.height - 260,
          child: chatLoad
              ? CommonWidgets.progressIndicator(context)
              : ScrollablePositionedList.builder(
                  addAutomaticKeepAlives: true,
                  key: PageStorageKey("discussion"),
                  minCacheExtent: 1000,
                  scrollDirection: Axis.vertical,
                  reverse: false,
                  physics: ClampingScrollPhysics(),
                  itemScrollController: itemScrollController,
                  itemPositionsListener: itemPositionsListener,
                  itemCount: chatList.length + 1,
                  initialScrollIndex: chatList.length + 1,
                  itemBuilder: (BuildContext context, int index) {
                    if (index == 0)
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Wrap(
                              alignment: WrapAlignment.start,
                              spacing: 5,
                              children: <Widget>[
                                Text(
                                  widget.caseDetails["isanonymous"]
                                      ? widget.caseDetails["anonymousname"] ??
                                          "Anonymous"
                                      : widget.caseDetails["addedby"]["name"] ??
                                          "Anonymous",
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  "posted the case",
                                  style: TextStyle(color: Colors.black),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Align(
                                  alignment: Alignment.topRight,
                                  child: Text(
                                    CommonFunction.timeFormatter.format(
                                        DateTime.parse(widget
                                                .caseDetails["createddate"])
                                            .toLocal()),
                                    style: TextStyle(
                                        color: Colors.black, fontSize: 11.5),
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                              ],
                            ),
                            widget.caseDetails["description"] == null ||
                                    widget.caseDetails["description"] == ""
                                ? SizedBox.shrink()
                                : ReadMoreText(
                                    widget.caseDetails["description"] ?? "",
                                    trimLines: 2,
                                    colorClickableText: Colors.teal,
                                    trimMode: TrimMode.Line,
                                    trimCollapsedText: ' ...  show more',
                                    trimExpandedText: '   show less',
                                    textAlign: TextAlign.justify,
                                    style: TextStyle(color: Colors.black),
                                    key: Key('readMoreText'),
                                    textDirection: TextDirection.ltr,
                                    locale: Locale('en'),
                                    textScaleFactor: 1.0,
                                    semanticsLabel: 'Read more text',
                                  ),
                            Divider(
                              height: widget.caseDetails["description"] ==
                                          null ||
                                      widget.caseDetails["description"] == ""
                                  ? 0.0
                                  : 20.0,
                            ),
                          ],
                        ),
                      );

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        index == 1
                            ? displayChatDate(
                                context,
                                CommonFunction.dateFormatter.format(
                                    DateTime.parse(chatList[index - 1].createTime)
                                        .toLocal()))
                            : CommonFunction.dateFormatter.format(
                                        DateTime.parse(chatList[index - 2].createTime)
                                            .toLocal()) !=
                                    CommonFunction.dateFormatter.format(
                                        DateTime.parse(chatList[index - 1].createTime)
                                            .toLocal())
                                ? displayChatDate(
                                    context,
                                    CommonFunction.dateFormatter.format(
                                        DateTime.parse(chatList[index - 1].createTime)
                                            .toLocal()))
                                : SizedBox.shrink(),
                        buildSingleMessage(context, index - 1),
                      ],
                    );
                  },
                ),
        ),
      ),
    );
  }

  final ItemScrollController itemScrollController = ItemScrollController();
  final ItemPositionsListener itemPositionsListener =
      ItemPositionsListener.create();

  Widget displayChatDate(BuildContext context, var text) {
    return Center(
        child: Card(
      child: Container(
          padding: const EdgeInsets.all(5.0),
          color: Colors.teal.withOpacity(0.2),
          child: Text(
            text ?? "",
            style: TextStyle(color: Colors.black54),
          )),
    ));
  }

  final formKey = GlobalKey<FormState>();
  var message;

  final nameHolder = TextEditingController();
  bool personSuggestion = false, hashTag = false;

  Future<void> onTextTyped(var val) async {
    bool? isAnonymous = await LocalPrefManager.getAnonymity();
    // socketIO.sendMessage(
    //     'usertyping', json.encode({'token':widget.token,'incident':incidentId.toString(), "isanonymous": isAnonymous}),
    //     _onSocketInfo);

    List splitWords = [];
    splitWords = val.split(" ");
    for (int i = 0; i < splitWords.length; i++) {
      if (splitWords[i].startsWith((new RegExp(r'@'))))
        setState(() {
          personSuggestion = true;
          if (personSuggestion) callSearchFun(splitWords[i]);
        });
      else if (splitWords[i].startsWith((new RegExp(r'#'))))
        setState(() {
          hashTag = true;
          if (hashTag) callSearchFun(splitWords[i]);
        });
      else
        setState(() {
          personSuggestion = false;
          hashTag = false;
        });
    }
  }

  FocusNode keyboardOne = FocusNode();

  Widget buildChatInput() {
    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: 50, maxHeight: 120),
      child: Form(
        key: formKey,
        child: Container(
            margin: EdgeInsets.symmetric(vertical: 5.0),
            decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(
                  color: Colors.grey.withOpacity(0.5),
                ),
                borderRadius: BorderRadius.all(Radius.circular(10))),
            width: MediaQuery.of(context).size.width - 70,
            padding: const EdgeInsets.all(5.0),
            child: Scrollbar(
              child: TextField(
                focusNode: keyboardOne,
                controller: nameHolder,
                scrollPhysics: AlwaysScrollableScrollPhysics(),
                onChanged: (val) {
                  onTextTyped(val);
                },
                autocorrect: true,
                decoration: InputDecoration.collapsed(
                    hintText: 'Send Message ...',
                    hintStyle: TextStyle(fontSize: 12)),
                keyboardType: TextInputType.multiline,
                maxLines: null,
                textCapitalization: TextCapitalization.sentences,
              ),
            )),
      ),
    );
  }

  Widget buildSendButton() {
    return InkWell(
      onTap: () {
        formKey.currentState?.save();
        sendMessage();
      },
      child: CircleAvatar(
        child: Icon(
          Icons.send,
          size: 20,
        ),
      ),
    );
  }

  Widget buildInputArea() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.0),
      width: width,
      child: Column(
        children: <Widget>[
          requestForReply
              ? Container(
                  padding: EdgeInsets.all(5.0),
                  width: double.infinity,
                  decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.2),
                      border: Border.all(
                        color: Colors.grey.withOpacity(0.2),
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(15))),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          Icon(Icons.reply),
                          Text(
                            selectedMsg.anonymous
                                ? selectedMsg.anonymousName ?? "Anonymous"
                                : selectedMsg.user["name"] ?? "Anonymous",
                            style: TextStyle(
                                color: Colors.black87,
                                fontWeight: FontWeight.w600),
                          ),
                          Spacer(),
                          IconButton(
                            icon: Icon(Icons.cancel),
                            onPressed: () {
                              setState(() {
                                requestForReply = false;
                              });
                              FocusScope.of(context).unfocus();
                            },
                          )
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15.0),
                        child: Text(
                          selectedMsg.text,
                          style: TextStyle(color: Colors.black54),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                )
              : SizedBox.shrink(),
          requestForReply
              ? SizedBox(
                  height: 8.0,
                )
              : SizedBox.shrink(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              buildChatInput(),
              // attachMedia(),
              isMsgOnAir
                  ? SizedBox(
                      height: 25.0,
                      width: 25.0,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                      ))
                  : buildSendButton(),
            ],
          ),
        ],
      ),
    );
  }

  Widget customAppBar(BuildContext context) {
    return Column(
      children: <Widget>[
        Card(
          elevation: 5.0,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
            height: 40.0,
            color: Colors.white,
            child: Row(
              children: <Widget>[
                GestureDetector(
                    onTap: () async {
                      if (goToCommentEnabled) goToCommentEnabled = false;
                      var result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => DiscussionSearch(
                                  widget.caseDetails["_id"], currentUserId)));
                      if (result != null) gotoSearchResult(result);
                    },
                    child: Text("Search ...")),
                Spacer(),
                VerticalDivider(
                  thickness: 1.0,
                ),
                InkWell(
                    onTap: () async {
                      var filterChat;
                      var filterData;
                      filterChat = await Navigator.push(
                          context,
                          CupertinoPageRoute(
                              builder: (context) => DiscussionFormFilter(
                                  widget.caseDetails["_id"],
                                  filterType,
                                  selectedFilterList,
                                  commentsSelected,
                                  isInFilter: filterOn)));
                      setState(() {
                        filterData =
                            json.decode(filterChat)["filterData"] as List;
                        filterCount = json.decode(filterChat)["filterCount"];
                        filterType = json.decode(filterChat)["filterType"];
                        selectedFilterList =
                            json.decode(filterChat)["types"] as List;
                      });
                      print(filterCount);
                      print(filterType);
                      print(selectedFilterList);
                      if (filterData.isNotEmpty) {
                        setState(() {
                          chatLoad = true;
                          chatList.clear();
                        });
                        for (int i = 0; i < filterData.length; i++)
                          chatList.add(ChatModel(
                              filterData[i]["id"],
                              filterData[i]["isanonymous"],
                              filterData[i]["anonymousname"],
                              filterData[i]["messagetype"],
                              filterData[i]["media"],
                              filterData[i]["hash"],
                              filterData[i]["refer"],
                              filterData[i]["text"],
                              filterData[i]["user"],
                              filterData[i]["replyto"],
                              filterData[i]["createdAt"],
                              filterData[i]["isUpVoted"],
                              filterData[i]["upvotecount"],
                              filterData[i]["downvotecount"],
                              filterData[i]["isDownVoted"],
                              false));

                        itemScrollController.scrollTo(
                            index: allComments.length,
                            alignment: 0.0,
                            duration: Duration(microseconds: 50),
                            curve: Curves.bounceInOut);
                        filterOn = true;
                        chatLoad = false;
                      } else {
                        if (filterType) {
                          setState(() {
                            chatList.clear();
                          });
                        } else {}
                      }
                      setState(() {});
                    },
                    child: Row(
                      children: <Widget>[
                        Text("Filter"),
                        filterType && filterCount != 0
                            ? Text(
                                " (" + filterCount.toString() + ")",
                                style: TextStyle(color: Colors.teal),
                              )
                            : SizedBox.shrink(),
                      ],
                    )),
              ],
            ),
          ),
        ),

        //Comment Selection
        containsTopComments
            ? AnimatedContainer(
                duration: Duration(milliseconds: 600),
                height: isVisible ? 50.0 : 0.0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: commentButtons(context),
                ),
              )
            : SizedBox.shrink(),
        SizedBox(
          height: 3,
        ),
      ],
    );
  }

  //Menu Class callBack Function
  refresh() {
    setState(() {});
  }

  bool goToCommentEnabled = false;
  var goToCommentSelected = "";
  int goToIndex = 0;

  void goToCommentsInChat(dynamic goToCommentSelected) {
    goToIndex = 0;
    for (int i = 0; i < allComments.length; i++) {
      if (goToCommentSelected == allComments[i].id) goToIndex = i;
    }
    chatLoad = true;
    commentsSelected = "All Comments";
    chatList = allComments;
    Future.delayed(const Duration(milliseconds: 55), () {
      itemScrollController.jumpTo(
        index: goToIndex,
        alignment: 0.0,
      );
    });
    _animationController[goToIndex].addListener(() => setState(() {}));
    TickerFuture tickerFuture = _animationController[goToIndex].repeat();
    tickerFuture.timeout(Duration(seconds: 3), onTimeout: () {
      _animationController[goToIndex].forward(from: 1);
      _animationController[goToIndex].stop(canceled: true);
    });

    chatLoad = false;
    setState(() {});
  }

  void replyToComment(var index) {
    FocusScope.of(context).requestFocus(keyboardOne);
    setState(() {
      requestForReply = true;
      selectedMsg = chatList[index];
      //selectedItem(chatList[index]);
    });
  }

  gotoSearchResult(var result) {
    int searchMsgIndex = -1;
    for (int i = 0; i < allComments.length; i++) {
      if (result == allComments[i].id) searchMsgIndex = i;
    }
    if (searchMsgIndex != -1) {
      itemScrollController.scrollTo(
          index: searchMsgIndex,
          alignment: 0.0,
          duration: Duration(microseconds: 50),
          curve: Curves.bounceInOut);
      _animationController[searchMsgIndex].addListener(() => setState(() {}));
      TickerFuture tickerFuture = _animationController[searchMsgIndex].repeat();
      tickerFuture.timeout(Duration(seconds: 4), onTimeout: () {
        _animationController[searchMsgIndex].forward(from: 1);
        _animationController[searchMsgIndex].stop(canceled: true);
      });
    }
  }

  var caseDetails;
  bool isLoading = false;
  late int updateCount, watchCount, commentCount, reportCount;

  Future<void> getIncidentFullView(var id) async {
    print(id);
    var fullCaseDetail;

    showLoading(context);
    Position currentLocation;
    currentLocation = await Geolocator.getCurrentPosition();

    CustomResponse response = await ApiCall.makeGetRequestToken(
        'incident/getbyidentifier?caseidentifier=${id.toUpperCase()}&lat=${currentLocation.latitude}&lon=${currentLocation.longitude}');
    print(json.decode(response.body));
    if (response.status == 200) {
      if (json.decode(response.body)["status"]) {
        fullCaseDetail = json.decode(response.body)["data"];
        updateCount = fullCaseDetail["updates"].length;
        watchCount = fullCaseDetail["watchcount"];
        commentCount = fullCaseDetail["commentcount"];
        reportCount = fullCaseDetail["reportcount"];
        if (fullCaseDetail["updates"].isEmpty)
          caseDetails = fullCaseDetail;
        else
          caseDetails =
              fullCaseDetail["updates"][fullCaseDetail["updates"].length];
        Navigator.pop(context);
        showPostFeedbackDialog(context);
      } else
        CommonWidgets.alertBox(context, json.decode(response.body)["msg"],
            leaveThatPage: true);
    } else if (response.status == 403) {
      CommonWidgets.loginLimit(context);
    } else
      isLoading = false;
    if (mounted) setState(() {});
  }

  Future<void> showLoading(BuildContext context) async {
    return showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return WillPopScope(
              onWillPop: () async => false,
              child: Center(
                child: Container(
                    height: 80,
                    width: 80,
                    color: Colors.white,
                    child: Center(
                      child: SizedBox(
                          height: 40,
                          width: 40,
                          child: CircularProgressIndicator()),
                    )),
              ));
        });
  }

  Future<void> showPostFeedbackDialog(BuildContext context) async {
    return showDialog<void>(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return WillPopScope(
              onWillPop: () async => true,
              child: Dialog(
                  backgroundColor: Colors.white,
                  child: Container(
                      width: double.infinity,
                      child: ListView(
                        children: [
                          Container(
                            height: 200,
                            width: double.infinity,
                            child: Stack(
                              children: [
                                Swiper(
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    final photo = caseDetails["photos"][index]
                                            ["photo"]
                                        .toString();
                                    final imageUrl = ApiCall.imageUrl + photo;

                                    return CachedNetworkImage(
                                      imageUrl: imageUrl,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) => Center(
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          backgroundColor: Colors.white54,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                  Colors.green),
                                        ),
                                      ),
                                      errorWidget: (context, url, error) =>
                                          Icon(Icons.error),
                                    );
                                  },
                                  itemCount: caseDetails["photos"]?.length ?? 0,
                                  pagination: SwiperPagination(
                                    builder: caseDetails["photos"]?.length > 1
                                        ? SwiperPagination.dots
                                        : SwiperPagination.fraction,
                                  ),
                                  loop: false,
                                  autoplay: false,
                                  control: SwiperControl(),
                                  viewportFraction: 1.0,
                                  scale: 1.0,
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    children: [
                                      updateCount != 0
                                          ? Container(
                                              padding: EdgeInsets.all(4),
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(5.0)),
                                                color: Colors.black45,
                                              ),
                                              child: Text(
                                                updateCount == 1
                                                    ? "1 Update"
                                                    : "$updateCount Updates",
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 12),
                                              ),
                                            )
                                          : SizedBox.shrink(),
                                      SizedBox(
                                        width: updateCount == null ? 0 : 8.0,
                                      ),
                                      watchCount == 0
                                          ? SizedBox.shrink()
                                          : Container(
                                              padding: EdgeInsets.all(4),
                                              decoration: BoxDecoration(
                                                color: Colors.black45,
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(5.0)),
                                              ),
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
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
                                                    watchCount.toString(),
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 12),
                                                  ),
                                                ],
                                              ),
                                            ),
                                      SizedBox(
                                        width: watchCount == 0 ? 0 : 8.0,
                                      ),
                                      commentCount == 0
                                          ? SizedBox.shrink()
                                          : Container(
                                              padding: EdgeInsets.all(4),
                                              decoration: BoxDecoration(
                                                color: Colors.black45,
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(5.0)),
                                              ),
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
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
                                                    commentCount.toString(),
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 12),
                                                  ),
                                                ],
                                              ),
                                            ),
                                      Spacer(),
                                      reportCount == 0 || reportCount == null
                                          ? SizedBox.shrink()
                                          : Container(
                                              padding: EdgeInsets.all(4),
                                              decoration: BoxDecoration(
                                                color: Colors.deepOrange
                                                    .withOpacity(0.7),
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(5.0)),
                                              ),
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
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
                                                        reportCount.toString(),
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 12),
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
                          SizedBox(
                            height: 8.0,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      flex: 1,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Text("Posted by:",
                                              style: TextStyle(
                                                fontSize: 11,
                                              )),
                                          Text(
                                            caseDetails["isanonymous"]
                                                ? caseDetails[
                                                        "anonymousname"] ??
                                                    "Anonymous"
                                                : caseDetails["addedby"]
                                                            ["name"] ==
                                                        null
                                                    ? " "
                                                    : caseDetails["addedby"]
                                                        ["name"],
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 11,
                                                fontWeight: FontWeight.w800),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      flex: 0,
                                      child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: <Widget>[
                                                SizedBox(
                                                  width: 5,
                                                ),
                                                Container(
                                                  decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      border: Border.all(
                                                          color:
                                                              Colors.black45),
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  5))),
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 4),
                                                  child: Text(
                                                    "${caseDetails["beencut"] + caseDetails["mightbecut"] + caseDetails["havebeencut"]}",
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w600),
                                                  ),
                                                ),
                                                SizedBox(
                                                  width:
                                                      caseDetails["beencut"] ==
                                                              0
                                                          ? 0
                                                          : 8,
                                                ),
                                                caseDetails["beencut"] == 0
                                                    ? SizedBox.shrink()
                                                    : Container(
                                                        decoration: BoxDecoration(
                                                            color: Colors.red,
                                                            border: Border.all(
                                                                color:
                                                                    Colors.red),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .all(Radius
                                                                        .circular(
                                                                            5))),
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                horizontal: 8,
                                                                vertical: 4),
                                                        child: Text(
                                                          caseDetails["beencut"]
                                                                  .toString() ??
                                                              "",
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: TextStyle(
                                                              fontSize: 14,
                                                              color:
                                                                  Colors.white,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600),
                                                        )),
                                                SizedBox(
                                                  width: caseDetails[
                                                              "mightbecut"] ==
                                                          0
                                                      ? 0
                                                      : 8,
                                                ),
                                                caseDetails["mightbecut"] == 0
                                                    ? SizedBox.shrink()
                                                    : Container(
                                                        decoration: BoxDecoration(
                                                            color:
                                                                Colors.orange,
                                                            border: Border.all(
                                                                color: Colors
                                                                    .orange),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .all(Radius
                                                                        .circular(
                                                                            5))),
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                horizontal: 8,
                                                                vertical: 4),
                                                        child: Text(
                                                          caseDetails["mightbecut"]
                                                                  .toString() ??
                                                              "",
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: TextStyle(
                                                              fontSize: 14,
                                                              color:
                                                                  Colors.white,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600),
                                                        ),
                                                      ),
                                                SizedBox(
                                                  width: caseDetails[
                                                              "havebeencut"] ==
                                                          0
                                                      ? 0
                                                      : 8,
                                                ),
                                                caseDetails["havebeencut"] == 0
                                                    ? SizedBox.shrink()
                                                    : Container(
                                                        decoration: BoxDecoration(
                                                            color: Colors.grey,
                                                            border: Border.all(
                                                                color: Colors
                                                                    .grey),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .all(Radius
                                                                        .circular(
                                                                            5))),
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                horizontal: 8,
                                                                vertical: 4),
                                                        child: Text(
                                                          caseDetails["havebeencut"]
                                                                  .toString() ??
                                                              "",
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: TextStyle(
                                                              fontSize: 14,
                                                              color:
                                                                  Colors.white,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600),
                                                        ),
                                                      ),
                                              ],
                                            ),
                                            SizedBox(
                                              height: 8.0,
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                Text(
                                                  "500" + " km, ",
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 11),
                                                ),
                                                Text(
                                                  CommonFunction.timeWithStatus(
                                                      caseDetails[
                                                          "createddate"]),
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 11),
                                                ),
                                              ],
                                            ),
                                          ]),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 10.0,
                                ),
                                Text(caseDetails["locationname"] ?? " ",
                                    style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14),
                                    textAlign: TextAlign.left),
                                SizedBox(
                                  height: 8.0,
                                ),
                                Container(
                                  padding: EdgeInsets.all(5.0),
                                  color: Colors.transparent.withOpacity(0.1),
                                  width: double.infinity,
                                  child: Text(
                                    "Click on the pin to see navigation options",
                                    style: TextStyle(
                                        color: Colors.black, fontSize: 11),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                Container(
                                  height: 230,
                                  child: GoogleMap(
                                    mapType: MapType.normal,
                                    zoomGesturesEnabled: true,
                                    tiltGesturesEnabled: false,
                                    scrollGesturesEnabled: true,
                                    gestureRecognizers:
                                        <Factory<OneSequenceGestureRecognizer>>[
                                      new Factory<OneSequenceGestureRecognizer>(
                                        () => new ScaleGestureRecognizer(),
                                      ),
                                    ].toSet(),
                                    initialCameraPosition: CameraPosition(
                                      target: LatLng(caseDetails["location"][1],
                                          caseDetails["location"][0]),
                                      zoom: 15.77,
                                    ),
                                    markers: <Marker>{
                                      Marker(
                                          position: LatLng(
                                              caseDetails["location"][1],
                                              caseDetails["location"][0]),
                                          markerId:
                                              MarkerId("selected-location"),
                                          // icon: BitmapDescriptor.fromBytes(markerIcon),
                                          onTap: () {
                                            CommonFunction.openMap(
                                                caseDetails["location"][1],
                                                caseDetails["location"][0]);
                                          })
                                    },
                                  ),
                                ),
                                SizedBox(
                                  height: 8.00,
                                ),
                                caseDetails["description"] != null
                                    ? Container(
                                        child: ReadMoreText(
                                          widget.caseDetails["description"] ??
                                              "",
                                          trimLines: 2,
                                          colorClickableText: Colors.teal,
                                          trimMode: TrimMode.Line,
                                          trimCollapsedText: ' ...  show more',
                                          trimExpandedText: '   show less',
                                          textAlign: TextAlign.justify,
                                          style: TextStyle(color: Colors.black),
                                          key: Key('readMoreText'),
                                          textDirection: TextDirection.ltr,
                                          locale: Locale('en'),
                                          textScaleFactor: 1.0,
                                          semanticsLabel: 'Read more text',
                                        ),
                                      )
                                    : SizedBox.shrink(),
                                caseDetails["description"] != null
                                    ? Divider(
                                        thickness: 1.0,
                                        height: 20,
                                      )
                                    : SizedBox.shrink(),
                                SizedBox(
                                  height: 8.0,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    TextButton(
                                      // minWidth: 20,
                                      onPressed: () async {
                                        var link = await CommonFunction
                                            .createDynamicLink(
                                                caseId: caseDetails["_id"],
                                                description:
                                                    caseDetails["locationname"],
                                                title:
                                                    "Case ID: ${caseDetails["caseidentifier"] == null ? caseDetails["caseid"].toString() : caseDetails["caseidentifier"].toString()}",
                                                image: caseDetails["photos"][0]
                                                    ["photo"]);
                                        if (link != null)
                                          _onShareTap(link, caseDetails);
                                      },
                                      child: Row(
                                        children: [
                                          Text("Share "),
                                          Icon(Icons.share_sharp),
                                        ],
                                      ),
                                      // textColor: Colors.white,
                                      // color: Colors.teal,
                                    ),
                                    SizedBox(
                                      width: 8.0,
                                    ),
                                    TextButton(
                                        onPressed: () => {
                                              Navigator.pop(context),
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          CaseViewInDiscussion(
                                                            caseDetails["_id"],
                                                            isSearch: false,
                                                          )))
                                            },
                                        // minWidth: 50,
                                        // textColor: Colors.white,
                                        // color: Colors.teal,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text("Details "),
                                            Icon(
                                              Icons.arrow_forward,
                                              color: Colors.white,
                                            ),
                                          ],
                                        ))
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ))));
        });
  }

  Future<void> _onShareTap(String linkMessage, Map<String, dynamic> caseDetail) async {
    try {
      // Calculate tree count with null safety
      final treeCount = (caseDetail["mightbecut"] ?? 0) +
          (caseDetail["beencut"] ?? 0) +
          (caseDetail["havebeencut"] ?? 0);

      // Build share text with string buffer for better performance
      final shareText = StringBuffer()
        ..write("Check out this case about $treeCount ")
        ..write(treeCount > 1 ? "trees" : "tree")
        ..write(" at ${caseDetail["locationname"] ?? "a location"}, ")
        ..write("using Save Trees app. (Case ID: ")
        ..write(caseDetail["caseidentifier"] ?? caseDetail["caseid"] ?? "N/A")
        ..write(")");

      // Get render box with proper null checking
      final box = context.findRenderObject() as RenderBox?;
      if (box == null) {
        debugPrint('Could not get render box for share position');
        await Share.share('$shareText\n$linkMessage');
        return;
      }

      // Calculate share position origin
      final sharePosition = box.localToGlobal(Offset.zero) & box.size;

      await Share.share(
        '$shareText\n$linkMessage',
        sharePositionOrigin: sharePosition,
      );
    } catch (e) {
      debugPrint('Error sharing content: $e');
      // Fallback sharing without position if error occurs
      await Share.share(linkMessage);
    }
  }
}

// ---------Message Model---------
class ChatModel {
  String id;
  final anonymous;
  final anonymousName;
  final messageType;
  final media;
  final hash;
  final refer;
  String text;
  var user;
  var relatedUser;
  var replyTo;
  var createTime;
  bool isUpVoted;
  int upVoteCount;
  int downVoteCount;
  bool isDownVoted;
  bool selected;

  setter(selected) {
    this.selected = selected;
  }

  ChatModel(
      this.id,
      this.anonymous,
      this.anonymousName,
      this.messageType,
      this.media,
      this.hash,
      this.refer,
      this.text,
      this.user,
      this.replyTo,
      this.createTime,
      this.isUpVoted,
      this.upVoteCount,
      this.downVoteCount,
      this.isDownVoted,
      this.selected,
      {this.relatedUser});
}

//---------- Customized PopUp Menu--------------------

//----------Horizontal PopUp Menu ----------
typedef void IntCallback(var id);

class ReactionMenu extends PopupMenuEntry<int> {
  @override
  final double height = 25;
  final index;
  final Function() notifyParent;
  final IntCallback gotoComment;
  final IntCallback replySelfComment;
  final bool isTopComment;
  final bool selfReply;

  ReactionMenu(
      {required Key key,
      this.index,
      required this.notifyParent,
      required this.isTopComment,
      required this.gotoComment,
      required this.replySelfComment,
      required this.selfReply})
      : super(key: key);

  @override
  bool represents(int? n) => n == 1 || n == -1;

  @override
  _ReactionMenu createState() => _ReactionMenu();
}

class _ReactionMenu extends State<ReactionMenu> {
  Future<void> upVote(var msgId, bool upVoteStatus) async {
    Map data = {
      "id": msgId,
      "status": upVoteStatus != null
          ? upVoteStatus
              ? false
              : true
          : true,
    };
    CustomResponse response = await ApiCall.makePostRequestToken(
        "discussion/upvote",
        paramsData: data);
    if (response.status == 200) if (json.decode(response.body)["status"]) {
      chatList[widget.index].isUpVoted = upVoteStatus != null
          ? upVoteStatus
              ? false
              : true
          : true;
      chatList[widget.index].upVoteCount = upVoteStatus != null
          ? upVoteStatus
              ? chatList[widget.index].upVoteCount - 1
              : chatList[widget.index].upVoteCount + 1
          : 1;
    } else
      Fluttertoast.showToast(msg: "Failed to post your reaction");
    else
      Fluttertoast.showToast(msg: "Something went wrong");
  }

  Future<void> downVote(
    var msgId,
    bool downVoteStatus,
  ) async {
    Map data = {
      "id": msgId,
      "status": downVoteStatus != null
          ? downVoteStatus
              ? false
              : true
          : true,
    };
    CustomResponse response = await ApiCall.makePostRequestToken(
        "discussion/downvote",
        paramsData: data);
    if (response.status == 200) if (json.decode(response.body)["status"]) {
      chatList[widget.index].isDownVoted = downVoteStatus != null
          ? downVoteStatus
              ? false
              : true
          : true;
      chatList[widget.index].downVoteCount = downVoteStatus != null
          ? downVoteStatus
              ? chatList[widget.index].downVoteCount - 1
              : chatList[widget.index].downVoteCount + 1
          : 1;
    } else
      Fluttertoast.showToast(msg: "Failed to post your Reaction!");
    else
      Fluttertoast.showToast(msg: "Something went wrong");
  }

  Future<void> _likeReaction() async {
    if (chatList[widget.index].isDownVoted != null &&
        chatList[widget.index].isDownVoted) {
      await downVote(
          chatList[widget.index].id, chatList[widget.index].isDownVoted);
      await upVote(chatList[widget.index].id, chatList[widget.index].isUpVoted);
    } else
      await upVote(chatList[widget.index].id, chatList[widget.index].isUpVoted);
    CommonFunction.player
        .play(CommonFunction.messageReply as Source, volume: 0.1);
    await widget.notifyParent();
    Navigator.pop<int>(context, 1);
  }

  Future<void> _angryReaction() async {
    if (chatList[widget.index].isUpVoted != null &&
        chatList[widget.index].isUpVoted) {
      await upVote(chatList[widget.index].id, chatList[widget.index].isUpVoted);
      await downVote(
          chatList[widget.index].id, chatList[widget.index].isDownVoted);
    } else
      await downVote(
          chatList[widget.index].id, chatList[widget.index].isDownVoted);
    CommonFunction.player
        .play(CommonFunction.messageReply as Source, volume: 0.1);
    await widget.notifyParent();
    Navigator.pop<int>(context, -1);
  }

  void _reply() async {
    widget.replySelfComment(widget.index);
    Navigator.pop<int>(context, -1);
  }

  Future<void> _goToComment() async {
    widget.gotoComment(chatList[widget.index].id);
    Navigator.pop<int>(context, -1);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
            flex: 0,
            child: TextButton(
                onPressed: _likeReaction,
                child: Icon(
                  Icons.thumb_up_alt_sharp,
                  size: 20,
                  color: Colors.blueAccent,
                ))),
        Expanded(
            flex: 0,
            child: TextButton(
                onPressed: _angryReaction,
                child: Icon(
                  Icons.sentiment_dissatisfied,
                  size: 20,
                  color: Colors.red,
                ))),
        !widget.selfReply
            ? SizedBox.shrink()
            : Expanded(
                flex: 0,
                child: TextButton(
                    onPressed: _reply,
                    child: Icon(
                      Icons.reply,
                      size: 20,
                    ))),
        !widget.isTopComment
            ? SizedBox.shrink()
            : Expanded(
                flex: 1,
                child: TextButton(
                    onPressed: _goToComment,
                    child: Text(
                      "Goto this in all Comments",
                      style: TextStyle(fontSize: 11),
                    ))),
      ],
    );
  }
}

// -----Vertical PopUp Menu -------
class MenuOptions extends PopupMenuEntry<int> {
  @override
  final double height = 100;
  final index;
  final Function() notifyParent;
  final IntCallback replyToComment;

  MenuOptions(
      {this.index, required this.notifyParent, required this.replyToComment});

  @override
  bool represents(int? n) => n == 1 || n == -1;

  @override
  _MenuOptions createState() => _MenuOptions();
}

class _MenuOptions extends State<MenuOptions> {
  //Passing Server
  Future<void> upVote(var msgId, bool upVoteStatus) async {
    Map data = {
      "id": msgId,
      "status": upVoteStatus != null
          ? upVoteStatus
              ? false
              : true
          : true,
    };
    CustomResponse response = await ApiCall.makePostRequestToken(
        "discussion/upvote",
        paramsData: data);
    print(json.decode(response.body));
    if (response.status == 200) if (json.decode(response.body)["status"]) {
      chatList[widget.index].isUpVoted = upVoteStatus != null
          ? upVoteStatus
              ? false
              : true
          : true;
      chatList[widget.index].upVoteCount = upVoteStatus != null
          ? upVoteStatus
              ? chatList[widget.index].upVoteCount - 1
              : chatList[widget.index].upVoteCount + 1
          : 1;
    } else
      Fluttertoast.showToast(msg: json.decode(response.body)["msg"]);
    else
      Fluttertoast.showToast(msg: "Something went wrong");
  }

  Future<void> downVote(
    var msgId,
    bool downVoteStatus,
  ) async {
    Map data = {
      "id": msgId,
      "status": downVoteStatus != null
          ? downVoteStatus
              ? false
              : true
          : true,
    };
    CustomResponse response = await ApiCall.makePostRequestToken(
        "discussion/downvote",
        paramsData: data);
    if (response.status == 200) if (json.decode(response.body)["status"]) {
      chatList[widget.index].isDownVoted = downVoteStatus != null
          ? downVoteStatus
              ? false
              : true
          : true;
      chatList[widget.index].downVoteCount = downVoteStatus != null
          ? downVoteStatus
              ? chatList[widget.index].downVoteCount - 1
              : chatList[widget.index].downVoteCount + 1
          : 1;
    } else
      Fluttertoast.showToast(msg: "Failed to post your Reaction!");
    else
      Fluttertoast.showToast(msg: "Something went wrong");
  }

  Future<void> reportMessage(var msgId) async {
    Map data = {
      "id": msgId,
      "comment": "",
    };
    CustomResponse response = await ApiCall.makePostRequestToken(
        "discussion/report",
        paramsData: data);
    if (response.status == 200) if (json.decode(response.body)["status"])
      Fluttertoast.showToast(msg: "Comment has been reported!");
    else
      Fluttertoast.showToast(msg: json.decode(response.body)["msg"]);
    else
      Fluttertoast.showToast(msg: "Could not connect to server. Try again");
  }

  void _likeReaction() async {
    if (chatList[widget.index].isDownVoted != null &&
        chatList[widget.index].isDownVoted) {
      await downVote(
          chatList[widget.index].id, chatList[widget.index].isDownVoted);
      await upVote(chatList[widget.index].id, chatList[widget.index].isUpVoted);
    } else
      await upVote(chatList[widget.index].id, chatList[widget.index].isUpVoted);
    CommonFunction.player
        .play(CommonFunction.messageReply as Source, volume: 0.1);
    await widget.notifyParent();

    Navigator.pop<int>(context, 1);
  }

  void _angryReaction() async {
    if (chatList[widget.index].isUpVoted != null &&
        chatList[widget.index].isUpVoted) {
      await upVote(chatList[widget.index].id, chatList[widget.index].isUpVoted);
      await downVote(
          chatList[widget.index].id, chatList[widget.index].isDownVoted);
    } else
      await downVote(
          chatList[widget.index].id, chatList[widget.index].isDownVoted);
    CommonFunction.player
        .play(CommonFunction.messageReply as Source, volume: 0.1);
    await widget.notifyParent();
    Navigator.pop<int>(context, -1);
  }

  void _reply() {
    widget.replyToComment(widget.index);
    Navigator.pop<int>(context, -1);
  }

  void _copy() async {
    Clipboard.setData(ClipboardData(text: chatList[widget.index].text));
    Fluttertoast.showToast(msg: "Text copied!");
    Navigator.pop<int>(context, -1);
  }

  void _forward() {
    Navigator.pop<int>(context, -1);
  }

  void _report() {
    reportMessage(chatList[widget.index].id);
    Navigator.pop<int>(context, -1);
  }

  @override
  Widget build(BuildContext context) {
    double iconSize = 20;
    double fontSize = 12.0;
    return Row(
      children: [
        Expanded(
          // flex:0,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextButton.icon(
                onPressed: _likeReaction,
                icon: Icon(
                  Icons.thumb_up_alt_sharp,
                  size: iconSize,
                  color: Colors.blueAccent,
                ),
                label: Text(
                  "Like",
                  style: TextStyle(fontSize: fontSize),
                ),
              ),
              TextButton.icon(
                onPressed: _angryReaction,
                icon: Icon(
                  Icons.sentiment_dissatisfied,
                  size: iconSize,
                  color: Colors.red,
                ),
                label: Text("Angry Reaction",
                    style: TextStyle(fontSize: fontSize)),
              ),
              TextButton.icon(
                onPressed: _reply,
                icon: Icon(
                  Icons.reply,
                  size: iconSize,
                ),
                label: Text("Reply", style: TextStyle(fontSize: fontSize)),
              ),
              TextButton.icon(
                onPressed: _copy,
                icon: Icon(
                  Icons.copy_sharp,
                  size: iconSize,
                ),
                label: Text("Copy", style: TextStyle(fontSize: fontSize)),
              ),
              TextButton.icon(
                onPressed: _forward,
                icon: Icon(
                  Icons.forward,
                  size: iconSize,
                ),
                label: Text("Forward", style: TextStyle(fontSize: fontSize)),
              ),
              TextButton.icon(
                onPressed: _report,
                icon: Icon(
                  Icons.report,
                  size: iconSize,
                  color: Colors.red,
                ),
                label: Text("Report", style: TextStyle(fontSize: fontSize)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
