class UserProfile {
  final String userId;
  final String username;
  final DateTime? createdAt;
  final int serialNumber;
  final String? guildIcon;
  final String? guildSlug;
  final String? guildId;
  final bool isSupporter;
  final String? supporterIcon;
  final String? locationName;
  final int followingCount;
  final String? guildName;
  final bool hasPublicPosts;
  final String? profilePictureUrl;
  final DateTime? updatedAt;
  final String? bio;
  final String? websiteName;
  final String? websiteUrl;
  final int postsCount;
  final int publicPostsCount;
  final String? pinnedPostId;
  final int followersCount;
  final DateTime? lastActiveAt;

  const UserProfile({
    required this.userId,
    required this.username,
    this.createdAt,
    required this.serialNumber,
    this.guildIcon,
    this.guildSlug,
    this.guildId,
    required this.isSupporter,
    this.supporterIcon,
    this.locationName,
    required this.followingCount,
    this.guildName,
    required this.hasPublicPosts,
    this.profilePictureUrl,
    this.updatedAt,
    this.bio,
    this.websiteName,
    this.websiteUrl,
    required this.postsCount,
    required this.publicPostsCount,
    this.pinnedPostId,
    required this.followersCount,
    this.lastActiveAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
    userId: json['userId'] as String,
    username: json['username'] as String,
    createdAt: json['createdAt'] != null
        ? DateTime.parse(json['createdAt'] as String)
        : null,
    serialNumber: (json['serialNumber'] as int?) ?? 0,
    guildIcon: json['guildIcon'] as String?,
    guildSlug: json['guildSlug'] as String?,
    guildId: json['guildId'] as String?,
    isSupporter: (json['isSupporter'] as bool?) ?? false,
    supporterIcon: json['supporterIcon'] as String?,
    locationName: json['locationName'] as String?,
    followingCount: (json['followingCount'] as int?) ?? 0,
    guildName: json['guildName'] as String?,
    hasPublicPosts: (json['hasPublicPosts'] as bool?) ?? false,
    profilePictureUrl: json['profilePictureUrl'] as String?,
    updatedAt: json['updatedAt'] != null
        ? DateTime.parse(json['updatedAt'] as String)
        : null,
    bio: json['bio'] as String?,
    websiteName: json['websiteName'] as String?,
    websiteUrl: json['websiteUrl'] as String?,
    postsCount: (json['postsCount'] as int?) ?? 0,
    publicPostsCount: (json['publicPostsCount'] as int?) ?? 0,
    pinnedPostId: json['pinnedPostId'] as String?,
    followersCount: (json['followersCount'] as int?) ?? 0,
    lastActiveAt: json['lastActiveAt'] != null
        ? DateTime.parse(json['lastActiveAt'] as String)
        : null,
  );
}
