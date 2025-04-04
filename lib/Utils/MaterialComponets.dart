
import 'package:flutter/material.dart';

class MaterialTools{
  static final basicColor = Colors.teal;

  //Border
  static final borderColor = Colors.black45;
  static final borderWidth = 1.0;
  static final borderRadius = 5.0;

  static final normalTextColor = Colors.black;
  static final nonHighlightTextColor = Colors.black45;
  static final deletionColor = Colors.redAccent;
  static final tutorialBoxColor = Colors.white;

  static final appTitle = "Save Trees";


  static final labelStyle = TextStyle(color: Colors.teal,fontWeight: FontWeight.w500);

  static final materialButtonShape = RoundedRectangleBorder(side: BorderSide(color: MaterialTools.basicColor,  width: 1),
      borderRadius: BorderRadius.all(Radius.circular(5))
  );

  static final materialButtonShapeBasic = RoundedRectangleBorder(side: BorderSide(color: Colors.black45,  width: 1),
      borderRadius: BorderRadius.all(Radius.circular(5))
  );

  // Error message Style
static final errorMessageStyle = TextStyle(fontWeight: FontWeight.w800, color: Colors.black, fontSize: 16);

//chat dialog
static final hashTagHighlight = TextStyle(fontWeight: FontWeight.w600, color: Colors.red,);
static final userTagHighlight = TextStyle(fontWeight: FontWeight.w600, color: Colors.green, fontStyle: FontStyle.italic);
}