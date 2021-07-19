class WeatherData {
  final int time; //time of measurement
  final double lon, lat; //coords
  final String main;
  final String description;
  final String base; //type of measurement
  final int visibility;
  final int windSpeed;
  final int clouds;
  final String countryCode;
  final int sunRiseTimestamp;
  final int sunSetTimestamp;
  final String name;
  final String icon;
  final double temperature;
  final double feelsLikeTemperature;
  final int pressure;
  final int humidity;
  final int seaLevel;
  final int groundLevel;

  // final double? value; // numerical value of the calculated index
  // final String? level; // level of the index
  // final String? advice;
  // final String? color; // color representing index level

  // final double? pm1;
  // final double? pm25;
  // final double? pm10;
  // final int? pressure;
  // final int? humidity;
  // final int? temperature;

  // final String? requestsLeft; //left requests per day
  // final String? requestsPerDay; //number of requests available per day

  // final int? statusCode;

  // final String? city;

  // final List? history;
  // final List? forecast;

  WeatherData({
    required this.time,
    required this.lon,
    required this.lat,
    required this.main,
    required this.description,
    required this.base,
    required this.visibility,
    required this.windSpeed,
    required this.clouds,
    required this.countryCode,
    required this.sunRiseTimestamp,
    required this.sunSetTimestamp,
    required this.name,
    required this.icon,
    required this.temperature,
    required this.feelsLikeTemperature,
    required this.pressure,
    required this.humidity,
    required this.seaLevel,
    required this.groundLevel,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    return WeatherData(
      name: json["name"],
      description: json["weather"][0]["description"],
      base: json["base"],
      clouds: json["clouds"]["all"],
      countryCode: json["sys"]["country"],
      lat: json["coord"]["lat"],
      lon: json["coord"]["lon"],
      main: json['weather'][0]['main'],
      time: json["dt"],
      windSpeed: json["wind"]["speed"].round(),
      visibility: json['visibility'],
      sunRiseTimestamp: json["sys"]["sunrise"],
      sunSetTimestamp: json["sys"]["sunset"],
      icon: json["weather"][0]["icon"],
      temperature: json["main"]["temp"] * 1.0,
      feelsLikeTemperature: json["main"]["feels_like"] * 1.0,
      pressure: json["main"]["pressure"],
      humidity: json["main"]["humidity"],
      groundLevel: json["main"].containsKey('grnd_level')
          ? json["main"]["grnd_level"]
          : 0,
      seaLevel:
          json["main"].containsKey('sea_level') ? json["main"]["sea_level"] : 0,
    );
  }
}
