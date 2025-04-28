import 'package:flutter/material.dart';

class MyDashboard extends StatelessWidget {
  const MyDashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Profile",
          style: TextStyle(fontSize: 24, color: Colors.white),
        ),
        backgroundColor: Colors.blue.shade700,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Background Watermark
          Positioned.fill(
            child: Opacity(
              opacity: 0.1, // Light watermark effect
              child: Image.asset(
                'assets/register.png',
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Foreground Content
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Profile Photo (Rectangular Shape with Female Icon)
                    Container(
                      width: 100,
                      height: 120,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.grey[300], // Background color for placeholder
                      ),
                      child: Icon(
                        Icons.girl_rounded, // Female icon
                        size: 80,
                        color: Colors.blue.shade700,
                      ),
                    ),
                    SizedBox(width: 15), // Spacing between photo and details

                    // User Info (Increased Font Size)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Rupal Bagora",
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 5),
                        Text("19", style: TextStyle(fontSize: 18)),
                        SizedBox(height: 5),
                        Text("Female", style: TextStyle(fontSize: 18)),
                        SizedBox(height: 5),
                        Text("Indore, India", style: TextStyle(fontSize: 18)),
                      ],
                    ),
                  ],
                ),
              ),

              Spacer(), // Pushes the SOS button to the center

              // Big, Round SOS Button
              GestureDetector(
                onTap: () {
                  // SOS Functionality
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
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),

              Spacer(), // Pushes the Add Emergency Contacts button to the bottom

              // Add Emergency Contacts Button
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
                      // Navigate to emergency contacts screen
                      Navigator.pushNamed(context, 'contact');
                    },
                    child: Text(
                      "Add Emergency Contacts",
                      style: TextStyle(fontSize: 20, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
