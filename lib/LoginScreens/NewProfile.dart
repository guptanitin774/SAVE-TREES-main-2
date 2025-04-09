import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart' as fdtp;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:naturesociety_new/LoginScreens/AddLocations.dart';
import 'package:naturesociety_new/Utils/LocalPrefManager.dart';
import 'package:naturesociety_new/Utils/MaterialComponets.dart';
import 'package:naturesociety_new/Utils/NetworkCall.dart';
import 'package:naturesociety_new/Widgets/CommonFunction.dart';
import 'package:http/http.dart' as http;
import 'package:naturesociety_new/Widgets/UploadingLoader.dart';
import 'package:permission_handler/permission_handler.dart';

class NewProfile extends StatefulWidget {
  final String userId, phoneNumber, country, state, city;

  const NewProfile(this.userId, this.phoneNumber, this.country, this.state, this.city, {Key? key}) : super(key: key);

  @override
  _NewProfileState createState() => _NewProfileState();
}

class _NewProfileState extends State<NewProfile> {
  @override
  void initState() {
    super.initState();
  }

  List<String> gender = ["Male", "Female", "Others"];

  String selectedChoice = "", selected1 = "";
  bool selected = false;

  File? _image;

  void _settingModalBottomSheet(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return Container(
            child: Wrap(
              children: <Widget>[
                ListTile(
                    leading: Icon(Icons.camera_alt),
                    title: Text('Camera'),
                    onTap: () async {
                      cameraPermission();
                    }),
                ListTile(
                  leading: Icon(Icons.image),
                  title: Text('Gallery'),
                  onTap: () async {
                    mediaPermission();
                  },
                ),
              ],
            ),
          );
        });
  }

  static void alertBoxWithOption(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) => Platform.isIOS
            ? CupertinoAlertDialog(
          content: Text("Do you want to Skip completing Profile? "),
          actions: <Widget>[
            CupertinoDialogAction(
              child: Text("CANCEL"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            CupertinoDialogAction(
              isDefaultAction: true,
              child: Text("OK"),
              onPressed: () {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => AddBasicLocations()));
              },
            ),
          ],
        )
            : AlertDialog(
          content: Text("Do you want to Skip completing Profile? "),
          actions: [
            TextButton(
              child: Text("CANCEL"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => AddBasicLocations()));
              },
            ),
          ],
        ));
  }

  Future<bool> _onWillPop() async {
    FocusScope.of(context).unfocus();
    alertBoxWithOption(context);
    return Future.value(false);
  }

  @override
  Widget build(BuildContext context) {
    bool keyboardIsOpened = MediaQuery.of(context).viewInsets.bottom != 0.0;
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: Opacity(
          opacity: keyboardIsOpened ? 0 : 1,
          child: MaterialButton(
            minWidth: double.infinity,
            height: 60,
            color: MaterialTools.basicColor,
            onPressed: () async {
              if (nameOn || genderOn || dobOn || occupationOn) {
                validation();
              } else {
                await LocalPrefManager.setUserName('');
                await LocalPrefManager.setAnonymity(stayAnonymous);
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => AddBasicLocations()));
              }
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(
                  nameOn || genderOn || dobOn || occupationOn
                      ? "Continue"
                      : "Skip",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                SizedBox(
                  width: 5.0,
                ),
                Icon(
                  Icons.arrow_forward,
                  color: Colors.white,
                ),
              ],
            ),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Center(
                child: Container(
                  color: Colors.grey[100],
                  padding: EdgeInsets.all(10),
                  child: Column(
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            "Congratulations!",
                            style: TextStyle(
                                fontSize: 18,
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                          )
                        ],
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              "Your account has been created.",
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                            ),
                          )
                        ],
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      Text(
                        "Complete your profile",
                        style: TextStyle(
                            color: Colors.teal, fontWeight: FontWeight.w600),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      InkWell(
                        onTap: () => _settingModalBottomSheet(context),
                        child: CircleAvatar(
                          radius: 90,
                          backgroundColor: Colors.white,
                          backgroundImage: _image == null
                              ? const NetworkImage(
                              "https://cdn3.iconfinder.com/data/icons/social-messaging-productivity-6/128/profile-male-circle2-512.png")
                              : FileImage(_image!) as ImageProvider,
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      formField(context),
                      SizedBox(
                        height: keyboardIsOpened ? 0.0 : 70.0,
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

  //Media Permission
  mediaPermission() async {
    await Permission.storage.request();
    if (await Permission.storage.isDenied) {
      if (!await Permission.storage.isGranted) {
        Fluttertoast.showToast(msg: "Access Storage permission not granted");
        Navigator.of(context).pop();
        openAppSettings();
        return;
      }
    } else if (await Permission.storage.isPermanentlyDenied) {
      Fluttertoast.showToast(msg: "Access Storage permission not granted");
      Navigator.of(context).pop();
      openAppSettings();
      return;
    } else {
      getFromGallery();
    }
  }

  //Camera Permission
  cameraPermission() async {
    await Permission.camera.request();
    if (await Permission.camera.isDenied) {
      if (!await Permission.camera.isGranted) {
        Fluttertoast.showToast(msg: "Camera permission not granted");
        Navigator.of(context).pop();
        openAppSettings();
        return;
      }
    } else if (await Permission.camera.isPermanentlyDenied) {
      Fluttertoast.showToast(msg: "Camera permission not granted");
      Navigator.of(context).pop();
      openAppSettings();
      return;
    } else {
      getFormCamera();
    }
  }

  getFromGallery() async {
    FocusScope.of(context).unfocus();
    _image = await ApiCall.getImageFile(ImageSource.gallery);
    setState(() {});
    Navigator.pop(context);
  }

  getFormCamera() async {
    FocusScope.of(context).unfocus();
    _image = await ApiCall.getImageFile(ImageSource.camera);
    setState(() {});
    Navigator.pop(context);
  }

  final formKey = GlobalKey<FormState>();
  var name, sex, age, occupation;
  bool stayAnonymous = false;

  bool nameOn = false, anonymousOn = false, genderOn = false, dobOn = false, occupationOn = false;

  Widget formField(BuildContext context) {
    return Form(
      key: formKey,
      autovalidateMode: autoValidate
          ? AutovalidateMode.onUserInteraction
          : AutovalidateMode.disabled,
      child: Theme(
        data: ThemeData(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            TextFormField(
              decoration: InputDecoration(
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black, width: 1.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black, width: 1.0),
                  ),
                  labelText: 'NAME',
                  labelStyle: TextStyle(
                    color: Color(0xff3c908d),
                  )),
              onSaved: (value) {
                name = value;
              },
              onChanged: (v) {
                if (v.length > 0)
                  nameOn = true;
                else
                  nameOn = false;
                setState(() {});
              },
              textCapitalization: TextCapitalization.words,
              keyboardType: TextInputType.text,
            ),
            SizedBox(
              height: 20,
            ),
            Container(
              padding: EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                  border: Border.all(
                      color: MaterialTools.borderColor,
                      width: MaterialTools.borderWidth),
                  color: Colors.white),
              child: Text(
                "You will have the option to stay anonymous while posting / updating case and commenting on cases.",
                style: TextStyle(fontSize: 12),
                textAlign: TextAlign.left,
              ),
            ),
            SizedBox(
              height: 10.0,
            ),
            Divider(
              height: 20.0,
              thickness: 0.5,
            ),
            Container(
              padding: EdgeInsets.all(8.0),
              width: MediaQuery.of(context).size.width - 20,
              child: Text(
                "We need the following details to learn the demographics about our users.",
                style: TextStyle(fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text(
                "Gender",
                style: TextStyle(color: Colors.teal, fontSize: 12),
              ),
            ),
            SizedBox(
              height: 8.0,
            ),
            Row(
              children: _genderBuilder(context),
            ),
            SizedBox(
              height: 20,
            ),
            GestureDetector(
              onTap: () => getDOB(context),
              child: AbsorbPointer(
                child: TextFormField(
                  decoration: InputDecoration(
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
                  onTap: () => getDOB(context),
                  keyboardType: TextInputType.datetime,
                  controller: dobController,
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            TextFormField(
              decoration: InputDecoration(
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
              onSaved: (value) {
                occupation = value;
              },
              onChanged: (v) {
                if (v.length > 0)
                  occupationOn = true;
                else
                  occupationOn = false;
                setState(() {});
              },
              textCapitalization: TextCapitalization.words,
            ),
            SizedBox(
              height: 20,
            ),
            TextFormField(
              enabled: false,
              initialValue: widget.phoneNumber,
              decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black, width: 1.0),
                  ),
                  labelText: 'PHONE NUMBER',
                  labelStyle: TextStyle(
                    color: Color(0xff3c908d),
                  )),
              onSaved: (value) {
                occupation = value;
              },
              textCapitalization: TextCapitalization.words,
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _genderBuilder(BuildContext context) {
    final List<Widget> listItem = <Widget>[];

    for (int pos = 0; pos < gender.length; pos++)
      listItem.add(Expanded(
        child: Container(
          decoration:
          BoxDecoration(border: Border.all(width: 1, color: Colors.black)),
          child: ListTile(
            title: Align(
              alignment: Alignment.topLeft,
              child: FilterChip(
                showCheckmark: false,
                backgroundColor: Colors.grey[100],
                label: Text(
                  gender[pos],
                  style: TextStyle(fontWeight: FontWeight.normal),
                ),
                selected: selectedChoice == gender[pos],
                onSelected: (selected) {
                  setState(() {
                    selectedChoice = gender[pos];
                    selected1 = gender[pos];
                    genderOn = true;
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

  bool autoValidate = false;

  void validation() {
    if (formKey.currentState != null && formKey.currentState!.validate()) {
      formKey.currentState!.save();
      UploadingLoader.progressLoader(context: context, message: "Uploading Profile");
      if (_image != null)
        uploadPhoto();
      else
        submitProfile();
    } else
      setState(() {
        autoValidate = true;
      });
  }

  var percent;

  void uploadPhoto() async {
    var request = http.MultipartRequest(
        'POST', Uri.parse(ApiCall.webUrl + 'user/photo'));
    String? token = await LocalPrefManager.getToken();
    request.headers.addAll(
        {'Content-Type': 'application/form-data', 'x-auth-token': token ?? ''});

    if (_image != null) {
      request.files.add(http.MultipartFile.fromBytes(
          'photo', await _image!.readAsBytes(),
          filename: _image!.path.split('/').last));
    }

    try {
      http.Response response =
      await http.Response.fromStream(await request.send());
      if (json.decode(response.body)["status"]) submitProfile();
    } catch (e) {
      print(e);
    }
  }

  Future<void> submitProfile() async {
    Map<String, dynamic> info = {
      "id": widget.userId,
      "name": name,
      "age": age,
      "gender": selected1,
      "occupation": occupation,
      "dob": dobController.text,
      "country": widget.country,
      "state": widget.state,
      "city": widget.city,
    };

    var response = await ApiCall.makePostRequestToken('user/completeprofile',
        paramsData: info);
    if (json.decode(response.body)["status"]) {
      Fluttertoast.showToast(msg: "Profile Created Successfully");
      await LocalPrefManager.setUserName(name);
      await LocalPrefManager.setAnonymity(stayAnonymous);
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => AddBasicLocations()));
    } else {
      Navigator.pop(context);
      Fluttertoast.showToast(
          msg: "Some Error occurred while creating Profile. Please try again");
    }
  }

  TextEditingController dobController = TextEditingController();

  Future<void> getDOB(BuildContext context) async {
    FocusScope.of(context).requestFocus(FocusNode());
    DateTime thirteenYearsAgo = DateTime.now().subtract(Duration(days: 4745));

    fdtp.DatePicker.showDatePicker(context,
        theme: fdtp.DatePickerTheme(
          containerHeight: 210.0,
          titleHeight: 44.0,
          itemHeight: 40.0,
          itemStyle: TextStyle(color: Colors.black),
          doneStyle: TextStyle(color: MaterialTools.basicColor, fontWeight: FontWeight.w800),
          cancelStyle: TextStyle(color: Colors.red),
        ),
        showTitleActions: true,
        minTime: DateTime(1917, 1),
        maxTime: thirteenYearsAgo,
        onChanged: (date) {
          // print('change $date');
        },
        onConfirm: (date) {
          setState(() {
            dobController.text = CommonFunction.dateFormatter.format(date);
            dobOn = true;
          });
        },
        currentTime: DateTime(1980, 1, 1), // Set a more reasonable default date
        locale: fdtp.LocaleType.en);
  }
}