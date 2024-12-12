import 'package:flutter/material.dart';
import 'package:task_application/core/extensions/size_extension.dart';

extension MarginIntX on num {
  EdgeInsets get toHorizontalMargin =>
      EdgeInsets.symmetric(horizontal: toDouble().widthMultiplier);

  EdgeInsets get toVerticalMargin =>
      EdgeInsets.symmetric(vertical: toDouble().heightMultiplier);

  EdgeInsets get toLeftOnlyMargin => EdgeInsets.only(left: toDouble().widthMultiplier);

  EdgeInsets get toRightOnlyMargin => EdgeInsets.only(right: toDouble().widthMultiplier);

  EdgeInsets get toTopOnlyMargin => EdgeInsets.only(top: toDouble().heightMultiplier);

  EdgeInsets get toBottomOnlyMargin => EdgeInsets.only(bottom: toDouble().heightMultiplier);
}
