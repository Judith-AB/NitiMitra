import 'package:flutter/material.dart';
import 'package:frontend/register_screen.dart';
import 'package:login/dashboard.dart';

class AuthLandingPage extends StatefulWidget {
  const AuthLandingPage({super.key});

  @override
  State<AuthLandingPage> createState() => _AuthLandingPageState();
}

class _AuthLandingPageState extends State<AuthLandingPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Controllers for Login
  final TextEditingController _loginPhoneController = TextEditingController();
  final TextEditingController _loginPasswordController =
      TextEditingController();

  // Controllers for Sign Up
  final TextEditingController _signUpNameController = TextEditingController();
  final TextEditingController _signUpPhoneController = TextEditingController();
  final TextEditingController _signUpPasswordController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _loginPhoneController.dispose();
    _loginPasswordController.dispose();
    _signUpNameController.dispose();
    _signUpPhoneController.dispose();
    _signUpPasswordController.dispose();
    super.dispose();
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: const Color(0xFFF5F5F5),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Logo
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.blue.shade100,
                  child: const Icon(
                    Icons.support_agent,
                    size: 70,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 20),

                // Welcome Text
                const Text(
                  "Welcome to NitiMitra",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),

                // Tab bar (Login / Sign Up)
                Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F1F1),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    labelColor: Colors.black,
                    unselectedLabelColor: Colors.black54,
                    tabs: const [Tab(text: "Login"), Tab(text: "Sign Up")],
                  ),
                ),
                const SizedBox(height: 25),

                // Tab Views
                SizedBox(
                  height: 400,
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // ---------------- Login ----------------
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Phone Number"),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _loginPhoneController,
                            keyboardType: TextInputType.phone,
                            decoration: _inputDecoration("+91 XXXXX XXXXX"),
                          ),
                          const SizedBox(height: 16),
                          const Text("Password"),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _loginPasswordController,
                            obscureText: true,
                            decoration: _inputDecoration("Enter password"),
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: () {
                                if (_loginPhoneController.text.isEmpty ||
                                    _loginPasswordController.text.isEmpty) {
                                  _showSnackBar("Please fill all fields");
                                } else {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const Dashboard(),
                                    ),
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                "Login",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                      ),

                      // ---------------- Sign Up ----------------
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Full Name"),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _signUpNameController,
                            decoration: _inputDecoration(
                              "Enter your full name",
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text("Phone Number"),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _signUpPhoneController,
                            keyboardType: TextInputType.phone,
                            decoration: _inputDecoration("Enter phone number"),
                          ),
                          const SizedBox(height: 16),
                          const Text("Password"),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _signUpPasswordController,
                            obscureText: true,
                            decoration: _inputDecoration("Enter password"),
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: () {
                                if (_signUpNameController.text.isEmpty ||
                                    _signUpPhoneController.text.isEmpty ||
                                    _signUpPasswordController.text.isEmpty) {
                                  _showSnackBar("Please fill all fields");
                                } else {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const RegisterScreen2(),
                                    ),
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                "Sign Up",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
