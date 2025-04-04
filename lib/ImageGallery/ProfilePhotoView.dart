
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:naturesociety_new/Utils/NetworkCall.dart';
import 'package:photo_view/photo_view.dart';

class ProfilePhotoView  extends StatefulWidget{
  final profilePhoto;
  ProfilePhotoView(this.profilePhoto);
  _ProfilePhotoView createState()=> _ProfilePhotoView();
}

class _ProfilePhotoView extends State <ProfilePhotoView>
{

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body:  Stack(
        children: <Widget>[
          Hero(
            tag: "ProfilePic",
            child: PhotoView(
              imageProvider: NetworkImage(ApiCall.imageUrl + widget.profilePhoto),
              loadFailedChild: Image(image: AssetImage("assests/image_loading.png"),),
              minScale: PhotoViewComputedScale.contained * 0.8,
              maxScale: 1.0,
              gestureDetectorBehavior: HitTestBehavior.opaque,
              enableRotation: false,
              loadingBuilder: (BuildContext context, ImageChunkEvent loadingProgress){
                if (loadingProgress == null) return Container();
                return Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    backgroundColor: Colors.white54,
                    valueColor: new AlwaysStoppedAnimation<Color>(Colors.green),
                    value: loadingProgress.expectedTotalBytes != null ?
                    loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes : null,
                  ),
                );
              },
            ),
          ),

          Positioned(
            top: 0.0,
            child: Container(
              height: 120.0,
              width: MediaQuery.of(context).size.width,
              color: Colors.white30.withOpacity(.1),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  IconButton(icon: Icon(Icons.arrow_back, color: Colors.white,), onPressed: ()=> Navigator.of(context).pop(true),),
                  SizedBox(width: 10.0,),
                  Text("Profile Photo", style: TextStyle(color: Colors.white, fontSize: 20.0),),
                ],
              )
            ),
          ),
        ],
      ),
    );
  }

}