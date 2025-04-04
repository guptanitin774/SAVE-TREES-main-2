


import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:naturesociety_new/SettingsScreen/EditProfile.dart';
import 'package:naturesociety_new/Utils/LocalPrefManager.dart';
import 'package:naturesociety_new/Utils/MaterialComponets.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Anonymity extends StatefulWidget{
  _Anonymity createState()=> _Anonymity();

}

class _Anonymity extends State <Anonymity>{

  late String _radioValue; //Initial definition of radio button value
  late String choice;
@override
void initState()
{
  super.initState();
  getUserDetails();
  getUserList();

}
var userName;
var userData;
Future<void> getUserDetails() async{

  userData = await LocalPrefManager.getUserName();
}

Future<void>getUserList() async{
  userName = await LocalPrefManager.getUserName();
  if(userName == '') {
    setState(() {
      _radioValue = "anonymous";
    });
    SharedPreferences preference = await SharedPreferences.getInstance();
    preference.setBool("anonymous",true);
  }
   else
     {
       bool? isAnonymous = await LocalPrefManager.getAnonymity();
       setState(() {
         _radioValue = isAnonymous ?? false ? "anonymous" : "name";
       });
     }


}

  void radioButtonChanges(String value) async{
    SharedPreferences preference = await SharedPreferences.getInstance();
    setState(() {
      _radioValue = value;
      switch (value) {
        case 'anonymous':
          choice = value;
          preference.setBool("anonymous",true);
          break;
        case 'name':
          choice = value;
          preference.setBool("anonymous",false);
          break;
        default:
          choice = 'anonymous';
          preference.setBool("anonymous",true);
      }
     // debugPrint(choice); //Debug the choice in console
    });
  }
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
          backgroundColor: Colors.white,
          automaticallyImplyLeading: true,

          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: ()=>onWillPopScope(),
          ),
          iconTheme: IconThemeData(color: Colors.black),
          centerTitle: false,
          title: Text("Anonymity",style: TextStyle(color: Colors.teal, fontWeight: FontWeight.w800),),
        ),

        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
            child:  userName == '' || userName ==null ? noUserText(context) : anonymousSettings(context)
          ),
        ),
      ),
    );
  }

  Widget anonymousSettings(BuildContext context) {
  return AnimationLimiter(
    child: Column(
      children: AnimationConfiguration.toStaggeredList(
        duration: const Duration(milliseconds: 375),
        childAnimationBuilder: (widget) => SlideAnimation(
          horizontalOffset: 50.0,
          child: ScaleAnimation(
            child: widget,
          ),
        ),
        children: [

          Text("While posting / updating / commenting on cases, I want to:",style: TextStyle(fontWeight: FontWeight.w700),),

          Row(
            children: <Widget>[
              Radio(
                value: 'anonymous',
                groupValue: _radioValue,
                onChanged: (value) => value != null ? radioButtonChanges(value) : null,
              ),
              Expanded(
                flex: 2,
                child: GestureDetector(
                  onTap: ()=> radioButtonChanges('anonymous'),
                  child: Text(
                    "be Anonymous", maxLines: 3,overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 10.0,),
          userName != '' ?  Row(
            children: <Widget>[
              Radio(
                value: 'name',
                groupValue: _radioValue,
                onChanged: (value) => value != null ? radioButtonChanges(value) : null,
              ),
              Expanded(
                flex: 2,
                child: GestureDetector(
                  onTap: ()=> radioButtonChanges('name'),
                  child: Text(
                    "use my Username\n(ie. $userName) ", maxLines: 3, overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ): SizedBox.shrink(),

          SizedBox(height: 15.0,),
          Container(
            padding: EdgeInsets.all(8.0),
            decoration: BoxDecoration(
                border: Border.all(color:MaterialTools.borderColor, width: MaterialTools.borderWidth)
            ),
            child: _radioValue == "anonymous" ? Text("This is just a default setting, you will have the option to use your name while posting / updating case.",
              style:  TextStyle(fontWeight: FontWeight.w700, fontSize: 12),):
            Text("This is just a default setting, you will have the option to be anonymous while posting / updating case.",
              style:  TextStyle(fontWeight: FontWeight.w700, fontSize: 12),),
          ),


        ],
      ),

    ),
  );
  }


  Widget noUserText(BuildContext context) {
  return Column(
    children: [
      RichText(
        text: TextSpan(
            text:  "Since you have not provided your name, you will be shown as ",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal, fontSize: 16),
            children: <TextSpan>[
              TextSpan(text: "Anonymous ",
                style: TextStyle(color: Colors.black,  fontWeight: FontWeight.w800, fontSize: 16),
              ),
              TextSpan(text: "while posting / updating / commenting on cases. ",
                style: TextStyle(color: Colors.black,  fontWeight: FontWeight.normal, fontSize: 16),
              ),
            ]
        ),textAlign: TextAlign.left,
      ),

      SizedBox(height: 15.0,),

      RichText(
        text: TextSpan(
            text:  "Please add you name in the ",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal, fontSize: 16),
            children: <TextSpan>[
              TextSpan(text: "User Details and Activity ",
                style: TextStyle(color: Colors.black,  fontWeight: FontWeight.w800, fontSize: 16),
                recognizer: TapGestureRecognizer()
                  ..onTap = () async{
                  bool needRefresh = await Navigator.push(context, MaterialPageRoute(builder: (context)=> ViewProfile(key: UniqueKey())));
                  if(needRefresh)
                   { getUserDetails();
                  getUserList();}
                  else{}
                  },
              ),

              TextSpan(text: "page if you wish to use your name.",
                style: TextStyle(color: Colors.black,  fontWeight: FontWeight.normal, fontSize: 16),
              ),
            ]
        ),textAlign: TextAlign.left,

      ),
    ],
  );
  }
}