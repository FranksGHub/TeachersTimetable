class LessonItem {
  String text;
  List<LessonItem> subitems;
  String? status; // 'P', 'W', 'F' for left, null for right

  LessonItem({required this.text, List<LessonItem>? subitems, this.status = 'P'}) : subitems = List<LessonItem>.from(subitems ?? []);

  Map<String, dynamic> toJson() => {
    'text': text,
    'subitems': subitems.map((e) => e.toJson()).toList(),
    'status': status,
  };

  factory LessonItem.fromJson(Map<String, dynamic> json) => LessonItem(
    text: json['text'],
    subitems: (json['subitems'] as List<dynamic>? ?? []).map((e) => LessonItem.fromJson(e)).toList(),
    status: json['status'],
  );
}