

import 'package:flutter/material.dart';

import '../config/responsive/size_config.dart';

extension SizeExtension on num {

  double get widthMultiplier => this * SizeConfig.widthMultiplier;
  double get heightMultiplier => this * SizeConfig.heightMultiplier;
  double get imageSizeMultiplier => this * SizeConfig.imageSizeMultiplier;
  double get textMultiplier => this * SizeConfig.textMultiplier;
  double get radiusMultiplier => this * SizeConfig.radiusMultiplier;
  double get screenWidth => this * SizeConfig.screenWidth;
  SizedBox get toVerticalSizedBox =>
      SizedBox(height: this * SizeConfig.heightMultiplier);
  SizedBox get toHorizontalSizedBox =>
      SizedBox(width: this * SizeConfig.widthMultiplier);
}


