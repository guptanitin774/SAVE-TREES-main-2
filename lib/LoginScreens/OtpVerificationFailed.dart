
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:naturesociety_new/LoginScreens/LoginSignUpWithOnBoarding.dart';

class OtpVerificationFailed extends StatefulWidget{
  final number;
  OtpVerificationFailed(this. number);
  _OtpVerificationFailed createState()=> _OtpVerificationFailed();
}

class _OtpVerificationFailed extends State<OtpVerificationFailed>{

  Future<bool>_onWillPop() async{
    return Future.value(false);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          elevation: 0.0,
          centerTitle: true,backgroundColor: Colors.white,
          title: Text("OTP verification", style: TextStyle(fontWeight: FontWeight.bold,color: Colors.teal),),
        ),

        body: SafeArea(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10.0),
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  flex: 3,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(Icons.alarm_off, color: Colors.grey, size: 70,),
                      SizedBox(height: 8.0,),
                      RichText(
                        text: TextSpan(
                            text:  "OTP has expired!\n\n\n",
                            style: TextStyle(color: Colors.black, fontWeight: FontWeight.w800, fontSize: 18),

                            children: <TextSpan>[

                              TextSpan(text:   "Please click on Resend OTP button if you wish to receive OTP once more on the same number i.e. ",
                                style: TextStyle(color: Colors.black,  fontWeight: FontWeight.normal, fontSize: 16),
                              ),
                              TextSpan(text:   widget.number,
                                style: TextStyle(color: Colors.black,  fontWeight: FontWeight.w700, fontSize: 16),
                              ),
                            ]
                        ),textAlign: TextAlign.center,
                        maxLines: 8, overflow: TextOverflow.ellipsis,
                      ),

                      SizedBox(height: 10.0,),
                    ],
                  ),
                ),


                Expanded(
                  flex: 0,
                  child: Column(
                    children: <Widget>[
                      MaterialButton(
                        height: 50,
                        shape: RoundedRectangleBorder(),
                        minWidth: double.infinity,
                        elevation: 5.0,
                        color: Colors.teal,
                        onPressed: (){
                          Navigator.of(context).pop(true);
                        },
                        textColor: Colors.white,
                        child: Text("Resend OTP", style: TextStyle(fontWeight: FontWeight.w600),),
                      ),
                      SizedBox(height: 10.0,),
                      MaterialButton(
                        height: 50,
                        shape: RoundedRectangleBorder(
                            side: BorderSide(width: 1, color: Colors.teal)
                        ),
                        minWidth: double.infinity,
                        elevation: 0.0,
                        color: Colors.white,
                        onPressed: (){
                          Navigator.of(context).pop();
                          Navigator.of(context).pop();
                        },
                        textColor: Colors.teal,
                        child: Text("Sign Up using another number", style: TextStyle(fontWeight: FontWeight.w600),),
                      ),

                      SizedBox(height: 10.0,),
                      MaterialButton(
                        shape: RoundedRectangleBorder(side: BorderSide(width: 1, color: Colors.grey)),
                        height: 50,
                        minWidth: double.infinity,
                        elevation: 0.0,
                        color: Colors.white,
                        onPressed: (){
                          Navigator.pushAndRemoveUntil(context, CupertinoPageRoute(builder: (context) => LoginSignUpWithOnBoarding()), (route) => false);
                        },
                        textColor: Colors.grey,
                        child: Text("Cancel Sign Up", style: TextStyle(fontWeight: FontWeight.w600),),
                      ),
                    ],
                  ),
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }

}