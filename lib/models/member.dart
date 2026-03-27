class MemberStats {
  final String email;
  final bool membershipActive;
  final int monthlyBoostsUsed;
  final int maxMonthlyBoosts;
  final int supportsGiven;
  final int supportsReceived;

  MemberStats({
    required this.email,
    required this.membershipActive,
    required this.monthlyBoostsUsed,
    required this.maxMonthlyBoosts,
    required this.supportsGiven,
    required this.supportsReceived,
  });

  factory MemberStats.fromJson(Map<String, dynamic> json) {
    return MemberStats(
      email: json['email']?.toString() ?? '',
      membershipActive: json['membership_active'] == true ||
          json['membership_active']?.toString() == "true",
      monthlyBoostsUsed:
          int.tryParse(json['monthly_boosts_used']?.toString() ?? '') ?? 0,
      maxMonthlyBoosts:
          int.tryParse(json['max_monthly_boosts']?.toString() ?? '') ?? 0,
      supportsGiven:
          int.tryParse(json['supports_given']?.toString() ?? '') ?? 0,
      supportsReceived:
          int.tryParse(json['supports_received']?.toString() ?? '') ?? 0,
    );
  }
}
