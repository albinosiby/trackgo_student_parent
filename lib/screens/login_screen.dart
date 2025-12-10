import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'parent_main_screen.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../models/organization_model.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool otpSent = false;
  String? _verificationId;
  String? _selectedOrgId;
  bool _isLoading = false;

  final phoneController = TextEditingController();
  final otpController = TextEditingController();
  final AuthService _authService = AuthService();
  final DatabaseService _dbService = DatabaseService();

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _sendOTP() async {
    if (_selectedOrgId == null) {
      _showSnackBar("Please select an organization");
      return;
    }

    String phoneNumber = phoneController.text.trim();
    if (phoneNumber.isEmpty) {
      _showSnackBar("Please enter a phone number");
      return;
    }

    // Basic formatting if needed, assuming user enters 10 digits
    if (!phoneNumber.startsWith('+')) {
      // Default to India (+91) if no country code is provided, or ask user to add it.
      // For now, let's assume the user might need to add it or we prepend +91.
      // Adjust this based on your target audience.
      phoneNumber = "+91$phoneNumber";
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _authService.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Android only: Auto-retrieval or instant verification
          await _authService.signInWithCredential(credential);

          // Save Org ID
          final refs = await SharedPreferences.getInstance();
          await refs.setString('orgId', _selectedOrgId!);

          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => ParentMainScreen(orgId: _selectedOrgId!),
              ),
            );
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          setState(() {
            _isLoading = false;
          });
          _showSnackBar("Verification Failed: ${e.message}");
        },
        codeSent: (String verificationId, int? resendToken) {
          setState(() {
            _verificationId = verificationId;
            otpSent = true;
            _isLoading = false;
          });
          _showSnackBar("OTP Sent to $phoneNumber");
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showSnackBar("Error: $e");
    }
  }

  Future<void> _verifyOTP() async {
    String otp = otpController.text.trim();
    if (otp.isEmpty) {
      _showSnackBar("Please enter OTP");
      return;
    }

    if (_verificationId == null) {
      _showSnackBar("Verification ID is missing. Please resend OTP.");
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: otp,
      );

      await _authService.signInWithCredential(credential);

      // Save Org ID
      final refs = await SharedPreferences.getInstance();
      await refs.setString('orgId', _selectedOrgId!);

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ParentMainScreen(orgId: _selectedOrgId!),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showSnackBar("Invalid OTP: ${e.message}");
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showSnackBar("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(24.w),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Icon(Icons.shield_moon_rounded, size: 80.r),
                  SizedBox(height: 16.h),
                  Text(
                    "Student/Parent Login",
                    style: TextStyle(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 24.h),

                  // Organization selection
                  if (!otpSent)
                    FutureBuilder<List<OrganizationModel>>(
                      future: _dbService.getOrganizations(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        }
                        if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        }
                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return const Text('No organizations found');
                        }

                        return DropdownButtonFormField<String>(
                          value: _selectedOrgId,
                          hint: const Text("Select Organization"),
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.business),
                          ),
                          items: snapshot.data!.map((org) {
                            return DropdownMenuItem<String>(
                              value: org.id,
                              child: Text(org.name),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedOrgId = value;
                            });
                          },
                        );
                      },
                    ),

                  if (!otpSent) SizedBox(height: 16.h),

                  // Phone number
                  TextField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    enabled: !otpSent,
                    decoration: const InputDecoration(
                      labelText: "Phone Number",
                      prefixIcon: Icon(Icons.phone),
                      border: OutlineInputBorder(),
                      hintText: "Enter 10 digit number",
                    ),
                  ),

                  SizedBox(height: 16.h),

                  // OTP
                  if (otpSent)
                    TextField(
                      controller: otpController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "Enter OTP",
                        prefixIcon: Icon(Icons.lock),
                        border: OutlineInputBorder(),
                      ),
                    ),

                  SizedBox(height: 24.h),

                  // Login Button
                  if (_isLoading)
                    const CircularProgressIndicator()
                  else
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: otpSent ? _verifyOTP : _sendOTP,
                        child: Text(otpSent ? "Login" : "Send OTP"),
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
