import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'services/scheme_service.dart';
import 'models/policy_scheme.dart';
import 'login_register.dart';
import 'profile_screen.dart'; // Import the new profile screen

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;
  late Future<Map<String, dynamic>> _dashboardDataFuture;
  final SchemeService _schemeService = SchemeService();

  @override
  void initState() {
    super.initState();
    _dashboardDataFuture = _loadDashboardData();
  }

  Future<Map<String, dynamic>> _loadDashboardData() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("No user logged in. Please sign in again.");

      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!userDoc.exists || userDoc.data() == null) {
        throw Exception("Your profile data was not found. Please complete your profile.");
      }
      
      final userData = userDoc.data() as Map<String, dynamic>;
      final String userName = userData['name'] ?? 'User';
      final String userState = userData['state'];
      final String userDob = userData['dob'];
      final String userGender = userData['gender'];

      List<Map<String, dynamic>> schemesData = await _schemeService.getEligibleSchemes(
        userState: userState,
        userDobStr: userDob,
        userGender: userGender,
      );

      List<PolicyScheme> recommendedSchemes =
          schemesData.map((data) => PolicyScheme.fromMap(data)).toList();

      return {'userName': userName, 'schemes': recommendedSchemes};
    } catch (e) {
      // Return the error to be handled by the FutureBuilder
      throw Exception("Failed to load dashboard data: ${e.toString()}");
    }
  }
  
  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      // Navigate to the login screen and remove all previous routes
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const AuthLandingPage()),
        (Route<dynamic> route) => false,
      );
    }
  }

  /// This function now launches the URL from the scheme.
  void _applyForScheme(PolicyScheme scheme) async {
    // Check if the link is valid and not empty
    if (scheme.link.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No application link is available for this scheme.')),
      );
      return;
    }

    final Uri url = Uri.parse(scheme.link);

    if (await canLaunchUrl(url)) {
      // Opens the link in an external browser app
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      // Show an error message if the URL can't be launched
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open the link: ${scheme.link}')),
        );
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.fromARGB(255, 241, 251, 253),
              Color.fromARGB(255, 254, 253, 255),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildTopNavigationBar(),
              Expanded(
                child: _currentIndex == 0
                    ? _buildDashboardContent()
                    : _buildOtherScreens(),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildDashboardContent() {
    return FutureBuilder<Map<String, dynamic>>(
      future: _dashboardDataFuture,
      builder: (context, snapshot) {
        // Handle loading state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        // Handle error state
        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                "Error: ${snapshot.error}",
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          );
        }
        // Handle no data state
        if (!snapshot.hasData || snapshot.data == null) {
          return const Center(child: Text("No data available."));
        }

        // If data is available, build the UI
        final String userName = snapshot.data!['userName'];
        final List<PolicyScheme> schemes = snapshot.data!['schemes'];

        return RefreshIndicator(
          onRefresh: () {
            setState(() {
              _dashboardDataFuture = _loadDashboardData();
            });
            return _dashboardDataFuture;
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildWelcomeSection(userName),
                const SizedBox(height: 25),
                _buildQuickStats(schemes.length),
                const SizedBox(height: 30),
                _buildSectionTitle("Recommended for You", Icons.star),
                _buildPoliciesList(schemes),
                const SizedBox(height: 30),
                _buildSectionTitle("Tools", Icons.build),
                _buildTaxCalculatorCard(),
                const SizedBox(height: 100),
              ],
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildTopNavigationBar() {
    return Container(
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color.fromARGB(255, 163, 176, 248), Color.fromARGB(255, 68, 114, 255)]),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.account_balance_wallet, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text("NitiMitra", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2c3e50))),
                    Text("Smart Assistant", style: TextStyle(fontSize: 11, color: Colors.grey)),
                  ],
                ),
              ],
            ),
            InkWell(
              onTap: () => _openAIBot(),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF00D4AA), Color(0xFF00A3E0)]),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.support_agent, color: Colors.white, size: 18),
                    SizedBox(width: 6),
                    Text("AI Bot", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeSection(String userName) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.blue.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 10))],
      ),
      padding: const EdgeInsets.all(25),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Welcome back, $userName 👋",
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF2c3e50)),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Here’s your personalized finance dashboard",
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                ),
              ],
            ),
          ),
          // --- THIS IS THE CLICKABLE PROFILE ICON ---
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              ).then((_) {
                // This re-fetches data when you return from the profile screen
                setState(() {
                  _dashboardDataFuture = _loadDashboardData();
                });
              });
            },
            child: const CircleAvatar(
              radius: 28,
              backgroundColor: Color.fromARGB(255, 216, 223, 255),
              child: Icon(Icons.person, color: Colors.white, size: 28),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(int schemeCount) {
    return Row(
      children: [
        Expanded(child: _buildStatCard(Icons.savings, "₹1,20,000", "Tax Savings", Colors.green)),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard(Icons.verified, schemeCount.toString(), "Eligible Schemes", Colors.blue)),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard(Icons.trending_up, "45", "Days Left", Colors.orange)),
      ],
    );
  }

  Widget _buildStatCard(IconData icon, String number, String label, Color color) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          Icon(icon, size: 26, color: color),
          const SizedBox(height: 8),
          Text(number, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2c3e50))),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: Colors.black, size: 18),
          const SizedBox(width: 8),
          Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.black)),
        ],
      ),
    );
  }

  Widget _buildPoliciesList(List<PolicyScheme> schemes) {
    if (schemes.isEmpty) {
      return const Center(child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Text("No recommended schemes found based on your profile."),
      ));
    }
    return Column(
      children: schemes.map((scheme) => Padding(
        padding: const EdgeInsets.only(bottom: 15),
        child: _buildPolicyCard(scheme),
      )).toList(),
    );
  }

  Widget _buildPolicyCard(PolicyScheme scheme) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, 6))],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(scheme.title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF2c3e50))),
          const SizedBox(height: 6),
          Text(scheme.description, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          const SizedBox(height: 10),
          Row(
            children: [
              ElevatedButton(
                onPressed: () => _showPolicyDetails(scheme),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF667eea),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                child: const Text("Learn More", style: TextStyle(fontSize: 12)),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: () => _applyForScheme(scheme),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF667eea),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  side: const BorderSide(color: Color(0xFF667eea)),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                child: const Text("Apply", style: TextStyle(fontSize: 12)),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildTaxCalculatorCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, 6))],
      ),
      child: Row(
        children: [
          CircleAvatar(radius: 26, backgroundColor: Colors.green.withOpacity(0.15), child: const Icon(Icons.calculate, color: Colors.green, size: 26)),
          const SizedBox(width: 15),
          const Expanded(child: Text("Quick Tax Calculator\nEstimate your taxes instantly", style: TextStyle(fontSize: 13, color: Colors.black87))),
          ElevatedButton(
            onPressed: () => _openTaxCalculator(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            ),
            child: const Text("Open", style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }

  void _openTaxCalculator() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Tax Calculator", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            const TextField(keyboardType: TextInputType.number, decoration: InputDecoration(labelText: "Enter your annual income", border: OutlineInputBorder())),
            const SizedBox(height: 15),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Tax calculation coming soon!")));
              },
              child: const Text("Calculate"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (index) {
        if (index == 3) {
          _logout();
        } else {
          setState(() => _currentIndex = index);
        }
      },
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFF667eea),
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
        BottomNavigationBarItem(icon: Icon(Icons.explore), label: "Explore"),
        BottomNavigationBarItem(icon: Icon(Icons.notifications), label: "Alerts"),
        BottomNavigationBarItem(icon: Icon(Icons.logout), label: "Logout"),
      ],
    );
  }

  Widget _buildOtherScreens() {
    return const Center(
      child: Text("Coming Soon!", style: TextStyle(fontSize: 20, color: Colors.black54)),
    );
  }

  void _openAIBot() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        height: MediaQuery.of(context).size.height * 0.6,
        child: const Center(child: Text("AI Bot Coming Soon", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
      ),
    );
  }

  void _showPolicyDetails(PolicyScheme scheme) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Text("${scheme.title}\n\n${scheme.description}"),
      ),
    );
  }
}

