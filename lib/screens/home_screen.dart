import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:tripventure/screens/account_screen.dart';
import 'package:tripventure/screens/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';


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
        "$otmAPI${"radius"}?apikey=$apiKey&radius=1000&limit=-1&lon=$lon&lat=$lat&rate=2&format=json";
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

Future<Map<String, dynamic>> fetchAttractionDetails(String xid) async {
  String apiUrl = "$otmAPI${"xid"}/$xid?apikey=$apiKey&format=json";
  final response = await http.get(Uri.parse(apiUrl));

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    return data;
  } else {
    throw Exception('Failed to fetch attraction details');
  }
}


  String getCountryName(String code) {
    // Replace this function with the logic to get the country name from the country code.
    // For example, you can use a map to map country codes to country names.
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
      // Map the category codes to their corresponding names using a mapping function
      categoryNames.add(mapCategoryCodeToName(code));
    }

    return categoryNames.join(', '); // Join the category names with commas
  } else {
    return "Unknown"; // If kinds is not a string, provide a fallback category name
  }
}

// Helper function to map category codes to their corresponding names
String mapCategoryCodeToName(String code) {
  // Replace this mapping logic with the appropriate mapping for your use case
  // For example, you can use a map to map category codes to category names.
  // Here, we are providing a simple mapping for demonstration purposes.
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


void onShowPOI(Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (context) {
        return FutureBuilder<Map<String, dynamic>>(
          future: fetchAttractionDetails(data['xid']),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return AlertDialog(
                title: Text(data['name'] ?? 'Unknown'),
                content: CircularProgressIndicator(),
              );
            } else if (snapshot.hasError || snapshot.data == null) {
              return AlertDialog(
                title: Text(data['name'] ?? 'Unknown'),
                content: Text("Error loading attraction details."),
              );
            } else {
              final attractionDetails = snapshot.data!;
              return AlertDialog(
                title: Text(attractionDetails['name'] ?? data['name'] ?? 'Unknown'),
                content: Column(
                  children: [
                    if (attractionDetails['preview'] != null &&
                        attractionDetails['preview']['source'] != null)
                      Image.network(attractionDetails['preview']['source']),
                    if (attractionDetails['wikipedia_extracts'] != null &&
                        attractionDetails['wikipedia_extracts']['html'] != null)
                      Text(
                        attractionDetails['wikipedia_extracts']['html'],
                        textAlign: TextAlign.justify,
                      )
                    else if (attractionDetails['descr'] != null)
                      Text(
                        attractionDetails['descr'],
                        textAlign: TextAlign.justify,
                      )
                    else
                      Text("No description"),
                    if (attractionDetails['otm'] != null)
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
            }
          },
        );
      },
    );
  }
}