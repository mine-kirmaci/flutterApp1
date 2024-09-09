import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

LocationSettings locationSettings = LocationSettings(
  accuracy: LocationAccuracy.high,
  distanceFilter: 10,
);

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => RestaurantProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class RestaurantProvider extends ChangeNotifier {
  Position? _currentPosition;
  List<String> _restaurantNames = [];
  bool _isLoading = true;
  bool locationPermissionDenied = false;

  List<String> get restaurantNames => _restaurantNames;
  bool get isLoading => _isLoading;

  Future<void> fetchRestaurants(BuildContext context) async {
    _isLoading = true;
    notifyListeners();
    await _getCurrentLocation(context);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> _getCurrentLocation(BuildContext context) async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      _showDialog(context);  // context'i burada kullanarak dialog gösteriyoruz.
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        _showDialog(context);  // Yine context kullanarak dialog gösterimi.
        return;
      }
    }

    try {
      _currentPosition = await Geolocator.getCurrentPosition(
        locationSettings: locationSettings,
      );
      if (_currentPosition != null) {
        await findNearbyRestaurants(
            _currentPosition!.latitude, _currentPosition!.longitude);
      }
    } catch (e) {
      print("Error getting current location: $e");
    }
  }

  Future<void> findNearbyRestaurants(double latitude, double longitude) async {
    var mapUrl = Uri.parse(
        'https://google-map-places.p.rapidapi.com/maps/api/place/nearbysearch/json?location=$latitude,$longitude&radius=1500&type=restaurant');
    var headers = {
      'X-RapidAPI-Key': '068aa1865bmsh3f9b068a27c0ab7p17e286jsn71ed581c6592',
      'X-RapidAPI-Host': 'google-map-places.p.rapidapi.com',
    };
    var response = await http.get(mapUrl, headers: headers);

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      var jsonResponse = convert.jsonDecode(response.body) as Map<String, dynamic>;
      var results = jsonResponse['results'] as List<dynamic>;

      if (results.isNotEmpty) {
        _restaurantNames = results.map((place) => place['name'] as String).toList();
        notifyListeners();
      }
    } else {
      print('Request failed with status: ${response.statusCode}.');
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> _showDialog(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konum Servisi Kapalı'),
          content: const Text('Konum servisinin açık olması gerekiyor.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Tamam'),
            ),
          ],
        );
      },
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Consumer<RestaurantProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return const CircularProgressIndicator();
            } else if (provider.restaurantNames.isEmpty) {
              return const Text("Yakınlarda restoran bulunamadı.");
            } else {
              return ListView.builder(
                itemCount: provider.restaurantNames.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(provider.restaurantNames[index]),
                  );
                },
              );
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Provider.of<RestaurantProvider>(context, listen: false).fetchRestaurants(context); // context'i buradan geçiyoruz.
        },
        tooltip: 'Restoranları Getir',
        child: const Icon(Icons.search),
      ),
    );
  }
}
