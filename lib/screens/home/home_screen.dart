import 'package:flutter/material.dart';
import 'package:tripventure/screens/home/home_bloc.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:tripventure/screens/account/account_screen.dart';
import 'package:tripventure/screens/login/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> attractions = [];
  int selectedDistance = 1000;
  final List<int> distances = [1000, 2000, 5000, 10000];
  TextEditingController searchController =
      TextEditingController(); // Добавление контроллера текстового поля
  List<bool> isSelected = [
    true,
    false,
    false,
    false
  ]; // Список для выбора расстояния

  void clearAttractions() {
    setState(() {
      attractions.clear();
    });
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
        "$otmAPI${"radius"}?apikey=$apiKey&radius=$selectedDistance&limit=$pageLength&offset=$offset&lon=$lon&lat=$lat&rate=2&format=count";
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
        "$otmAPI${"radius"}?apikey=$apiKey&radius=$selectedDistance&limit=-1&lon=$lon&lat=$lat&rate=2&format=json";
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
                    builder: (context) => const AccountScreen(),
                  ),
                );
              }
            },
            icon: Icon(
              Icons.person,
              color: (user == null) ? Colors.black : Colors.blue,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Ваш текущий код здесь
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: searchController,
                            decoration: InputDecoration(
                              labelText: 'Поиск города',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        IconButton(
                      onPressed: () {
                        String query = searchController.text;
                        searchCities(query);
                      },
                      icon: Icon(Icons.search),
                    ),
                      ],
                    ),
                  ),
                  Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: ToggleButtons(
                      children: distances.map((distance) {
                        return Text('$distance м');
                      }).toList(),
                      isSelected: isSelected,
                      onPressed: (int index) {
                        setState(() {
                          for (int i = 0; i < isSelected.length; i++) {
                            if (i == index) {
                              isSelected[i] = true;
                              selectedDistance = distances[i];
                            } else {
                              isSelected[i] = false;
                            }
                          }
                        });
                      },
                      borderRadius: const BorderRadius.all(Radius.circular(8)),
                      selectedBorderColor: Colors.black,
                      selectedColor: Colors.white,
                      fillColor: Colors.grey,
                      color: Colors.black,
                      constraints: const BoxConstraints(
                        minHeight: 40.0,
                        minWidth: 80.0,
                      ),
                    ),
                  ),),
                  if (attractions
                      .isNotEmpty) // Проверка наличия результатов поиска
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: attractions.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(attractions[index]['name'] ?? 'Unknown'),
                          subtitle: Text(
                            getCategoryName(attractions[index]['kinds']) ??
                                'Unknown',
                          ),
                          onTap: () {
                            onShowPOI(attractions[index]);
                          },
                        );
                      },
                    ),
                  SizedBox(height: 16), // Отступ для пространства внизу
                ],
              ),
            ),
            if (attractions
                .isNotEmpty) // Условие показа кнопки "Закрыть список"
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: ElevatedButton(
                    onPressed: () {
                      clearAttractions(); // Вызов метода для очистки результатов поиска
                    },
                    child: Text('Закрыть список'),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
