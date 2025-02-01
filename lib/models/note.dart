class Note {
  final int? id;
  final int audioId;
  final String text;
  final int timestamp;

  Note({
    this.id,
    required this.audioId,
    required this.text,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'audioId': audioId,
      'text': text,
      'timestamp': timestamp,
    };
  }

  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'],
      audioId: map['audioId'],
      text: map['text'],
      timestamp: map['timestamp'],
    );
  }
}
