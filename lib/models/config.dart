import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';

/// Creates easily accesible configuration data for things like app theme.
class ConfigData extends ChangeNotifier {


  // void readConfigs() async {
  //   prefs = await SharedPreferences.getInstance();
  //   List<String> notPresent() {
  //     prefs.setStringList('configData', templateConfig);
  //     return templateConfig;
  //   }

  //   List<String> configData = prefs.getStringList('configData') ?? notPresent();
  //   if (configData.length < templateConfig.length) {
  //     List<String> newArray = templateConfig;

  //     for (var i = 0; i <= configData.length - 1; i++) {
  //       newArray[i] = configData[i];
  //     }
  //     prefs.setStringList('configData', newArray);
  //     configData = newArray;
  //   }
  //   weatherLight = configData[0] == 'false' ? false : true;
  //   showChart = configData[2] == 'false' ? false : true;
  //   showAlternativeColorsOnChart = configData [3] == 'false' ? false : true;
  //   themeColor = int.parse(configData[1] ?? '0');
  //   notifyListeners();
  // }
}
