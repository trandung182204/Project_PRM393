import 'dart:async';
import 'package:bai1/models/reset_password_request.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String phoneNumber;
  const ResetPasswordScreen({super.key, required this.phoneNumber});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  final AuthService _authService = AuthService();

  bool _isLoading = false;

  // Variable for countdown timer
  int _timeLeft = 20; // 20 seconds, match with your Backend
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer(); // Start countdown immediately on screen entry
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancel timer when leaving screen to avoid memory leaks
    super.dispose();
  }

  // Function for countdown timer
  void _startTimer() {
    setState(() => _timeLeft = 20);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft > 0) {
        setState(() => _timeLeft--);
      } else {
        _timer?.cancel();
      }
    });
  }

  // Handle Resend OTP button click
  void _handleResendOtp() async {
    setState(() => _isLoading = true);
    try {
      await _authService.sendOtp(widget.phoneNumber);
      _startTimer(); // Reset countdown to 20s on success
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("OTP code has been resent to your Email!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Handle Confirm Reset Password button click
  void _handleReset() async {
    final otpCode = _otpController.text.trim();
    final newPassword = _passController.text.trim();

    if (otpCode.isEmpty || newPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter both OTP and a new Password")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final request = ResetPasswordRequest(
        phoneNumber: widget.phoneNumber,
        otpCode: otpCode,
        newPassword: newPassword,
      );

      bool success = await _authService.resetPassword(request);

      if (success) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Password changed successfully! Please log in again."),
          ),
        );
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/login',
          (route) => false,
        ); // Navigate to login, clear history
      }
    } catch (e) {
      // IF CODE IS EXPIRED OR WRONG, ERRORS WILL APPEAR HERE
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Verify OTP"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.lightBlue,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              const Icon(
                Icons.mark_email_read_outlined,
                size: 80,
                color: Colors.lightBlue,
              ),
              const SizedBox(height: 20),
              Text(
                "An OTP code has been sent to the account linked with phone:\n${widget.phoneNumber}",
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 30),

              TextFormField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.password),
                  labelText: "Enter OTP code",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: _passController,
                obscureText: true, // Hide password
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.lock),
                  labelText: "New Password",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 30),

              // Nút xác nhận
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  onPressed: _isLoading ? null : _handleReset,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "Confirm password change",
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                ),
              ),
              const SizedBox(height: 20),

              // LOGIC HIỂN THỊ NÚT RESEND OTP THEO THỜI GIAN
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   const Text("Didn't receive code? "),
                  _timeLeft > 0
                      ? Text(
                          "Resend after ${_timeLeft}s",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        )
                      : TextButton(
                          onPressed: _isLoading ? null : _handleResendOtp,
                          child: const Text(
                            "Gửi lại mã",
                            style: TextStyle(
                              color: Colors.lightBlue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
