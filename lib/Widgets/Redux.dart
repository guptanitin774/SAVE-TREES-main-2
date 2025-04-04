

import 'package:flutter/material.dart';

class AppState {
  int notificationCount = 0;
  bool isInWatchList = false;
  int cameraPhotosCount = 0;

  AppState(
      {required this.notificationCount, this.isInWatchList = false, required this.cameraPhotosCount});

  AppState.fromAppState(AppState another) {
    notificationCount = another.notificationCount;
    isInWatchList = another.isInWatchList;
    cameraPhotosCount = another.cameraPhotosCount;
  }

  int get viewFontSize => notificationCount;
}


class NotificationCount {
  final int payload;
  NotificationCount(this.payload);
}

class CameraPhotosCount {
  final int payload;
  CameraPhotosCount(this.payload);
}

class IsInWatchList{
  final bool payload;
  IsInWatchList(this.payload);
}


AppState reducer(AppState prevState, dynamic action) {
  AppState newState = AppState.fromAppState(prevState);

  if (action is NotificationCount) {
    newState.notificationCount = action.payload;
  }
  else   if (action is CameraPhotosCount) {
    newState.cameraPhotosCount = action.payload;
  }

  else if (action is IsInWatchList) {
    newState.isInWatchList = action.payload;
  }

  return newState;
}