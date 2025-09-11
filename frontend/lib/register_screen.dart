import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dashboard.dart';

class RegisterScreen2 extends StatefulWidget {
  final String? name;
  final String? email;

  const RegisterScreen2({super.key, this.name, this.email});

  @override
  State<RegisterScreen2> createState() => _RegisterScreen2State();
}

class _RegisterScreen2State extends State<RegisterScreen2> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for text fields
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController dateController = TextEditingController();

  // State variables for dropdowns
  String? selectedSex;
  String? selectedLanguage;
  String? selectedState;
  String? selectedIncome;
  String? selectedCaste;
  String? selectedReligion;
  String? selectedMaritalStatus;

  bool _isLoading = false; // To show a loading indicator on the button

  @override
  void initState() {
    super.initState();
    // Pre-fill name and email from the previous screen
    if (widget.name != null) nameController.text = widget.name!;
    if (widget.email != null) emailController.text = widget.email!;
  }

  /// Saves the user's profile data to Firestore.
  Future<void> _saveProfileAndContinue() async {
    // First, validate the form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true; // Show loading indicator
    });

    try {
      // Get the current user's unique ID
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception("No authenticated user found. Please sign in again.");
      }

      // Prepare the data to be saved
      final userData = {
        'uid': user.uid,
        'name': nameController.text.trim(),
        'email': emailController.text.trim(),
        'phone': phoneController.text.trim(),
        'language': selectedLanguage,
        'state': selectedState,
        'dob': dateController.text, // Stored as "DD/MM/YYYY" string
        'gender': selectedSex,
        'income': selectedIncome,
        'caste': selectedCaste,
        'religion': selectedReligion,
        'maritalStatus': selectedMaritalStatus,
        'createdAt': FieldValue.serverTimestamp(), // Track creation time
      };

      // Save the data to the 'users' collection with the document ID as user's UID
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set(userData);
      
      if (!mounted) return;
      // Navigate to the dashboard on success
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DashboardScreen()),
      );

    } catch (e) {
      // Show an error message if saving fails
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to save profile: ${e.toString()}")),
      );
    } finally {
      setState(() {
        _isLoading = false; // Hide loading indicator
      });
    }
  }

  // --- UI Build Methods ---

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: const Color(0xFFF8F9FB),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      body: Container(
        // 🌟 Background Image
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/bg1.png"), // Ensure you have this file
            fit: BoxFit.cover,
            alignment: Alignment.center,
            colorFilter: ColorFilter.mode(
              Color(0xC4FFFFFF), // white with ~30% opacity
              BlendMode.dstATop,
            ),
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Container(
              width: screenWidth < 500 ? double.infinity : 450,
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Center(
                      child: Column(
                        children: [
                          Text(
                            "Profile",
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            "Fill this to continue",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.black54),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 25),

                    // Full Name
                    const Text("Full Name *"),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: nameController,
                      validator: (value) =>
                          value!.isEmpty ? "Full name is required" : null,
                      decoration: _inputDecoration("Enter your full name"),
                    ),
                    const SizedBox(height: 15),

                    // Email
                    const Text("Email *"),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) =>
                          value!.isEmpty ? "Email is required" : null,
                      decoration: _inputDecoration("Enter your email"),
                    ),
                    const SizedBox(height: 15),
                    
                    // Phone
                    const Text("Phone Number *"),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(10),
                      ],
                      validator: (value) => value == null || value.length != 10
                          ? "Enter a valid 10-digit number"
                          : null,
                      decoration: _inputDecoration("Enter your phone number"),
                    ),
                    const SizedBox(height: 15),
                    
                    // Language
                    const Text("Language *"),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: selectedLanguage,
                      items: const [
                        DropdownMenuItem(value: "Tamil", child: Text("Tamil")),
                        DropdownMenuItem(value: "Hindi", child: Text("Hindi")),
                        DropdownMenuItem(value: "Malayalam", child: Text("Malayalam")),
                      ],
                      onChanged: (value) => setState(() => selectedLanguage = value),
                      validator: (value) => value == null ? "Please select a language" : null,
                      decoration: _inputDecoration("Select your language"),
                    ),
                    const SizedBox(height: 15),

                    // State
                    const Text("State *"),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: selectedState,
                      items: const [
                        DropdownMenuItem(value: "Kerala", child: Text("Kerala")),
                        DropdownMenuItem(value: "Tamil Nadu", child: Text("Tamil Nadu")),
                        DropdownMenuItem(value: "Karnataka", child: Text("Karnataka")),
                      ],
                      onChanged: (value) => setState(() => selectedState = value),
                      validator: (value) =>
                          value == null ? "Please select a state" : null,
                      decoration: _inputDecoration("Select your state"),
                    ),
                    const SizedBox(height: 15),

                    // DOB
                    const Text("Date of Birth *"),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: dateController,
                      readOnly: true,
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(1900),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) {
                          setState(() {
                            dateController.text =
                                "${picked.day}/${picked.month}/${picked.year}";
                          });
                        }
                      },
                      validator: (value) =>
                          value!.isEmpty ? "Date of Birth is required" : null,
                      decoration: _inputDecoration("Select date of birth")
                          .copyWith(suffixIcon: const Icon(Icons.calendar_today)),
                    ),
                    const SizedBox(height: 15),

                    // Biological Sex
                    const Text("Biological Sex *"),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: selectedSex,
                      items: const [
                        DropdownMenuItem(value: "Male", child: Text("Male")),
                        DropdownMenuItem(value: "Female", child: Text("Female")),
                        DropdownMenuItem(value: "Other", child: Text("Other")),
                      ],
                      onChanged: (value) => setState(() => selectedSex = value),
                      validator: (value) =>
                          value == null ? "Please select your sex" : null,
                      decoration: _inputDecoration("Select sex"),
                    ),
                    const SizedBox(height: 15),

                    // Income Status
                    const Text("Income Status *"),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: selectedIncome,
                      items: const [
                        DropdownMenuItem(value: "Student", child: Text("Student")),
                        DropdownMenuItem(value: "<2L", child: Text("Less than 2 L")),
                        DropdownMenuItem(value: "2-5L", child: Text("2-5 L")),
                        DropdownMenuItem(value: "5-10L", child: Text("5-10 L")),
                        DropdownMenuItem(value: ">10L", child: Text("More than 10 L")),
                      ],
                      onChanged: (value) => setState(() => selectedIncome = value),
                      validator: (value) => value == null ? "Please select income status" : null,
                      decoration: _inputDecoration("Select income status"),
                    ),
                    const SizedBox(height: 15),

                    // Caste
                    const Text("Caste *"),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: selectedCaste,
                      items: const [
                        DropdownMenuItem(value: "General", child: Text("General")),
                        DropdownMenuItem(value: "OBC", child: Text("OBC")),
                        DropdownMenuItem(value: "SC/ST", child: Text("SC/ST")),
                      ],
                      onChanged: (value) => setState(() => selectedCaste = value),
                      validator: (value) => value == null ? "Please select caste" : null,
                      decoration: _inputDecoration("Select caste"),
                    ),
                    const SizedBox(height: 15),

                    // Religion
                    const Text("Religion *"),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: selectedReligion,
                      items: const [
                        DropdownMenuItem(value: "Hindu", child: Text("Hindu")),
                        DropdownMenuItem(value: "Muslim", child: Text("Muslim")),
                        DropdownMenuItem(value: "Christian", child: Text("Christian")),
                        DropdownMenuItem(value: "Other", child: Text("Other")),
                      ],
                      onChanged: (value) => setState(() => selectedReligion = value),
                      validator: (value) => value == null ? "Please select religion" : null,
                      decoration: _inputDecoration("Select religion"),
                    ),
                    const SizedBox(height: 15),

                    // Marital Status
                    const Text("Marital Status *"),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: selectedMaritalStatus,
                      items: const [
                        DropdownMenuItem(value: "Single", child: Text("Single")),
                        DropdownMenuItem(value: "Married", child: Text("Married")),
                        DropdownMenuItem(value: "Divorced", child: Text("Divorced")),
                        DropdownMenuItem(value: "Widowed", child: Text("Widowed")),
                      ],
                      onChanged: (value) => setState(() => selectedMaritalStatus = value),
                      validator: (value) => value == null ? "Please select marital status" : null,
                      decoration: _inputDecoration("Select marital status"),
                    ),
                    const SizedBox(height: 25),

                    // Continue button
                    SizedBox(
                      width: double.infinity,
                      height: 53,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _saveProfileAndContinue,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text(
                                "Continue",
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

