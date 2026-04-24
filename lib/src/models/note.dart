class Note {
  final String noteId;
  final String content;
  final List<String> topics;
  final int revision;
  final DateTime? createdAt;
  final bool deleted;

  const Note({
    required this.noteId,
    required this.content,
    required this.topics,
    required this.revision,
    this.createdAt,
    required this.deleted,
  });

  factory Note.fromJson(Map<String, dynamic> json) => Note(
        noteId: json['noteId'] as String,
        content: json['content'] as String,
        topics: json['topics'] != null
            ? (json['topics'] as List).cast<String>()
            : [],
        revision: json['revision'] as int,
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'] as String)
            : null,
        deleted: (json['deleted'] as bool?) ?? false,
      );
}
