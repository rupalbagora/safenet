import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:safenet_final/dashboard.dart';
import 'package:safenet_final/emergency_cont.dart';
import 'package:safenet_final/login.dart';
import 'package:safenet_final/register.dart';
import 'package:safenet_final/verification.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SafeNet App',
      debugShowCheckedModeBanner: false,
      initialRoute: 'login',
      routes: {
        'login': (context) => MyLogin(),
        'register': (context) => MyRegister(),
        'dashboard': (context) => MyDashboard(),
        'verification': (context) => MyOtp(),
        'contact': (context) => AddEmergencyContacts(),
      },
    );
  }
}