
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:naturesociety_new/OfflineCreditinals/SaveFile.dart';
import 'package:naturesociety_new/Utils/NetworkCall.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_view/photo_view.dart';


class GalleryImageView extends StatefulWidget{
  final List  imageList;
  final int index;
  final  getdata;
  GalleryImageView(this.imageList, this.index, this.getdata);

  _GalleryImageView createState() => _GalleryImageView();
}

class _GalleryImageView extends State<GalleryImageView>{
  late PageController _pageController;
  late int pageIndex;

  @override
  void initState()
  {
    super.initState();
    pageIndex = widget.index;
   firstPage =  widget.index == 0 ?  true : false;
   lastPage = widget.index == widget.imageList.length -1? true : false;
    _pageController = PageController(initialPage: widget.index);
    print(widget.getdata);
    print(widget.imageList);
  }

  var dateFormatter = new DateFormat('dd-MMM-yyyy');
  late bool firstPage, lastPage ;
  final textStyle = TextStyle(color: Colors.white, fontWeight: FontWeight.w600);
  final dateStyle = TextStyle(color: Colors.white, fontWeight: FontWeight.w600);


  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 5.0,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text("Gallery Images", style: TextStyle(color: Colors.white),),
      ),
      body: SafeArea(
        child: PageView.builder(
          itemCount: widget.imageList.length,
          controller: _pageController,
          scrollDirection: Axis.horizontal,
          onPageChanged: (val){

            setState(() {
              pageIndex = val;
            });
            if(pageIndex == 0) {
              firstPage = true;
              lastPage = false;
            }
            else if(pageIndex == widget.imageList.length -1)
              {
                firstPage = false;
                lastPage = true;
              }
            else
              {
                firstPage = false;
                lastPage = false;
              }
          },
          itemBuilder: (context, pageIndex){

            return GestureDetector(
              onLongPress: () =>bottomSheet(context),
              child: Stack(
                children: [


                  PhotoView(
                    backgroundDecoration: BoxDecoration(color: Colors.black,),

                    imageProvider: CachedNetworkImageProvider(ApiCall.imageUrl+widget.imageList[pageIndex]["photo"],),
                     minScale: PhotoViewComputedScale.contained * 1.0,

                    maxScale: 2.0,
                    gestureDetectorBehavior: HitTestBehavior.opaque,
                    enableRotation: false,
                      loadingBuilder: (BuildContext context, ImageChunkEvent? loadingProgress) {
                        if (loadingProgress == null || loadingProgress.expectedTotalBytes == null) {
                          return Container();
                        }
                        return Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            backgroundColor: Colors.white54,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                            value: loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!,
                          ),
                        );
                      },
                  ),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white10, width: 1.5),
                      color: Colors.transparent.withOpacity(0.3)
                    ),
                    height: 80.0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[

                        IconButton(icon: Icon(Icons.arrow_back_ios, color:firstPage? Colors.grey: Colors.teal,),
                          onPressed: firstPage ? null :() {
                            pageIndex --;
                            _pageController.jumpToPage(pageIndex);
                            if(pageIndex ==  widget.imageList.length - 1)
                              firstPage = true;
                            setState(() {});
                          },),

                        Expanded(
                            flex: 0,
                            child: Text("(" + (pageIndex + 1).toString() + "/" + (widget.imageList.length).toString() + ")", style: textStyle,)),
                        SizedBox(width: 5.0,),
                        Expanded(
                            flex: 0,child: Text(dateFormatter.format(DateTime.parse(widget.getdata["createddate"])), style: dateStyle,)),
                        SizedBox(width: 5.0,),
                        Expanded(
                            flex: 0,child: Text( widget.getdata["isupdate"]?  "Update: " : "Initial: ", style: textStyle,)),
                        Expanded(
                          flex: 1,
                          child: Text(widget.getdata["isanonymous"] ? "Anonymous" :widget.getdata["addedby"]["name"], style: textStyle,
                            maxLines: 1, overflow: TextOverflow.ellipsis,),
                        ),


                        IconButton(icon: Icon(Icons.arrow_forward_ios, color: lastPage ? Colors.grey : Colors.teal,),
                          onPressed:lastPage? null: (){
                            pageIndex ++;
                            _pageController.jumpToPage(pageIndex);
                            if(pageIndex == widget.imageList.length - 1)
                              lastPage = true;
                            setState(() {});
                          },)
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void bottomSheet(BuildContext context) {
    showModalBottomSheet(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(topRight: Radius.circular(10.0),
              topLeft: Radius.circular(10.0))
        ),
        context: context,
        builder: (BuildContext bc) {
          return Container(
            height: 80.0,
            padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 10.0),
            child: TextButton.icon(onPressed: () =>mediaPermission(), icon: Icon(Icons.save_alt, size: 30,),
                label: Text("Save Photo", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),)),

            // child: InkWell(
            //   onTap: () =>mediaPermission(),
            //    child: Row(
            //     mainAxisAlignment: MainAxisAlignment.center,
            //     crossAxisAlignment: CrossAxisAlignment.end,
            //     children: <Widget>[
            //       Icon(Icons.save_alt, size: 30,),
            //       SizedBox(width: 10.0,),
            //       Text("Save Photo", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),),
            //     ],
            //   ),
            // )
          );
        }
    );
  }

  mediaPermission() async {
    await Permission.storage.request();
    if (await Permission.storage.isDenied) {
      print(await Permission.storage.isGranted);
      if (!await Permission.storage.isGranted) {
        Fluttertoast.showToast(msg: "Access Storage permission not granted");
        Navigator.of(context).pop(false);
        openAppSettings();
        return;
      }
    } else if (await Permission.storage.isPermanentlyDenied) {
      Fluttertoast.showToast(msg: "Access Storage permission not granted");
      Navigator.of(context).pop(false);
      openAppSettings();
      return;
    }
    else
      saveFile();
  }


  Future<void> saveFile()async{
    Navigator.pop(context);
    File downloaded  = await SaveFile.saveImage(ApiCall.imageUrl+widget.imageList[pageIndex]["photo"]);
    var path = await SaveFile.createFolderInAppDocDir();
    downloaded.copy(path + widget.getdata["caseidentifier"]+"-${widget.getdata["isupdate"]?  "update" : "initial"}"+" case "+"Image-${pageIndex+1}"+".png");

    if(downloaded != null)
      Fluttertoast.showToast(msg: "Photo has been Saved!");
    else
      Fluttertoast.showToast(msg: "Sorry can't get path");
  }

  @override
  void dispose(){
    _pageController.dispose();
    super.dispose();
  }
}