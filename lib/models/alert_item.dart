class AlertItem {
  final String id;
  final String title;
  final String message;

  AlertItem({required this.id, required this.title, required this.message});

  factory AlertItem.fromJson(Map<String, dynamic> json) => AlertItem(
    id: json['id']?.toString() ?? '',
    title: json['title'] ?? '',
    message: json['message'] ?? '',
  );
}
