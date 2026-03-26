import 'package:flutter/material.dart';

class DisclaimerScreen extends StatelessWidget {
  const DisclaimerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Disclaimer')),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Text(
          '''Disclaimer (Draft)
Last updated: March 2026

The information and services provided by Content Amplifier Hub (“CAH”) are for general information and community support purposes only. By using CAH, you acknowledge and agree to the following:

No Guarantee of Results
CAH does not guarantee any particular outcome from using the app, including but not limited to increased views, likes, followers, revenue, or business success.

Any examples of engagement, growth, or success shared in the app or marketing materials are illustrative only and do not represent a promise or typical result.

No Professional Advice
CAH does not provide legal, financial, or professional marketing advice.

You are responsible for your own decisions regarding content, marketing strategies, and compliance with platform rules and laws.

Third‑Party Platforms
CAH links to third‑party platforms (e.g., Facebook, TikTok, YouTube) that we do not control. We are not responsible for their content, policies, availability, or any actions they take against your accounts.

You are solely responsible for complying with each platform’s terms of service and community guidelines.

User Content and Behaviour
Content shared by Members does not represent our views or endorsements. We do not routinely review or verify all submitted content.

We are not responsible for any offensive, inappropriate, or unlawful content posted by users, but we reserve the right to remove or restrict content or accounts at our discretion.

Limitation of Liability
To the fullest extent permitted by law, CAH and its owners, employees, and partners shall not be liable for any direct, indirect, incidental, consequential, or special damages arising out of or in connection with your use of the app, including but not limited to loss of data, profits, accounts, or reputation.

Engagement Is Voluntary
All engagement actions (views, likes, comments, shares, follows) are voluntary actions taken by Members on third‑party platforms. CAH does not force or automate these actions and is not responsible for how Members choose to engage.

Updates
We may update this Disclaimer from time to time. Continued use of CAH after changes take effect constitutes your acceptance of the updated Disclaimer.

For any questions about this Disclaimer, please contact us at [your contact email].''',
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}