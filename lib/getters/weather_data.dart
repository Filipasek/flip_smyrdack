import 'package:flip_smyrdack/models/weather_data_model.dart';
import 'package:flip_smyrdack/services/random_color.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:pogoda/models/error_data_model.dart';
// import 'package:pogoda/models/weather_data_model.dart';
import 'dart:convert';
import 'package:location/location.dart';

Future getWeatherData() async {
  String urlReq;
  List<String>? customCoordinates;
  // List<String>? customCoordinates = ['49.886673', '19.480886', 'Wadowice'];
  String city = '';
  late String lat;
  late String lon;
  if (customCoordinates == null) {
    Location location = new Location();

    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    LocationData _locationData;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        // throw Exception("We've fucked up");
        return Future.error(
            'Funkcje lokalizacyjne są wyłączone, przez co nie możemy wyświetlić pogody.');
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        // throw Exception("We've fucked upopp");
        return Future.error(
            'Brak uprawnień lokalizacyjnych, dlatego nie możemy wyświetlić pogody.');
        //TODO: no location permission given
      }
    }
    _locationData = await location.getLocation();

    lat = _locationData.latitude.toString();
    lon = _locationData.longitude.toString();
  } else {
    lat = customCoordinates[0];
    lon = customCoordinates[1];
    city = customCoordinates[2];
  }
  urlReq =
      'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=560de8ac99a3be9bd0bcedb2cb048ac0&units=metric&lang=pl';
  var response;
  try {
    response = await http.get(
      Uri.parse(urlReq),
      // headers: {
      //   'Accept': 'application/json',
      //   'apikey': _apikey,
      //   'Accept-Language': 'pl',
      // }
    );
  } catch (error) {
    return Future.error(error);
  }

  if (response.statusCode == 200) {
    Map<String, dynamic> decodedResponse = json.decode(response.body);

    // if (decodedResponse['current']['indexes'][0]['value'] == null &&
    //     decodedResponse['current']['indexes'][0]['level'] == 'UNKNOWN') {

    WeatherData weatherData = new WeatherData.fromJson(decodedResponse);
    return weatherData;
  } else {
    // ErrorData errorData = new ErrorData.fromJson(
    //     json.decode(response.body), response.statusCode);
    // return errorData;
    return Future.error(response.body);
  }
}
