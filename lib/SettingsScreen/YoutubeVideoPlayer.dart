import 'dart:io';
import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/material.dart';
import 'package:naturesociety_new/Utils/NetworkCall.dart';
import 'package:naturesociety_new/Widgets/NoConnection.dart';
import 'package:naturesociety_new/Widgets/CommonWidgets.dart';
import 'package:video_player/video_player.dart';

class VideoApp extends StatefulWidget {
  final String videoLink;

  const VideoApp({Key? key, required this.videoLink}) : super(key: key);

  @override
  _VideoAppState createState() => _VideoAppState();
}

class _VideoAppState extends State<VideoApp> {
  late FlickManager flickManager;
  bool isConnected = true;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    connectionCheck();
  }

  Future<void> initController() async {
    try {
      flickManager = FlickManager(
        autoPlay: true,
        videoPlayerController: VideoPlayerController.network(
          ApiCall.imageUrl + widget.videoLink,
        ),
      );
      setState(() {
        loading = false;
      });
    } catch (e) {
      print("Error initializing video: $e");
      setState(() {
        loading = false;
      });
    }
  }

  Future<void> connectionCheck() async {
    try {
      var result = await InternetAddress.lookup("google.com");
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        setState(() {
          isConnected = true;
        });
        await initController();
      }
    } on SocketException catch (_) {
      setState(() {
        isConnected = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              Navigator.pop(context);
            },
          )
        ],
      ),
      body: isConnected
          ? loading
          ? Center(child: CommonWidgets.progressIndicator(context))
          : Padding(
        padding: const EdgeInsets.all(2.0),
        child: Center(
          child: FlickVideoPlayer(
            wakelockEnabled: true,
            flickManager: flickManager,
          ),
        ),
      )
          : NoConnection(notifyParent: connectionCheck, key: UniqueKey()),
    );
  }

  @override
  void dispose() {
    flickManager.dispose();
    super.dispose();
  }
}
