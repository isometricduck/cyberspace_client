class Notification {
  final String notificationId;
  final String type;
  final bool read;
  final Map<String, dynamic> data;
  final DateTime? createdAt;

  const Notification({
    required this.notificationId,
    required this.type,
    required this.read,
    required this.data,
    this.createdAt,
  });

  factory Notification.fromJson(Map<String, dynamic> json) => Notification(
        notificationId: json['notificationId'] as String,
        type: json['type'] as String,
        read: json['read'] as bool,
        data: (json['data'] as Map<String, dynamic>?) ?? {},
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'] as String)
            : null,
      );
}
