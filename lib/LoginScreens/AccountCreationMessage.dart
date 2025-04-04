
import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:naturesociety_new/LoginScreens/NewProfile.dart';

class AccountMessage extends StatefulWidget{
  final idUser, phoneNumber, country, state, city;
  AccountMessage({this.idUser, this.phoneNumber, this.country, this.state, this.city});
  _AccountMessage createState()=> _AccountMessage();
}

class _AccountMessage extends State<AccountMessage>{

  @override
  void initState(){
    super.initState();
    startTime();
  }

  startTime() async {
    var _duration = new Duration(seconds: 2);
    return new Timer(_duration, navigateFromSplash);
  }
  Future navigateFromSplash () async {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => NewProfile(widget.idUser, widget.phoneNumber, widget.country,
    widget.state, widget.city)));

  }

  Future<bool> _onWillPop() async{
    return Future.value(false);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              CircleAvatar(
                radius: 50,
                child: Icon(Icons.done, color: Colors.white, size: 60,),
              ),
              SizedBox(height: 20,),
              Text("Congratulations!", style: TextStyle(color: Colors.teal, fontWeight: FontWeight.w900, fontSize: 18),),
              SizedBox(height: 10.0,),
              Text("Your account has been created.", style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal, fontSize: 14 ),),
            ],
          ),
        ),
      ),
    );
  }

}