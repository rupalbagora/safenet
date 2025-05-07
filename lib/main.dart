import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:safenet_final/login.dart';
import 'package:safenet_final/dashboard.dart';
import 'package:safenet_final/register.dart';
import 'package:safenet_final/verification.dart';
<<<<<<< HEAD
import 'package:safenet_final/emergency_cont.dart';
import 'package:safenet_final/config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  try {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "YOUR_API_KEY",
        appId: "YOUR_APP_ID",
        messagingSenderId: "YOUR_SENDER_ID",
        projectId: "YOUR_PROJECT_ID",
      ),
    );
  } catch (e) {
    print('Error initializing Firebase: $e');
  }

  // Initialize server connection
  try {
    final serverUrl = await Config.getServerUrl();
    print('Server URL: $serverUrl');
  } catch (e) {
    print('Error initializing server connection: $e');
  }

  runApp(const MyApp());
=======
import 'package:safenet_final/firebase_api.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FirebaseApi().initNotification();
  runApp(MyApp());
>>>>>>> 978a57669a192ede359381f40e300cf981ae96a4
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SafeNet',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: 'login',
      routes: {
        'login': (context) => const LoginScreen(),
        'register': (context) => const RegisterScreen(),
        'dashboard': (context) => const DashboardScreen(),
        'verification': (context) => const VerificationScreen(),
        'contact': (context) => const AddEmergencyContacts(),
      },
    );
  }
}