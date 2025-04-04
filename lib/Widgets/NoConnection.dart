import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NoConnection extends StatefulWidget{
  final Future<void> Function() notifyParent;
  NoConnection({Key key, @required this.notifyParent}) : super(key: key);
  @override
  _NoConnection createState() => _NoConnection();

}

class _NoConnection extends State<NoConnection>{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Image(
                  image: AssetImage("assets/noconnection.png"),
                ),
                Text(
                  "Opps !",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 32.0),
                ),
                SizedBox(
                  height: 10,
                ),
                Text("Failed to establish connection"),
                SizedBox(
                  height: 10,
                ),
                Text("Please Connect to WiFi or  Mobile Data"),
                SizedBox(
                  height: 25.0,
                ),

                FloatingActionButton.extended(onPressed: ()=> widget.notifyParent(),
                  heroTag: "No Connection",
                  label: Text("Refresh"),
                  icon: Icon(Icons.refresh),
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.teal,
                  splashColor: Colors.transparent,),

                SizedBox(height: 10.0,),

                SizedBox(
                  height: 10,
                ),
                Text("You can still post cases in Offline - Mode", style: TextStyle(fontWeight: FontWeight.w600),),

                SizedBox(height: 10.0,),

                Expanded(
                  flex: 0,
                  child: Text("The Cases will be Uploaded only when you are connected to a Network", style: TextStyle(fontSize: 11.5), maxLines: 2,
                    overflow: TextOverflow.ellipsis, textAlign: TextAlign.center,),
                ),

                SizedBox(height: 10.0,),

              ],
            ),
          ),
        ),
      ),
    );
  }


}