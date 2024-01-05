import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';


const apiKey = "5ae2e3f221c38a28845f05b6949649ad6d947533abcb8f5eb5fe0f52";
const otmAPI = "https://api.opentripmap.com/0.1/en/places/";

const pageLength = 5;
double lon = 0.0;
double lat = 0.0;
int offset = 0;
int count = 0;

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

void showPOIDetails(BuildContext context, Map<String, dynamic> data) {
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

