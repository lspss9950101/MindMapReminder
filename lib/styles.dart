import 'package:flutter/material.dart';

const Color _textColorLight = Color.fromARGB(255, 240, 240, 240);

const Color _textColorLightGrey = Color.fromARGB(255, 145, 145, 145);

const Color _textColorGrey = Color.fromARGB(255, 128, 128, 128);

const Color _textColorDarkGrey = Color.fromARGB(255, 48, 48, 48);

const Color _textColorDark = Color.fromARGB(255, 64, 64, 64);

const TextStyle _mindMapNodeDisplayTitleStyleLight = TextStyle(
  color: _textColorLight,
  fontSize: 24,
  fontWeight: FontWeight.bold,
);

const TextStyle _mindMapNodeDisplayTitleStyleDark = TextStyle(
  color: _textColorDark,
  fontSize: 24,
  fontWeight: FontWeight.bold,
);

const TextStyle _mindMapNodeDisplayDescriptionStyleLight = TextStyle(
  color: _textColorLight,
  fontSize: 14,
  fontWeight: FontWeight.normal,
);

const TextStyle _mindMapNodeDisplayDescriptionStyleDark = TextStyle(
  color: _textColorDark,
  fontSize: 14,
  fontWeight: FontWeight.normal,
);

const TextStyle _bottomSheetButtonTextStyleLight = TextStyle(
  color: _textColorLight,
  fontSize: 16,
  fontWeight: FontWeight.w400,
);

const TextStyle _bottomSheetButtonTextStyleDark = TextStyle(
  color: _textColorDark,
  fontSize: 16,
  fontWeight: FontWeight.w400,
);

const TextStyle _bottomSheetInputLabelStyle = TextStyle(
  color: _textColorDarkGrey,
  fontSize: 15,
  fontWeight: FontWeight.w400,
);

const TextStyle _bottomSheetFocusedInputLabelStyle = TextStyle(
  color: _textColorDarkGrey,
  fontSize: 15,
  fontWeight: FontWeight.w500,
);

const OutlineInputBorder _bottomSheetInputBorderStyle = OutlineInputBorder(
  borderSide: BorderSide(color: _textColorLightGrey, width: 1),
);

const OutlineInputBorder _bottomSheetFocusedInputBorderStyle = OutlineInputBorder(
  borderSide: BorderSide(color: _textColorDarkGrey, width: 1.5),
);

const TextStyle _bottomSheetTextFieldStyle = TextStyle(
  color: _textColorDark,
  fontSize: 16,
  fontWeight: FontWeight.w300,
);

enum CustomStyle {
  textColorLight,
  textColorLightGrey,
  textColorGrey,
  textColorDarkGrey,
  textColorDark,

  mindMapNodeDisplayTitleStyle,
  mindMapNodeDisplayTitleStyleLight,
  mindMapNodeDisplayTitleStyleDark,

  mindMapNodeDisplayDescriptionStyle,
  mindMapNodeDisplayDescriptionStyleLight,
  mindMapNodeDisplayDescriptionStyleDark,

  bottomSheetButtonTextStyleLight,
  bottomSheetButtonTextStyleDark,
  bottomSheetInputLabelStyle,
  bottomSheetFocusedInputLabelStyle,
  bottomSheetInputBorderStyle,
  bottomSheetFocusedInputBorderStyle,
  bottomSheetTextFieldStyle,
}

const Map<CustomStyle, dynamic> customStyle = {
  CustomStyle.textColorLight: _textColorLight,
  CustomStyle.textColorLightGrey: _textColorLightGrey,
  CustomStyle.textColorGrey: _textColorGrey,
  CustomStyle.textColorDarkGrey: _textColorDarkGrey,
  CustomStyle.textColorDark: _textColorDark,

  CustomStyle.mindMapNodeDisplayTitleStyle: _mindMapNodeDisplayTitleStyleLight,
  CustomStyle.mindMapNodeDisplayTitleStyleLight: _mindMapNodeDisplayTitleStyleLight,
  CustomStyle.mindMapNodeDisplayTitleStyleDark: _mindMapNodeDisplayTitleStyleDark,

  CustomStyle.mindMapNodeDisplayDescriptionStyle: _mindMapNodeDisplayDescriptionStyleLight,
  CustomStyle.mindMapNodeDisplayDescriptionStyleLight: _mindMapNodeDisplayDescriptionStyleLight,
  CustomStyle.mindMapNodeDisplayDescriptionStyleDark: _mindMapNodeDisplayDescriptionStyleDark,

  CustomStyle.bottomSheetButtonTextStyleLight: _bottomSheetButtonTextStyleLight,
  CustomStyle.bottomSheetButtonTextStyleDark: _bottomSheetButtonTextStyleDark,
  CustomStyle.bottomSheetInputLabelStyle: _bottomSheetInputLabelStyle,
  CustomStyle.bottomSheetFocusedInputLabelStyle: _bottomSheetFocusedInputLabelStyle,
  CustomStyle.bottomSheetInputBorderStyle: _bottomSheetInputBorderStyle,
  CustomStyle.bottomSheetFocusedInputBorderStyle: _bottomSheetFocusedInputBorderStyle,
  CustomStyle.bottomSheetTextFieldStyle: _bottomSheetTextFieldStyle,
};