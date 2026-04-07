class Member {
  final int id;
  final String email;
  final bool membershipActive;
  final bool profileComplete;
  final bool paymentComplete;

  Member({
    required this.id,
    required this.email,
    required this.membershipActive,
    required this.profileComplete,
    required this.paymentComplete,
  });

  factory Member.fromJson(Map<String, dynamic> json) {
    return Member(
      id: json['id'],
      email: json['email'],
      membershipActive: json['membership_active'] ?? false,
      profileComplete: json['profile_complete'] ?? false,
      paymentComplete: json['payment_complete'] ?? false,
    );
  }
}
