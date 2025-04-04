
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:naturesociety_new/Utils/NetworkCall.dart';
import 'package:photo_view/photo_view.dart';

class GalleryView extends StatefulWidget{
  final List  imageList;
  final int index;
  GalleryView(this.imageList, this.index);
  _GalleryView createState() => _GalleryView();
}

class _GalleryView extends State<GalleryView>{
  bool showContents = true;

  @override
  Widget build(BuildContext context) {
    int length = widget.imageList.length;

    return Scaffold(
      body: PageView.builder(
          physics: ClampingScrollPhysics(),
          itemCount:length,
          controller: PageController(initialPage: widget.index, keepPage: true, viewportFraction: 1),
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
                    imageProvider: NetworkImage(ApiCall.imageUrl+widget.imageList[position]["photo"]),
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

//                showContents? Positioned(
//                  bottom: 0,
//                  child:  Container(
//                      color: Colors.white30.withOpacity(.1),
//                      width: MediaQuery.of(context).size.width,
//
//                      padding: EdgeInsets.symmetric(vertical: 25.0,horizontal: 15.0),
//                      child: Column(
//                        mainAxisAlignment: MainAxisAlignment.end,
//                        crossAxisAlignment: CrossAxisAlignment.start,
//                        children: <Widget>[
//                          ReadMoreText(
//                            widget.eventDetails["title"],
//                            trimLines: 2,
//                            colorClickableText: Colors.white54,
//                            trimMode: TrimMode.Line,
//                            trimCollapsedText: ' ...  show more',
//                            trimExpandedText: '   show less',
//                            textAlign: TextAlign.justify,
//                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//                          ),
//
//                          SizedBox(height: 15.0,),
//
//                          Row(
//                            children: <Widget>[
//                              new Icon(Icons.local_see,color: Colors.white.withOpacity(.7),),
//                              SizedBox(width: 8.0,),
//                              new Text(widget.eventDetails["ownerName"],style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),),
//                            ],
//                          ),
//                          SizedBox(height: 15.0,),
//                          Row(
//                            mainAxisAlignment: MainAxisAlignment.end,
//                            children: <Widget>[
//                              Text("Posted on: ",style: TextStyle(color: Colors.white),),
//                              Text(StyleSheet.formatter.format(DateTime.parse(widget.eventDetails["create_date"])),style: TextStyle(color: Colors.white),),
//                            ],
//                          ),
//                        ],
//                      )
//                  ),
//                ): SizedBox.shrink(),

                showContents? Positioned(
                    top: 25.0,
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

}