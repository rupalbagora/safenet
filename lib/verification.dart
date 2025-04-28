import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart';
import 'face_capture_screen.dart'; // Ensure correct import path

class MyOtp extends StatefulWidget {
  const MyOtp({Key? key}) : super(key: key);

  @override
  State<MyOtp> createState() => _MyOtpState();
}

class _MyOtpState extends State<MyOtp> {
  final TextEditingController _otpController = TextEditingController();
  final LocalAuthentication auth = LocalAuthentication();
  final String correctOtp = "123456"; // Replace with your OTP logic
  String? errorMessage;
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  void verifyOtp() async {
    String enteredOtp = _otpController.text;

    if (enteredOtp.isEmpty) {
      setState(() {
        errorMessage = "Please enter the OTP!";
      });
    } else if (enteredOtp != correctOtp) {
      setState(() {
        errorMessage = "Invalid OTP. Please try again!";
      });
    } else {
      setState(() {
        errorMessage = null;
      });

      // ✅ Face verification
      await verifyFace();
    }
  }

  Future<void> verifyFace() async {
    try {
      final cameras = await availableCameras();
      final frontCamera = cameras.firstWhere(
            (camera) => camera.lensDirection == CameraLensDirection.front,
      );

      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FaceCaptureScreen(camera: frontCamera),
        ),
      );

      if (result == true) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("Verification Successful"),
            content: Text("Your phone number has been verified successfully."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, 'login'); // Navigate to login screen
                },
                child: Text("Go to Login"),
              ),
            ],
          ),
        );
      } else {
        _scaffoldMessengerKey.currentState?.showSnackBar(
          SnackBar(content: Text('Face not recognized or capture failed. Please try again.')),
        );
      }
    } on PlatformException catch (e) {
      _scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(content: Text('Error: ${e.message}')),
      );
    } catch (e) {
      _scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(content: Text('Unexpected error: $e')),
      );
    }
  }

  void resendOtp() {
    _scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text("OTP has been resent to your phone number."),
        duration: Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldMessengerKey, // Attach the key to Scaffold
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_ios_rounded, color: Colors.black),
        ),
        elevation: 0,
      ),
      body: Container(
        margin: EdgeInsets.symmetric(horizontal: 25),
        alignment: Alignment.center,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/Aadhaar_Logo.png', width: 150, height: 150),
              SizedBox(height: 25),
              Text("Phone Verification",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              Text(
                "We need to verify your phone number before getting started!",
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 30),
              Pinput(
                controller: _otpController,
                length: 6,
                showCursor: true,
                defaultPinTheme: PinTheme(
                  width: 56,
                  height: 56,
                  textStyle: TextStyle(
                    fontSize: 17,
                    color: Colors.grey.shade800,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
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
              SizedBox(
                width: double.infinity,
                height: 45,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: verifyOtp,
                  child: Text(
                    "Verify Phone Number",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              SizedBox(height: 15),
              TextButton(
                onPressed: resendOtp,
                child: Text(
                  "OTP not received? Resend",
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}