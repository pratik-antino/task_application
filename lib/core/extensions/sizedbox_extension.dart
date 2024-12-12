import 'package:flutter/material.dart';

extension SizedBoxExtension on num {
  SizedBox get verticalSizedBox => SizedBox(height: toDouble());
  SizedBox get horizontalSizedBox => SizedBox(width: toDouble());
}
