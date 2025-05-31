import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import 'package:weather_app/models/weather.dart';
import 'package:weather_app/models/weather_codes.dart';
import 'package:intl/intl.dart';


class WeatherCodes {
  static const Map<int, WeatherInfo> _codes = {
    0: WeatherInfo(
      color: Color(0xFFF1F1F1),
      name: "Clear",
      imageKey: "clear",
    ),
    1: WeatherInfo(
      color: Color(0xFFE2E2E2),
      name: "Mostly Clear",
      imageKey: "mostly-clear",
    ),
    2: WeatherInfo(
      color: Color(0xFFC6C6C6),
      name: "Partly Cloudy",
      imageKey: "partly-cloudy",
    ),
    3: WeatherInfo(
      color: Color(0xFFABABAB),
      name: "Overcast",
      imageKey: "overcast",
    ),
    45: WeatherInfo(
      color: Color(0xFFA4ACBA),
      name: "Fog",
      imageKey: "fog",
    ),
    48: WeatherInfo(
      color: Color(0xFF8891A4),
      name: "Icy Fog",
      imageKey: "rime-fog",
    ),
    51: WeatherInfo(
      color: Color(0xFF3DECEB),
      name: "Light Drizzle",
      imageKey: "light-drizzle",
    ),
    53: WeatherInfo(
      color: Color(0xFF0CCECE),
      name: "Drizzle",
      imageKey: "moderate-drizzle",
    ),
    55: WeatherInfo(
      color: Color(0xFF0AB1B1),
      name: "Heavy Drizzle",
      imageKey: "dense-drizzle",
    ),
    56: WeatherInfo(
      color: Color(0xFFD3BFE8),
      name: "Light Freezing Drizzle",
      imageKey: "light-freezing-drizzle",
    ),
    57: WeatherInfo(
      color: Color(0xFFA780D4),
      name: "Freezing Drizzle",
      imageKey: "dense-freezing-drizzle",
    ),
    61: WeatherInfo(
      color: Color(0xFFBFC3FA),
      name: "Light Rain",
      imageKey: "light-rain",
    ),
    63: WeatherInfo(
      color: Color(0xFF9CA7FA),
      name: "Rain",
      imageKey: "moderate-rain",
    ),
    65: WeatherInfo(
      color: Color(0xFF748BF8),
      name: "Heavy Rain",
      imageKey: "heavy-rain",
    ),
    66: WeatherInfo(
      color: Color(0xFFCAC1EE),
      name: "Light Freezing Rain",
      imageKey: "light-freezing-rain",
    ),
    67: WeatherInfo(
      color: Color(0xFF9486E1),
      name: "Freezing Rain",
      imageKey: "heavy-freezing-rain",
    ),
    71: WeatherInfo(
      color: Color(0xFFF9B1D8),
      name: "Light Snow",
      imageKey: "slight-snowfall",
    ),
    73: WeatherInfo(
      color: Color(0xFFF983C7),
      name: "Snow",
      imageKey: "moderate-snowfall",
    ),
    75: WeatherInfo(
      color: Color(0xFFF748B7),
      name: "Heavy Snow",
      imageKey: "heavy-snowfall",
    ),
    77: WeatherInfo(
      color: Color(0xFFE7B6EE),
      name: "Snow Grains",
      imageKey: "snowflake",
    ),
    80: WeatherInfo(
      color: Color(0xFF9BCCFD),
      name: "Light Showers",
      imageKey: "light-rain",
    ),
    81: WeatherInfo(
      color: Color(0xFF51B4FF),
      name: "Showers",
      imageKey: "moderate-rain",
    ),
    82: WeatherInfo(
      color: Color(0xFF029AE8),
      name: "Heavy Showers",
      imageKey: "heavy-rain",
    ),
    85: WeatherInfo(
      color: Color(0xFFE7B6EE),
      name: "Light Snow Showers",
      imageKey: "slight-snowfall",
    ),
    86: WeatherInfo(
      color: Color(0xFFCD68E0),
      name: "Snow Showers",
      imageKey: "heavy-snowfall",
    ),
    95: WeatherInfo(
      color: Color(0xFF525F7A),
      name: "Thunderstorm",
      imageKey: "thunderstorm",
    ),
    96: WeatherInfo(
      color: Color(0xFF3D475C),
      name: "Light T-storm w/ Hail",
      imageKey: "thunderstorm-with-hail",
    ),
    99: WeatherInfo(
      color: Color(0xFF2A3140),
      name: "T-storm w/ Hail",
      imageKey: "thunderstorm-with-hail",
    ),
  };

  // Get weather info by code
  static WeatherInfo? getWeatherInfo(int code) {
    return _codes[code];
  }

  // Get weather info with fallback
  static WeatherInfo getWeatherInfoWithFallback(int code) {
    return _codes[code] ?? const WeatherInfo(
      color: Color(0xFF757575),
      name: "Unknown",
      imageKey: "unknown",
    );
  }
}



void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: MyHomePage(title: 'Weather App'),
    );
  }
}
      
class MyHomePage extends StatefulWidget {
   
  MyHomePage({super.key, required this.title});

  final String title;
  
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}


class _MyHomePageState extends State<MyHomePage> {


  bool _isLoading = true;

