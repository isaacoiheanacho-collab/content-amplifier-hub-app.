import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';

class PaymentAPI {
  // ---------------------------------------------------------
  // CHECK MAINTENANCE STATUS
  // GET /member/maintenance-status/:id
  // ---------------------------------------------------------
  static Future<MaintenanceStatus> checkMaintenanceStatus(
      int memberId, String token) async {
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
  // START REGISTRATION PAYMENT (YEARLY MEMBERSHIP)
  // POST /member/payment-url
  // ---------------------------------------------------------
  static Future<String> startRegistrationPayment(
      String token) async {
    final response = await http.post(
      Uri.parse('$baseUrl/member/payment-url'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json'
      },
    );

    print("Start Registration Payment API: ${response.statusCode}");

    if (response.statusCode != 200) {
      throw Exception('Payment init failed: ${response.body}');
    }

    final data = jsonDecode(response.body);

    if (data['paymentUrl'] == null) {
      throw Exception("Payment URL missing from response");
    }

    return data['paymentUrl'];
  }

  // ---------------------------------------------------------
  // START MAINTENANCE PAYMENT (MONTHLY)
  // POST /auth/payment/maintenance  → replaced with Stripe version
  // NEW ENDPOINT: POST /member/payment-maintenance
  // ---------------------------------------------------------
  static Future<String> startMaintenancePayment(
      String token) async {
    final response = await http.post(
      Uri.parse('$baseUrl/member/payment-maintenance'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json'
      },
    );

    print("Start Maintenance Payment API: ${response.statusCode}");

    if (response.statusCode != 200) {
      throw Exception('Maintenance payment init failed: ${response.body}');
    }

    final data = jsonDecode(response.body);

    if (data['paymentUrl'] == null) {
      throw Exception("Payment URL missing from response");
    }

    return data['paymentUrl'];
  }
}

// ---------------------------------------------------------
// MODEL
// ---------------------------------------------------------
class MaintenanceStatus {
  final bool allowed;
  final String? reason;
  final DateTime? nextDue;

  MaintenanceStatus({required this.allowed, this.reason, this.nextDue});
}
