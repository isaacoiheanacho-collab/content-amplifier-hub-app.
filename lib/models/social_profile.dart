class SocialProfile {
  final String platform;
  final String handle;
  final bool boostEnabled;

  SocialProfile({
    required this.platform,
    required this.handle,
    required this.boostEnabled,
  });

  Map<String, dynamic> toJson() {
    return {
      'platform': platform,
      'handle': handle,
      'boostEnabled': boostEnabled,
    };
  }
}
