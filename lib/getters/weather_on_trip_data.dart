import 'package:flip_smyrdack/models/weather_data_on_trip_model.dart';
import 'package:http/http.dart' as http;
// import 'package:pogoda/models/error_data_model.dart';
// import 'package:pogoda/models/weather_data_model.dart';
import 'dart:convert';

Future getWeatherOnTripData(String lat, String lon) async {
  String urlReq;

  urlReq =
      'https://api.openweathermap.org/data/2.5/onecall?lat=$lat&lon=$lon&appid=560de8ac99a3be9bd0bcedb2cb048ac0&units=metric&lang=pl';
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

    WeatherDataOnTrip weatherData =
        new WeatherDataOnTrip.fromJson(decodedResponse);
    return weatherData;
  } else {
    // ErrorData errorData = new ErrorData.fromJson(
    //     json.decode(response.body), response.statusCode);
    // return errorData;
    return Future.error(response.body);
  }
}
