import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_swiper_null_safety/flutter_swiper_null_safety.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:naturesociety_new/LoginScreens/Signup.dart';
import 'package:naturesociety_new/Utils/MaterialComponets.dart';

class LoginSignUpWithOnBoarding extends StatefulWidget {
  _LoginSignUpWithOnBoarding createState() => _LoginSignUpWithOnBoarding();
}

class _LoginSignUpWithOnBoarding extends State<LoginSignUpWithOnBoarding> {
  List displayData = [
    DisplayDataModel(
        image: "assets/A.jpg",
        text:
            "A tree produces oxygen, controls air pollution, recharges ground water table, provides food and shelter to wildlife, prevents soil erosion, controls ambient air temperature, generates rainfall etc."),
    DisplayDataModel(
        image: "assets/B.jpg",
        text: "Everyday trees are being cut all over the world."),
    DisplayDataModel(
        image: "assets/C.jpg",
        text:
            "Sometimes we don’t know what to do to save the trees from being cut."),
    DisplayDataModel(
        image: "assets/D.jpg",
        text:
            "But if we know what to do, then maybe we don’t know where they are being cut."),
    DisplayDataModel(
        image: "assets/E.jpg",
        text: "So, we can use this app to connect with people to save trees."),
  ];
  late DateTime currentBackPressedTime;

  Future<bool> onWillPop() {
    DateTime now = DateTime.now();
    if (currentBackPressedTime == null ||
        now.difference(currentBackPressedTime) > Duration(seconds: 2)) {
      currentBackPressedTime = now;
      Fluttertoast.showToast(msg: "Press again to exit the app");
      return Future.value(false);
    } else {
      SystemNavigator.pop();
      return Future.value(true);
    }
  }

  @override
  void initState() {
    super.initState();
    checkForUpdate();
  }

  late AppUpdateInfo _updateInfo;

  Future<void> checkForUpdate() async {
    InAppUpdate.checkForUpdate().then((info) {
      setState(() {
        _updateInfo = info;
      });
    }).catchError((e) => {_showError(e), print(e)});
  }

  void _showError(dynamic exception) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(exception.toString())));
  }

  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: Column(
        children: [
          Container(
            color: Colors.white.withOpacity(0.01),
            height: MediaQuery.of(context).size.height - 150,
            width: double.infinity,
            child: Swiper(
              itemBuilder: (
                BuildContext context,
                int k,
              ) {
                return Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Container(
                          child: Image(
                            image: AssetImage(displayData[k].image),
                            fit: BoxFit.cover,
                            width: double.infinity,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  backgroundColor: Colors.white54,
                                  valueColor: new AlwaysStoppedAnimation<Color>(
                                      Colors.green),
                                  value: loadingProgress.expectedTotalBytes !=
                                          null
                                      ? (loadingProgress.cumulativeBytesLoaded /
                                          (loadingProgress.expectedTotalBytes
                                              as num))
                                      : null,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 0,
                        child: Container(
                          padding: EdgeInsets.all(10.0),
                          child: Text(
                            displayData[k].text,
                            textAlign: TextAlign.left,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 20.0,
                      ),
                    ],
                  ),
                );
              },
              itemCount: displayData.length,
              pagination: displayData.length > 1
                  ? SwiperPagination(
                      builder: new DotSwiperPaginationBuilder(
                          color: Colors.grey,
                          activeColor: MaterialTools.basicColor),
                      alignment: Alignment.bottomCenter,
                      margin: EdgeInsets.all(2.0))
                  : SwiperPagination(builder: SwiperPagination.rect),
              loop: false,
              autoplay: false,
            ),
          ),
          Spacer(),
          Container(
            margin: EdgeInsets.all(0.0),
            decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                // BoxShape.circle or BoxShape.retangle
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey,
                    blurRadius: 5.0,
                  ),
                ]),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  SizedBox(
                    height: 10,
                  ),
                  MaterialButton(
                    elevation: 1.0,
                    height: 50,
                    shape: RoundedRectangleBorder(
                        side: BorderSide(
                            color: MaterialTools.basicColor, width: 1),
                        borderRadius: BorderRadius.all(Radius.circular(5))),
                    minWidth: double.infinity,
                    onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SignUp("Sign Up"))),
                    textColor: Colors.black,
                    color: Colors.white,
                    child: Text(
                      "Sign Up",
                      style: TextStyle(
                          color: MaterialTools.basicColor,
                          fontWeight: FontWeight.w800),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  MaterialButton(
                    elevation: 1.0,
                    height: 50,
                    minWidth: double.infinity,
                    shape: RoundedRectangleBorder(
                        side: BorderSide(
                            color: MaterialTools.basicColor, width: 1),
                        borderRadius: BorderRadius.all(Radius.circular(5))),
                    onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SignUp("Login"))),
                    textColor: Colors.white,
                    color: MaterialTools.basicColor,
                    child: Text(
                      "Login",
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DisplayDataModel {
  final image;
  final text;

  DisplayDataModel({this.image, this.text});
}
