import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:naturesociety_new/ImageGallery/ProfilePhotoView.dart';
import 'package:naturesociety_new/Utils/MaterialComponets.dart';
import 'package:naturesociety_new/Utils/NetworkCall.dart';
import 'package:naturesociety_new/Widgets/CommonFunction.dart';
import 'package:naturesociety_new/Widgets/CommonWidgets.dart';
import 'package:naturesociety_new/Widgets/NoConnection.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ViewProfile extends StatefulWidget {
  const ViewProfile({Key key}) : super(key: key);

  @override
  _ViewProfileState createState() => _ViewProfileState();
}

class _ViewProfileState extends State<ViewProfile> {


  bool connectionStatus = true;


  @override
  void initState() {
    super.initState();
    viewProfile();
   }
  bool isConnected = true;

  bool startLoading = true, _autoValidate = false;
  var profile;

  final formKey = GlobalKey<FormState>();

  void _validate() {
    if (formKey.currentState.validate()) {
      formKey.currentState.save();
      completeProfile();
    } else {
      setState(() {
        _autoValidate = true;
      });
    }
  }

  String name, occupation, age;

  void completeProfile() async {
    Map data = {
      'id': profile["_id"],
      'name':name,
      'age':age,
      'gender':selectedChoice,
      'occupation':occupation,
      'dob': dobController.text,
    };
    setState(() {
      startLoading = true;
    });
    CustomResponse response = await ApiCall.makePostRequestToken("user/completeprofile",
        paramsData: data);
    if(response.status == 200)
      if (json.decode(response.body)["status"]) {
        startLoading = false;
        Fluttertoast.showToast(msg: "Profile has been Updated");
        SharedPreferences preference = await SharedPreferences.getInstance();
        preference.setString("User_Name",name);
        Navigator.of(context).pop(true);
      } else {
        setState(() {
          startLoading = false;
          Fluttertoast.showToast(msg: "Not Success");
        });
      }
    else
      setState(() {
        isConnected = false;
        startLoading = false;
      });
  }

  Future <void> viewProfile() async {
    setState(() {
      startLoading = true;
    });
    CustomResponse response = await ApiCall.makeGetRequestToken("user/profile");
    if(response.status == 200)
     { if (json.decode(response.body)["status"])
        setState(() {
          profile = json.decode(response.body)['data'];
         selectedChoice = profile["gender"];
         name = profile["name"];
          dobController.text = profile["dob"] !=null?  CommonFunction.dateFormatter.format(DateTime.parse(profile["dob"])) : "";
        });
      else
        Fluttertoast.showToast(msg: "Something went wrong!");
     isConnected = true;
     }
    else
      setState(() {
        isConnected = false;
      });
    setState(() {
      startLoading = false;
    });
  }

  List<dynamic> gender = ["Male", "Female", "Others"];

  String selectedChoice , selected1;
  bool selected = false;

