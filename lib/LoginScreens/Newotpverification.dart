import 'dart:async';
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:naturesociety_new/LoginScreens/AccountCreationMessage.dart';
import 'package:naturesociety_new/LoginScreens/AddLocations.dart';
import 'package:naturesociety_new/LoginScreens/LiveNotificationBanner.dart';
import 'package:naturesociety_new/LoginScreens/OtpVerificationFailed.dart';
import 'package:naturesociety_new/Utils/LocalPrefManager.dart';
import 'package:naturesociety_new/Utils/NetworkCall.dart';
import 'package:pin_code_fields/pin_code_fields.dart';



class NewOtp extends StatefulWidget {
  final  phoneNumber, prefix,countryName, state, city;
  NewOtp({this.phoneNumber,this.prefix, this.countryName, this.state, this.city});

  @override
  _NewOtpState createState() => _NewOtpState();
}

class _NewOtpState extends State<NewOtp> {
  @override
  void initState() {
    super.initState();
    _siginOutFireBase();
    verifyPhone();
  }



void _siginOutFireBase() async{
  await FirebaseAuth.instance.signOut();
}
  //New Code

  String phoneNo;
  String smsOTP;
  String verificationId;
  String errorMessage = '';
  FirebaseAuth _auth = FirebaseAuth.instance;


  Future<void> verifyPhone() async {
   setState(() {
     startTimer();
     textEditingController.clear();
   });

   final PhoneCodeSent codeSent = (String verId, [int forceCodeResend]) {
     this.verificationId = verId;
   };



   try {
     await _auth.verifyPhoneNumber(
         phoneNumber: widget.prefix+" "+widget.phoneNumber,
         timeout: const Duration(seconds: 112),
         verificationCompleted: (AuthCredential phoneAuthCredential) async{},
         verificationFailed:   (AuthException e){print("${e.message}");},
         codeSent: codeSent,
         codeAutoRetrievalTimeout:  (String verId) {
       this.verificationId = verId;
     },);
   } catch (e) {
     FocusScope.of(context).requestFocus(new FocusNode());
     setState(() {
       errorMessage = '${e.toString()}';
     });

    // handleError(e);
   }

  }



