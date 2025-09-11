import 'package:flutter/foundation.dart';

class UserData with ChangeNotifier {
  double monthlyIncome;
  double loanAmount;
  double annualInterestRate;
  int loanTermMonths;
  double essentialExpenses;

  UserData({
    required this.monthlyIncome,
    required this.loanAmount,
    required this.annualInterestRate,
    required this.loanTermMonths,
    required this.essentialExpenses,
  });
}