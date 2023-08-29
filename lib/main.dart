import 'package:flutter/material.dart';
import 'package:weather_sdk/model/location_data.dart';
import 'package:weather_sdk/weather_sdk.dart';
import 'package:weather_sdk/weather_sdk_initializer.dart';
import 'package:weather_sdk/weather_widget.dart';
import 'package:weather_sdk_example/search_page.dart';

void main() {
  final sdkInitializer = WeatherSDKInitializer();
  sdkInitializer.initialize(apiKey: "bd5e378503939ddaee76f12ad7a97608");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Weather SDK Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  LocationData? _locationData;
  final WeatherSDK _weatherSDK = WeatherSDK();

  TemperatureUnit units = TemperatureUnit.metric;

  DateTime selectedWeatherDate = DateTime.now();

  @override
  void initState() {
    super.initState();

    WeatherSDKInitializer().unitsStream.listen((units) {
      // Units have changed, refresh weather data
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: [
          IconButton(
              onPressed: () async {
                final location = await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const SearchPage(),
                  ),
                );
                setState(() {
                  _locationData = location;
                });
              },
              icon: const Icon(Icons.search)),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Weather SDK Demo',
            ),
            _buildWeatherWidget(),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherWidget() {
    if (_locationData != null) {
      return Column(
        children: [
          Text(
            "Selected Location: ${_locationData?.name ?? 'None'}",
          ),
          SizedBox(height: 16,),
          ElevatedButton(
            onPressed: () async {
              final selectedDate = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime.now(),
              );
              if (selectedDate != null) {
                setState(() {
                  selectedWeatherDate = selectedDate;
                });
              }
            },
            child: Text('Select Date'),
          ),
          Text(
            "Selected Date: $selectedWeatherDate",
          ),
          SizedBox(height: 16,),
          DropdownButton<TemperatureUnit>(
            value: units,
            items: const [
              DropdownMenuItem(
                child: Text('Metric'),
                value: TemperatureUnit.metric,
              ),
              DropdownMenuItem(
                child: Text('Imperial'),
                value: TemperatureUnit.imperial,
              ),
            ],
            onChanged: (value) {
              _weatherSDK.updateUnits(value!);
              setState(() {
                units = value;
              });
            },
          ),
          SizedBox(height: 16,),
          WeatherWidget(
            dateTime: selectedWeatherDate,
            latitude: _locationData!.lat,
            longitude: _locationData!.lon,
          ),
        ],
      );
    } else {
      return const Text('No location selected');
    }
  }
}
