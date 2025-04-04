
import 'package:flutter/material.dart';

class UploadingLoader{

  static Future<void> progressLoader({required BuildContext context, required String message}) async {
      return showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return new WillPopScope(
                onWillPop: () async => false,
                child: SimpleDialog(
                    backgroundColor: Colors.teal.withOpacity(.7),
                    children: <Widget>[
                      Center(
                        child: Column(children: [
                          CircularProgressIndicator( strokeWidth: 2.5,  valueColor: new AlwaysStoppedAnimation<Color>(Colors.white),),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            "Please Wait",
                            style: TextStyle(color: Colors.white),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            message ?? "Uploading",
                            style: TextStyle(color: Colors.white),
                          )
                        ]),
                      )
                    ]));
          });
  }

}

