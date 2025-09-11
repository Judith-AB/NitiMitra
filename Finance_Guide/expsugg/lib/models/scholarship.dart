class Scholarship {
  final String name;
  final String eligibility;
  final double amount;
  final String category;

  Scholarship({
    required this.name,
    required this.eligibility,
    required this.amount,
    required this.category,
  });

  factory Scholarship.fromJson(Map<String, dynamic> json) {
    return Scholarship(
      name: json['name'],
      eligibility: json['eligibility'],
      amount: json['amount'].toDouble(),
      category: json['category'],
    );
  }
}