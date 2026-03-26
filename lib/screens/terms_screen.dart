import 'package:flutter/material.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Terms & Conditions')),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Text(
          '''Terms and Conditions (Draft)
Last updated: March 2026.

1. About Content Amplifier Hub
Content Amplifier Hub (“CAH”, “we”, “us”, “our”) is a membership‑based platform that helps content creators (“Members”, “you”) amplify each other’s social media posts by coordinating/encourage mandatory engagement from within the app. CAH is owned and operated by [Content Amplifier Hub, registered in UAE].

By creating an account, accessing, or using CAH, you agree to be bound by these Terms and Conditions (“Terms”). If you do not agree, you must not use CAH.

2. Eligibility and Accounts
You must be at least 18 years old, or the age of legal majority in your jurisdiction, to become a Member.
You are responsible for providing accurate information during registration and keeping it up to date.
You are responsible for maintaining the confidentiality of your login credentials and for all activity under your account.
We may suspend or terminate accounts that provide false information, misuse the service, or violate these Terms.

3. Membership, Fees, and Payment
CAH operates on a paid membership model. Details of membership fees, billing periods, and included benefits are shown in‑app or on our website.
Fees are payable in advance and are generally non‑refundable, except where required by law or explicitly stated otherwise.
Membership fee is paid once for each account.
Maintenance may auto‑renew unless you cancel before the renewal date, according to the instructions provided in the app or billing portal.
We may change our pricing or membership structure in the future, with reasonable notice where required. Continued use after changes take effect constitutes acceptance of the new fees.

4. Service Description (What CAH Does and Does Not Do)
CAH allows Members to:
- Create a profile and list their social media accounts.
- Submit a limited number of content links (“Boost Requests”) per period (e.g., up to 10 per month).
- View and voluntarily engage with other Members’ content via links that open in third‑party platforms (e.g., Facebook, TikTok, YouTube).

CAH does not:
- Guarantee any specific number of views, likes, follows, comments, or financial results.
- Automatically like, comment, follow, or view content on your behalf on third‑party platforms.
- Provide bots, fake accounts, or artificially generated engagement.

Your participation in viewing, liking, commenting, or sharing content is always voluntary and performed by you directly on the third‑party platforms.

5. Member Obligations and Acceptable Use
You agree that you will:
- Submit only content that:
  - You own or have the right to share;
  - Complies with the terms and policies of each platform (e.g., Facebook, TikTok, YouTube);
  - Does not contain illegal, hateful, violent, deceptive, or otherwise inappropriate material.
- Not use CAH to:
  - Buy, sell, or simulate fake engagement or violate third‑party platform rules on inauthentic behaviour;
  - Harass, abuse, or harm other Members;
  - Post spam, scams, or misleading content;
  - Attempt to reverse engineer, hack, or overload our systems.

We may limit, suspend, or terminate your account if we believe you have violated these obligations or applicable law.

6. Third‑Party Platforms and Links
CAH contains links that direct you to third‑party platforms (such as Facebook, TikTok, YouTube). We do not own or control those services and are not responsible for their content, policies, or availability.
Your use of third‑party platforms is governed by their own terms and conditions and privacy policies. You are solely responsible for complying with those terms.

7. Intellectual Property
We (or our licensors) own all rights in and to CAH, including logos, trademarks, design, software, and content we provide.
You retain ownership of the content you submit, but you grant us a non‑exclusive, worldwide licence to display, store, and process that content within CAH for the purpose of operating the service.
You may not copy, modify, resell, or create derivative works from our service or branding without our prior written consent.

8. Data and Privacy
We collect and process personal data in accordance with our Privacy Policy, which forms part of these Terms. Please read it carefully before using CAH.

9. Termination
You may stop using CAH at any time and, where offered, cancel your membership via the app or your billing provider.
We reserve the right to suspend or terminate your account or access to CAH at our discretion if:
- You breach these Terms or applicable law;
- We are required to do so by law or by a third‑party platform;
- We discontinue or materially change the service.
Upon termination, your right to access CAH will cease. Certain clauses (e.g., fees owed, disclaimers, limitation of liability) will continue to apply.

10. Disclaimers and Limitation of Liability
CAH is provided on an “as is” and “as available” basis, without warranties of any kind, whether express or implied, including but not limited to fitness for a particular purpose, non‑infringement, or accuracy.
We do not guarantee:
- Any particular number of engagements, views, followers, or growth;
- That the service will be error‑free, uninterrupted, or secure at all times;
- That your accounts on third‑party platforms will not be affected by their own policies.
To the maximum extent permitted by law:
- We will not be liable for any indirect, incidental, special, consequential, or punitive damages, including lost profits or data, arising from your use of CAH.
- Our total liability for any claim relating to CAH will not exceed the amount you paid to us in the 12 months preceding the claim.

11. Changes to These Terms
We may modify these Terms from time to time. We will notify you by updating the “Last updated” date and, where appropriate, providing additional notice (e.g., in‑app message or email). Your continued use of CAH after changes take effect constitutes acceptance of the revised Terms.

12. Governing Law and Disputes
These Terms are governed by the laws of [jurisdiction], without regard to its conflict of laws rules. Any disputes shall be subject to the exclusive jurisdiction of the courts of [city/country], unless mandatory law provides otherwise.

13. Contact
If you have any questions about these Terms, contact us at:
Email: [your contact email]
Address: [your business address]''',
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}