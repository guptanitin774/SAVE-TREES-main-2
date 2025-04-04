

import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

 class UploadChatMedia extends StatefulWidget{
  final image;
  UploadChatMedia(this.image);
  _UploadChatMedia createState()=> _UploadChatMedia();
}

class _UploadChatMedia extends State<UploadChatMedia>{


   File displayImage;
   @override
   void initState(){
     super.initState();
     displayImage = widget.image[0] ;
   }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: PageView.builder(
          physics: ClampingScrollPhysics(),
          itemCount:1,
          controller: PageController(initialPage: 1, keepPage: true, viewportFraction: 1),
          itemBuilder: (BuildContext context, int position) {
            return Stack(
              children: <Widget>[
                PhotoView(
                  imageProvider: FileImage( displayImage),
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
                Positioned(
                  bottom: 0,
                  child:  Container(
                      color: Colors.white30.withOpacity(.1),
                      width: MediaQuery.of(context).size.width,

                      padding: EdgeInsets.symmetric(vertical: 25.0,horizontal: 15.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[


                          SizedBox(height: 15.0,),

                          Row(
                            children: <Widget>[
                              new Icon(Icons.image,color: Colors.white.withOpacity(.7),),
                              SizedBox(width: 8.0,),
                              new Text("Case Image",style: TextStyle(color: Colors.white.withOpacity(.7), fontWeight: FontWeight.w600),),
                            ],
                          ),
                          SizedBox(height: 15.0,),
                        ],
                      )
                  ),
                ),

                 Positioned(
                    top: 20,
                    child:  Container(
                      color: Colors.white30.withOpacity(.1),
                      width: MediaQuery.of(context).size.width,
                      child: Row(
                        children: <Widget>[
                          IconButton(icon: Icon(Icons.clear, color: Colors.white.withOpacity(.7),),
                            onPressed: ()=>Navigator.pop(context),)
                        ],
                      ),
                    )

                ),

              ],
            );
          }
      ),
    );
  }

}