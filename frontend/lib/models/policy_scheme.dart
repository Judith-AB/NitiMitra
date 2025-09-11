class PolicyScheme {
  final String title;
  final String description;
  final String link;
  // You can add other fields here as needed from your Firestore document

  PolicyScheme({
    required this.title,
    required this.description,
    required this.link,
  });

  /// A factory constructor that creates a PolicyScheme instance from a map (Firestore document).
  factory PolicyScheme.fromMap(Map<String, dynamic> map) {
    return PolicyScheme(
      title: map['name'] ?? 'No Title',
      description: map['description'] ?? 'No Description available.',
      link: map['link'] ?? '',
    );
  }
}

