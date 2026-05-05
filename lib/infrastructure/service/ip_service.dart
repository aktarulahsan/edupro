import 'dart:convert';

import 'package:http/http.dart' as http;

class IpService {
  static const String url = "https://api.ipregistry.co/?key=tryout";

  Future<String> lookupUserCountry() async {
    // final response = await http.get(url,  headers: {"Content-Type": "application/json"});

    final response = await http.get(
      Uri.parse(url),
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode == 200) {
      return json.decode(response.body)['location']['country']['name'];
    } else {
      throw Exception('Failed to get user country from IP address');
    }
  }
}
