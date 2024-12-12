import 'package:flutter/material.dart';

abstract class AppColors {
  //Text colors
  static const Color text50 = Color(0xffeaebed);
  static const Color text75 = Color(0xffa8acb4);
  static const Color text100 = Color(0xff838a94);
  static const Color text200 = Color(0xff4e5766);
  static const Color text300 = Color(0xff2a3547);
  static const Color text400 = Color(0xff1d2532);
  static const Color text500 = Color(0xff1a202b);

  //Primary Colors
  static const Color primary50 = Color(0xffeaf0ff);
  static const Color primary75 = Color(0xffa9bfff);
  static const Color primary100 = Color(0xff86a5ff);
  static const Color primary200 = Color(0xff527eff);
  static const Color primary300 = Color(0xFF2E64FF);
  static const Color primary400 = Color(0xff2046b3);
  static const Color primary500 = Color(0xff1c3d9c);

  //Background Color
  static const Color bg50 = Color(0xfffafafa);

  //Border
  static const Color borderColor50 = Color(0xFFEEEFF0);
  static const Color borderColor100 = Color(0xFFCBD5E1);

  //Green shade
  static const Color green50 = Color(0xFFAA741A);
  static const Color green100 = Color(0xFF00AA74);

  static const Color kPureWhite = Color(0xFFFFFFFF);
  static const Color flashWhite = Color(0xFFF1F5F9);
  static const Color kPureBlack = Color(0xFF000000);

  static const Color primaryLight = Color(0xFFFEF0E7);
  static const Color seashell = Color(0xFFFFF2EA);
  static const Color heading = Color(0xFF262626);
  static const Color subHeading = Color(0xFF8C8C8C);
  static const Color grey = Color(0xFF595959);
  static const Color cadetGrey = Color(0xFF94A3B8);
  static const Color border = Color(0xFFCBD5E1);
  static const Color border2 = Color(0xFFEAECF0);
  static const Color lightBorder = Color(0xFFF0F0F0);
  static const Color darkBlue = Color(0xFF0F172A);
  static const Color errorBorder = Color(0xFFF43F5E);
  static const Color lightError = Color(0xFFFFF1F2);
  static const Color errorText = Color(0xFFE11D48);
  static const Color iconColor = Color(0xFF292D32);
  static const Color hintText = Color(0xFF475569);
  static const Color divider = Color(0xFFE2E8F0);
  static const Color toastColor = Color(0xFF1E293B);
  static const Color green = Color(0xFF16A34A);
  static const Color ufoGreen = Color(0xFF22C55E);
  static const Color lightGreen = Color(0xFFF0FDF4);
  static const Color title = Color(0xFF475467);
  static const Color subTitle = Color(0xFF101828);
  static const Color black22 = Color(0xFF161616);
  static const Color black13 = Color(0xFF0D0D0D);
  static const Color commonGrey = Color(0xFF666666);
  static const Color blackShade = Color(0xFF64748B);

  static const Color textfieldHintColor = Color(0xFF838A94);
  static const Color neutraln200 = Color(0xFFCACDD1);
  static const Color neutraln50 = Color(0xFFF7F7F8);
  static const Color brightGrey = Color(0xFFE6E8EA);

  static const Color darkGunmetal = Color(0xFF1A202B);
  static const Color ultramarineBlue = Color(0xFF2E64FF);
  static const Color aliceBlue = Color(0xFFEAF0FF);
  static const Color independence = Color(0xFF4E5766);
  static const Color cultured = Color(0xFFF7F7F8);
  static const Color brightGray = Color(0xFFEEEFF0);
  static const Color blueBerry = Color(0xFF527EFF);
  static const Color azureishWhite = Color(0xFFE2E8F0);
  static const Color romanSilver = Color(0xFF838A94);
  static const Color crayola = Color(0xFF2A3547);
  static const Color ghostWhite = Color(0xFFF8FAFC);
  static const Color greenMunsell = Color(0xFF00AA74);
  static const Color tangerine = Color(0xFFF08C00);
  static const Color terraCotta = Color(0xFFEC6A5E);
  static List<BoxShadow> boxShadow = [
    BoxShadow(
      color: darkBlue.withOpacity(0.05),
      blurRadius: 2,
      spreadRadius: 0,
      offset: const Offset(0, 1),
    )
  ];
}
