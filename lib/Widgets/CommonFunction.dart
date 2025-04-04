import 'dart:convert';
import 'dart:io';

import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:naturesociety_new/Utils/LocalPrefManager.dart';
import 'package:naturesociety_new/Utils/NetworkCall.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';


class CommonFunction {
  static Future<bool> uploadPhoto(File _image) async {

    var request = http.MultipartRequest('POST', Uri.parse(ApiCall.webUrl + 'user/photo'));
    String to = await LocalPrefManager.getToken();

    request.headers.addAll({'Content-Type': 'application/form-data', 'x-auth-token': to});
    // request.fields.addAll(data);

    if (_image != null) {
      request.files.add(http.MultipartFile.fromBytes(
          'photo', _image.readAsBytesSync(),
          filename: _image.path.split('/').last));

    }
    try {
      http.Response response = await http.Response.fromStream(await request.send());
      print(json.decode(response.body)["status"]);
      return true;
    } catch (e) {
      print(e);
      return false;
    }

  }

  static var timeFormatter = new DateFormat('hh:mm a');
  static var dateFormatter = new DateFormat('dd MMM yyyy');
  static var profileDateFormatter = new DateFormat('dd/M/yyyy');
  static var calenderDateFormatter = new DateFormat('MM-dd-yyyy');
  static var convertDateString = new DateFormat('yyyyMMdd');

  static exactTime(var time){
    final caseTime = DateTime.parse(time);
    final DateFormat formatter = DateFormat('jm');
    final String formatted = formatter.format(caseTime.toLocal());
    return formatted;
  }

  static timeCalculation(var time) {
    final today = DateTime.now();
    final caseDate = DateTime.parse(time);
    final difference = today.difference(caseDate).inDays;

    if (difference == 0) {
      final caseTime1 = DateTime.parse(time);
      final timeDifference = today.difference(caseTime1).inHours;
      if (timeDifference == 0) {
        final caseTime = DateTime.parse(time);
        final minDifference = today.difference(caseTime).inMinutes;

        if (minDifference == 0)
          return "added now";
        else
          return "$minDifference mins ago";
      } else
        return "$timeDifference hrs ago";
    } else if (difference == 1)
      return "Yesterday";
    else if (difference <= 30)
      return "$difference days ago";
    else
      return CommonFunction.dateFormatter
          .format(DateTime.parse(time).toLocal());
  }

  static timeWithStatus(var time) {
    final today = DateTime.now();
    final caseDate = DateTime.parse(time);
    final difference = today.difference(caseDate).inDays;

    if (difference == 0) {
      final caseTime1 = DateTime.parse(time);
      final timeDifference = today.difference(caseTime1).inHours;
      if (timeDifference == 0) {
        final caseTime = DateTime.parse(time);
        final minDifference = today.difference(caseTime).inMinutes;

        if (minDifference == 0)
          return "added now";
        else
          return "$minDifference mins ago";
      } else
        return "$timeDifference hrs ago";
    } else if (difference == 1)
      return "Yesterday";
    else
      return CommonFunction.dateFormatter
          .format(DateTime.parse(time).toLocal());
  }


  static notificationTimeStatus(var time) {
    final today = DateTime.now();
    final caseDate = DateTime.parse(time);
    final difference = today.difference(caseDate).inDays;

    final caseTime = DateTime.parse(time);
    final DateFormat formatter = DateFormat('jm');
    final String formatted = formatter.format(caseTime.toLocal());


    if (difference == 0) {
      final caseTime1 = DateTime.parse(time);
      final timeDifference = today.difference(caseTime1).inHours;
      if (timeDifference == 0) {
        final caseTime = DateTime.parse(time);
        final minDifference = today.difference(caseTime).inMinutes;

        if (minDifference == 0)
          return "added now";
        else
          return "$minDifference mins ago";
      } else
        return "$timeDifference hrs ago";
    } else if (difference == 1)
      return "Yesterday at $formatted";
    else
      return CommonFunction.dateFormatter.format(DateTime.parse(time).toLocal())+" at "+formatted;
  }


  static createDynamicLink({@required var caseId,@required  var title,@required  var description ,@required  var image}) async {
    String _linkMessage;
    final DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix: 'https://ndns.page.link',
     // link: Uri.parse('http://naturesociety.leopardtechlabs.com/$caseId'),
      link: Uri.parse('http://savetrees.ndns.in/$caseId'),
      androidParameters: AndroidParameters(
        packageName: 'ndns.save_trees',
        minimumVersion: 0,
      ),
      dynamicLinkParametersOptions: DynamicLinkParametersOptions(
        shortDynamicLinkPathLength: ShortDynamicLinkPathLength.short,
      ),
      iosParameters: IosParameters(
        bundleId: 'com.google.FirebaseCppDynamicLinksTestApp.dev',
        minimumVersion: '0',
      ),
      socialMetaTagParameters: SocialMetaTagParameters(
        description: description,
        imageUrl: Uri.parse(ApiCall.imageUrl+ image),
        title: title

      ),
    );

    Uri url;
    final ShortDynamicLink shortLink = await parameters.buildShortLink();
    url = shortLink.shortUrl;

    _linkMessage = url.toString();
    if (_linkMessage != null)
      return _linkMessage;
    else
      return null;
  }



  static AudioPlayer  player = new AudioPlayer();
  static const messageSend = "message_send.mp3";
  static const messageReply = "message_reply.mp3";


  static Future<void> openMap(double latitude, double longitude) async {
    String googleUrl = 'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    if (await canLaunch(googleUrl)) {
      await launch(googleUrl);
    } else {
      throw 'Could not open the map.';
    }
  }


}
