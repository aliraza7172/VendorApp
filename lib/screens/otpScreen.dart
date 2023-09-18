import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/api_response.dart';
import '../models/user.dart';
import '../services/user_service.dart';
import 'login.dart';

class OtpScreen extends StatefulWidget {
  final String email;
  final String phone;
  final String password;
  final String name;
  final String updated_at;
  final String shop;


  const OtpScreen({
    Key? key,
    required this.email,
    required this.phone,
    required this.password,
    required this.name,
    required this.updated_at,
    required this.shop,

  }) : super(key: key);

  @override
  _OtpScreenState createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  late List<FocusNode> _focusNodes;
  late List<TextEditingController> _controllers;
  late Timer _timer;
  int _remainingTime = 120;
  bool _isTimerRunning = true;

  bool _isResendingOtp = false;

  void _registerUser() async {
    String otp = '';
    for (var controller in _controllers) {
      otp += controller.text;
    }
    ApiResponse response = await register(
        widget.name, widget.email, widget.password, otp, widget.phone,widget.shop);

    if (response.error == null) {
      _saveAndRedirectToHome(response.data as User);
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('${response.error}')));
    }
  }

  void _saveAndRedirectToHome(User user) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.setString('token', user.token ?? '');
    await pref.setInt('userId', user.id ?? 0);
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const Login()), (route) => false);
  }

  @override
  void initState() {
    super.initState();
    _isResendingOtp = false;
    _startTimer();
    _focusNodes = List.generate(6, (index) => FocusNode());
    _controllers = List.generate(6, (index) => TextEditingController());

    for (int i = 0; i < 6; i++) {
      _controllers[i].addListener(() {
        if (_controllers[i].text.isNotEmpty && i < 5) {
          _focusNodes[i + 1].requestFocus();
        }
      });
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingTime > 0) {
          _remainingTime--;
        } else {
          _timer.cancel();
          _isTimerRunning = false; // Timer has finished
          expiredOtpRequest();
        }
      });
    });
  }

  Future<void> expiredOtpRequest() async {
    try {
      final response = await http.post(
        Uri.parse(
            'http://dev.codesisland.com/api/emptycustomerotp/${widget.email}'),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Your OTP is expired, Regenerate your OTP'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('OTP has Expired'),
          ),
        );
      }
    } catch (error) {
      // Handle error, if needed
    }
  }

  void _resendOtp() async {
    setState(() {
      _isResendingOtp = true; // Set the loading indicator
    });

    try {
      final response = await http.post(
        Uri.parse(
            'http://dev.codesisland.com/api/resendcustomerotp/${widget.email}'),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('OTP has been resent. Check your email'),
          ),
        );

        // Start the timer again after showing the SnackBar
        setState(() {
          _isTimerRunning = true; // Set the timer to running state
          _remainingTime = 120; // Reset the remaining time
        });
        _startTimer();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error resending OTP. Please try again.'),
          ),
        );
      }
    } catch (error) {
      // Handle error, if needed
    } finally {
      setState(() {
        _isResendingOtp = false; // Reset the loading indicator
      });
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [],
        backgroundColor: Colors.green,
      ),
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 150,
              height: 150,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('images/otplogo.png'),
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'OTP is sent on your Email',
              style: TextStyle(
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Enter OTP',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (int i = 0; i < 6; i++)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      border: Border.all(width: 1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: TextFormField(
                        focusNode: _focusNodes[i],
                        controller: _controllers[i],
                        maxLength: 1,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 20),
                        onChanged: (text) {
                          if (text.isEmpty) {
                            if (i > 0) {
                              _focusNodes[i - 1].requestFocus();
                            }
                          }
                        },
                        decoration: const InputDecoration(
                          counterText: '',
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(),
                if (_isTimerRunning)
                  Text(
                    '$_remainingTime seconds remaining',
                    style: const TextStyle(color: Colors.red),
                  )
                else
                  TextButton(
                    onPressed: () {
                      if (!_isTimerRunning) {
                        if (!_isResendingOtp) {
                          _resendOtp(); // Start the resend OTP process
                        }
                      } else {
                        _startTimer();
                      }
                    },
                    child: _isResendingOtp
                        ? const CircularProgressIndicator() // Show a loading indicator
                        : const Text(
                            'Resend OTP',
                            style: TextStyle(
                              color: Colors.green,
                            ),
                          ),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (_remainingTime > 0) {
                  _registerUser();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content:
                          Text('OTP has expired. Please request a new one.'),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Padding(
                padding:
                    EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Text(
                  'Verify',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
