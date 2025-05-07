import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AddEmergencyContacts extends StatefulWidget {
  @override
  State<AddEmergencyContacts> createState() => _AddEmergencyContactsState();
}

class _AddEmergencyContactsState extends State<AddEmergencyContacts> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController numberController = TextEditingController();

  final List<String> relations = [
    "Father",
    "Mother",
    "Brother",
    "Sister",
    "Spouse",
    "Friend",
    "Guardian"
  ];

  String? selectedRelation;
  bool isSubmitting = false;

  // Local list to store contacts temporarily
  List<Map<String, String>> emergencyContacts = [];

  Future<void> _submitContact() async {
    setState(() {
      isSubmitting = true;
    });

    final url = Uri.parse('http://192.168.137.187:3001/emergency/save'); // Replace this
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": "user@example.com", // Use actual user data
        "name": nameController.text.trim(),
        "relation": selectedRelation,
        "mobile": numberController.text.trim(),
      }),
    );

    final responseData = jsonDecode(response.body);

    setState(() {
      isSubmitting = false;
    });

    if (response.statusCode == 200 && responseData["success"] == true) {
      // Add to local list
      setState(() {
        emergencyContacts.add({
          "name": nameController.text.trim(),
          "relation": selectedRelation!,
          "mobile": numberController.text.trim(),
        });
        nameController.clear();
        numberController.clear();
        selectedRelation = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Emergency contact added!")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${responseData["msg"] ?? "Something went wrong"}")),
      );
    }
  }

  Widget buildContactList() {
    if (emergencyContacts.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 20),
        child: Text("No emergency contacts added yet."),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: emergencyContacts.map((contact) {
        return Card(
          margin: EdgeInsets.symmetric(vertical: 6),
          child: ListTile(
            title: Text(contact["name"]!),
            subtitle: Text("${contact["relation"]} - ${contact["mobile"]}"),
            leading: Icon(Icons.contact_phone, color: Colors.blue.shade700),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Emergency Contact", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue.shade700,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  // Name
                  TextFormField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: "Name",
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) return "Please enter a name";
                      return null;
                    },
                  ),
                  SizedBox(height: 15),

                  // Relation
                  DropdownButtonFormField<String>(
                    value: selectedRelation,
                    hint: Text("Select Relation"),
                    decoration: InputDecoration(
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue),
                      ),
                    ),
                    items: relations.map((relation) {
                      return DropdownMenuItem<String>(
                        value: relation,
                        child: Text(relation),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedRelation = value;
                      });
                    },
                    validator: (value) {
                      if (value == null) return "Please select a relation";
                      return null;
                    },
                  ),
                  SizedBox(height: 15),

                  // Phone Number
                  TextFormField(
                    controller: numberController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: "Phone Number",
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please enter a phone number";
                      } else if (!RegExp(r'^[0-9]{10}$').hasMatch(value)) {
                        return "Enter a valid 10-digit number";
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isSubmitting
                          ? null
                          : () {
                        if (_formKey.currentState!.validate()) {
                          _submitContact();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade700,
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: isSubmitting
                          ? CircularProgressIndicator(color: Colors.white)
                          : Text(
                        "Save Contact",
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 30),
            Divider(),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Saved Contacts",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            buildContactList(),
          ],
        ),
      ),
    );
  }
}
