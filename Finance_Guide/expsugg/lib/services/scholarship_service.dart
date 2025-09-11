import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/scholarship.dart';

class ScholarshipService {
  static Future<List<Scholarship>> loadScholarships() async {
    try {
      final String response = await rootBundle.loadString('assets/scholarships.json');
      final List<dynamic> data = await json.decode(response);
      return data.map((json) => Scholarship.fromJson(json)).toList();
    } catch (e) {
      print('Error loading scholarships: $e');
      return [];
    }
  }

  static List<Scholarship> filterScholarships(
    List<Scholarship> allScholarships, 
    double monthlyIncome,
    String course,
    String category
  ) {
    return allScholarships.where((scholarship) {
      // Simple filtering logic
      final incomeMatch = scholarship.eligibility.toLowerCase().contains('income') 
        ? _extractIncomeLimit(scholarship.eligibility) >= monthlyIncome * 12
        : true;
      
      final categoryMatch = scholarship.category.toLowerCase() == 'general' || 
                           scholarship.category.toLowerCase() == category.toLowerCase();
      
      return incomeMatch && categoryMatch;
    }).toList();
  }

  static double _extractIncomeLimit(String eligibility) {
    try {
      final RegExp incomeRegExp = RegExp(r'income\s*[<≤]\s*([\d,]+)');
      final Match? match = incomeRegExp.firstMatch(eligibility.toLowerCase());
      if (match != null && match.groupCount >= 1) {
        String incomeStr = match.group(1)!.replaceAll(',', '');
        return double.parse(incomeStr);
      }
    } catch (e) {
      print('Error extracting income limit: $e');
    }
    return double.infinity;
  }
}