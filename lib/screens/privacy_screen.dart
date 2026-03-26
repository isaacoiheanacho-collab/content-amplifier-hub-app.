import 'package:flutter/material.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Privacy Policy')),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Text(
          '''Privacy Policy 
Last updated: March 2026

This Privacy Policy explains how Content Amplifier Hub (“CAH”, “we”, “us”) collects, uses, and protects your personal information when you use our mobile app and related services.

By using CAH, you agree to the collection and use of information in accordance with this policy.

1. Information We Collect
We may collect the following categories of information:

Account Information
- Name
- Email address
- Password (stored in hashed form)
- Country
- Profile photo

Social Media Details
- Usernames and/or URLs for platforms you add (e.g., TikTok, Facebook, YouTube, etc.)
- Your selected interests and categories.

Usage Data
- App screens visited, features used, date/time of access
- Interaction data (e.g., how many boosts you submit, how many supports you perform).

Device and Technical Data
- Device type, operating system, app version
- IP address, language, and general region (where available).

Payment Data
- We may collect limited billing information (e.g., transaction IDs, plan type).
- Detailed card data is normally processed by third‑party payment providers (e.g., Stripe, Paystack) and not stored by us.

Notifications Data
- Push notification tokens to send you alerts about boosts, account status, etc.

2. How We Use Your Information
We use your information to:
- Create and manage your Member account and profile.
- Operate CAH’s core features (boost queue, support assignments, dashboards).
- Communicate with you about your account, membership, payments, and important updates.
- Personalize which boosts you see (e.g., matching categories/interests).
- Monitor usage, maintain security, and prevent abuse or fraud.
- Improve the app, develop new features, and understand performance.
- Comply with legal obligations.

We do not sell your personal information to third‑party data brokers.

3. Legal Bases (where applicable)
If required by applicable law (e.g., GDPR/UK GDPR), we process your data based on:
- Performance of a contract (providing the service you signed up for).
- Legitimate interests (improving CAH, maintaining security, preventing fraud).
- Your consent (e.g., for marketing emails or certain kinds of analytics, where required).
- Compliance with legal obligations.

4. Sharing Your Information
We may share your data with:
- Service Providers: such as hosting providers, analytics tools, email services, and payment processors, who process data on our behalf under appropriate contracts.
- Legal and Safety: when required by law, regulation, court order, or to protect our rights, safety, or that of others.
- Business Transfers: in connection with a merger, acquisition, or sale of assets, subject to appropriate safeguards.

We do not share your personal data with other Members except what you choose to display on your profile (e.g., name, country, social handles).

5. International Transfers
Your information may be stored and processed on servers located outside your country of residence. We will take reasonable steps to ensure that any international transfers comply with applicable data protection laws and that your data remains protected.

6. Data Retention
We retain your personal information for as long as necessary to:
- Provide the service and fulfill the purposes described above.
- Comply with legal and accounting obligations.
- Resolve disputes and enforce our agreements.

If you close your account, we may retain limited information where required or permitted by law (e.g., payment records, security logs).

7. Your Rights
Depending on your jurisdiction, you may have rights to:
- Access the personal information we hold about you.
- Correct or update inaccurate data.
- Delete your data, in certain circumstances.
- Object to or restrict certain processing.
- Withdraw consent, where we rely on consent.
- Port your data to another service provider.

You can exercise these rights by contacting us at [your contact email]. We may need to verify your identity before responding.

8. Security
We use reasonable technical and organisational measures to protect your personal data, such as encryption in transit (HTTPS), secure password storage, and restricted access. However, no system is completely secure and we cannot guarantee absolute security.

9. Children’s Privacy
CAH is not intended for use by children under 18, and we do not knowingly collect personal data from minors. If you believe a child has provided us with personal information, contact us so we can delete it where required.

10. Changes to This Policy
We may update this Privacy Policy from time to time. We will post the new version in the app and update the “Last updated” date. You should review this Policy periodically. Continuing to use CAH after changes take effect means you accept the updated Policy.

11. Contact
For questions or requests about this Privacy Policy, contact us at:
Email: [your contact email]
Address: [your business address]''',
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}