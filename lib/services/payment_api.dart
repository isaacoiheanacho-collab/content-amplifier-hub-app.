import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';

class PaymentAPI {
  // ---------------------------------------------------------
  // CHECK MAINTENANCE STATUS
  // Hits: GET /member/maintenance-status/:id
  // ---------------------------------------------------------
  static Future<MaintenanceStatus> checkMaintenanceStatus(
      int memberId, String token) async {
    // We keep this under /member because it's a data retrieval task
    final response = await http.get(
      Uri.parse('$baseUrl/member/maintenance-status/$memberId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    print("Maintenance Status API: ${response.statusCode}");

    if (response.statusCode != 200) {
      throw Exception('Failed to load status: ${response.body}');
    }

    final data = jsonDecode(response.body);

    return MaintenanceStatus(
      allowed: data['allowed'] ?? false,
      reason: data['reason'],
      nextDue: data['nextDue'] != null ? DateTime.parse(data['nextDue']) : null,
    );
  }

  // ---------------------------------------------------------
  // START MAINTENANCE PAYMENT
  // Hits: POST /auth/payment/maintenance 
  // (Matches index.ts app.use('/auth', authRoutes))
  // ---------------------------------------------------------
  static Future<String> startMaintenancePayment(
      int memberId, String token) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/payment/maintenance'), // Added /auth prefix
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json'
      },
      body: jsonEncode({
        "memberId": memberId,
        "type": "maintenance",
      }),
    );

    print("Start Maintenance API: ${response.statusCode}");

    if (response.statusCode != 200) {
      throw Exception('Payment init failed: ${response.body}');
    }

    final data = jsonDecode(response.body);

    if (data['paymentUrl'] == null) {
      throw Exception("Payment URL missing from response");
    }

    return data['paymentUrl'];
  }
}

// Removed the underscore (_) so this class can be used in your BillingScreen
class MaintenanceStatus {
  final bool allowed;
  final String? reason;
  final DateTime? nextDue;

  MaintenanceStatus({required this.allowed, this.reason, this.nextDue});
}