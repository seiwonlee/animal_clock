import 'package:flutter/material.dart';

enum Item {
  background,
  text,
  shadow,
}

final lightTheme = {
//  _Element.background: Colors.black,ff3a42
  Item.background: Color(0xff7e57c2),
  Item.text: Colors.white,
  Item.shadow: Colors.black54.withOpacity(0.3),
};

final darkTheme = {
  Item.background: Colors.black,
  Item.text: Colors.black,
  Item.shadow: Colors.black54.withOpacity(0.3),
};

TextStyle getDefaultTextStyle(Color text, double fontSize, Color shadow) {
  return TextStyle(
    color: text,
    fontFamily: 'Oswald',
    fontWeight: FontWeight.w500,
    fontSize: fontSize,
    shadows: [
      Shadow(
        blurRadius: 3,
        color: Colors.white.withOpacity(0.3),
        offset: Offset(-3, -3),
      ),
      Shadow(
        blurRadius: 3,
        color: shadow,
        offset: Offset(3, 3),
      ),
    ],
  );
}

TextStyle getPeriodOfDayStyle(weight) {
  return TextStyle(
    fontFamily: 'Righteous',
    fontWeight: weight,
    color: Colors.greenAccent.withOpacity(0.3),
    shadows: [],
  );
}

TextStyle getNumberStyle(weight) {
  return TextStyle(fontWeight: weight);
}