  signIn(BuildContext context) async {
    try {
      final AuthCredential credential = PhoneAuthProvider.getCredential(verificationId: verificationId, smsCode: smsOTP);

      final  user = (await _auth.signInWithCredential(credential)).user;
      //print( await user.getIdToken(refresh: false));

      var idToken = await user.getIdToken(refresh: false);
     print(idToken.token.toString());

      Map data={'phone': widget.phoneNumber,
        "prefix":widget.prefix,
        "country": widget.countryName,
        "state":widget.state,
        "city": widget.city,
        //"otp" :"1234",
        "token": idToken.token.toString()
      };
      var response = await ApiCall.makePostRequestToken("user/verifyotp",paramsData: data);
       print(json.decode(response.body));
     // Fluttertoast.showToast(msg: json.decode(response.body));

      if(json.decode(response.body)["status"]) {
        // Fluttertoast.showToast(msg: json.decode(response.body));
       var idUser = json.decode(response.body)["id"];

        await LocalPrefManager.setToken(json.decode(response.body)["token"]);
        await LocalPrefManager.setUserId(json.decode(response.body)["id"]);
        await LocalPrefManager.setAnonymity(true);
        await LocalPrefManager.setFirebaseToken(idToken.token.toString());


        if(!json.decode(response.body)["profile"])
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => AccountMessage(idUser: idUser,
          phoneNumber: widget.phoneNumber,country: widget.countryName, state: widget.state, city: widget.city,)));
       else if(!json.decode(response.body)["location"])
         Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>AddBasicLocations()));
        else
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>LiveNearByNotification()));

      }
      else
        Fluttertoast.showToast(msg: json.decode(response.body)["msg"]);
    } catch (e) {
      FocusScope.of(context).requestFocus(new FocusNode());
      setState(() {
        errorMessage = '${e.toString()}';
      });
      //handleError(e.toString());
    }
    setState(() {
      buttonLoading = false;
    });
  }



  Timer _timer;
  int _start ;
  String sendPin;

  void startTimer()  {
    _start = 110;
    const oneSec = const Duration(seconds: 1);
    _timer = new Timer.periodic(
      oneSec,
      (Timer timer)  async{
      if (_start == 0) {
        timer.cancel();
    bool needRefresh= await Navigator.push(context, MaterialPageRoute(builder: (context)=> OtpVerificationFailed(widget.phoneNumber)));
    if(needRefresh)
      verifyPhone();
  } else {
    _start = _start - 1;
    }
      if(mounted)
        setState(() {});
      },
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    textEditingController.clear();
    textEditingController.dispose();
    super.dispose();
  }



bool buttonLoading = false;

  TextEditingController textEditingController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading:  false,
        elevation: 0.0,
        title: Text(
          "OTP VERIFICATION",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(left: 16.0,right: 16.0, top: 20.0,bottom: 10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: 30,),

            RichText(
              text: TextSpan(
                  text:  "A 6 digit code has been sent to you via a text message to your phone number which is: ",
                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal, fontSize: 16),

                  children: <TextSpan>[
                    TextSpan(text: widget.prefix +" "+ widget.phoneNumber,
                      style: TextStyle(color: Colors.black,  fontWeight: FontWeight.w700, fontSize: 16),
                    ),
                  ]
              ),textAlign: TextAlign.center,
              maxLines: 5, overflow: TextOverflow.ellipsis,
            ),

            SizedBox(
              height: 20,
            ),
            Container(
              width: double.infinity,
              child: Text(
                "Enter the code here once you receive it.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black,
                    fontWeight: FontWeight.normal,
                    fontSize: 16),
              ),
            ),
            SizedBox(
              height: 20,
            ),

            Form(
              key: formKey,
              child: PinCodeTextField(
                enablePinAutofill: false,
                enableActiveFill: true,
                autoDisposeControllers: true,
                autoFocus: true,
                cursorColor: Colors.black,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                appContext: context,
                pastedTextStyle: TextStyle(
                  color: Colors.green.shade600,
                  fontWeight: FontWeight.bold,
                ),
                length: 6,
                obscureText: false,
                // animationType: AnimationType.fade,
                validator: (v) {
                  if (v.length < 3) {
                    return null;
                  } else {
                    return null;
                  }
                },

                pinTheme: PinTheme(
                  activeFillColor: Colors.white,
                  selectedFillColor: Colors.grey,
                  inactiveFillColor: Colors.white,
                  activeColor: Colors.black45,
                  selectedColor: Colors.black45,
                  inactiveColor: Colors.black45,
                  shape: PinCodeFieldShape.box,
                  borderRadius: BorderRadius.circular(5),
                  fieldHeight: 50,
                  fieldWidth: 45,
                ),
                animationDuration: Duration(milliseconds: 300),
                backgroundColor: Colors.white,
                controller: textEditingController,
                keyboardType: TextInputType.number,
                onCompleted: (v) {
                  smsOTP = v;
                },
                onChanged: (value) {

                },
                beforeTextPaste: (text) {
                  smsOTP = text;
                  return true;
                },
              ),
            ),

            SizedBox(height: 20,),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  alignment: Alignment.center,
                  child: Text(
                    "Time Remaining:", style: TextStyle(color: Colors.grey,  fontStyle: FontStyle.normal, fontSize: 14),
                  ),
                ),

                SizedBox(width: 20,),

                Container(
                  alignment: Alignment.center,
                  child: Text("$_start"+ " seconds",
                    style: TextStyle(fontWeight: FontWeight.bold, fontStyle: FontStyle.normal, fontSize: 12),
                  ),
                )
              ],
            ),

            SizedBox(height: 25,),

            buttonLoading? Center(child: CircularProgressIndicator(),):  MaterialButton(
              minWidth: double.infinity,
              height: 50,
              onPressed: () async {
                setState(() {
                  buttonLoading = true;
                });
                signIn(context);
              },
              textColor: Colors.white,
              color: Colors.teal,
              child: Text(
                "DONE",
                style: TextStyle(fontSize: 14,  fontWeight: FontWeight.bold),
              ),
            ),

          ],
        ),
      ),
    );
  }
}
