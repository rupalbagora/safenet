import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'api.dart';
import 'dart:math';
import 'dart:convert';
import 'package:http/http.dart' as http;


class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    ApiService.fetchData(); // Call API on build
    return Scaffold(
      appBar: AppBar(title: Text("Home")),
      body: Center(child: Text("Check console for backend response")),
    );
  }
}

class MyRegister extends StatefulWidget {
  const MyRegister({Key? key}) : super(key: key);

  @override
  _MyRegisterState createState() => _MyRegisterState();
}

class _MyRegisterState extends State<MyRegister> {
  // Country list
  final List<Map<String, dynamic>> countries = [
    {"code": "+91", "flag": "🇮🇳", "name": "India"},
    {"code": "+1", "flag": "🇺🇸", "name": "USA"},
    // … other countries …
    {"code": "+55", "flag": "🇧🇷", "name": "Brazil"},
  ];

  // Selected country for phone code
  Map<String, dynamic> selectedCountry = {"code": "+91", "flag": "🇮🇳", "name": "India"};

  // Form field variables
  String enteredName = "";
  String enteredEmail = "";
  String enteredAadhaar = "";
  String phoneNumber = "";
  String enteredPassword = "";

  get userId => null;

  // Simple form validation
  bool isFormValid() {
    return enteredName.isNotEmpty &&
        enteredEmail.isNotEmpty &&
        enteredAadhaar.length == 12 &&
        phoneNumber.length == 10 &&
        enteredPassword.length >= 5;
  }

  bool _isEmailVerification = true; // Default to email verification

  // Submit to backend
  void submitForm() async {
    if (!isFormValid()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all fields correctly!')),
      );
      return;
    }

    // Simulating a set of already assigned user IDs
    Set<int> assignedUserIds = {}; // Ideally fetched from your backend/database

    int generateUniqueUserId() {
      final rand = Random();
      int userId;

      do {
        userId = 10000000 + rand.nextInt(90000000); // Always 8 digits
      } while (assignedUserIds.contains(userId));

      assignedUserIds.add(userId); // Add to local set (or send to backend)
      return userId;
    }
    final formData = {
      "user_id": userId,
      "name": enteredName,
      "email": enteredEmail,
      "aadhar_no": enteredAadhaar,
      "mobile": "${selectedCountry['code']}$phoneNumber",
      "password": enteredPassword,
      "role": "user",
      "status": 0, // Set to 0 until verified
      "info": ""
    };

