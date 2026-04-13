class Member {
  final int id;
  final String email;
  final bool membershipActive;
  final bool profileComplete;
  final bool paymentComplete;
  
  // These fields are essential for the Waterfall Navigation logic
  // to check if name and region are actually present.
  final String? fullName; 
  final String? region;

  Member({
    required this.id,
    required this.email,
    required this.membershipActive,
    required this.profileComplete,
    required this.paymentComplete,
    this.fullName,
    this.region,
  });

  factory Member.fromJson(Map<String, dynamic> json) {
    // Helper to safely parse strings that might be "null" from the API
    String? s(dynamic value) => (value == null || value.toString() == 'null') ? null : value.toString();

    return Member(
      id: json['id'],
      email: json['email']?.toString() ?? '',
      // Ensure boolean values are handled correctly from JSON
      membershipActive: json['membership_active'] == true,
      profileComplete: json['profile_complete'] == true,
      paymentComplete: json['payment_complete'] == true,
      // Map both variants of naming (backend full_name vs profile name)
      fullName: s(json['full_name'] ?? json['name']),
      region: s(json['region']),
    );
  }

  /// Waterfall Logic: Decide if we should force the Profile Setup screen.
  /// Returns [true] if the user is missing their name or location.
  bool get needsProfileSetup {
    return !profileComplete || 
           fullName == null || fullName!.trim().isEmpty || 
           region == null || region!.trim().isEmpty;
  }
}