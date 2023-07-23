import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:tripventure/screens/account_screen.dart';
import 'package:tripventure/screens/login_screen.dart';

const apiKey = "5ae2e3f221c38a28845f05b6949649ad6d947533abcb8f5eb5fe0f52";
const otmAPI = "https://api.opentripmap.com/0.1/en/places/";

const pageLength = 5; // number of objects per page
double lon = 0.0; // place longitude
double lat = 0.0; // place latitude
int offset = 0; // offset from the first object in the list
int count = 0; // total objects count

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> attractions = [];

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
        "$otmAPI${"radius"}?apikey=$apiKey&radius=1000&limit=$pageLength&offset=$offset&lon=$lon&lat=$lat&rate=2&format=json";
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data is List) {
        setState(() {
          attractions = List.from(data); // Initialize with the API response
        });
      } else {
        print('Error: Invalid API response - not a List.');
      }
    } else {
      print('Error during API request: ${response.reasonPhrase}');
    }
  }

  String getCountryName(String code) {
    // Replace this function with the logic to get the country name from the country code.
    // For example, you can use a map to map country codes to country names.
    return "Country";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Главная страница'),
        actions: [
          IconButton(
            onPressed: () {
              // Open login screen when the person icon is clicked.
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
            icon: Icon(Icons.person),
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
                  // Call the searchCities function when the user submits the query.
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
                "${count.toString()} objects with description in a 1km radius"),
            ElevatedButton(
              onPressed: () {
                offset += pageLength;
                loadList();
              },
              child: Text("Next (${offset + pageLength} of $count)"),
            ),
          ],
        ),
      ),
    );
  }

String getCategoryName(dynamic kinds) {
  if (kinds is List) {
    // If kinds is a list, use the existing logic to map category codes to category names.
    // Replace this logic with the appropriate mapping for your use case.
    return "Category"; // Provide the fallback category name
  } else if (kinds is String) {
    // If kinds is a string, it represents the category name directly.
    return kinds;
  } else {
    // If kinds is neither a list nor a string, provide a fallback category name.
    return "Unknown";
  }
}

  void onShowPOI(Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(data['name']),
          content: Column(
            children: [
              if (data['preview'] != null && data['preview']['source'] != null)
                Image.network(data['preview']['source']),
              Text(
                data['wikipedia_extracts'] != null
                    ? data['wikipedia_extracts']['html']
                    : (data['descr'] != null
                        ? data['descr']
                        : "No description"),
                textAlign: TextAlign.justify,
              ),
              if (data['otm'] != null)
                TextButton(
                  onPressed: () {},
                  child: Text("Show more at OpenTripMap"),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Close"),
            ),
          ],
        );
      },
    );
  }
}
