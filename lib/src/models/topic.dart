class Topic {
  final String topicId;
  final String name;
  final int postsCount;

  const Topic({required this.topicId, required this.name, required this.postsCount});

  factory Topic.fromJson(Map<String, dynamic> json) => Topic(
        topicId: json['topicId'] as String,
        name: json['name'] as String,
        postsCount: (json['postsCount'] as num).toInt(),
      );
}
