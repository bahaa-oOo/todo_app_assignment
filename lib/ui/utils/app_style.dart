import 'package:flutter/material.dart';

import 'app_colors.dart';

abstract class AppStyle {
  static const TextStyle appBarStyle = TextStyle(
      fontSize: 30, fontWeight: FontWeight.bold, color: AppColors.white);
  static const TextStyle titlesTextStyle = TextStyle(
      fontSize: 27, fontWeight: FontWeight.bold, color: AppColors.primary);

  static const TextStyle bottomSheetTitle = TextStyle(
      fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.black);

  static const TextStyle bodyTextStyle = TextStyle(
      fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.black);

  static const TextStyle appBarDarkStyle = TextStyle(
      fontSize: 30, fontWeight: FontWeight.bold, color: AppColors.black);

  static const TextStyle unSelectedCalendarDayStyle = TextStyle(
      color: AppColors.black, fontWeight: FontWeight.bold, fontSize: 15);

  static TextStyle selectedCalendarDayStyle =
      unSelectedCalendarDayStyle.copyWith(color: AppColors.primary);
  static const TextStyle normalGreyTextStyle =
      TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w500);
}
