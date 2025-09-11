class FinanceCalculator {
  static double calculateEMI(double principal, double annualRate, int months) {
    if (months == 0 || annualRate == 0) return 0;
    
    double monthlyRate = annualRate / 12 / 100;
    double emi = (principal * monthlyRate * _pow(1 + monthlyRate, months)) / 
                 (_pow(1 + monthlyRate, months) - 1);
    return emi;
  }

  static double _pow(double x, int n) {
    double result = 1;
    for (int i = 0; i < n; i++) {
      result *= x;
    }
    return result;
  }

  static double calculateSafeSpend(double monthlyIncome, double emi, double essentialExpenses) {
    return monthlyIncome - emi - essentialExpenses;
  }
}