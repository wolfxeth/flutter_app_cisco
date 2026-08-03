class Session {
  final String id;
  final String title;
  final String day;
  final String time;
  final String room;
  final String? description;
  final int? matchPercent;
  final String? alignmentText;
  int? distanceMeters;
  bool scheduled;

  Session({
    required this.id,
    required this.title,
    required this.day,
    required this.time,
    required this.room,
    this.description,
    this.matchPercent,
    this.alignmentText,
    this.distanceMeters,
    this.scheduled = false,
  });

  factory Session.fromJson(Map<String, dynamic> json) => Session(
        id: json['id']?.toString() ?? '',
        title: json['title']?.toString() ?? '',
        day: json['day']?.toString() ?? '',
        time: json['time']?.toString() ?? '',
        room: json['room']?.toString() ?? '',
        description: json['description']?.toString(),
        matchPercent: json['matchPercent'] is num
            ? (json['matchPercent'] as num).toInt()
            : null,
        alignmentText: json['alignmentText']?.toString(),
        distanceMeters: json['distanceMeters'] is num
            ? (json['distanceMeters'] as num).toInt()
            : null,
        scheduled: json['scheduled'] == true,
      );
}
