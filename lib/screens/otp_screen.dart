import 'dart:async';
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class OtpScreen extends StatefulWidget {
  final String email;

  const OtpScreen({
    super.key,
    required this.email,
  });

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final TextEditingController otpController = TextEditingController();

  int seconds = 60;
  Timer? timer;
  bool expired = false;
  bool loading = false;

  // 🔥 RESEND CONTROL
  bool canResend = false;
  int resendTimer = 60;
  Timer? resendCountdown;

  @override
  void initState() {
    super.initState();
    startTimer();
    startResendTimer();
  }

  // ================= OTP TIMER =================
  void startTimer() {
    timer?.cancel();

    setState(() {
      seconds = 60;
      expired = false;
    });

    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (seconds == 0) {
        setState(() {
          expired = true;
        });
        t.cancel();
      } else {
        setState(() {
          seconds--;
        });
      }
    });
  }

  // ================= RESEND TIMER =================
  void startResendTimer() {
    resendCountdown?.cancel();

    setState(() {
      canResend = false;
      resendTimer = 60;
    });

    resendCountdown =
        Timer.periodic(const Duration(seconds: 1), (timer) {
      if (resendTimer == 0) {
        timer.cancel();
        setState(() {
          canResend = true;
        });
      } else {
        setState(() {
          resendTimer--;
        });
      }
    });
  }

  // ================= VERIFY OTP =================
  Future<void> verifyOtp() async {
    if (otpController.text.isEmpty) return;

    setState(() => loading = true);

    try {
      final res = await ApiService.verifyOtp(
        widget.email,
        otpController.text.trim(),
      );

      setState(() => loading = false);

      if (!mounted) return;

      if (res['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Account verified ✅"),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pushReplacementNamed(context, '/login');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(res['error'] ?? "Wrong OTP"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() => loading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Server error ❌"),
        ),
      );
    }
  }

  // ================= RESEND OTP =================
  Future<void> resendOtp() async {
    if (!canResend) return;

    setState(() => loading = true);

    try {
      await ApiService.resendOtp(widget.email);

      setState(() => loading = false);

      startTimer();
      startResendTimer(); // 🔥 مهم جداً

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("New OTP sent 🔁"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() => loading = false);
    }
  }

  // ================= DISPOSE =================
  @override
  void dispose() {
    timer?.cancel();
    resendCountdown?.cancel();
    otpController.dispose();
    super.dispose();
  }

  // ================= UI =================
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

            const SizedBox(height: 20),

            const Icon(
              Icons.lock,
              size: 80,
              color: Colors.deepPurple,
            ),

            const SizedBox(height: 20),

            Text(
              "Verify ${widget.email}",
              style: const TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 20),

            // ================= TIMER =================
            Text(
              expired ? "OTP expired ⛔" : "Time left: $seconds s",
              style: TextStyle(
                color: expired ? Colors.red : Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            // ================= OTP INPUT =================
            TextField(
              controller: otpController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Enter OTP",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            // ================= VERIFY BUTTON =================
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: expired || loading ? null : verifyOtp,
                child: loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Verify OTP"),
              ),
            ),

            const SizedBox(height: 10),

            // ================= RESEND =================
            TextButton(
              onPressed: canResend ? resendOtp : null,
              child: Text(
                canResend
                    ? "Resend OTP 🔁"
                    : "Wait $resendTimer s",
              ),
            ),
          ],
        ),
      ),
    );
  }
}