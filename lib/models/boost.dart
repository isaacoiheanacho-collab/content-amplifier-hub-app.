class Boost {
  final int id;
  final int memberId;
  final String contentUrl;
  final String platform;
  final String category;
  final String status; // queued, approved, completed
  final int impressionsCount;
  final int clicksCount;
  final int confirmedSupportsCount;

  Boost({
    required this.id,
    required this.memberId,
    required this.contentUrl,
    required this.platform,
    required this.category,
    required this.status,
    required this.impressionsCount,
    required this.clicksCount,
    required this.confirmedSupportsCount,
  });

  factory Boost.fromJson(Map<String, dynamic> json) {
    return Boost(
      id: json['id'],
      memberId: json['member_id'],
      contentUrl: json['content_url'],
      platform: json['platform'],
      category: json['category'] ?? '',
      status: json['status'] ?? 'queued',
      impressionsCount: json['impressions_count'] ?? 0,
      clicksCount: json['clicks_count'] ?? 0,
      confirmedSupportsCount: json['confirmed_supports_count'] ?? 0,
    );
  }
}