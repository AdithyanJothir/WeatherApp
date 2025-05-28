import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import 'package:weather_app/models/weather.dart';
import 'package:intl/intl.dart';


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

  Location location = Location();
  bool _serviceEnabled = false;
  PermissionStatus? _permissionStatus;
  LocationData? _locationData;
  
  // Location data
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

  List<Weather>? weeklyWeatherData;

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
  
    weeklyWeatherData = List.generate(dataLength, (index){
      return Weather(time: DateTime.parse(hourlyData['time'][index]),
      temprature: hourlyData['temperature_2m'][index].toString(),
      weatherCode: hourlyData['weather_code'][index],
      relativeHumidity: hourlyData['relative_humidity_2m'][index],
      visibility: hourlyData["visibility"][index],
      isDay: hourlyData['is_day'][index]
      );
    });

    setState(() {});
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
                    alignment: Alignment(-0.2, -0.68),
                    child: Text(
                      "o",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 60,
                        ),
                    ),
                  ),
                  Align(
                    alignment: Alignment(-0.8, -0.6),
                    child: Text(
                      "19",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 100,
                        ),
                    ),
                  )
                ]
              )
              ),
            Expanded(flex:1 ,
            child: Container(
              child: SizedBox(width: 60, height: 40),
            ))
          ],
        ),
      ),
    );
  }
}


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

