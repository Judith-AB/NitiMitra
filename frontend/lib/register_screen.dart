import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/dashboard.dart';
class RegisterScreen2 extends StatefulWidget {
  const RegisterScreen2({super.key});

  @override
  State<RegisterScreen2> createState() => _RegisterScreen2State();
}

class _RegisterScreen2State extends State<RegisterScreen2> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController dateController = TextEditingController();

  String? selectedSex;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      body: Center(
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
                  color: Colors.black,
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
                  // Title
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
                    validator:
                        (value) =>
                            value!.isEmpty ? "Full name is required" : null,
                    decoration: _inputDecoration("Enter your full name"),
                  ),
                  const SizedBox(height: 15),

                  // Phone
                  const Text("Phone Number *"),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly, // Only numbers
                      LengthLimitingTextInputFormatter(10), // Max 10 digits
                    ],
                    validator:
                        (value) =>
                            value == null || value.length != 10
                                ? "Enter a valid 10-digit number"
                                : null,
                    decoration: _inputDecoration("Enter your phone number"),
                  ),
                  const SizedBox(height: 15),

                  // Language
                  const Text("Language *"),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    items: const [
                      DropdownMenuItem(value: "Tamil", child: Text("Tamil")),
                      DropdownMenuItem(value: "Hindi", child: Text("Hindi")),
                      DropdownMenuItem(
                        value: "Malayalam",
                        child: Text("Malayalam"),
                      ),
                    ],
                    onChanged: (value) {},
                    validator:
                        (value) =>
                            value == null ? "Please select a language" : null,
                    decoration: _inputDecoration("Select your language"),
                  ),
                  const SizedBox(height: 15),

                  // State
                  const Text("State *"),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    items: const [
                      DropdownMenuItem(value: "Kerala", child: Text("Kerala")),
                      DropdownMenuItem(
                        value: "Tamil Nadu",
                        child: Text("Tamil Nadu"),
                      ),
                      DropdownMenuItem(
                        value: "Karnataka",
                        child: Text("Karnataka"),
                      ),
                    ],
                    onChanged: (value) {},
                    validator:
                        (value) =>
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
                    decoration: _inputDecoration(
                      "Select date of birth",
                    ).copyWith(suffixIcon: const Icon(Icons.calendar_today)),
                  ),
                  const SizedBox(height: 15),

                  // Sex
                  const Text("Biological Sex *"),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: selectedSex,
                    items: const [
                      DropdownMenuItem(value: "Male", child: Text("Male")),
                      DropdownMenuItem(value: "Female", child: Text("Female")),
                    ],
                    onChanged: (value) => setState(() => selectedSex = value),
                    validator:
                        (value) =>
                            value == null ? "Please select your sex" : null,
                    decoration: _inputDecoration("Select sex"),
                  ),
                  const SizedBox(height: 25),

                  // Continue button
                  SizedBox(
                    width: double.infinity,
                    height: 53,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const DashboardScreen(),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Ink(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Colors.blue, Colors.blue],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Container(
                          alignment: Alignment.center,
                          child: const Text(
                            "Continue",
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
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

// // Blank page
// class BlankPage extends StatelessWidget {
//   const BlankPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return const Scaffold(
//       body: Center(
//         child: Text(
//           "This is the next blank page",
//           style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//         ),
//       ),
//     );
//   }
// }
