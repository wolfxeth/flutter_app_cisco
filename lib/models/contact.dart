class Contact {
  final String id;
  final String name;
  final String title;
  final String company;
  final String? currentLocation;
  final double? lat;
  final double? lon;
  final String? badge;        // "Attendee" or "Cisco Expert"
  final String? description;
  final int? matchPercent;
  final String? alignmentText;
  int? distanceMeters;
  bool saved;

  Contact({
    required this.id,
    required this.name,
    required this.title,
    required this.company,
    this.currentLocation,
    this.lat,
    this.lon,
    this.badge,
    this.description,
    this.matchPercent,
    this.alignmentText,
    this.distanceMeters,
    this.saved = false,
  });

  factory Contact.fromJson(Map<String, dynamic> json) => Contact(
        id: json['id']?.toString() ?? '',
        name: json['name'] ?? '',
        title: json['title'] ?? '',
        company: json['company'] ?? '',
        currentLocation: json['currentLocation'],
        lat: (json['location'] != null && json['location']['lat'] != null)
            ? (json['location']['lat'] as num).toDouble()
            : null,
        lon: (json['location'] != null && json['location']['lon'] != null)
            ? (json['location']['lon'] as num).toDouble()
            : null,
        badge: json['badge']?.toString(),
        description: json['description']?.toString(),
        matchPercent: json['matchPercent'] is num
            ? (json['matchPercent'] as num).toInt()
            : null,
        alignmentText: json['alignmentText']?.toString(),
        distanceMeters: json['distanceMeters'] is num
            ? (json['distanceMeters'] as num).toInt()
            : null,
        saved: json['saved'] == true,
      );
}
