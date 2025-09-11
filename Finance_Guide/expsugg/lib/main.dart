import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/user_data.dart';
import 'widgets/chat_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => UserData(
        monthlyIncome: 0,
        loanAmount: 0,
        annualInterestRate: 0,
        loanTermMonths: 0,
        essentialExpenses: 0,
      ),
      child: MaterialApp(
        title: 'Finance & Scholarship Chatbot',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
        ),
        home: ChatScreen(),
      ),
    );
  }
}