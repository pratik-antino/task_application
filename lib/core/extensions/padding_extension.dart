import 'package:flutter/material.dart';
import 'package:task_application/core/extensions/size_extension.dart';

extension PaddingIntX on num {
  EdgeInsets get toPaddingAllDirection =>
      EdgeInsets.symmetric(horizontal: toDouble().widthMultiplier, vertical: toDouble().heightMultiplier);

  EdgeInsets get toHorizontalPadding =>
      EdgeInsets.symmetric(horizontal: toDouble().widthMultiplier);

  EdgeInsets get toVerticalPadding =>
      EdgeInsets.symmetric(vertical: toDouble().heightMultiplier);

  EdgeInsets get toLeftOnlyPadding => EdgeInsets.only(left: toDouble().widthMultiplier);

  EdgeInsets get toRightOnlyPadding => EdgeInsets.only(right: toDouble().widthMultiplier);

  EdgeInsets get toTopOnlyPadding => EdgeInsets.only(top: toDouble().heightMultiplier);

  EdgeInsets get toBottomOnlyPadding => EdgeInsets.only(bottom: toDouble().heightMultiplier);
}