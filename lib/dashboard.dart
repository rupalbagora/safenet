import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MyDashboard extends StatefulWidget {
  const MyDashboard({Key? key}) : super(key: key);

  @override
  State<MyDashboard> createState() => _MyDashboardState();
}

class _MyDashboardState extends State<MyDashboard> {
  String name = "";
  String gender = "";
  int age = 0;
  String location = "";

  @override
  void initState() {
    super.initState();
    fetchUserDetails();
  }

  Future<void> fetchUserDetails() async {
    final prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('user_id');

    if (userId == null) {
      print("User ID not found");
      return;
    }

    // Replace with your backend API endpoint
    final response = await http.get(Uri.parse("https://yourapi.com/user/$userId"));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      setState(() {
        name = data['name'] ?? "Unknown";
        gender = data['gender'] ?? "Unknown";
        age = data['age'] ?? 0;
        location = data['location'] ?? "Unknown";
      });
    } else {
      print("Failed to load user data: ${response.statusCode}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profile", style: TextStyle(fontSize: 24, color: Colors.white)),
        backgroundColor: Colors.blue.shade700,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.1,
              child: Image.asset('assets/register.png', fit: BoxFit.cover),
            ),
          ),
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 100,
                      height: 120,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.grey[300],
                      ),
                      child: Icon(
                        Icons.girl_rounded,
                        size: 80,
                        color: Colors.blue.shade700,
                      ),
                    ),
                    SizedBox(width: 15),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        SizedBox(height: 5),
                        Text("$age", style: TextStyle(fontSize: 18)),
                        SizedBox(height: 5),
                        Text(gender, style: TextStyle(fontSize: 18)),
                        SizedBox(height: 5),
                        Text(location, style: TextStyle(fontSize: 18)),
                      ],
                    ),
                  ],
                ),
              ),
              Spacer(),
              GestureDetector(
                onTap: () {
                  sendSOS;
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text("SOS Triggered"),
                      content: Text("Emergency contacts have been alerted!"),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text("OK"),
                        ),
                      ],
                    ),
                  );
                },
                child: Container(
                  width: 130,
                  height: 130,
                  decoration: BoxDecoration(
                    color: Colors.red.shade700,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.shade300,
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      "SOS",
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),
              ),
              Spacer(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                child: SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade700,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pushNamed(context, 'contact');
                    },
                    child: Text("Add Emergency Contacts", style: TextStyle(fontSize: 20, color: Colors.white)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> sendSOS() async {
    final prefs = await SharedPreferences.getInstance();
    final position = await Geolocator.getCurrentPosition();
    int? userId = prefs.getInt('user_id');
    if (userId == null) {
      print("User ID not found");
      return;
    }

    Map<String, dynamic> sosData = {
      'user_id': userId.toString(),
      'latitude': position.latitude,
      'longitude': position.longitude,
      'timestamp': DateTime.now().toIso8601String(),
      'message': 'Help needed immediately!'
    };

    print(sosData);

    // Optionally send it to your API
    // await http.post(Uri.parse("https://yourapi.com/sos"), body: jsonEncode(sosData));
  }
}
