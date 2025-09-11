import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:frontend/register_screen.dart';
import 'package:frontend/dashboard.dart';

class AuthLandingPage extends StatefulWidget {
  const AuthLandingPage({super.key});

  @override
  State<AuthLandingPage> createState() => _AuthLandingPageState();
}

class _AuthLandingPageState extends State<AuthLandingPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Controllers
  final TextEditingController _loginEmailController = TextEditingController();
  final TextEditingController _loginPasswordController =
      TextEditingController();

  final TextEditingController _signUpNameController = TextEditingController();
  final TextEditingController _signUpEmailController = TextEditingController();
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
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _signUpNameController.dispose();
    _signUpEmailController.dispose();
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
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _login() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _loginEmailController.text.trim(),
        password: _loginPasswordController.text.trim(),
      );
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => const DashboardScreen()));
    } on FirebaseAuthException catch (e) {
      _showSnackBar(e.message ?? "Login failed");
    }
  }

  Future<void> _signUp() async {
    if (_signUpNameController.text.isEmpty) {
      _showSnackBar("Please enter your name");
      return;
    }
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _signUpEmailController.text.trim(),
        password: _signUpPasswordController.text.trim(),
      );
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => const RegisterScreen2()));
    } on FirebaseAuthException catch (e) {
      _showSnackBar(e.message ?? "Sign up failed");
    }
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
                const Text(
                  "Welcome to NitiMitra",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
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
                          color: Colors.black,
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
                SizedBox(
                  height: 400,
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // ---------------- Login ----------------
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Email"),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _loginEmailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: _inputDecoration("Enter your email"),
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
                              onPressed: _login,
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
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
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
                            decoration:
                                _inputDecoration("Enter your full name"),
                          ),
                          const SizedBox(height: 16),
                          const Text("Email"),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _signUpEmailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: _inputDecoration("Enter your email"),
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
                              onPressed: _signUp,
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
                                    fontWeight: FontWeight.bold),
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
