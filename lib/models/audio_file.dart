class AudioFile {
  final int? id;
  final String title;
  final String filePath;

  AudioFile({
    this.id,
    required this.title,
    required this.filePath,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'filePath': filePath,
    };
  }

  factory AudioFile.fromMap(Map<String, dynamic> map) {
    return AudioFile(
      id: map['id'],
      title: map['title'],
      filePath: map['filePath'],
    );
  }
}