    try {
      final resp = await ApiService.submitData(formData);
      if (resp != null && resp['success'] == true) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(resp['message'] ?? 'Registration successful!')),
        );

        // Wait for a short time to show message
        await Future.delayed(Duration(seconds: 2));

        // Navigate to verification screen with necessary data
        Navigator.pushNamed(
          context,
          'verification',
          arguments: {
            'isEmailVerification': _isEmailVerification,
            'email': enteredEmail,
            'phoneNumber': "${selectedCountry['code']}$phoneNumber",
            'verificationId': resp['verificationId'],
          },
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registration failed: ${resp?['message'] ?? 'Unknown error'}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error submitting form!')),
      );
    }
  }

  /// Function to send SOS alert
  Future<void> sendSosAlert({
    required String userId,
    required String name,
    required double latitude,
    required double longitude,
  }) async {
    const String apiUrl = 'https://your-backend-url.com/api/send-sos'; // Replace with your actual endpoint

    final Map<String, dynamic> sosData = {
      "user_id": userId,
      "user_name": name,
      "location": {
        "latitude": latitude,
        "longitude": longitude
      },
      "message": "⚠️ SOS Alert from $name at location (Lat: $latitude, Lon: $longitude)"
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(sosData),
      );

      if (response.statusCode == 200) {
        print("✅ SOS alert sent successfully.");
      } else {
        print("❌ Failed to send SOS. Response: ${response.body}");
      }
    } catch (e) {
      print("❌ Error sending SOS: $e");
    }
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(image: AssetImage('assets/register.png'), fit: BoxFit.cover),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
        body: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 35, top: 48),
              child: Text('Create\nAccount', style: TextStyle(color: Colors.white, fontSize: 33)),
            ),
            SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.25),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 35),
                  child: Column(
                    children: [
                      // Name
                      TextField(
                        onChanged: (v) => enteredName = v,
                        style: TextStyle(color: Colors.white),
                        decoration: _buildDecoration("Name"),
                      ),
                      SizedBox(height: 15),

                      // Email
                      TextField(
                        onChanged: (v) => enteredEmail = v,
                        style: TextStyle(color: Colors.white),
                        decoration: _buildDecoration("Email"),
                      ),
                      SizedBox(height: 15),

                      // Aadhaar
                      TextField(
                        onChanged: (v) => enteredAadhaar = v,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        style: TextStyle(color: Colors.white),
                        decoration: _buildDecoration("Aadhaar No."),
                      ),
                      SizedBox(height: 15),

                      // Phone with country code
                      Row(
                        children: [
                          // Country picker
                          SizedBox(
                            width: 110,
                            child: InkWell(
                              onTap: () => _showCountryPicker(context),
                              child: Container(
                                height: 58,
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.white),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text("${selectedCountry['flag']} ${selectedCountry['code']}",
                                        style: TextStyle(color: Colors.white)),
                                    Icon(Icons.arrow_drop_down, color: Colors.white),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              onChanged: (v) => phoneNumber = v,
                              keyboardType: TextInputType.phone,
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                              style: TextStyle(color: Colors.white),
                              decoration: _buildDecoration("Phone Number"),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 15),

                      // Password
                      TextField(
                        onChanged: (v) => enteredPassword = v,
                        obscureText: true,
                        style: TextStyle(color: Colors.white),
                        decoration: _buildDecoration("Password"),
                      ),
                      SizedBox(height: 20),

                      // Add verification type selection
                      SizedBox(height: 20),
                      Text(
                        "Choose Verification Method",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: RadioListTile<bool>(
                              title: Text(
                                "Email",
                                style: TextStyle(color: Colors.white),
                              ),
                              value: true,
                              groupValue: _isEmailVerification,
                              onChanged: (value) {
                                setState(() {
                                  _isEmailVerification = value!;
                                });
                              },
                              activeColor: Colors.white,
                            ),
                          ),
                          Expanded(
                            child: RadioListTile<bool>(
                              title: Text(
                                "Phone",
                                style: TextStyle(color: Colors.white),
                              ),
                              value: false,
                              groupValue: _isEmailVerification,
                              onChanged: (value) {
                                setState(() {
                                  _isEmailVerification = value!;
                                });
                              },
                              activeColor: Colors.white,
                            ),
                          ),
                        ],
                      ),

                      // Buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pushNamed(context, 'login'),
                            child: Text('Sign In',
                                style: TextStyle(color: Colors.white, fontSize: 24)),
                          ),
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: Color(0xff4c505b),
                            child: IconButton(
                              icon: Icon(Icons.arrow_forward, color: Colors.white),
                              onPressed: submitForm,
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Shared InputDecoration builder
  InputDecoration _buildDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.white),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.white),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.black),
      ),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
    );
  }

  // Country picker sheet
  void _showCountryPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Color(0xff4c505b),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      isScrollControlled: true,
      builder: (_) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
        child: Column(
          children: [
            Text("Select Country",
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            Divider(color: Colors.white30),
            Expanded(
              child: ListView.builder(
                itemCount: countries.length,
                itemBuilder: (_, i) => ListTile(
                  leading: Text(countries[i]["flag"], style: TextStyle(fontSize: 24)),
                  title: Text(countries[i]["name"], style: TextStyle(color: Colors.white)),
                  trailing: Text(countries[i]["code"], style: TextStyle(color: Colors.white70)),
                  onTap: () {
                    setState(() => selectedCountry = countries[i]);
                    Navigator.pop(context);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
