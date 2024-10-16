import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:habit_tracker/theme/dark_mode.dart';
import 'package:habit_tracker/theme/light_mode.dart';

class ThemeProvider extends ChangeNotifier {
//intitially light mode

ThemeData _themeData = lightMode;

// get current theme

ThemeData get themeData => _themeData;


// is current theme dark mode 

bool get isDarkMode => _themeData == darkMode ;


//set theme 

set  themeData (ThemeData themeData){
_themeData = themeData;
notifyListeners();

}

// toggle theme 

void toggleTheme (){
  if (_themeData == lightMode) {
    themeData = darkMode;

  } else  {

    themeData = lightMode;
  }
}


}