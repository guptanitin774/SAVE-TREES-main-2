import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:naturesociety_new/ImageGallery/SinglePhotoView.dart';
import 'package:naturesociety_new/Utils/LocalPrefManager.dart';
import 'package:naturesociety_new/Utils/NetworkCall.dart';
import 'package:naturesociety_new/Widgets/CommonWidgets.dart';
import 'package:naturesociety_new/Widgets/UploadingLoader.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:naturesociety_new/NavigatePage.dart';
import 'package:http/http.dart' as http;


class FeedbackForm extends StatefulWidget {
  final type ;
  FeedbackForm(this.type);

  _FeedbackForm createState() => _FeedbackForm();
}

class _FeedbackForm extends State<FeedbackForm> {
  @override
  void initState() {
    super.initState();
  }

  mediaPermission() async {
    await Permission.storage.request();
    if (await Permission.storage.isDenied) {
      print(await Permission.storage.isGranted);
      if (!await Permission.storage.isGranted) {
        Fluttertoast.showToast(msg: "Access Storage permission not granted");
      //  Navigator.of(context).pop(false);
        CommonWidgets.permissionDialog(context: context, type: "Storage");
      //  openAppSettings();
        return;
      }
    } else if (await Permission.storage.isPermanentlyDenied) {
      Fluttertoast.showToast(msg: "Access Storage permission not granted");
     // Navigator.of(context).pop(false);
      CommonWidgets.permissionDialog(context: context, type: "Storage");
     // openAppSettings();
      return;
    }
    else{
      initMultiPickUp();
      //getImage();
    }
  }
  List<File> selectedImage=[];
  initMultiPickUp() async {
   try
    { FilePickerResult? result = await FilePicker.platform.pickFiles(allowMultiple: true, type: FileType.custom,
      allowedExtensions: ['jpg', 'png', 'jpeg'],allowCompression: true);
    if(result != null) {
      if(selectedImage.length + result.files.length > 4) {
        Fluttertoast.showToast(msg: "Maximum selected Images are 4");
      }
      else {
        List<File> files = result.paths.map((path) => File(path!)).toList();
        files.forEach((element) {selectedImage.add(File(element.path));});
        setState(() {});
      }
    }}
    catch(e){
      Fluttertoast.showToast(msg: e.toString());
    }
  }

