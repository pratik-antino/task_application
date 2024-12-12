import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SizeConfig {
  static late double screenWidth;
  static late double screenHeight;
  static late double blockSizeHorizontal;
  static late double blockSizeVertical;

  static late double textMultiplier;
  static late double imageSizeMultiplier;
  static late double heightMultiplier;
  static late double widthMultiplier;
  static late double radiusMultiplier;
  static late bool isPortrait;
  static late bool isMobilePortrait;

  void init(BoxConstraints constraints, Orientation orientation) {
    // Set screen dimensions based on orientation
    isPortrait = orientation == Orientation.portrait;
    screenWidth = isPortrait ? constraints.maxWidth : constraints.maxHeight;
    screenHeight = isPortrait ? constraints.maxHeight : constraints.maxWidth;

    // Determine if the device is in mobile portrait mode
    isMobilePortrait = isPortrait && screenWidth < 450;

    // Calculate block sizes for responsive layout
    blockSizeHorizontal = screenWidth / 100;
    blockSizeVertical = screenHeight / 100;

    // Multiplier values for different dimensions
    textMultiplier = 1.sp;
    imageSizeMultiplier = 1.w;
    heightMultiplier = 1.h;
    widthMultiplier = 1.w;
    radiusMultiplier=1.r;
  }
}
