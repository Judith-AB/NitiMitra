import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/scholarship.dart';

Future<List<Scholarship>> fetchScholarshipRecommendations(String query) async {
  final url = Uri.parse('http://localhost:8000/recommend');
  
  try {
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"text": query}),
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      List<String> recommendations = List<String>.from(data['recommendations']);
      
      // Convert the text recommendations to Scholarship objects
      return _parseScholarshipsFromRecommendations(recommendations);
    } else {
      throw Exception('Failed to load recommendations. Status code: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Network error: $e');
  }
}

List<Scholarship> _parseScholarshipsFromRecommendations(List<String> recommendations) {
  List<Scholarship> scholarships = [];
  
  for (var recommendation in recommendations) {
    try {
      // Parse the text recommendation to extract scholarship information
      // This is a simplified parser - you might need to adjust based on your actual data format
      final lines = recommendation.split('\n');
      String name = '';
      String eligibility = '';
      double amount = 0;
      String category = 'General';
      
      for (var line in lines) {
        if (line.toLowerCase().contains('scholarship') || 
            line.toLowerCase().contains('fellowship') ||
            line.toLowerCase().contains('grant')) {
          name = line.trim();
        } else if (line.toLowerCase().contains('eligibility') || 
                  line.toLowerCase().contains('criteria')) {
          eligibility = line.trim();
        } else if (line.contains('₹') || line.contains('Rs.') || line.contains('INR')) {
          // Extract amount
          final amountMatch = RegExp(r'[₹Rs\.INR\s]*([\d,]+)').firstMatch(line);
          if (amountMatch != null) {
            amount = double.parse(amountMatch.group(1)!.replaceAll(',', ''));
          }
        } else if (line.toLowerCase().contains('category') || 
                  line.toLowerCase().contains('type')) {
          category = line.trim();
        }
      }
      
      if (name.isNotEmpty) {
        scholarships.add(Scholarship(
          name: name,
          eligibility: eligibility.isNotEmpty ? eligibility : 'Eligibility criteria available',
          amount: amount,
          category: category,
        ));
      }
    } catch (e) {
      print('Error parsing scholarship: $e');
    }
  }
  
  return scholarships;
}

// Alternative: If you want to use the Flask CSV-based endpoint instead
Future<List<Scholarship>> fetchScholarshipsFromCSV({
  required String field,
  required String level,
  required String category,
  required String region,
}) async {
  final url = Uri.parse('http://localhost:5000/get_scholarships');
  
  try {
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "field": field,
        "level": level,
        "category": category,
        "region": region,
      }),
    );
    
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Scholarship.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load scholarships. Status code: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Network error: $e');
  }
}