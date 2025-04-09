import 'dart:async';
import 'dart:io' as Io;
import 'dart:io';
import 'dart:ui';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:image/image.dart' as img;

import 'package:path_provider/path_provider.dart';
class SaveFile {
  static Future<String> createFolderInAppDocDir() async {
    final Directory _appDocDirFolder =  Directory('/storage/emulated/0/SaveTrees/');
    if(await _appDocDirFolder.exists()){
      return _appDocDirFolder.path;
    }else{
      final Directory _appDocDirNewFolder=await _appDocDirFolder.create(recursive: true);
      return _appDocDirNewFolder.path;
    }
  }

 static Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    print(directory.path);

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
    img.Image image = img.decodeImage(file.readAsBytesSync())!;
    img.Image thumbnail = img.copyResize(image, height: 500, width: 500);

// Save the thumbnail as a PNG.
   return Io.File('$path/${DateTime.now().toUtc().toIso8601String()}.png')
     ..writeAsBytesSync(img.encodePng(thumbnail));
  }
}