
import 'dart:io';

import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:naturesociety_new/Utils/NetworkCall.dart';
import 'package:naturesociety_new/Widgets/NoConnection.dart';
import 'package:video_player/video_player.dart';
import 'package:naturesociety_new/Widgets/CommonWidgets.dart';

class VideoApp extends StatefulWidget {
  final videoLink;
  VideoApp({@required this.videoLink});
  @override
  _VideoAppState createState() => _VideoAppState();
}

class _VideoAppState extends State<VideoApp> {
  VideoPlayerController _controller;
  FlickManager flickManager;
  @override
  void initState() {
    super.initState();
    connectionCheck();
  }

  Future<void> initController() async{
    flickManager = FlickManager(
      autoPlay: true,
      videoPlayerController:
      VideoPlayerController.network(ApiCall.imageUrl +
          widget.videoLink),
    );
    _controller = VideoPlayerController.network(ApiCall.imageUrl +
        widget.videoLink)
      ..initialize().then((_) {
        setState(() {
          loading=false;});
      });
  }

  bool isConnected = true;
  bool loading=true;
  Future<void> connectionCheck() async{
    try{
      var result = await InternetAddress.lookup("google.com");
      if(result.isNotEmpty && result[0].rawAddress.isNotEmpty)
        {setState(() {
          isConnected = true;
        });initController();}
    }on SocketException catch(_){
      setState(() {
        isConnected = false;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return   Scaffold(
      backgroundColor: Colors.black,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.black,
          iconTheme: IconThemeData(
            color: Colors.white
          ),
          actions: [
            IconButton(icon: Icon(Icons.close), onPressed: (){
              Navigator.pop(context);
            },)
          ],
        ),
        body: isConnected?
            loading?Center(child: CommonWidgets.progressIndicator(context)):
        Padding(
          padding: const EdgeInsets.all(2.0),
          child: Center(
            child: _controller.value.initialized
                ? AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: FittedBox(
                  fit: BoxFit.fitWidth,
                  child: SizedBox(
                      width: _controller.value.size?.width ?? 0,
                      height: _controller.value.size?.height ?? 0,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          FlickVideoPlayer(
                            wakelockEnabled: true,
                            preferredDeviceOrientation: [DeviceOrientation.portraitUp],
                              preferredDeviceOrientationFullscreen: [DeviceOrientation.portraitUp],
                              flickManager: flickManager
                          ),
                        ],
                      ))),
            )
                : Container(),
          ),
        ): NoConnection(notifyParent: connectionCheck),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    flickManager.dispose();
    super.dispose();
  }
}
