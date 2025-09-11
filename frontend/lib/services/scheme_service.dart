import 'package:cloud_firestore/cloud_firestore.dart';

/// A service class to handle all logic related to government schemes.
class SchemeService {
  /// Fetches schemes from Firestore and filters them based on user data.
  ///
  /// This method connects to the 'schemes' collection, retrieves all documents,
  /// and then applies filtering logic in the app based on the user's state,
  /// age, and gender.
  ///
  /// [userState]: The state selected by the user (e.g., "Tamil Nadu").
  /// [userDobStr]: The user's date of birth in "DD/MM/YYYY" format.
  /// [userGender]: The user's selected gender (e.g., "Male", "Female").
  ///
  /// Returns a `Future` that completes with a list of eligible schemes.
  /// Each scheme is represented as a `Map<String, dynamic>`.
  /// Throws a detailed error if fetching or filtering fails.
  Future<List<Map<String, dynamic>>> getEligibleSchemes({
    required String userState,
    required String userDobStr,
    required String userGender,
  }) async {
    try {
      // --- 1. Calculate user's age from the date of birth string ---
      final parts = userDobStr.split('/'); // Splits "DD/MM/YYYY" into a list
      // Note: DateTime constructor is (Year, Month, Day)
      final dob = DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
      final today = DateTime.now();
      int age = today.year - dob.year;
      // Adjust age if the birthday hasn't occurred yet this year
      if (today.month < dob.month || (today.month == dob.month && today.day < dob.day)) {
        age--;
      }

      // --- 2. Fetch ALL schemes from the Firestore database ---
      QuerySnapshot schemesSnapshot = await FirebaseFirestore.instance.collection('schemes').get();
      // Convert the documents into a standard List
      List allSchemes = schemesSnapshot.docs.map((doc) => doc.data()).toList();
      
      List<Map<String, dynamic>> eligibleSchemes = [];

      // --- 3. Loop through each scheme and apply filtering logic ---
      for (var schemeData in allSchemes) {
        // Safety check to ensure the data is in the expected format
        if (schemeData is! Map<String, dynamic>) continue;
        
        final eligibility = schemeData['eligibility'] as Map<String, dynamic>;
        bool isEligible = true; // Assume eligible until a rule fails

        // --- Rule Check: State ---
        List<String> states = List<String>.from(eligibility['states'] ?? []);
        if (!states.contains(userState) && !states.contains("All")) {
          isEligible = false;
        }

        // --- Rule Check: Gender ---
        String gender = eligibility['gender'] ?? 'Any';
        if (gender != 'Any' && gender != userGender) {
          isEligible = false;
        }

        // --- Rule Check: Minimum Age ---
        // Only check if the 'min_age' field exists in the database
        if (eligibility.containsKey('min_age')) {
          int minAge = eligibility['min_age'] as int;
          if (age < minAge) {
            isEligible = false;
          }
        }

        // --- Rule Check: Maximum Age ---
        // Only check if the 'max_age' field exists in the database
        if (eligibility.containsKey('max_age')) {
          int maxAge = eligibility['max_age'] as int;
          if (age > maxAge) {
            isEligible = false;
          }
        }
        
        // --- Final Decision ---
        // If all checks passed, add the scheme to our results list
        if (isEligible) {
          eligibleSchemes.add(schemeData);
        }
      }

      // --- 4. Return the final list of schemes that passed all the rules ---
      return eligibleSchemes;

    } catch (e) {
      // If any error occurs, print it for debugging
      // and throw a user-friendly error message to be caught by the UI.
      print("Error in SchemeService: $e");
      throw Exception('Failed to get eligible schemes. Please check your network connection and try again.');
    }
  }
}
