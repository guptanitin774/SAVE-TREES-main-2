
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:naturesociety_new/Utils/MaterialComponets.dart';
import 'package:naturesociety_new/Utils/NetworkCall.dart';
import 'package:naturesociety_new/Widgets/CommonWidgets.dart';
import 'package:naturesociety_new/Widgets/UploadingLoader.dart';

class SearchPlaces extends StatefulWidget{
  _SearchPlaces createState()=> _SearchPlaces();
}

class _SearchPlaces extends State<SearchPlaces>{

  @override
  void initState(){
    super.initState();
  }

  bool isConnected = true, loading = false;
  List stateList =[], cityList=[], countryList=[];

  TextEditingController _searchController = TextEditingController();
  FocusNode searchKeyboard = FocusNode();

  final searchTitle = TextStyle(fontSize: 16.0, fontWeight: FontWeight.w700);
  final subTitle = TextStyle(fontSize: 12.0, fontWeight: FontWeight.normal);

  bool emptyResult = false;

  Future<void> searchPlaces(var keyword) async{
    CustomResponse response = await ApiCall.makeGetRequestToken("location/search?keyword=$keyword");
    if(response.status == 200){
      if(json.decode(response.body)["status"]){
        if(_searchController.text.length == 0){
          cityList.clear();   stateList.clear();    countryList.clear();
        }
        else{
          if( json.decode(response.body)["Citylist"].isEmpty &&json.decode(response.body)["Statelist"].isEmpty && json.decode(response.body)["countrylist"].isEmpty  ){
            emptyResult = true;
          }
         else{
            cityList = json.decode(response.body)["Citylist"];
            stateList = json.decode(response.body)["Statelist"];
            countryList = json.decode(response.body)["countrylist"];
            emptyResult = false;
          }
        }
      }
      else{
        Fluttertoast.showToast(msg: json.decode(response.body)["msg"]);
      }
    }
    else if(response.status == 403){
      CommonWidgets.loginLimit(context);
    }
    else{
      isConnected = false;
    }
    if(mounted)
      setState(() {});
  }



  Future<void> onLocationSave(String name, String type) async{
    UploadingLoader.progressLoader(context: context, message: "Adding Location");
    Map data={
      "name": name,
      "type": type
    };
    CustomResponse response = await ApiCall.makePostRequestToken("user/saveplace", paramsData: data);
    if(response.status == 200){
      if(json.decode(response.body)["status"])
      { Navigator.pop(context);
       Navigator.of(context).pop(true);
        Fluttertoast.showToast(msg: json.decode(response.body)["msg"],
            gravity: ToastGravity.CENTER,
            backgroundColor: MaterialTools.basicColor, textColor: Colors.white);}
      else
      { Navigator.pop(context);
        Fluttertoast.showToast(msg: json.decode(response.body)["msg"],
            gravity: ToastGravity.CENTER,
            backgroundColor: MaterialTools.deletionColor, textColor: Colors.white);}
    }
    else if(response.status == 403){
      Navigator.pop(context);
      CommonWidgets.loginLimit(context);
    }
    else{
      Navigator.pop(context);
      isConnected = false;
      Fluttertoast.showToast(msg: response.body);
    }
    if(mounted)
      setState(() {});
  }

  @override
  void dispose(){
    super.dispose();
    _searchController.dispose();
    searchKeyboard.dispose();
  }

  Future<bool> _onWillPop() async{
    Navigator.of(context).pop(true);
    return Future.value(false);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: buildBar(context),

        body: SafeArea(
          child: emptyResult ?Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset("assets/noSearchResult.png"),
              Text("No Search Results", style: MaterialTools.errorMessageStyle,)
            ],
          ) : ListView(
            padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: countyListing(context),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: stateListing(context),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: cityListing(context),
              )
            ],
          ),
        ),
      ),
    );
  }

  countyListing(BuildContext context){
    List<Widget> countryData =<Widget>[];
    countryList.forEach((element) {
      countryData.add(InkWell(
        onTap: (){
          onLocationSave(element["country"], "Country");
        },
        child:  Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(Icons.language),
            SizedBox(width: 10.0,),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(element["country"], style: searchTitle,),
                Text("country", style: subTitle,),
                Divider(),
              ],
            ),
          ],
        ),
      ));
    });
    return countryData.toList();
  }

  stateListing(BuildContext context){
    List<Widget> stateData =<Widget>[];
    stateList.forEach((element) {
      stateData.add(InkWell(
        onTap: (){
          onLocationSave(element["state"], "State");
        },
        child:  Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(Icons.language),
            SizedBox(width: 10.0,),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(element["state"], style: searchTitle,),
                Text("State in ${element["country"]["country"]}", style: subTitle,),
                Divider(),
              ],
            ),
          ],
        ),
      ));
    });
    return stateData.toList();
  }

  cityListing(BuildContext context){
    List<Widget> cityData =<Widget>[];
    cityList.forEach((element) {
      cityData.add(InkWell(
        onTap: (){
          onLocationSave(element["city"], "City");
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(Icons.language),
            SizedBox(width: 10.0,),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(element["city"], style: searchTitle,),
                Text("City in ${element["state"]["state"]} State", style: subTitle,),
                Divider(),
              ],
            ),
          ],
        ),
      ));
    });
    return cityData.toList();
  }

  PreferredSizeWidget buildBar(BuildContext context) {
    return new AppBar(
      centerTitle: true,
      automaticallyImplyLeading: false,
      elevation: 1.0,
      backgroundColor: Colors.white,
      title: TextField(
        autofocus: true,
        focusNode: searchKeyboard,
        controller: _searchController,
        style: new TextStyle(color: Colors.black),
        onChanged: searchPlaces,
        decoration: new InputDecoration(
            border: InputBorder.none,
            prefixIcon: new Icon(Icons.search, color: Colors.black),
            hintText: "Search a City / State / Country",
            hintStyle: new TextStyle(color: Colors.grey)
        ),
        onSubmitted: searchPlaces,
        keyboardType: TextInputType.streetAddress,
          textInputAction: TextInputAction.search
      ),
    );
  }
}