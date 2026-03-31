import 'dart:convert';
import 'package:http/http.dart' as http;

import '../utils/constants.dart';

class PaymentAPI {
  static Future<dynamic> checkMaintenanceStatus(
      int memberId, String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/member/maintenance-status/$memberId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    print("Maintenance API response: ${response.body}");

    final data = jsonDecode(response.body);

    return _MaintenanceStatus(
      allowed: data['allowed'],
      reason: data['reason'],
      nextDue:
          data['nextDue'] != null ? DateTime.parse(data['nextDue']) : null,
    );
  }

  static Future<String> startMaintenancePayment(
      int memberId, String token) async {
    final response = await http.post(
      Uri.parse('$baseUrl/payment/maintenance'),
      headers: {'Authorization': 'Bearer $token'},
    );

    print("Start Payment API response: ${response.body}");

    final data = jsonDecode(response.body);
    return data['paymentUrl'];
  }
}

class _MaintenanceStatus {
  final bool allowed;
  final String? reason;
  final DateTime? nextDue;

  _MaintenanceStatus({required this.allowed, this.reason, this.nextDue});
}
