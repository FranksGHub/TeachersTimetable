class LessonItem {
  String text;
  List<LessonItem> subitems;
  String? status; // '(P)', '(W)', '(F)' for left, null for right
  String? timestamp;

  LessonItem({required this.text, List<LessonItem>? subitems, this.status = '(P)', this.timestamp = ''}) : subitems = List<LessonItem>.from(subitems ?? []);

  Map<String, dynamic> toJson() => {
    'text': text,
    'subitems': subitems.map((e) => e.toJson()).toList(),
    'status': status,
    'timestamp': timestamp,
  };

  factory LessonItem.fromJson(Map<String, dynamic> json) => LessonItem(
    text: json['text'],
    subitems: List<LessonItem>.from(
      (json['subitems'] as List<dynamic>? ?? []).map((e) => LessonItem.fromJson(e))
    ),
    status: json['status'],
    timestamp: json['timestamp'],
  );

  String GetText() {
    return (timestamp != null && timestamp!.isNotEmpty) ? '- $timestamp $text' : text;
  }
}