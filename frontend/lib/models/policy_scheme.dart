class PolicyScheme {
  final String title;
  final String description;
  final String sourceUrl;
  // You can add other fields here as needed from your Firestore document

  PolicyScheme({
    required this.title,
    required this.description,
    required this.sourceUrl,
  });

  /// A factory constructor that creates a PolicyScheme instance from a map (Firestore document).
  factory PolicyScheme.fromMap(Map<String, dynamic> map) {
    return PolicyScheme(
      title: map['title'] ?? 'No Title',
      description: map['description'] ?? 'No Description available.',
      sourceUrl: map['source_url'] ?? '',
    );
  }
}

