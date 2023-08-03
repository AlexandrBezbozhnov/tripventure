import 'package:flutter/material.dart';
import 'package:tripventure/screens/home/home_bloc.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:tripventure/screens/account_screen.dart';
import 'package:tripventure/screens/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> attractions = [];
  void onShowPOI(Map<String, dynamic> data) {
    // Call the backend function to show the POI details
    showPOIDetails(context, data);
  }
  Future<void> searchCities(String query) async {
    String apiUrl = "$otmAPI${"geoname"}?apikey=$apiKey&name=$query";
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == "OK") {
        setState(() {
          String message =
              "${data['name']}, ${getCountryName(data['country'])}";
          lon = double.parse(data['lon'].toString());
          lat = double.parse(data['lat'].toString());
          firstLoad();
        });
      }
    } else {
      print('Error during API request: ${response.reasonPhrase}');
    }
  }

  Future<void> firstLoad() async {
    String apiUrl =
        "$otmAPI${"radius"}?apikey=$apiKey&radius=1000&limit=$pageLength&offset=$offset&lon=$lon&lat=$lat&rate=2&format=count";
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        count = data['count'];
        offset = 0;
        loadList();
      });
    } else {
      print('Error during API request: ${response.reasonPhrase}');
    }
  }

  Future<void> loadList() async {
    String apiUrl =
        "$otmAPI${"radius"}?apikey=$apiKey&radius=1000&limit=-1&lon=$lon&lat=$lat&rate=2&format=json";
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data is List) {
        setState(() {
          attractions = List.from(data);
        });
      } else {
        print('Error: Invalid API response - not a List.');
      }
    } else {
      print('Error during API request: ${response.reasonPhrase}');
    }
  }

  String getCountryName(String code) {
    return "Country";
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Главная страница'),
        actions: [
          IconButton(
            onPressed: () {
              if ((user == null)) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const AccountScreen()),
                );
              }
            },
            icon: Icon(
              Icons.person,
              color: (user == null) ? Colors.white : Colors.yellow,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                onSubmitted: (value) {
                  searchCities(value);
                },
                decoration: InputDecoration(
                  labelText: 'Поиск города',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: attractions.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(attractions[index]['name'] ?? 'Unknown'),
                    subtitle: Text(
                        getCategoryName(attractions[index]['kinds']) ?? 'Unknown'),
                    onTap: () {
                      onShowPOI(attractions[index]);
                    },
                  );
                },
              ),
            ),
            Text(
              "${attractions.length.toString()} objects with description in a 1km radius",
            ),
          ],
        ),
      ),
    );
  }

  String getCategoryName(dynamic kinds) {
    if (kinds is String) {
      List<String> categoryCodes = kinds.split(',');
      List<String> categoryNames = [];

      for (String code in categoryCodes) {
        categoryNames.add(mapCategoryCodeToName(code));
      }

      return categoryNames.join(', ');
    } else {
      return "Unknown";
    }
  }

  String mapCategoryCodeToName(String code) {
    if (code == "religion") {
      return "Religion";
    } else if (code == "architecture") {
      return "Architecture";
    } else if (code == "historic_architecture") {
      return "Historic Architecture";
    } else if (code == "other_temples") {
      return "Other Temples";
    } else if (code == "interesting_places") {
      return "Interesting Places";
    } else if (code == "destroyed_objects") {
      return "Destroyed Objects";
    } else {
      return "Unknown Category";
    }
  }
}
