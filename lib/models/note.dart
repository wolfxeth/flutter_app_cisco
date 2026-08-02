class Note {
  final String id;
  final String title;
  final String body;
  final String? timestamp;

  bool local;

  Note({required this.id, required this.title, required this.body, this.timestamp, this.local = false});

  factory Note.fromJson(Map<String, dynamic> json) => Note(
    id: json['id']?.toString() ?? '',
    title: json['title'] ?? '',
    body: json['body'] ?? '',
    timestamp: json['timestamp']?.toString(),
    local: json['local'] == true,
  );
}
