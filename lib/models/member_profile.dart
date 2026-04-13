class MemberProfile {
  final String email;
  final String? name;
  final String? phone;
  final String? region;
  final String? profilePhotoUrl;
  final String? youtubeUrl;
  final String? facebookUrl;
  final String? tiktokUrl;

  final bool membershipActive;
  final bool profileComplete; // <-- NEW FIELD
  final int monthlyBoostsUsed;
  final int maxMonthlyBoosts;
  final int supportsGiven;
  final int supportsReceived;

  MemberProfile({
    required this.email,
    this.name,
    this.phone,
    this.region,
    this.profilePhotoUrl,
    this.youtubeUrl,
    this.facebookUrl,
    this.tiktokUrl,
    required this.membershipActive,
    required this.profileComplete,
    required this.monthlyBoostsUsed,
    required this.maxMonthlyBoosts,
    required this.supportsGiven,
    required this.supportsReceived,
  });

  factory MemberProfile.fromJson(Map<String, dynamic> json) {
    // Helper to safely parse strings that might be null
    String? s(dynamic value) => (value == null || value.toString() == 'null') ? null : value.toString();

    return MemberProfile(
      email: json['email']?.toString() ?? '',
      name: s(json['name']),
      phone: s(json['phone']),
      region: s(json['region']),
      profilePhotoUrl: s(json['profile_photo_url']),
      youtubeUrl: s(json['youtube_url']),
      facebookUrl: s(json['facebook_url']),
      tiktokUrl: s(json['tiktok_url']),
      membershipActive: json['membership_active'] == true,
      profileComplete: json['profile_complete'] == true, // <-- PARSE FROM JSON
      monthlyBoostsUsed: _toInt(json['monthly_boosts_used']),
      maxMonthlyBoosts: _toInt(json['max_monthly_boosts'], defaultValue: 20),
      supportsGiven: _toInt(json['supports_given']),
      supportsReceived: _toInt(json['supports_received']),
    );
  }

  static int _toInt(dynamic value, {int defaultValue = 0}) {
    if (value == null) return defaultValue;
    if (value is int) return value;
    return int.tryParse(value.toString()) ?? defaultValue;
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phone': phone,
      'region': region,
      'profile_photo_url': profilePhotoUrl,
      'youtube_url': youtubeUrl,
      'facebook_url': facebookUrl,
      'tiktok_url': tiktokUrl,
    };
  }
}