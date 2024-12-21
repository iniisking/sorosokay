class Note {
  final String id;
  String content;
  final DateTime timestamp;

  Note({
    required this.id,
    required this.content,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'],
      content: map['content'],
      timestamp: DateTime.parse(map['timestamp']),
    );
  }
}
