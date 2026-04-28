import 'dart:async';
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class OtpScreen extends StatefulWidget {
  final String email;
  final String otpFromServer;

  const OtpScreen({
  super.key,
  required this.email,
  required this.otpFromServer,
});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final otpController = TextEditingController();

  bool loading = false;
  bool resendLoading = false;

  int timer = 60;
  bool canResend = false;
  Timer? countdown;

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  // ================= TIMER =================
  void startTimer() {
    countdown?.cancel();

    setState(() {
      timer = 60;
      canResend = false;
    });

    countdown = Timer.periodic(const Duration(seconds: 1), (t) {
      if (timer == 0) {
        setState(() => canResend = true);
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
      final res = await ApiService.verifyOtp(
        widget.email,
        otpController.text.trim(),
      );

      setState(() => loading = false);

      if (res['success'] == true) {
        msg("Account verified ✔️", ok: true);

        Navigator.pushNamedAndRemoveUntil(
          context,
          '/login',
          (route) => false,
        );
      } else {
        msg(res['error'] ?? "Invalid OTP ❌");
      }
    } catch (e) {
      setState(() => loading = false);
      msg("Server error ❌");
    }
  }

  // ================= RESEND OTP =================
  Future<void> resendOtp() async {
    if (!canResend) return;

    setState(() => resendLoading = true);

    try {
      await ApiService.resendOtp(widget.email);

      msg("OTP sent again ✔️", ok: true);

      startTimer();
    } catch (e) {
      msg("Failed to resend OTP ❌");
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
        title: const Text("OTP Verification"),
        backgroundColor: Colors.deepPurple,
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            const Icon(Icons.lock, size: 80, color: Colors.deepPurple),

            const SizedBox(height: 20),

            Text(
              "OTP sent to ${widget.email}",
              style: const TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 30),

            TextField(
              controller: otpController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Enter OTP",
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
                  : "Resend in $timer seconds",
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