  File _image;
  void _settingModalBottomSheet(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return Container(
            child: new Wrap(
              children: <Widget>[
                new ListTile(
                    leading: new Icon(Icons.camera_alt,color: Colors.teal,),
                    title: new Text('Camera'),
                    onTap: () async => {
                      _image = null,
                      _image = await ApiCall.getImageFile(ImageSource.camera),
                      Navigator.pop(context),
                      setState(() {
                        _image = _image;
                        startLoading = true;
                      }),
                      await   CommonFunction.uploadPhoto(_image)?
              Fluttertoast.showToast(msg: "Profile Photo Updated") : Fluttertoast.showToast(msg: "Failed to Update Profile Photo"),
                      viewProfile()
                    }),
                new ListTile(
                  leading: new Icon(Icons.image, color: Colors.teal,),
                  title: new Text('Gallery'),
                  onTap: () async => {
                    _image = null,
                    _image = await ApiCall.getImageFile(ImageSource.gallery),
                    Navigator.pop(context),
                    setState(() {
                      _image = _image;
                    }),
                  await CommonFunction.uploadPhoto(_image) ?
                  Fluttertoast.showToast(msg: "Profile Photo Updated") : Fluttertoast.showToast(msg: "Failed to Update Profile Photo"),
                },
                ),
              ],
            ),
          );
        });
  }


  Widget mainScreen(BuildContext context){
    return SafeArea(
      child: SingleChildScrollView(
        physics: ClampingScrollPhysics(),
        child: Form(
          key: formKey,
          autovalidateMode: AutovalidateMode.always,
          child: Center(
            child: Container(

              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
              child: Column(
                children: <Widget>[

                  SizedBox(height: 20.0,),

                  Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.0),
                        border: Border.all(width: 1, color: Colors.black)),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.only(
                            top: 40, bottom: 40, left: 10, right: 10),
                        child: Row(
                          children: <Widget>[
                            Expanded(
                                flex: 0,
                                child: Stack(
                                  children: <Widget>[
                                    Hero(
                                      tag: "ProfilePic",
                                      child: GestureDetector(
                                        onTap: ()=>  profile['photo'] == null ? null :
                                            Navigator.push(context, MaterialPageRoute(builder: (context)=>ProfilePhotoView( profile['photo']))),
                                        child: _image == null?
                                        profile['photo'] != null?CircleAvatar(
                                          radius: 50.0,
                                          backgroundColor: Colors.teal,
                                          backgroundImage: NetworkImage( profile['photo'] != null? ApiCall.imageUrl+ profile['photo']: "" ),
                                        ):
                                        CircleAvatar(
                                          radius: 50.0,
                                          backgroundColor: Colors.teal,
                                        )
                                            :CircleAvatar(
                                          radius: 50.0,
                                          backgroundColor: Colors.teal,
                                          backgroundImage: FileImage(_image),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      right: 0.0, bottom: 0.0,
                                      child: GestureDetector(
                                        onTap: ()=>_settingModalBottomSheet(context),
                                        child: CircleAvatar(
                                          radius: 15.0,
                                            backgroundColor: Colors.white,
                                            child: Icon(Icons.camera, color: Colors.teal,)),
                                      ),
                                    ),
                                  ],
                                )),
                            SizedBox(width: 20.0,),

                            Expanded(
                              child: Column(
                                children: <Widget>[
                                  Row(
                                    children: <Widget>[
                                      Expanded(
                                        flex:0,
                                        child: Text("Id:", style: TextStyle(fontSize: 16)),
                                      ),

                                      SizedBox(width: 5,),

                                      Expanded(
                                          flex:1,
                                          child: Text(profile['userid'],
                                            style: TextStyle(fontSize: 16, color: Color(0xff3c908d),),
                                          )),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      Expanded(
                                          flex: 0,
                                          child: Text(
                                            "No:",
                                            style: TextStyle(fontSize: 16),
                                          )),
                                      SizedBox(
                                        width: 0,
                                      ),
                                      Expanded(
                                          flex: 1,
                                          child: Text(
                                            profile['phone'],
                                            style: TextStyle(fontSize: 16, color: Color(0xff3c908d),),
                                          )),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Divider(),
                  TextFormField(
                    initialValue: profile['name'],
                    decoration: new InputDecoration(
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                          BorderSide(color: Colors.black, width: 1.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                          BorderSide(color: Colors.black, width: 1.0),
                        ),
                        labelText: 'NAME',
                        labelStyle: TextStyle(
                          color: Color(0xff3c908d),
                        )),
                    validator: (val) {
                      if (val.isEmpty)
                        return "Cannot be empty!";
                      else if(RegExp(r'(^[a-zA-Z ]*$)')
                          .hasMatch(val)) {
                        return null; }
                      else {return "Only Alphabets are Allowed";}
                    },
                    onSaved: (val) {name = val;},
                    textCapitalization: TextCapitalization.words,
                    keyboardType: TextInputType.text
                  ),

                  SizedBox(height: 20,),

                  Row(children: _genderBuilder(context),),

                  SizedBox(
                    height: 20,
                  ),
                  GestureDetector(
                    onTap: () => getDOB(context),
                    child: AbsorbPointer(
                      child: TextFormField(
                       //   initialValue:  profile['dob'].toString() ?? " ",
                        decoration: new InputDecoration(
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black, width: 1.0),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black, width: 1.0),
                            ),
                            labelText: 'DATE OF BIRTH',
                            labelStyle: TextStyle(
                              color: Color(0xff3c908d),
                            )),
                        onSaved: (value) {
                          // dob = value.toIso8601String();
                        },
                        validator: (value) {
                          if (value.isEmpty)
                            return null;
                          else
                            return null;
                        },
                        onTap: ()=>  getDOB(context),
                        keyboardType: TextInputType.datetime,
                        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[/\\]')),],
                        controller: dobController,
                      ),
                    ),
                  ),

                  // TextFormField(
                  //   initialValue:  profile['age'] == null ? " " : profile['age'].toString() ?? " ",
                  //   decoration: new InputDecoration(
                  //       focusedBorder: OutlineInputBorder(
                  //         borderSide:
                  //         BorderSide(color: Colors.black, width: 1.0),
                  //       ),
                  //       enabledBorder: OutlineInputBorder(
                  //         borderSide:
                  //         BorderSide(color: Colors.black, width: 1.0),
                  //       ),
                  //       labelText: 'AGE',
                  //       labelStyle: TextStyle(
                  //         color: Color(0xff3c908d),
                  //       )),
                  //   validator: (val) {
                  //     if (val.isEmpty)
                  //       return "Cannot be empty!";
                  //     else
                  //       return null;
                  //   },
                  //   onSaved: (val) {age = val;},
                  // ),
                  SizedBox(
                    height: 20,
                  ),
                  TextFormField(
                    initialValue: profile['occupation'],
                    decoration: new InputDecoration(
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black, width: 1.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black, width: 1.0),
                        ),
                        labelText: 'OCCUPATION',
                        labelStyle: TextStyle(
                          color: Color(0xff3c908d),
                        )),

                    onSaved: (val) {
                      occupation = val;
                    },
                    textCapitalization: TextCapitalization.words,
                  ),
                  SizedBox(
                    height: 40,
                  ),
                  MaterialButton(
                    minWidth: double.infinity,
                    height: 60,
                    color: Color(0xff3c908d),
                    onPressed: () {_validate();},
                    child: Text("UPDATE",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }


  Future<bool> onWillPopScope() async{
    Navigator.of(context).pop(true);
    return  Future.value(false);
  }
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: onWillPopScope,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          automaticallyImplyLeading: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: ()=> onWillPopScope(),
          ),
          backgroundColor: Colors.grey.withOpacity(.02),
          elevation: 0.0,
          iconTheme: IconThemeData(color: Colors.black),
          title: Text("Edit Profile", style: TextStyle(color: Colors.black),),
        ),


        body:  isConnected ? startLoading ? CommonWidgets.progressIndicator(context) : mainScreen(context): NoConnection( notifyParent:  viewProfile,),),
    );
  }

  _genderBuilder(BuildContext context){

    final List<Widget>listItem = <Widget>[];

    for(int pos=0; pos<gender.length; pos++)
      listItem.add(Expanded(
        child: Container(
          decoration: BoxDecoration(
              border: Border.all(width: 1, color: Colors.black)),
          child: ListTile(
            title: Align(
              alignment: Alignment.topLeft,
              child: ChoiceChip(
                backgroundColor: Colors.grey[100],
                label: Text(gender[pos], style: TextStyle(fontWeight: FontWeight.normal),),
                selected:  selectedChoice == gender[pos],
                onSelected: (selected) {
                  setState(() {
                    selectedChoice = gender[pos];
                    selected1 = gender[pos];
                  });
                },
              ),
            ),
            onTap: () {
              setState(() {
                selected1 = gender[pos];
              });
            },
          ),
        ),
      ));
    return listItem;
  }




  TextEditingController dobController = TextEditingController();

  Future<Null> getDOB(BuildContext context) async {
    FocusScope.of(context).requestFocus(FocusNode());
    DateTime threenYearsAgo = DateTime.now().subtract(new Duration(days: 4745));

    DatePicker.showDatePicker(context,
        theme: DatePickerTheme(
          itemStyle: TextStyle(color: Colors.teal),
            doneStyle: TextStyle(color: MaterialTools.basicColor, fontWeight: FontWeight.w800)),
        showTitleActions: true,
        minTime: DateTime(1917, 1),

        maxTime: threenYearsAgo,
        onChanged: (date) {
          print('change $date');
        }, onConfirm: (date) {
          dobController.text = CommonFunction.dateFormatter.format(date);
          print('confirm $date');
        }, currentTime: profile['dob'] != null ? DateTime.parse(profile['dob']) : DateTime.now(), locale: LocaleType.en);

  }


  @override
  void dispose(){
    super.dispose();
  }
}
