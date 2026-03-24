class Member {
  final int id;
  final String email;
  final bool membershipActive;

  Member({required this.id, required this.email, required this.membershipActive});

  factory Member.fromJson(Map<String, dynamic> json) {
    return Member(
      id: json['id'],
      email: json['email'],
      membershipActive: json['membership_active'],
    );
  }
}