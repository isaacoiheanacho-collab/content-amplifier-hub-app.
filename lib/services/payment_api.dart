import 'dart:convert';
import 'package:http/http.dart' as http;

import '../utils/constants.dart';

class PaymentAPI {
  // ---------------------------------------------------------
  // CHECK MAINTENANCE STATUS
  // ---------------------------------------------------------
  static Future<_MaintenanceStatus> checkMaintenanceStatus(
      int memberId, String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/member/maintenance-status/$memberId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    print("Maintenance API status: ${response.statusCode}");
    print("Maintenance API body: ${response.body}");

    if (response.statusCode != 200) {
      throw Exception(
          'Maintenance status failed: ${response.statusCode} ${response.body}');
    }

    final data = jsonDecode(response.body);

    return _MaintenanceStatus(
      allowed: data['allowed'] ?? false,
      reason: data['reason'],
      nextDue:
          data['nextDue'] != null ? DateTime.parse(data['nextDue']) : null,
    );
  }

  // ---------------------------------------------------------
  // START MAINTENANCE PAYMENT
  // ---------------------------------------------------------
  static Future<String> startMaintenancePayment(
      int memberId, String token) async {
    final response = await http.post(
      Uri.parse('$baseUrl/payment/maintenance'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json'
      },
      body: jsonEncode({
        "memberId": memberId,
        "type": "maintenance",
      }),
    );

    print("Start Payment API status: ${response.statusCode}");
    print("Start Payment API body: ${response.body}");

    if (response.statusCode != 200) {
      throw Exception(
          'Start payment failed: ${response.statusCode} ${response.body}');
    }

    final data = jsonDecode(response.body);

    if (data['paymentUrl'] == null) {
      throw Exception("Payment URL missing from backend");
    }

    return data['paymentUrl'];
  }
}

class _MaintenanceStatus {
  final bool allowed;
  final String? reason;
  final DateTime? nextDue;

  _MaintenanceStatus({required this.allowed, this.reason, this.nextDue});
}
