class UserProfile {
  final String userId;
  final String username;
  final String? displayName;
  final String? bio;
  final String? pinnedPostId;
  final String? websiteUrl;
  final String? websiteName;
  final String? websiteImageUrl;
  final double? locationLatitude;
  final double? locationLongitude;
  final String? locationName;
  final DateTime? createdAt;

  const UserProfile({
    required this.userId,
    required this.username,
    this.displayName,
    this.bio,
    this.pinnedPostId,
    this.websiteUrl,
    this.websiteName,
    this.websiteImageUrl,
    this.locationLatitude,
    this.locationLongitude,
    this.locationName,
    this.createdAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        userId: json['userId'] as String,
        username: json['username'] as String,
        displayName: json['displayName'] as String?,
        bio: json['bio'] as String?,
        pinnedPostId: json['pinnedPostId'] as String?,
        websiteUrl: json['websiteUrl'] as String?,
        websiteName: json['websiteName'] as String?,
        websiteImageUrl: json['websiteImageUrl'] as String?,
        locationLatitude: (json['locationLatitude'] as num?)?.toDouble(),
        locationLongitude: (json['locationLongitude'] as num?)?.toDouble(),
        locationName: json['locationName'] as String?,
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'] as String)
            : null,
      );
}
