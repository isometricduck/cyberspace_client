class Topic {
  final String slug;
  final int postCount;

  const Topic({required this.slug, required this.postCount});

  factory Topic.fromJson(Map<String, dynamic> json) => Topic(
        slug: json['slug'] as String,
        postCount: (json['postCount'] as num).toInt(),
      );
}
