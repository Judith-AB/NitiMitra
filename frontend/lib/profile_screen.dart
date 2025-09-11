import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = true;
  String? _errorMessage;

  // Controllers for text fields will be initialized after data is fetched
  late TextEditingController nameController;
  late TextEditingController phoneController;
  late TextEditingController emailController;
  late TextEditingController dateController;

  // State variables for dropdowns
  String? selectedSex;
  String? selectedLanguage;
  String? selectedState;
  String? selectedIncome;
  String? selectedCaste;
  String? selectedReligion;
  String? selectedMaritalStatus;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  /// Fetches user data from Firestore and populates the form fields.
  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("No authenticated user found.");

      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (!doc.exists || doc.data() == null) throw Exception("User profile not found.");
      
      final data = doc.data()!;

      // Initialize controllers and dropdowns with fetched data
      nameController = TextEditingController(text: data['name']);
      phoneController = TextEditingController(text: data['phone']);
      emailController = TextEditingController(text: data['email']);
      dateController = TextEditingController(text: data['dob']);
      selectedSex = data['gender'];
      selectedLanguage = data['language'];
      selectedState = data['state'];
      selectedIncome = data['income'];
      selectedCaste = data['caste'];
      selectedReligion = data['religion'];
      selectedMaritalStatus = data['maritalStatus'];

    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Validates and saves the updated user profile to Firestore.
  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("Authentication error.");

      final updatedData = {
        'name': nameController.text.trim(),
        'phone': phoneController.text.trim(),
        'language': selectedLanguage,
        'state': selectedState,
        'dob': dateController.text,
        'gender': selectedSex,
        'income': selectedIncome,
        'caste': selectedCaste,
        'religion': selectedReligion,
        'maritalStatus': selectedMaritalStatus,
      };

      await FirebaseFirestore.instance.collection('users').doc(user.uid).update(updatedData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile updated successfully!")),
        );
        Navigator.of(context).pop(); // Go back to the dashboard
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to update profile: ${e.toString()}")),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profile"),
        backgroundColor: const Color(0xFFF5F6F8),
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      backgroundColor: const Color(0xFFF5F6F8),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text("Error: $_errorMessage"))
              : _buildProfileForm(),
    );
  }

  Widget _buildProfileForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Container(
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
              // All the form fields are here, similar to the register screen
              _buildTextFormField(controller: nameController, label: "Full Name"),
              const SizedBox(height: 15),
              _buildTextFormField(controller: emailController, label: "Email", readOnly: true), // Email should not be editable
              const SizedBox(height: 15),
              _buildTextFormField(controller: phoneController, label: "Phone Number", keyboardType: TextInputType.phone),
              const SizedBox(height: 15),
              _buildDropdown("Language", selectedLanguage, ["Tamil", "Hindi", "Malayalam"], (val) => setState(() => selectedLanguage = val)),
              const SizedBox(height: 15),
              _buildDropdown("State", selectedState, ["Kerala", "Tamil Nadu", "Karnataka"], (val) => setState(() => selectedState = val)),
              const SizedBox(height: 15),
              _buildDatePicker(),
              const SizedBox(height: 15),
              _buildDropdown("Biological Sex", selectedSex, ["Male", "Female", "Other"], (val) => setState(() => selectedSex = val)),
              const SizedBox(height: 15),
              _buildDropdown("Income Status", selectedIncome, ["Student", "<2L", "2-5L", "5-10L", ">10L"], (val) => setState(() => selectedIncome = val)),
              const SizedBox(height: 15),
              _buildDropdown("Caste", selectedCaste, ["General", "OBC", "SC/ST"], (val) => setState(() => selectedCaste = val)),
              const SizedBox(height: 15),
              _buildDropdown("Religion", selectedReligion, ["Hindu", "Muslim", "Christian", "Other"], (val) => setState(() => selectedReligion = val)),
              const SizedBox(height: 15),
              _buildDropdown("Marital Status", selectedMaritalStatus, ["Single", "Married", "Divorced", "Widowed"], (val) => setState(() => selectedMaritalStatus = val)),
              const SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                height: 53,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _updateProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Save Changes", style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Helper Widgets for Form Fields ---

  Widget _buildTextFormField({required TextEditingController controller, required String label, bool readOnly = false, TextInputType? keyboardType}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("$label *"),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          readOnly: readOnly,
          keyboardType: keyboardType,
          style: TextStyle(color: readOnly ? Colors.grey : Colors.black),
          validator: (value) => value!.isEmpty ? "$label is required" : null,
          decoration: _inputDecoration("Enter your $label"),
        ),
      ],
    );
  }

  Widget _buildDatePicker() {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                dateController.text = "${picked.day}/${picked.month}/${picked.year}";
                });
            }
            },
            validator: (value) => value!.isEmpty ? "Date of Birth is required" : null,
            decoration: _inputDecoration("Select date of birth").copyWith(suffixIcon: const Icon(Icons.calendar_today)),
        ),
        ],
    );
    }


  Widget _buildDropdown(String label, String? value, List<String> items, Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("$label *"),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
          onChanged: onChanged,
          validator: (val) => val == null ? "Please select $label" : null,
          decoration: _inputDecoration("Select $label"),
        ),
      ],
    );
  }

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
}
