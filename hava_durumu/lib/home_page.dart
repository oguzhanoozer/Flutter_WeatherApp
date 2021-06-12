import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hava_durumu/search_page.dart';
import "package:http/http.dart" as http;
import 'dart:convert';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String sehir = "Ankara";
  int sicaklik;
  var locationData;
  var woeid;
  String abbr = 'c';
  Position position;
  List<int> temps = List(5);
  List<String> abbrs = List(5);
  List<String> dates = List(5);

  Future<void> getDevicePosition() async {
    try {
      position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.low);
    } catch (e) {
      print("Şu hata oluştu $e");
    }
    print(position);
  }

  Future<void> getLocationData() async {
    locationData = await http
        .get("https://www.metaweather.com/api/location/search/?query=$sehir");
    var jsonParsed = jsonDecode(locationData.body);
    woeid = jsonParsed[0]["woeid"];
  }

  Future<void> getLocationDataLatLong() async {
    locationData = await http.get(
        "https://www.metaweather.com/api/location/search/?lattlong=${position.latitude},${position.longitude}");
    var jsonParsed = jsonDecode(locationData.body);
    woeid = jsonParsed[0]["woeid"];
    print(woeid);
    sehir = jsonParsed[0]["title"];
  }

  Future<void> getLocationTemperature() async {
    var response =
        await http.get("https://www.metaweather.com/api/location/$woeid/");
    var temperatureDataParsed = jsonDecode(response.body);
    setState(() {
      sicaklik =
          temperatureDataParsed["consolidated_weather"][0]["the_temp"].round();

      for (int i = 0; i < temps.length; i++) {
        temps[i] = temperatureDataParsed["consolidated_weather"][i + 1]
                ["the_temp"]
            .round();
        abbrs[i] = temperatureDataParsed["consolidated_weather"][i + 1]
            ["weather_state_abbr"];
        dates[i] = temperatureDataParsed["consolidated_weather"][i + 1]
            ["applicable_date"];
      }
      abbr = temperatureDataParsed["consolidated_weather"][0]
          ["weather_state_abbr"];
      print(sicaklik);
    });
  }

  void getDataFromAPI() async {
    await getDevicePosition();
    await getLocationDataLatLong();
    print("woeid: $woeid");
    getLocationTemperature();
  }

  void getDataFromAPIbyCity() async {
    await getLocationData();
    getLocationTemperature();
  }

  @override
  void initState() {
    getDataFromAPI();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          fit: BoxFit.cover,
          image: AssetImage('assets/$abbr.jpg'),
        ),
      ),
      child: sicaklik == null
          ? Center(
              child: SpinKitHourGlass(
              color: Colors.blueAccent,
              size: 100.0,
            ))
          : Scaffold(
              backgroundColor: Colors.transparent,
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    /*FlatButton(
                onPressed: () async {
                  //print("Tıklama öncesi Location Data:$locationData");
                  await getLocationData();
                  /* print("http get sonrası Location Data:$locationData");
                  print(locationData.body);
                  var woeid = jsonDecode(locationData.body)[0]["woeid"];
                  print(woeid); 

                  Future.delayed(Duration(seconds: 5), () {
                    print("Tıklama sonrası Location Data:$locationData");
                  }); */
                },
                child: Text("getLocationData"),
                color: Colors.grey,
              ), */
                    Container(
                      height: 60,
                      width: 60,
                      child: Image.network(
                          "https://www.metaweather.com/static/img/weather/png/$abbr.png"),
                    ),
                    Text(
                      "$sicaklik °C",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 70,
                        shadows: <Shadow>[
                          Shadow(
                              color: Colors.black38,
                              blurRadius: 5,
                              offset: Offset(-3, 3))
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          "$sehir",
                          style: TextStyle(
                            fontSize: 30,
                            shadows: <Shadow>[
                              Shadow(
                                  color: Colors.black38,
                                  blurRadius: 5,
                                  offset: Offset(-3, 3))
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.search),
                          onPressed: () async {
                            sehir = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => SearchPage()));
                            getDataFromAPIbyCity();
                            setState(() {
                              sehir = sehir;
                            });
                          },
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 120,
                    ),
                    buildDailyMethodWidget()
                  ],
                ),
              ),
            ),
    );
  }

  Container buildDailyMethodWidget() {
    List<Widget> cards = List(5);

    for (int i = 0; i < cards.length; i++) {
      cards[i] = DailyWeather(
          temp: temps[i].toString(), date: dates[i], image: abbrs[i]);
    }
    return Container(
      height: 120,
      //width: MediaQuery.of(context).size.width * 0.6,
      child: FractionallySizedBox(
        widthFactor: 0.8,
        child: ListView(
          //itemCount: 5,
          scrollDirection: Axis.horizontal,
          children: cards,
          /* itemBuilder: (_, __) {
                          return DailyWeather();
                        },
                        separatorBuilder: (_, __) {
                          return VerticalDivider(
                            
                            color: Colors.red,
                          );
                        }, */
        ),
      ),
    );
  }
}

class DailyWeather extends StatelessWidget {
  final String temp;
  final String date;
  final String image;

  const DailyWeather(
      {Key key, @required this.temp, @required this.date, @required this.image})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<String> weekDays = [
      "Pazartesi",
      "Salı",
      "Çarşamba",
      "Perşembe",
      "Cuma",
      "Cumartesi",
      "Pazar"
    ];

    String weekDay = weekDays[DateTime.parse(date).weekday - 1];

    return Card(
      elevation: 2,
      color: Colors.transparent,  
      child: Container(
        height: 120,
        width: 100,
        child: Column(
          children: <Widget>[
            Image.network(
              'https://www.metaweather.com/static/img/weather/png/$image.png',
              height: 50,
              width: 50,
            ),
            Text("$temp °"),
            Text("$weekDay"),
          ],
        ),
      ),
    );
  }
}
