import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  static Future<Map<String, dynamic>> submitData(Map<String, dynamic> formData) async {
    final url = Uri.parse('http://192.168.137.187:3001/user/save');


    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(formData),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {'success': false, 'message': 'Server error'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection failed'};
    }
  }

  // Already existing fetchData method
  static void fetchData() {
    print("Fetching data...");
  }
}
