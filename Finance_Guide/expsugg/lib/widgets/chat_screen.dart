import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/chat_message.dart';
import '../models/user_data.dart';
import '../models/scholarship.dart';
import '../services/finance_calculator.dart';
import '../services/scholarship_service.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final List<ChatMessage> _messages = [];
  final List<Scholarship> _allScholarships = [];
  final ScrollController _scrollController = ScrollController();
  
  final Map<String, dynamic> _userInputs = {
    'monthlyIncome': null,
    'loanAmount': null,
    'annualInterestRate': null,
    'loanTermMonths': null,
    'essentialExpenses': null,
    'course': '',
    'category': 'General'
  };
  
  int _currentInputStep = 0;
  final List<String> _inputSteps = [
    "Welcome! I'm here to help you calculate your safe spending amount and find suitable scholarships.\n\nLet's start with your monthly income after taxes:",
    "What's your total loan amount?",
    "What's the annual interest rate on your loan? (in %)",
    "What's the loan term in months?",
    "What are your essential monthly expenses (food, rent, utilities, etc.)?",
    "What course are you pursuing?",
    "What's your category? (General/SC/ST/OBC)"
  ];

  @override
  void initState() {
    super.initState();
    _loadScholarships();
    _addBotMessage(_inputSteps[_currentInputStep]);
  }

  Future<void> _loadScholarships() async {
    List<Scholarship> scholarships = await ScholarshipService.loadScholarships();
    setState(() {
      _allScholarships.addAll(scholarships);
    });
  }

  void _addBotMessage(String text) {
    setState(() {
      _messages.add(ChatMessage(
        text: text,
        isUser: false,
        timestamp: DateTime.now(),
      ));
      _scrollToBottom();
    });
  }

  void _addUserMessage(String text) {
    setState(() {
      _messages.add(ChatMessage(
        text: text,
        isUser: true,
        timestamp: DateTime.now(),
      ));
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // API Functions
  Future<List<Scholarship>> fetchScholarshipRecommendations(String query) async {
    // For testing - return mock data first
    await Future.delayed(Duration(seconds: 2)); // Simulate network delay
    
    // Return mock data for testing
    return [
      Scholarship(
        name: "National Scholarship",
        eligibility: "For students with family income < 5 LPA",
        amount: 50000,
        category: "General",
      ),
      Scholarship(
        name: "Merit Scholarship",
        eligibility: "For students with > 90% marks",
        amount: 25000,
        category: "General",
      ),
    ];
    
    /* Uncomment this when your backend is ready
    final url = Uri.parse('http://192.168.1.100:8000/recommend'); // Use your computer's IP
    
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"text": query}),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<Scholarship> recommendations = [];
        
        if (data['recommendations'] != null) {
          for (var rec in data['recommendations']) {
            recommendations.add(Scholarship(
              name: rec['name'] ?? 'Scholarship',
              eligibility: rec['eligibility'] ?? 'Eligibility information',
              amount: (rec['amount'] ?? 0.0).toDouble(),
              category: rec['category'] ?? 'General',
            ));
          }
        }
        return recommendations;
      } else {
        throw Exception('Failed to load recommendations. Status: ${response.statusCode}');
      }
    } catch (e) {
      print('API Error: $e');
      throw Exception('Network error: $e');
    }
    */
  }

  Future<List<Scholarship>> fetchScholarshipsFromCSV({
    required String field,
    required String level,
    required String category,
    required String region,
  }) async {
    // For testing - return mock data first
    await Future.delayed(Duration(seconds: 1));
    
    return [
      Scholarship(
        name: "CSV Scholarship for $field",
        eligibility: "For $category students studying $field",
        amount: 30000,
        category: category,
      ),
    ];
    
    /* Uncomment this when your Flask backend is ready
    final url = Uri.parse('http://192.168.1.100:5000/get_scholarships');
    
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
        throw Exception('Failed to load scholarships. Status: ${response.statusCode}');
      }
    } catch (e) {
      print('CSV API Error: $e');
      throw Exception('Network error: $e');
    }
    */
  }

  void _fetchAIRecommendations() async {
    String query = """
    I'm a student looking for scholarships.
    Monthly Income: ${_userInputs['monthlyIncome']}
    Course: ${_userInputs['course']}
    Category: ${_userInputs['category']}
    Loan Amount: ${_userInputs['loanAmount']}
    Please recommend suitable scholarships.
    """;
    
    try {
      _addBotMessage("🤖 Searching for AI-powered recommendations...");
      
      List<Scholarship> aiRecommendations = await fetchScholarshipRecommendations(query);
      
      if (aiRecommendations.isNotEmpty) {
        String aiMessage = "🎓 AI-Powered Recommendations:\n\n";
        for (var scholarship in aiRecommendations.take(3)) {
          aiMessage += "• ${scholarship.name} - ₹${scholarship.amount.toStringAsFixed(2)}\n";
          aiMessage += "  ${scholarship.eligibility}\n\n";
        }
        _addBotMessage(aiMessage);
      } else {
        _addBotMessage("No AI recommendations found. Using local database instead.");
      }
    } catch (e) {
      print("AI recommendation error: $e");
      _addBotMessage("⚠ Could not connect to AI service. Using local scholarship database.");
      
      // Fall back to local scholarships
      final userData = Provider.of<UserData>(context, listen: false);
      List<Scholarship> localScholarships = ScholarshipService.filterScholarships(
        _allScholarships,
        userData.monthlyIncome,
        _userInputs['course'],
        _userInputs['category'],
      ).take(3).toList();
      
      if (localScholarships.isNotEmpty) {
        String localMessage = "📚 Local Scholarship Recommendations:\n\n";
        for (var scholarship in localScholarships) {
          localMessage += "• ${scholarship.name} - ₹${scholarship.amount.toStringAsFixed(2)}\n";
          localMessage += "  ${scholarship.eligibility}\n\n";
        }
        _addBotMessage(localMessage);
      }
    }
  }

  void _handleSubmitted(String text) {
    if (text.isEmpty) return;
    
    _textController.clear();
    _addUserMessage(text);
    
    // Handle restart command
    if (text.toLowerCase() == 'restart' && _currentInputStep == -1) {
      _resetConversation();
      return;
    }
    
    // Store the input based on current step
    switch (_currentInputStep) {
      case 0:
        _userInputs['monthlyIncome'] = double.tryParse(text);
        break;
      case 1:
        _userInputs['loanAmount'] = double.tryParse(text);
        break;
      case 2:
        _userInputs['annualInterestRate'] = double.tryParse(text);
        break;
      case 3:
        _userInputs['loanTermMonths'] = int.tryParse(text);
        break;
      case 4:
        _userInputs['essentialExpenses'] = double.tryParse(text);
        break;
      case 5:
        _userInputs['course'] = text;
        break;
      case 6:
        _userInputs['category'] = text;
        break;
    }

    // Move to next step or calculate results
    if (_currentInputStep < 6) {
      _currentInputStep++;
      Future.delayed(Duration(milliseconds: 500), () {
        _addBotMessage(_inputSteps[_currentInputStep]);
      });
    } else {
      _calculateAndShowResults();
    }
  }

  void _calculateAndShowResults() {
    // Update user data in provider
    final userData = Provider.of<UserData>(context, listen: false);
    userData.monthlyIncome = _userInputs['monthlyIncome'] ?? 0;
    userData.loanAmount = _userInputs['loanAmount'] ?? 0;
    userData.annualInterestRate = _userInputs['annualInterestRate'] ?? 0;
    userData.loanTermMonths = _userInputs['loanTermMonths'] ?? 0;
    userData.essentialExpenses = _userInputs['essentialExpenses'] ?? 0;

    // Calculate EMI and safe spend
    double emi = FinanceCalculator.calculateEMI(
      userData.loanAmount,
      userData.annualInterestRate,
      userData.loanTermMonths,
    );
    
    double safeSpend = FinanceCalculator.calculateSafeSpend(
      userData.monthlyIncome,
      emi,
      userData.essentialExpenses,
    );

    // Find relevant scholarships
    List<Scholarship> relevantScholarships = ScholarshipService.filterScholarships(
      _allScholarships,
      userData.monthlyIncome,
      _userInputs['course'],
      _userInputs['category'],
    ).take(3).toList();

    // Prepare results message
    String resultsMessage = """
Based on your inputs:

📊 Financial Summary:
- Monthly Income: ₹${userData.monthlyIncome.toStringAsFixed(2)}
- Loan EMI: ₹${emi.toStringAsFixed(2)}
- Essential Expenses: ₹${userData.essentialExpenses.toStringAsFixed(2)}
- Safe to Spend/Save: ₹${safeSpend.toStringAsFixed(2)}

🎓 Recommended Scholarships:
""";

    if (relevantScholarships.isEmpty) {
      resultsMessage += "No scholarships found matching your criteria. Try adjusting your filters.";
    } else {
      for (var scholarship in relevantScholarships) {
        resultsMessage += "\n• ${scholarship.name} - ₹${scholarship.amount.toStringAsFixed(2)}\n  Eligibility: ${scholarship.eligibility}\n";
      }
    }

    resultsMessage += "\nType 'restart' to start over.";

    Future.delayed(Duration(milliseconds: 1000), () {
      _addBotMessage(resultsMessage);
      setState(() {
        _currentInputStep = -1; // Conversation complete
      });
      
      // After showing local scholarships, fetch AI recommendations
      Future.delayed(Duration(milliseconds: 2000), () {
        _fetchAIRecommendations();
      });
    });
  }

  void _resetConversation() {
    setState(() {
      _messages.clear();
      _currentInputStep = 0;
      _userInputs.forEach((key, value) {
        if (key != 'category') {
          _userInputs[key] = null;
        } else {
          _userInputs[key] = 'General';
        }
      });
    });
    _addBotMessage(_inputSteps[_currentInputStep]);
  }

  Widget _buildMessage(ChatMessage message) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            child: Text(message.isUser ? 'U' : 'B'),
            backgroundColor: message.isUser ? Colors.blue : Colors.green,
            foregroundColor: Colors.white,
          ),
          SizedBox(width: 10.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message.isUser ? 'You' : 'FinanceBot',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 5.0),
                  padding: EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                    color: message.isUser 
                      ? Colors.blue.withOpacity(0.2) 
                      : Colors.grey.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Text(message.text),
                ),
                Text(
                  DateFormat('HH:mm').format(message.timestamp),
                  style: TextStyle(
                    fontSize: 12.0,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Finance & Scholarship Assistant'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.all(8.0),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return _buildMessage(_messages[index]);
              },
            ),
          ),
          Divider(height: 1.0),
          Container(
            decoration: BoxDecoration(color: Theme.of(context).cardColor),
            child: _buildTextComposer(),
          ),
        ],
      ),
    );
  }

  Widget _buildTextComposer() {
    return IconTheme(
      data: IconThemeData(color: Theme.of(context).colorScheme.secondary),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          children: [
            Flexible(
              child: TextField(
                controller: _textController,
                onSubmitted: _handleSubmitted,
                decoration: InputDecoration.collapsed(
                  hintText: _currentInputStep == -1 ? "Type 'restart' to begin again" : "Send a message",
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 4.0),
              child: IconButton(
                icon: Icon(Icons.send),
                onPressed: () => _handleSubmitted(_textController.text),
              ),
            ),
          ],
        ),
      ),
    );
  }
}