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

  bool loading = false;
  bool resendLoading = false;

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
        setState(() => timer--);
      }
    });
  }

  void msg(String text, {bool ok = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        backgroundColor: ok ? Colors.green : Colors.red,
      ),
    );
  }

  // ================= VERIFY OTP =================
  Future<void> verifyOtp() async {
    if (otpController.text.isEmpty) {
      msg("Enter OTP");
      return;
    }

    setState(() => loading = true);

    try {
      final result = await ApiService.verifyOtp(
        widget.email,
        otpController.text.trim(),
      );

      setState(() => loading = false);

      if (result['success'] == true) {
        msg("Verified successfully", ok: true);

        Navigator.pushNamedAndRemoveUntil(
          context,
          '/login',
          (route) => false,
        );
      } else {
        msg(result['error'] ?? "Invalid OTP");
      }
    } catch (e) {
      setState(() => loading = false);
      msg("Server error");
    }
  }

  // ================= RESEND OTP (FIXED) =================
  Future<void> resendOtp() async {
    if (!canResend) return;

    setState(() => resendLoading = true);

    try {
      // 🔥 الصحيح: إعادة إرسال OTP عبر endpoint خاص
      await ApiService.resendOtp(widget.email);

      msg("OTP sent again", ok: true);

      startTimer();
    } catch (e) {
      msg("Failed to resend OTP");
    }

    setState(() => resendLoading = false);
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

            Text("OTP sent to ${widget.email}"),

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
                onPressed: loading ? null : verifyOtp,
                child: loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("VERIFY"),
              ),
            ),

            const SizedBox(height: 20),

            Text(
              canResend
                  ? "You can resend OTP now"
                  : "Resend in $timer s",
            ),

            const SizedBox(height: 10),

            TextButton(
              onPressed: canResend && !resendLoading
                  ? resendOtp
                  : null,
              child: resendLoading
                  ? const CircularProgressIndicator()
                  : const Text("Resend OTP"),
            ),
          ],
        ),
      ),
    );
  }
}