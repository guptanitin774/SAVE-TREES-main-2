
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:naturesociety_new/Utils/MaterialComponets.dart';
import 'package:naturesociety_new/Utils/NetworkCall.dart';
import 'package:naturesociety_new/Widgets/CommonFunction.dart';

class UsersProfile extends StatefulWidget{
  final userDetails;
  UsersProfile({@required this.userDetails});
  _UsersProfile createState()=> _UsersProfile();
}

class _UsersProfile extends State<UsersProfile>{

  @override
  void initState(){
    super.initState();
  }
  bool loader = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.userDetails["name"] ?? "Anonymous"),

      ),

      body: SafeArea(
        child: loader? Center(child: CircularProgressIndicator(),): mainScreen(context),
      ),
    );
  }
  final mainHeadingStyle = TextStyle(color: Colors.teal, fontWeight: FontWeight.bold, fontSize: 16);
  final subHeadingStyle = TextStyle(color: Colors.grey, fontSize: 12.0, fontWeight: FontWeight.w600);
  final normalTextStyle = TextStyle(color: Colors.black, fontWeight: FontWeight.w600);
  final countTextStyle = TextStyle(color: Colors.grey,fontSize: 23.0 ,fontWeight: FontWeight.w600);
  Widget mainScreen(BuildContext context){
    return SingleChildScrollView(
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
            children: [
              Container(
                padding: EdgeInsets.all(15.0),
                color: Colors.grey.withOpacity(.2),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[

                    Text("User Details", style: mainHeadingStyle,),

                  ],
                ),
              ),

              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    CircleAvatar(
                      backgroundColor: Colors.teal,
                      radius: 90.0,
                      backgroundImage:  widget.userDetails["photo"]==null ?
                      NetworkImage("https://image.flaticon.com/icons/png/512/21/21104.png"):
                      NetworkImage(ApiCall.imageUrl + widget.userDetails["photo"]),
                    ),
                    SizedBox(height: 10.0,),

                    Text(widget.userDetails["name"],style: normalTextStyle, textAlign: TextAlign.center,),

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
                            child: Text(widget.userDetails["userid"]?? ' ', style: normalTextStyle, maxLines: 2,overflow: TextOverflow.ellipsis,)),
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
                            child: Text(widget.userDetails["phonePrefix"]+" "+ widget.userDetails["phone"], style: normalTextStyle,maxLines: 2,overflow: TextOverflow.ellipsis,)),
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
                            child: Text(widget.userDetails["gender"]?? "not provided", style: normalTextStyle,maxLines: 2, overflow: TextOverflow.ellipsis,)),
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
                            child: widget.userDetails["dob"] == null ? Text(" ") : Text(CommonFunction.dateFormatter.format(DateTime.parse(widget.userDetails["dob"].toString())),  style: normalTextStyle,maxLines: 2,overflow: TextOverflow.ellipsis,)),
                      ],
                    ),
                  ),
                ],
              ),

              Container(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: <Widget>[
                    FittedBox(
                        fit: BoxFit.cover,
                        child: Text("OCCUPATION", style: subHeadingStyle,)),
                    FittedBox(
                        fit: BoxFit.cover,
                        child: Text(widget.userDetails["occupation"] ??"not provided", style: normalTextStyle,)),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.place_outlined, color: MaterialTools.basicColor,),
                    SizedBox(width: 10.0,),
                    Text("${widget.userDetails["city"]??""}${widget.userDetails["city"] ==null ? "": " city of "}"
                        "${widget.userDetails["state"]?? ""}${widget.userDetails["state"] == null ? "": " state in "}"
                        "${widget.userDetails["country"]}",
                      style: normalTextStyle,)
                  ],
                ),
              ),




              Container(
                color: Colors.grey.withOpacity(.2),
                padding: EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text("Contributions", style: mainHeadingStyle,textAlign: TextAlign.center),
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
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Text("Cases Posted", textAlign: TextAlign.center, style: subHeadingStyle,),
                        Text("0", style: countTextStyle,),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(12.0),
                    width: MediaQuery.of(context).size.width / 3,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Text("Cases Commented", textAlign: TextAlign.center, style: subHeadingStyle,),
                        Text("0",  style: countTextStyle,),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(12.0),
                    width: MediaQuery.of(context).size.width / 3,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Text("Cases Updated", textAlign: TextAlign.center, style: subHeadingStyle,),
                        Text("0", style: countTextStyle,),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),

        ),
      ),
    );
  }

  @override
  void dispose(){
    super.dispose();
  }
}