  final feedbackController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 5.0,
        automaticallyImplyLeading: true,
        centerTitle: false,
        title: Text("Feedback"),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: MaterialButton(
        minWidth: double.infinity,
        height: 60.0,
        color: Colors.teal,
        textColor: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text("SUBMIT"),
            SizedBox(
              width: 8.0,
            ),
            Icon(Icons.arrow_forward)
          ],
        ),
        onPressed: () =>
            feedbackController.text == null || feedbackController.text == ''
                ? Fluttertoast.showToast(msg: "Please Provide Feedback")
                :   sendFeedback(),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
                "Let us know how was your experience while using this app and how we could improve it."),
            SizedBox(
              height: 20.0,
            ),
            Container(
             height: MediaQuery.of(context).size.height - 250,
              padding: EdgeInsets.all(8.0),
              decoration:
                  BoxDecoration(border: Border.all(color: Colors.black)),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    ConstrainedBox(
                     constraints: BoxConstraints(
                       minHeight: 50,
                       maxHeight: MediaQuery.of(context).size.height - 330
                     ),
                      child: TextFormField(
                        scrollPhysics: ClampingScrollPhysics(),
                        decoration: new InputDecoration(
                          hintText: "Type your feedback here ...",
                           ),
                        controller: feedbackController,
                        maxLines: null,
                        textCapitalization: TextCapitalization.sentences,
                      ),
                    ),
                    SizedBox(
                      height: 10.0,
                    ),

                    //  SizedBox(height: MediaQuery.of(context).size.height - 400,),

                    selectedImage.length != 0
                        ? feedbackPhotos(context)
                        : MaterialButton(
                            onPressed: () async {
                              mediaPermission();

                            },
                            minWidth: double.infinity,
                            height: 50.0,
                            child: Text("Attach Image"),
                            color: Colors.teal,
                            textColor: Colors.white,
                          ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 70.0,
            ),
          ],
        ),
      ),
    );
  }


  Widget feedbackPhotos(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text("Photos (${selectedImage.length})"),
        SizedBox(
          height: 10.0,
        ),
        GridView.builder(
            physics: NeverScrollableScrollPhysics(),
            itemCount: selectedImage.length + 1,
            shrinkWrap: true,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisSpacing: 8, mainAxisSpacing: 8, crossAxisCount: 3),
            itemBuilder: (context, index) {
              if (index == selectedImage.length) {
                return index > 3
                    ? SizedBox.shrink()
                    : Container(
                        height: 200,
                        width: 200,
                        padding: const EdgeInsets.all(3.0),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.blueGrey),
                          borderRadius: BorderRadius.all(Radius.circular(8.0)),
                        ),
                        child: InkWell(
                          onTap: () => mediaPermission(),
                          child: Stack(
                            alignment: Alignment.center,
                            children: <Widget>[
                              Opacity(
                                  opacity: 1,
                                  child: Icon(
                                    Icons.photo_camera,
                                    color: Colors.grey,
                                    size: 50,
                                  )),
                              Positioned(
                                bottom: 70,
                                left: 70,
                                child: CircleAvatar(
                                  radius: 10,
                                  backgroundColor: Colors.blue,
                                  child: Icon(
                                    Icons.add,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
              }
              return Stack(
                children: <Widget>[
                  GestureDetector(
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                SinglePhotoView(selectedImage, initialIndex: index,))),
                    child: Container(
                        padding: const EdgeInsets.all(3.0),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.blueGrey),
                          borderRadius: BorderRadius.all(Radius.circular(8.0)),
                        ),
                        height: 200,
                        width: 200,
                        child: Image.file(
                          selectedImage[index],
                          fit: BoxFit.cover,
                        )),
                  ),
                  Positioned(
                    right: 0.0,
                    top: 0.0,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedImage.removeAt(index);
                        });
                      },
                      child: CircleAvatar(
                        radius: 15.0,
                        backgroundColor: Colors.white,
                        child: Icon(
                          Icons.cancel,
                          color: Colors.teal,
                        ),
                      ),
                    ),
                  )
                ],
              );
            }),
      ],
    );
  }

  Future<void> sendFeedback() async {
    UploadingLoader.progressLoader(context: context, message: "Sending Feedback");
    Map data = {
//      "email" : email,
//      "subject" : subject,
      "body": feedbackController.text,
      "type":widget.type
    };

    CustomResponse response =
        await ApiCall.makePostRequestToken("feedback/add", paramsData: data);
    if (response.status == 200) if (json.decode(response.body)["status"]) {
      if (selectedImage.length > 0)
        uploadFeedbackPhotos(json.decode(response.body)["id"]);
      else {
        Navigator.pop(context);
        Fluttertoast.showToast(msg: "Feedback Posted");
        await LocalPrefManager.clearLocalFeedbackTime();
         Navigator.pushAndRemoveUntil(context, CupertinoPageRoute(builder: (context) => NavigatePage()), (route) => false);
      }
    } else {
      Navigator.pop(context);
      Fluttertoast.showToast(msg: "Something went wrong.");
    }
    else {
      Navigator.pop(context);
      Fluttertoast.showToast(msg: "Not Network Connection.");
    }
  }

  var percent;
  void uploadFeedbackPhotos(var feedbackId) async {
    print("Image Uploading");
    var to = await LocalPrefManager.getToken();
    Map <String,String> data ={"id": feedbackId.toString()};

    var request = http.MultipartRequest('POST', Uri.parse(ApiCall.webUrl + "feedback/image"));

    request.headers.addAll({'Content-Type': 'application/form-data', 'x-auth-token': to ?? ''});
    request.fields.addAll(data);

    if (selectedImage != null) {
      selectedImage.forEach((File file) {
        request.files.add(http.MultipartFile.fromBytes(
            'image', file.readAsBytesSync(),
            filename: file.path.split('/').last));
      });
    }
    try {
      http.Response response = await http.Response.fromStream(await request.send());
      print(json.decode(response.body));
      if(json.decode(response.body)["status"]){
          Navigator.pop(context);
          LocalPrefManager.clearLocalFeedbackTime();
          Navigator.pushAndRemoveUntil(context, CupertinoPageRoute(builder: (context) => NavigatePage()), (route) => false);
      }

    } catch (e) {
      Navigator.pop(context);
      print(e);
      Fluttertoast.showToast(msg: e.toString());
    }
  }

  Future<void> showLoadingDialog(BuildContext context) async {
    sendFeedback();
    return showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return new WillPopScope(
              onWillPop: () async => false,
              child: SimpleDialog(
                  backgroundColor: Colors.teal.withOpacity(.7),
                  children: <Widget>[
                    Center(
                      child: Column(children: [
                        CircularProgressIndicator(),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          "Please Wait",
                          style: TextStyle(color: Colors.white),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          "Sending Feedback",
                          style: TextStyle(color: Colors.white),
                        )
                      ]),
                    )
                  ]));
        });
  }
}
