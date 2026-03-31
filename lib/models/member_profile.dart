class MemberProfile {
  final String email;
  final String? name;
  final String? phone;
  final String? region;
  final String? profilePhotoUrl;

  final bool membershipActive;
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
    required this.membershipActive,
    required this.monthlyBoostsUsed,
    required this.maxMonthlyBoosts,
    required this.supportsGiven,
    required this.supportsReceived,
  });

  factory MemberProfile.fromJson(Map<String, dynamic> json) {
    return MemberProfile(
      email: json['email'],
      name: json['name'],
      phone: json['phone'],
      region: json['region'],
      profilePhotoUrl: json['profile_photo_url'],
      membershipActive: json['membership_active'] ?? false,
      monthlyBoostsUsed: json['monthly_boosts_used'] ?? 0,
      maxMonthlyBoosts: json['max_monthly_boosts'] ?? 20,
      supportsGiven: json['supports_given'] ?? 0,
      supportsReceived: json['supports_received'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phone': phone,
      'region': region,
      'profile_photo_url': profilePhotoUrl,
    };
  }
}
