import 'dart:async';
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class OtpScreen extends StatefulWidget {
  final String name;
  final String email;
  final String password;
  final String role;

  const OtpScreen({
    super.key,
    required this.name,
    required this.email,
    required this.password,
    required this.role,
  });

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final otpController = TextEditingController();

  bool isLoading = false;
  bool canResend = false;
  int timer = 60;
  Timer? countdown;

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  void startTimer() {
    canResend = false;
    timer = 60;

    countdown?.cancel();
    countdown = Timer.periodic(const Duration(seconds: 1), (t) {
      if (timer == 0) {
        setState(() {
          canResend = true;
        });
        t.cancel();
      } else {
        setState(() {
          timer--;
        });
      }
    });
  }

  void showMsg(String msg, {bool success = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
  }

  // ✅ VERIFY OTP
  Future<void> verifyOtp() async {
    if (otpController.text.isEmpty) {
      showMsg("Enter OTP ❌");
      return;
    }

    setState(() => isLoading = true);

    final result = await ApiService.verifyOtp(
      widget.email,
      otpController.text.trim(),
    );

    setState(() => isLoading = false);

    if (result['success'] == true) {
      showMsg("Verified ✅", success: true);

      Navigator.pushNamedAndRemoveUntil(
        context,
        '/login',
        (route) => false,
      );
    } else {
      showMsg(result['error'] ?? "Wrong OTP ❌");
    }
  }

  // ✅ RESEND OTP (احترافي)
  Future<void> resendOtp() async {
    if (!canResend) return;

    setState(() => isLoading = true);

    await ApiService.registerUser(
      widget.name,
      widget.email,
      widget.password,
      widget.role,
    );

    setState(() => isLoading = false);

    showMsg("OTP resent 📩", success: true);
    startTimer();
  }

  @override
  void dispose() {
    countdown?.cancel();
    otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Verify OTP"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            const SizedBox(height: 30),
            const Icon(Icons.lock, size: 80, color: Colors.deepPurple),

            const SizedBox(height: 20),

            const Text("Enter OTP sent to"),
            Text(
              widget.email,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),

            const SizedBox(height: 30),

            TextField(
              controller: otpController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "OTP Code",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: isLoading ? null : verifyOtp,
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("VERIFY"),
              ),
            ),

            const SizedBox(height: 20),

            Text(
              canResend
                  ? "You can resend OTP now"
                  : "Resend OTP in $timer s",
            ),

            const SizedBox(height: 10),

            TextButton(
              onPressed: canResend ? resendOtp : null,
              child: const Text("Resend OTP"),
            ),
          ],
        ),
      ),
    );
  }
}