  // Location data
  Location location = Location();
  bool _serviceEnabled = false;
  PermissionStatus? _permissionStatus;
  LocationData? _locationData;
  Future<bool> requestLocationPermission() async{
    _serviceEnabled = await location.serviceEnabled();
    if (_serviceEnabled){
      _serviceEnabled = await location.requestService();
    }
    if(!_serviceEnabled){
      await SystemNavigator.pop();
      return false;
    }

    _permissionStatus = await location.hasPermission();
    if (_permissionStatus == PermissionStatus.denied){
      _permissionStatus = await location.requestPermission();
      if (_permissionStatus != PermissionStatus.granted){
        await SystemNavigator.pop();
        return false;
      }
    }

    _locationData = await location.getLocation();

    return true;
  }

  // Weather data

  Map<String ,Weather> weeklyWeatherData = {};
  List<Weather> dailyWeather = [];

  void getWeatherData(DateTime today, DateTime oneWeekFromNow ) async{
    bool hasLocationPermission = await requestLocationPermission();

    if(!hasLocationPermission || _locationData == null){
      throw Exception("Location permission not granted");
    }
    String formattedToday = DateFormat("yyyy-MM-dd").format(today);

    String formattedWeekend =  DateFormat("yyyy-MM-dd").format(oneWeekFromNow);
    String url  = 'https://api.open-meteo.com/v1/forecast?latitude=${_locationData!.latitude}&longitude=${_locationData!.longitude}&hourly=temperature_2m,weather_code,relative_humidity_2m,cloud_cover,visibility,is_day&current=is_day&start_date=$formattedToday&end_date=$formattedWeekend';
    Map<String, dynamic>  apiReponse =  await ApiService.fetch(url=url);
    Map<String, dynamic> hourlyData = apiReponse["hourly"];
    int dataLength =  hourlyData["time"].length;

    for (int index = 0; index < dataLength; index++) {

        DateTime time = DateTime.parse(hourlyData['time'][index]);
        String timeKey = DateFormat("yyyy-MM-dd:HH").format(time);

        Weather weatherObj = Weather(
        time: time,
        temprature: hourlyData['temperature_2m'][index].toString(),
        weatherCode: hourlyData['weather_code'][index],
        relativeHumidity: hourlyData['relative_humidity_2m'][index],
        visibility: hourlyData["visibility"][index],
        isDay: hourlyData['is_day'][index]
        );

        weeklyWeatherData[timeKey] = weatherObj;

        if (index < 23){
          dailyWeather.add(weatherObj);
        }
    }

    setState(() {
      _isLoading = false;
    });
  }

  DateTime now =  DateTime.now();
  String? url;
  

  final List<String> _imageUrls = [
    "assets/backgrounds/winter_vector.png"
  ];


  late ImageProvider currentImageProvider;

  @override
  void initState() {
    super.initState();
    DateTime today = DateTime(now.year, now.month, now.day);
    DateTime oneWeekFromNow = today.add(Duration(days: 7));
    currentImageProvider = AssetImage(_imageUrls[0]);
    getWeatherData(today, oneWeekFromNow);
  }

  @override
  Widget build(BuildContext context) {
    var currWeatherData = weeklyWeatherData[DateFormat("yyyy-MM-dd:HH").format(DateTime.now())];
    if(_isLoading){
      return Scaffold(
        body: Center(
          child: Text(
            "LOADING...."
          ),
        ),
      );
    }
    else{
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch, // <-- Add this line
          children: <Widget>[
            Expanded(
              flex: 2,
              child: Stack(
                children: <Widget>[
                  TopWeatherImageWidget(imageProvider: currentImageProvider),
                  Align(
                    alignment: Alignment(-0.8, -0.6),
                    child: Text(
                      "${currWeatherData?.temprature as String}°",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 100,
                        ),
                    ),
                  )
                ]
              )
              ),
            Expanded(
              flex:1 ,
              child: 
              FractionallySizedBox(
                heightFactor: 0.4,
                child: hourlyWeatherSection(weatherCodes:dailyWeather ),
            )
            )
          ],
        ),
      ),
    );
  }
  }
}


// use this to map weather codes https://gist.github.com/stellasphere/9490c195ed2b53c707087c8c2db4ec0c

class TopWeatherImageWidget extends StatelessWidget{
  final ImageProvider imageProvider;

  const TopWeatherImageWidget({Key? key, required this.imageProvider});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.elliptical(100, 40),
              bottomRight: Radius.elliptical(100, 40)
            ),
            child: Image(
              image: imageProvider,
              fit: BoxFit.cover,
              width: double.infinity,  // <-- Add this
              height: double.infinity,
            )
          );
  }
}


class ApiService{
  static Future<Map<String, dynamic>> fetch(String url) async {
      try {
          final response = await http.get(Uri.parse(url));
          if (response.statusCode == 200){
            return jsonDecode(response.body) as Map<String, dynamic>;
          }
          else{
            throw Exception("Failed to get response ${response.statusCode}");
          }
      } catch(e){
          throw Exception("Request failed! ${e}");
      }

  }
}


Container hourlyWeatherSection({required List<Weather> weatherCodes }){
  return Container(
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.only(left:20, right: 20),
        itemBuilder: (context, index) {
          return Container(
            width: 100, 
            decoration: 
            BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: WeatherCodes.getWeatherInfoWithFallback(weatherCodes[index].weatherCode).color
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  width: 50,
                  height: 50,
                  child: Image.asset(WeatherCodes.getWeatherInfoWithFallback(weatherCodes[index].weatherCode).assetPath),
                ),
                Text(WeatherCodes.getWeatherInfoWithFallback(weatherCodes[index].weatherCode).name)
              ],
            )
          );
        }, 
        separatorBuilder: (context, index) => SizedBox(width: 25,), itemCount: weatherCodes.length),
  );
}

