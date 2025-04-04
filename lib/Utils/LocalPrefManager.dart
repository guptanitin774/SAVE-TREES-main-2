
import 'package:shared_preferences/shared_preferences.dart';

class LocalPrefManager{

  // -----  Token --------

  static Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<void> setToken(var token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('token', token);
  }

  // ----- Firebase Token --------
  static Future<void> setFirebaseToken(var fbToken) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('firebase_token', fbToken);
  }

  static Future<String?> getFirebaseToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('firebase_token');
  }


  // ----- User Id --------

  static Future<void> setUserId(var userId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('user-id', userId);
  }
  static Future<String?> getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('user-id');
  }


  // ----- User Name --------

  static Future<void> setUserName(var userName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('User_Name', userName);
  }
  static Future<String?> getUserName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('User_Name');
  }


  // ----- Anonymity --------

  static Future<void> setAnonymity(var anonymous) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('anonymous', anonymous);
  }

  static Future<bool?> getAnonymity() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('anonymous');
  }

  // ----- FeedBack Time --------

  static Future<int?> getLocalFeedbackTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt('local_feedback_time');
  }

  static Future<void> setLocalFeedbackTime(int count) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('local_feedback_time', count);
  }

  static Future<void> clearLocalFeedbackTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('local_feedback_time');
  }


  // ----- Firebase Fcm Token --------

  static Future<String?> getFcmToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('firebase_fcm');
  }
  static void clearFcmToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('firebase_fcm');
  }




  // ----- Live Notification --------

  static Future<bool?> getLiveNotification() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('LiveNotification');
  }


  // ----- Is Opening for First Time --------
  static Future<void> setInitialLaunch(bool isInitial) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
     prefs.setBool('Initial_Launch', isInitial);
  }
  static Future<bool?> getInitialLaunch() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('Initial_Launch');
  }


  // ----- Updation Dialog Preference --------
  static Future<void> setMainLaunch(bool isInMain) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('Main_Launch', isInMain);
  }
  static Future<bool?> getMainLaunch() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('Main_Launch');
  }



}