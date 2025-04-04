import 'dart:async';
import 'dart:io';

import 'package:audioplayers/src/source.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:naturesociety_new/ImageGallery/SinglePhotoView.dart';
import 'package:naturesociety_new/Utils/NetworkCall.dart';
import 'package:naturesociety_new/Widgets/CommonFunction.dart';
import 'package:naturesociety_new/Widgets/CommonWidgets.dart';
import 'package:naturesociety_new/Widgets/Redux.dart';
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';



class TakePictureScreen extends StatefulWidget {
  @override
  TakePictureScreenState createState() => TakePictureScreenState();
}

class TakePictureScreenState extends State<TakePictureScreen> {
  late CameraController _controller ;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    cameraPermissionHandler();
        SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
  }
  late bool cameraPermission;

  cameraPermissionHandler()async{
    await Permission.camera.request();
    if(await Permission.camera.isDenied){
      Navigator.of(context).pop(<File>[]);
      return;
    }
    if(await Permission.camera.isPermanentlyDenied){
      Fluttertoast.showToast(msg: "Camera permission not granted");
      Navigator.of(context).pop(<File>[]);
      CommonWidgets.permissionDialog(context: context, type: "Camera");
      return;
    }
    else
    WidgetsBinding.instance.addPostFrameCallback((_){
      setAll();
    });
  }

bool loading = true;
  void setAll() async {
    final cameras = await availableCameras();
     final firstCamera = cameras[0];

    _controller = CameraController(
       firstCamera,
       ResolutionPreset.high,
      enableAudio: false
    );
     _initializeControllerFuture = _controller.initialize().then((_) {
       if (!mounted) {
         return;
       }
       setState(() {});
     });
    Future.delayed(const Duration(seconds: 1), ()async {
      setState(() {
        loading = false;
      });
    });
  }

  @override
  void dispose() {
    if(_controller != null)
     _controller.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    super.dispose();
  }

  void onTapCancel() async{
    Navigator.of(context).pop(<File>[]);
  }
  List<File> fileList = [];

  void onTapCapture() async{
    try {
      await _initializeControllerFuture;
      final path = join((await getTemporaryDirectory()).path, '${DateTime.now()}.jpeg');
      await _controller.takePicture().then((XFile file) => file.saveTo(path));

      var returnValue;
      CommonFunction.player.play(CommonFunction.messageReply as Source, volume: 0.5);
      returnValue = await Navigator.push(context, MaterialPageRoute(builder: (context) => DisplayPictureScreen(imagePath: path, key: UniqueKey())));
      if(returnValue.isNotEmpty)
      {
        final compression =  await ApiCall.compressAndGetFile(File(returnValue));
        fileList.add(compression as File);
        setState(() {});

      }
    } catch (e) {
      print(e);
    }
  }

  void onTapProceed() async{
    fileList.isNotEmpty ? Navigator.of(context).pop(fileList) : Navigator.of(context).pop(null);
  }

  Future<bool> _willPopScope() async{
    Navigator.of(context).pop(<File>[]);
    return Future.value(false);
  }
int tapCount = 0;
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _willPopScope,
      child: StoreConnector<AppState, AppState>(
        converter: (store) => store.state,
        builder: (context, state) {
       return Scaffold(
          body:SafeArea(
              child: loading ? CommonWidgets.progressIndicator(context):
              Stack(
                children: <Widget>[
                  CameraPreview(_controller),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Wrap(
                      children: <Widget>[
                        fileList.isNotEmpty ?
                            Container(
                              height: 80.0,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                  physics: BouncingScrollPhysics(),
                                  padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
                                  itemCount: fileList.length,
                                  itemBuilder: (BuildContext context, int index){
                                return Container(
                                  height: 70.0, width: 70.0,
                                  padding: EdgeInsets.symmetric(horizontal: 5.0),
                                  child: GestureDetector(
                                    onTap: () => Navigator.push(context, MaterialPageRoute(
                                        builder: (context) => SinglePhotoView(fileList, initialIndex: index,))),
                                    child: Card(
                                        elevation: 15.0,
                                        child: Image.file(fileList[index], fit: BoxFit.cover, width: 50.0,)),
                                  ),
                                );
                              }),
                            ):SizedBox.shrink(),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 20.0),
                          color: Colors.black,
                          height: 100.0, width: double.infinity,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              GestureDetector(
                                  onTap: (){
                                    print(tapCount);
                        StoreProvider.of<AppState>(context).dispatch(CameraPhotosCount(state.cameraPhotosCount - tapCount));
                                    onTapCancel();},
                                  child: Text("Cancel", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),)),
                              Spacer(),
                              GestureDetector(
                                  onTap: ()=> fileList.length >0 || fileList.isNotEmpty ? onTapProceed() : Fluttertoast.showToast(msg: "You have'nt capture any photo"),
                                  child: Text("Proceed", style: TextStyle(color: Colors.teal, fontWeight: FontWeight.w500),)),
                              SizedBox(
                                width: 10.0,
                                child: Icon(Icons.arrow_forward_ios, color: Colors.teal,),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              )),

              floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,

              floatingActionButton: FloatingActionButton(
                elevation: 5.0,
                onPressed: ()  {
                  if( state.cameraPhotosCount >8 )
                    Fluttertoast.showToast(msg: "Max Upload Photos count is 8");
                  else
                   {
                     tapCount ++;
                     print(tapCount);
                     StoreProvider.of<AppState>(context).dispatch(CameraPhotosCount(state.cameraPhotosCount +1));
                     onTapCapture();
                   }
                },
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 40.0,
                ),
              ),
        );}
      ),
    );
  }
}

class DisplayPictureScreen extends StatefulWidget{
  _DisplayPictureScreen createState()=> _DisplayPictureScreen();
  final String imagePath;

  const DisplayPictureScreen({required Key key, required this.imagePath}) : super(key: key);
}
class _DisplayPictureScreen extends State<DisplayPictureScreen> {


  void onImageCancel() async{
    Navigator.of(context).pop();
    Navigator.of(context).pop(<File>[]);
  }
  void onImageReTake() async{
    Navigator.of(context).pop();
  }
  void onImageChoose() async{
    Navigator.of(context).pop(widget.imagePath);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black54,
      appBar: AppBar(
        backgroundColor: Colors.black,
          automaticallyImplyLeading: false,
          centerTitle: true,
          title: Text('Photo View',style: TextStyle(color: Colors.white),)),
      body: Stack(
        children: <Widget>[
          Center(child: Image.file(File(widget.imagePath),fit: BoxFit.cover, )),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 15.0),
              color: Colors.black.withOpacity(0.9),
              height: 100, width: double.infinity,
              child: Row(
                children: <Widget>[
                  IconButton(
                    icon: Icon(Icons.clear),
                    color: Colors.white,
                    onPressed: ()=>onImageCancel(),
                  ),
                  Spacer(),
                  IconButton(
                    icon: Icon(Icons.refresh),
                    color: Colors.white,
                    onPressed: ()=>onImageReTake(),
                  ),
                  Spacer(),
                  IconButton(
                    icon: Icon(Icons.done),
                    color: Colors.white,
                    onPressed: ()=>onImageChoose(),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
