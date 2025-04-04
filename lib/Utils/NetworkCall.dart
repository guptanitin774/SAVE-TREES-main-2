import 'dart:async';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:core';
import 'package:image_picker/image_picker.dart';
import 'package:naturesociety_new/Utils/LocalPrefManager.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';



class ApiCall
{
 // static String webUrl = "http://192.168.43.152:7000/";
 // static String socketUrl = "http://192.168.43.152:7000";
//

  //
  static String webUrl = "http://3.6.245.85/";
  static String socketUrl = "http://3.6.245.85";

  static String imageUrl = "http://3.6.245.85/u/";

  static String mapKey = "AIzaSyCaccNxbzwR9tMvkppT7bT7zNKjChc_yAw";
  static String playStoreUrl = "https://play.google.com/store/apps/details?id=ndns.save_trees";



  //Token Request





  static Future<http.Response> makeGetRequest(url) async
  {
    http.Response response = await http.get(webUrl+url);
    return response;
  }

  static Future<CustomResponse> makeGetRequestToken(url,{paramsData}) async
  {
    String token = await LocalPrefManager.getToken();
    Map<String,String> data = {
      'x-auth-token':token
    };

    if(paramsData?.isNotEmpty ?? false){
      data.addAll(paramsData);
    }

    CustomResponse customResponse;
    try{
      var response = await http.get(
        webUrl+url,
        headers: data,
      ).timeout(Duration(seconds: 15
      ));
      if(response.statusCode == 200)
        customResponse = CustomResponse(200, response.body);
      else
        customResponse = CustomResponse(403, response.body);

    } on SocketException catch(_){
      customResponse = CustomResponse(503, "Please check your internet connection");

    } on TimeoutException catch(_){
      customResponse = CustomResponse(408, "Takes too much time, Please try again");

    }
    return customResponse;
  }


  static Future<CustomResponse> makeSocketGetRequestToken(url,{paramsData}) async
  {
    String token = await LocalPrefManager.getToken();
    Map<String,String> data = {
      'x-auth-token':token
    };

    if(paramsData?.isNotEmpty ?? false){
      data.addAll(paramsData);
    }

    CustomResponse customResponse;
    try{
      var response = await http.get(
        webUrl+url,
        headers: data,
      ).timeout(Duration(seconds: 120));

      customResponse = CustomResponse(200, response.body);

    } on SocketException catch(_){
      customResponse = CustomResponse(503, "Please check your internet connection");

    } on TimeoutException catch(_){
      customResponse = CustomResponse(408, "Takes too much time, Please try again");

    }
    return customResponse;
  }

  static Future<CustomResponse> makePostRequestToken(url,{Map paramsData}) async
  {

    String token = await LocalPrefManager.getToken();
    Map data = {
      'x-auth-token':token
    };
    if(paramsData?.isNotEmpty ?? false){
      data.addAll(paramsData);
    }
    //encode Map to JSON
    var body = json.encode(data);
    CustomResponse customResponse;

    try{
      var response = await http.post(
        webUrl+url,
        headers: {"Content-Type": "application/json", "x-auth-token": token,},
        body: body,
      ).timeout(Duration(seconds: 30));

      customResponse = CustomResponse(200, response.body);

    } on SocketException catch(_){

      customResponse = CustomResponse(503, "Please check your internet connection");

    } on TimeoutException catch(_){

      customResponse = CustomResponse(408, "Takes too much time, Please try again");
    }

    return customResponse;
  }


  static Future<File> getImageFile(ImageSource source) async {
//    Future<File> _futureImage;
   File _imageFile;
//    var date = DateTime.now();

    ImagePicker imagePicker = ImagePicker();
    PickedFile compressedImage = await imagePicker.getImage(
      source: source,
      imageQuality: 50,
    );
    // print(compressedImage.path);
    _imageFile = File(compressedImage.path);

     return _imageFile != null ? _imageFile : null;

  }

  static void clearLocalStorage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  static Future<File> compressAndGetFile(File file) async {
    var tempPath  =await getApplicationDocumentsDirectory();
    var result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path, tempPath.path+file.path.split("/").last,
      quality: 40,
      rotate: 0,
    );
    return result;
  }
}

class CustomResponse{
  var body;
  var status;
  CustomResponse(this.status,this.body);
}