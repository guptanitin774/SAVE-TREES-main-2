import 'dart:async';
import 'dart:convert';
import 'dart:io' as Io;
import 'dart:io';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:image/image.dart';
import 'package:intl/intl.dart';
import 'package:naturesociety_new/Utils/NetworkCall.dart';

import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
class SaveCaseListLocally {

  static Future<void> clearStoredCases(var imageList) async {
    final delDir = Directory(imageList);
    delDir.deleteSync(recursive: true);
  }

  static Future<String> get _localPath async {
    final directory = await getExternalStorageDirectory();
    return directory.path;
  }
  static Future<Io.File> getImageFromNetwork(String url) async {
    Io.File file = await DefaultCacheManager().getSingleFile(url);
    return file;
  }

  static Future<Io.File> saveImage(String url) async {

    final file = await getImageFromNetwork(url);
    //retrieve local path for device
    var path = await _localPath;
    Image image = decodeImage(file.readAsBytesSync());

    // For Image resize & Compression.
    Image thumbnail = copyResize(image,width: 100, height: 100,);

    // Save the thumbnail as a PNG.
    return new Io.File('$path/${DateTime.now().toUtc().toIso8601String()}.png')
      ..writeAsBytesSync(encodePng(thumbnail));
  }
  var formatter = new DateFormat('H:m:s');
  var formatter2 = new DateFormat('dd-MM-yyyy');

  static timeCalculation(var time){

    final today = DateTime.now();
    final caseDate =DateTime.parse(time);
    final difference =today.difference(caseDate).inDays;

    if(difference == 0)
    {
      final caseTime1 = DateTime.parse(time);
      final timeDifference =today.difference(caseTime1).inHours;
      if(timeDifference == 0) {
        final caseTime = DateTime.parse(time);
        final minDifference = today.difference(caseTime).inMinutes;

        if(minDifference == 0)
          return "added now";
        else
          return "$minDifference mins ago";
      }
      else
        return "$timeDifference hrs ago";
    }
    else
      return "$difference days ago";
  }

  static Future<void> arrangeData(var data) async{
    print(data.length);
    var cred;
    SharedPreferences prefs2 = await SharedPreferences.getInstance();
    cred = prefs2.getString('offlineCaseList');

    if(cred != null) {
      cred = json.decode(cred);
      for (int i = 0; i < cred.length; i++)
        for (int j = 0; j < cred[i]["photos"].length; j++)
          clearStoredCases(cred[i]["photos"][j]["path"]);

      SharedPreferences prefs1 = await SharedPreferences.getInstance();
      prefs1.remove('offlineCaseList');
      List fileInfo = [];

      if(data.length > 4)
      for(int i=0; i< 4; i++) {
        var time = timeCalculation(data[i]["createddate"]);
        List photos = [];
        for (int j = 0; j < data[i]["photos"].length; j++) {
          var cachedImage = await saveImage(ApiCall.imageUrl + data[i]["photos"][j]["photo"]);
          Map photoData = {
            "path" : cachedImage.path
          };
          photos.add(photoData);
        }

        Map dataList = {
          'caseId' : data[i]["caseidentifier"] == null ? data[i]["caseid"] : data[i]["caseidentifier"]  ,
          'id' : data[i]["_id"],
          'placeName': data[i]["locationname"],
          'mightbecut': data[i]["mightbecut"],
          'beencut': data[i]["beencut"],
          'havebeencut': data[i]["havebeencut"],
          'userName': data[i]["isanonymous"] ? "Anonymous" : data[i]["addedby"]["name"],
          'time': time,
          'photos': photos,
        };
        fileInfo.add(dataList);
      }
      else
        for(int i=0; i< data.length; i++) {
          var time = timeCalculation(data[i]["createddate"]);
          List photos = [];
          for (int j = 0; j < data[i]["photos"].length; j++) {
            var cachedImage = await saveImage(ApiCall.imageUrl + data[i]["photos"][j]["photo"]);
            Map photoData = {
              "path" : cachedImage.path
            };
            photos.add(photoData);
          }

          Map dataList = {
            'caseId' : data[i]["caseidentifier"] == null ? data[i]["caseid"] : data[i]["caseidentifier"],
            'id' : data[i]["_id"],
            'placeName': data[i]["locationname"],
            'mightbecut': data[i]["mightbecut"],
            'beencut': data[i]["beencut"],
            'havebeencut': data[i]["havebeencut"],
            'userName': data[i]["isanonymous"] ? "Anonymous" : data[i]["addedby"]["name"],
            'time': time,
            'photos': photos,
          };
          fileInfo.add(dataList);
        }
      var arrangedData = json.encode(fileInfo);
      SharedPreferences preference2 = await SharedPreferences.getInstance();
      preference2.setString("offlineCaseList", arrangedData);

    }
    else
      {
        if(data.length > 4)
          {
            List fileInfo = [];
            for(int i=0; i< 4; i++) {
              var time = timeCalculation(data[i]["createddate"]);
              List photos = [];
              for (int j = 0; j < data[i]["photos"].length; j++) {
                var cachedImage = await saveImage(ApiCall.imageUrl + data[i]["photos"][j]["photo"]);
                Map photoData = {
                  "path" : cachedImage.path
                };
                photos.add(photoData);
              }
              Map dataList = {
                'caseId' : data[i]["caseidentifier"] == null ? data[i]["caseid"] : data[i]["caseidentifier"],
                'id' : data[i]["_id"],
                'placeName': data[i]["locationname"],
                'mightbecut': data[i]["mightbecut"],
                'beencut': data[i]["beencut"],
                'havebeencut': data[i]["havebeencut"],
                'userName': data[i]["isanonymous"] ? "Anonymous" : data[i]["addedby"]["name"],
                'time': time,
                'photos': photos,
              };
              fileInfo.add(dataList);
            }
            var arrangedData = json.encode(fileInfo);
            SharedPreferences preference2 = await SharedPreferences.getInstance();
            preference2.setString("offlineCaseList", arrangedData);
          }
        else
          {
            List fileInfo = [];
            for(int i=0; i< data.length; i++) {
              var time = timeCalculation(data[i]["createddate"]);
              List photos = [];
              for (int j = 0; j < data[i]["photos"].length; j++) {
                var cachedImage = await saveImage(ApiCall.imageUrl + data[i]["photos"][j]["photo"]);
                Map photoData = {
                  "path" : cachedImage.path
                };
                photos.add(photoData);
              }
              Map dataList = {
                'caseId' : data[i]["caseidentifier"] == null ? data[i]["caseid"] : data[i]["caseidentifier"],
                'id' : data[i]["_id"],
                'placeName': data[i]["locationname"],
                'mightbecut': data[i]["mightbecut"],
                'beencut': data[i]["beencut"],
                'havebeencut': data[i]["havebeencut"],
                'userName': data[i]["isanonymous"] ? "Anonymous" : data[i]["addedby"]["name"],
                'time': time,
                'photos': photos,
              };
              fileInfo.add(dataList);
            }
            var arrangedData = json.encode(fileInfo);
            SharedPreferences preference2 = await SharedPreferences.getInstance();
            preference2.setString("offlineCaseList", arrangedData);
          }

      }
  }

}