class WeatherDataOnTrip {
  final int time; //time of measurement
  final double lon, lat; //coords of measurement
  final String description;
  final int visibility;
  final double windSpeed;
  final int clouds;
  final int sunRiseTimestamp;
  final int sunSetTimestamp;
  final String icon;
  final double temperature;
  final double feelsLikeTemperature;
  final int pressure;
  final int humidity;
  final List minutely;
  final List<HourlyForecast> hourlyForecast;
  final List<DailyForecast> dailyForecast;
  final List<Alerts> alerts;

  WeatherDataOnTrip({
    required this.time,
    required this.lon,
    required this.lat,
    required this.description,
    required this.visibility,
    required this.windSpeed,
    required this.clouds,
    required this.sunRiseTimestamp,
    required this.sunSetTimestamp,
    // required this.name,
    required this.icon,
    required this.temperature,
    required this.feelsLikeTemperature,
    required this.pressure,
    required this.humidity,
    required this.minutely,
    required this.hourlyForecast,
    required this.dailyForecast,
    required this.alerts,
  });

  factory WeatherDataOnTrip.fromJson(Map<String, dynamic> json) {
    late List<HourlyForecast> hourly;
    late List<DailyForecast> daily;
    late List<Alerts> alerts;

    if (json.containsKey('hourly')) {
      hourly = [HourlyForecast.fromJson(json['hourly'][0])];
      for (var i = 1; i < json['hourly'].length; i++) {
        hourly.add(HourlyForecast.fromJson(json['hourly'][i]));
      }
    } else {
      hourly = [];
    }

    if (json.containsKey('daily')) {
      daily = [DailyForecast.fromJson(json['daily'][0])];
      for (var i = 1; i < json['daily'].length; i++) {
        daily.add(DailyForecast.fromJson(json['daily'][i]));
      }
    } else {
      daily = [];
    }

    if (json.containsKey('alerts')) {
      alerts = [Alerts.fromJson(json['alerts'][0])];
      for (var i = 1; i < json['alerts'].length; i++) {
        alerts.add(Alerts.fromJson(json['alerts'][i]));
      }
    } else {
      alerts = [];
    }

    return WeatherDataOnTrip(
      // name: json["name"],
      description: json["current"]["weather"][0]["description"],
      clouds: json["current"]["clouds"],
      lat: json["lat"],
      lon: json["lon"],
      time: json["current"]["dt"],
      windSpeed: json["current"]["wind_speed"] * 1.0,
      visibility: json["current"]['visibility'],
      sunRiseTimestamp: json["current"]["sunrise"],
      sunSetTimestamp: json["current"]["sunset"],
      icon: json["current"]["weather"][0]["icon"],
      temperature: json["current"]["temp"] * 1.0,
      feelsLikeTemperature: json["current"]["feels_like"] * 1.0,
      pressure: json["current"]["pressure"],
      humidity: json["current"]["humidity"],

      minutely: json["minutely"] ?? [],
      hourlyForecast: hourly,
      dailyForecast: daily,
      alerts: alerts,
    );
  }
}

class HourlyForecast {
  final int time; //time of measurement
  final String description;
  final int visibility;
  final double windSpeed;
  final int clouds;
  final String icon;
  final double temperature;
  final double feelsLikeTemperature;
  final int pressure;
  final int humidity;

  ///pop: probability of precipitation
  final double pop;

  HourlyForecast({
    required this.time,
    required this.description,
    required this.visibility,
    required this.windSpeed,
    required this.clouds,
    required this.icon,
    required this.temperature,
    required this.feelsLikeTemperature,
    required this.pressure,
    required this.humidity,
    required this.pop,
  });

  factory HourlyForecast.fromJson(Map<String, dynamic> json) {
    return HourlyForecast(
      time: json["dt"],
      clouds: json["clouds"],
      description: json["weather"][0]["description"],
      icon: json["weather"][0]["icon"],
      pop: json["pop"] * 1.0,
      pressure: json["pressure"],
      humidity: json["humidity"],
      temperature: json["temp"] * 1.0,
      feelsLikeTemperature: json["feels_like"] * 1.0,
      visibility: json["visibility"].round(),
      windSpeed: json["wind_speed"] * 1.0,
    );
  }
}

class DailyForecast {
  final int time; //time of measurement
  final int sunRiseTimestamp;
  final int sunSetTimestamp;
  final int moonRiseTimestamp;
  final int moonSetTimestamp;
  final double moonPhase;

  final String description;
  final double windSpeed;
  final int clouds;
  final String icon;
  final double rain;

  ///[day], [min], [max], [night], [eve], [morn]
  final Map<String, double> temps;

  ///[day], [night], [eve], [morn]
  final Map<String, dynamic> feelsLikeTemps;
  final int pressure;
  final int humidity;

  ///pop: probability of precipitation
  final double pop;

  ///UV Index
  final double uvi;

  DailyForecast({
    required this.time,
    required this.sunRiseTimestamp,
    required this.sunSetTimestamp,
    required this.moonRiseTimestamp,
    required this.moonSetTimestamp,
    required this.moonPhase,
    required this.description,
    required this.windSpeed,
    required this.clouds,
    required this.icon,
    required this.temps,
    required this.feelsLikeTemps,
    required this.pressure,
    required this.humidity,
    required this.pop,
    required this.uvi,
    required this.rain,
  });

  factory DailyForecast.fromJson(Map<String, dynamic> json) {
    Map<String, double> temps = {
      "day": json["temp"]["day"] * 1.0,
      "night": json["temp"]["night"] * 1.0,
      "eve": json["temp"]["eve"] * 1.0,
      "morn": json["temp"]["morn"] * 1.0,
      "min": json["temp"]["min"] * 1.0,
      "max": json["temp"]["max"] * 1.0,
    };
    Map<String, dynamic> feelsLikeTemps = {
      "day": json["feels_like"]["day"] * 1.0,
      "night": json["feels_like"]["night"] * 1.0,
      "eve": json["feels_like"]["eve"] * 1.0,
      "morn": json["feels_like"]["morn"] * 1.0,
    };

    return DailyForecast(
      time: json["dt"],
      clouds: json["clouds"],
      description: json["weather"][0]["description"],
      icon: json["weather"][0]["icon"],
      pop: json["pop"] * 1.0,
      pressure: json["pressure"],
      humidity: json["humidity"],
      temps: temps,
      feelsLikeTemps: feelsLikeTemps,
      uvi: json["uvi"] * 1.0,
      sunRiseTimestamp: json["sunrise"],
      sunSetTimestamp: json["sunset"],
      moonRiseTimestamp: json["moonrise"],
      moonSetTimestamp: json["moonset"],
      moonPhase: json["moon_phase"] * 1.0,
      windSpeed: json["wind_speed"] * 1.0,
      rain: json.containsKey('rain') ? json["rain"] * 1.0 : 0.0,
    );
  }
}

class Alerts {
  final String senderName;
  final String event;
  final int startTimestamp;
  final int endTimestamp;
  final String description;
  final List tags;

  Alerts({
    required this.senderName,
    required this.event,
    required this.startTimestamp,
    required this.endTimestamp,
    required this.description,
    required this.tags,
  });
  factory Alerts.fromJson(Map<String, dynamic> json) {
    return Alerts(
      senderName: json["sender_name"],
      event: json["event"],
      startTimestamp: json["start"],
      endTimestamp: json["end"],
      description: json["description"],
      tags: json["tags"],
    );
  }
}
