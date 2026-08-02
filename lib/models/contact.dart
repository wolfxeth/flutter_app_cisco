class Contact {
  final String id;
  final String name;
  final String title;
  final String company;
  final String? currentLocation;
  final double? lat;
  final double? lon;
  int? distanceMeters;
  bool saved;

  Contact({required this.id, required this.name, required this.title, required this.company, this.currentLocation, this.lat, this.lon, this.distanceMeters, this.saved = false});

    factory Contact.fromJson(Map<String, dynamic> json) => Contact(
    id: json['id']?.toString() ?? '',
    name: json['name'] ?? '',
    title: json['title'] ?? '',
    company: json['company'] ?? '',
    currentLocation: json['currentLocation'],
    lat: (json['location'] != null && json['location']['lat'] != null) ? (json['location']['lat'] as num).toDouble() : null,
    lon: (json['location'] != null && json['location']['lon'] != null) ? (json['location']['lon'] as num).toDouble() : null,
    saved: json['saved'] == true,
  );
}
