import 'package:flutter/material.dart';

class AddEmergencyContacts extends StatefulWidget {
  @override
  State<AddEmergencyContacts> createState() => _AddEmergencyContactsState();
}

class _AddEmergencyContactsState extends State<AddEmergencyContacts> {
  final _formKey = GlobalKey<FormState>();

  // Controller for name and number
  final TextEditingController nameController = TextEditingController();
  final TextEditingController numberController = TextEditingController();

  // List of close relations
  final List<String> relations = [
    "Father",
    "Mother",
    "Brother",
    "Sister",
    "Spouse",
    "Friend",
    "Guardian"
  ];

  String? selectedRelation; // Stores selected relation

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Emergency Contact",
        style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.blue.shade700,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Name Input
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
                  if (value == null || value.isEmpty) {
                    return "Please enter a name";
                  }
                  return null;
                },
              ),
              SizedBox(height: 15),

              // Relation Dropdown
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
                  if (value == null) {
                    return "Please select a relation";
                  }
                  return null;
                },
              ),
              SizedBox(height: 15),

              // Number Input
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

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // Save logic (e.g., store in database or local storage)
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Emergency contact added!")),
                      );
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade700,
                    padding: EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text("Save Contact", style: TextStyle(color:Colors.white, fontSize: 18)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
