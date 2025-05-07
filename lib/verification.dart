import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'face_capture_screen.dart';

class MyOtp extends StatefulWidget {
  const MyOtp({Key? key}) : super(key: key);

  @override
  State<MyOtp> createState() => _MyOtpState();
}

class _MyOtpState extends State<MyOtp> {
  final TextEditingController _otpController = TextEditingController();
  final LocalAuthentication auth = LocalAuthentication();
  String? errorMessage;
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
  bool _canCheckBiometrics = false;
  String _status = '';
  bool _isVerifying = false;
  bool _isEmailVerification = true; // Default to email verification
  String? _verificationId;
  String? _email;
  String? _phoneNumber;

  @override
  void initState() {
    super.initState();
    _checkBiometrics();
    // Get verification type and contact info from route arguments
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null) {
        setState(() {
          _isEmailVerification = args['isEmailVerification'] ?? true;
          _email = args['email'];
          _phoneNumber = args['phoneNumber'];
          _verificationId = args['verificationId'];
        });
      }
    });
  }

  Future<void> _checkBiometrics() async {
    bool canCheckBiometrics;
    try {
      canCheckBiometrics = await auth.canCheckBiometrics;
    } catch (e) {
      canCheckBiometrics = false;
      print(e);
    }
    if (!mounted) return;

    setState(() {
      _canCheckBiometrics = canCheckBiometrics;
    });
  }

  Future<void> verifyOtp() async {
    if (_isVerifying) return;

    String enteredOtp = _otpController.text;

    if (enteredOtp.isEmpty) {
      setState(() {
        errorMessage = "Please enter the OTP!";
      });
      return;
    }

    setState(() {
      _isVerifying = true;
      errorMessage = null;
    });

    try {
      // Verify OTP with backend
      final response = await http.post(
        Uri.parse('http://192.168.31.121:3001/user/verify-otp'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'verificationId': _verificationId,
          'otp': enteredOtp,
          'type': _isEmailVerification ? 'email' : 'phone',
          'contact': _isEmailVerification ? _email : _phoneNumber,
        }),
      );

      if (response.statusCode == 200) {
        // Start face verification
        await _startFaceVerification();
      } else {
        setState(() {
          errorMessage = "Invalid OTP. Please try again!";
          _isVerifying = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "Error verifying OTP. Please try again!";
        _isVerifying = false;
      });
    }
  }

  Future<void> _startFaceVerification() async {
    try {
      final cameras = await availableCameras();
      if (!mounted) return;

      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FaceCaptureScreen(cameras: cameras),
        ),
      );

      if (result != null && result['success']) {
        setState(() {
          _status = 'Face verification successful';
        });
        
        // Show success dialog and navigate to login
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: Text("Verification Successful"),
            content: Text("Your account has been verified successfully. Please login to continue."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close dialog
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    'login',
                    (route) => false, // Remove all previous routes
                  );
                },
                child: Text("Go to Login"),
              ),
            ],
          ),
        );
      } else {
        setState(() {
          _status = result?['error'] ?? 'Face verification failed';
          _isVerifying = false;
        });
        
        _scaffoldMessengerKey.currentState?.showSnackBar(
          SnackBar(
            content: Text('Face verification failed. Please try again.'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _status = 'Error: $e';
        _isVerifying = false;
      });
      
      _scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(
          content: Text('Error during face verification: $e'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  void resendOtp() async {
    if (_isVerifying) return;
    
    try {
      final response = await http.post(
        Uri.parse('http://192.168.31.121:3001/user/resend-otp'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'type': _isEmailVerification ? 'email' : 'phone',
          'contact': _isEmailVerification ? _email : _phoneNumber,
        }),
      );

      if (response.statusCode == 200) {
        setState(() {
          _otpController.clear();
          errorMessage = null;
        });
        
        _scaffoldMessengerKey.currentState?.showSnackBar(
          SnackBar(
            content: Text("OTP has been resent to your ${_isEmailVerification ? 'email' : 'phone number'}."),
            duration: Duration(seconds: 4),
          ),
        );
      } else {
        _scaffoldMessengerKey.currentState?.showSnackBar(
          SnackBar(
            content: Text("Failed to resend OTP. Please try again."),
            duration: Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      _scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(
          content: Text("Error resending OTP. Please try again."),
          duration: Duration(seconds: 4),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldMessengerKey,
      appBar: AppBar(
        title: Text(_isEmailVerification ? "Email Verification" : "Phone Verification"),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blue.shade900, Colors.blue.shade500],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/Aadhaar_Logo.png', width: 150, height: 150),
                  SizedBox(height: 25),
                  Text(
                    _isEmailVerification ? "Email Verification" : "Phone Verification",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "We need to verify your ${_isEmailVerification ? 'email' : 'phone number'} before getting started!",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 30),
                  Pinput(
                    controller: _otpController,
                    length: 6,
                    showCursor: true,
                    enabled: !_isVerifying,
                    defaultPinTheme: PinTheme(
                      width: 56,
                      height: 56,
                      textStyle: TextStyle(
                        fontSize: 17,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  if (errorMessage != null) ...[
                    SizedBox(height: 10),
                    Text(
                      errorMessage!,
                      style: TextStyle(color: Colors.red, fontSize: 14),
                    ),
                  ],
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _isVerifying ? null : verifyOtp,
                    child: Text(_isVerifying ? "Verifying..." : "Verify OTP"),
                    style: ElevatedButton.styleFrom(
                      primary: Colors.white,
                      onPrimary: Colors.blue.shade900,
                      padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                    ),
                  ),
                  SizedBox(height: 15),
                  TextButton(
                    onPressed: _isVerifying ? null : resendOtp,
                    child: Text(
                      "Resend OTP",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}