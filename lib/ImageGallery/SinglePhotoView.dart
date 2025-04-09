
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class SinglePhotoView extends StatefulWidget{

  final photo, details, initialIndex;
  SinglePhotoView(this.photo, {this.details, this.initialIndex});
  _SinglePhotoView createState()=> _SinglePhotoView();
}

class _SinglePhotoView extends State <SinglePhotoView> with  WidgetsBindingObserver{

  bool showContents = true;
  @override
  void initState(){
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      body: PageView.builder(
          physics: ClampingScrollPhysics(),
          itemCount:widget.photo.length,
          controller: PageController(initialPage: widget.initialIndex, keepPage: true, viewportFraction: 1),
          itemBuilder: (BuildContext context, int position) {
            return Stack(
              children: <Widget>[
                GestureDetector(
                  onTap: ()async{
                    setState(() {
                      showContents =!showContents;
                    });
                  },
                  child: PhotoView(
                    imageProvider: FileImage(widget.photo[position]),
                    minScale: PhotoViewComputedScale.contained * 0.8,
                    maxScale: 1.0,
                    gestureDetectorBehavior: HitTestBehavior.opaque,
                    enableRotation: false,
                    loadingBuilder: (BuildContext context, ImageChunkEvent? loadingProgress) {
                      if (loadingProgress == null) return const SizedBox.shrink();
                      return Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          backgroundColor: Colors.white54,
                          valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      );
                    },
                    errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
                      return Image.asset(
                        "assets/image_loading.png",
                        fit: BoxFit.cover,
                      );
                    },
                  ),
                ),

                showContents? Positioned(
                  bottom: 0,
                  child:  Container(
                      color: Colors.red.withOpacity(.1),
                      width: MediaQuery.of(context).size.width,
                      height: 200,

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
                ): SizedBox.shrink(),

                showContents? Positioned(
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

                ):SizedBox.shrink(),

              ],
            );
          }
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}