class Follow {
  final String followId;
  final String followerId;
  final String followedId;
  final String? followerUsername;
  final String? followedUsername;
  final DateTime? createdAt;

  const Follow({
    required this.followId,
    required this.followerId,
    required this.followedId,
    this.followerUsername,
    this.followedUsername,
    this.createdAt,
  });

  factory Follow.fromJson(Map<String, dynamic> json) => Follow(
        followId: json['followId'] as String,
        followerId: json['followerId'] as String,
        followedId: json['followedId'] as String,
        followerUsername: json['followerUsername'] as String?,
        followedUsername: json['followedUsername'] as String?,
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'] as String)
            : null,
      );
}
