class Note {
  final String id;
  final String title;
  final String body;
  final String? timestamp;
  final String? linkedSessionId;
  final List<String> participants;

  bool local;

  Note({
    required this.id,
    required this.title,
    required this.body,
    this.timestamp,
    this.linkedSessionId,
    this.participants = const [],
    this.local = false,
  });

  factory Note.fromJson(Map<String, dynamic> json) => Note(
        id: json['id']?.toString() ?? '',
        title: json['title'] ?? '',
        body: json['body'] ?? '',
        timestamp: json['timestamp']?.toString(),
        linkedSessionId: json['linkedSessionId']?.toString(),
        participants: (json['participants'] as List?)
                ?.map((e) => e.toString())
                .toList() ??
            const [],
        local: json['local'] == true,
      );
}
