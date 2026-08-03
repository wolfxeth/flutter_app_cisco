class Channel {
  final String id;
  final String title;
  final String sponsor;
  final String topic;
  final String description;
  final int members;
  final int activeThreads;
  final int? matchPercent;
  final String? alignmentText;
  bool joined;

  Channel({
    required this.id,
    required this.title,
    required this.sponsor,
    required this.topic,
    required this.description,
    required this.members,
    required this.activeThreads,
    this.matchPercent,
    this.alignmentText,
    this.joined = false,
  });

  factory Channel.fromJson(Map<String, dynamic> json) => Channel(
        id: json['id']?.toString() ?? '',
        title: json['title']?.toString() ?? '',
        sponsor: json['sponsor']?.toString() ?? '',
        topic: json['topic']?.toString() ?? '',
        description: json['description']?.toString() ?? '',
        members: json['members'] is num ? (json['members'] as num).toInt() : 0,
        activeThreads: json['activeThreads'] is num
            ? (json['activeThreads'] as num).toInt()
            : 0,
        matchPercent: json['matchPercent'] is num
            ? (json['matchPercent'] as num).toInt()
            : null,
        alignmentText: json['alignmentText']?.toString(),
        joined: json['joined'] == true,
      );
}
