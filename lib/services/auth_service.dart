import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/auth_service.dart';
import '../services/payment_api.dart';
import '../models/plan.dart';
import '../utils/routes.dart';

class BillingScreen extends StatefulWidget {
  const BillingScreen({super.key});

  @override
  State<BillingScreen> createState() => _BillingScreenState();
}

class _BillingScreenState extends State<BillingScreen> {
  bool _loading = true;
  bool _allowed = false;
  String? _reason;
  DateTime? _nextDue;

  @override
  void initState() {
    super.initState();
    _loadMaintenanceStatus();
  }

  Future<void> _loadMaintenanceStatus() async {
    final auth = Provider.of<AuthService>(context, listen: false);
    final token = await auth.getToken();
    final memberId = await auth.getMemberId();

    final result = await PaymentAPI.checkMaintenanceStatus(memberId!, token!);

    setState(() {
      _allowed = result.allowed;
      _reason = result.reason;
      _nextDue = result.nextDue;
      _loading = false;
    });
  }

  Future<void> _payMaintenance() async {
    final auth = Provider.of<AuthService>(context, listen: false);
    final token = await auth.getToken();
    final memberId = await auth.getMemberId();

    final paymentUrl = await PaymentAPI.startMaintenancePayment(memberId!, token!);

    Navigator.pushNamed(
      context,
      AppRoutes.payment,
      arguments: {
        'paymentUrl': paymentUrl,
        'plan': Plan(
          name: "Monthly Maintenance Fee",
          price: 500,
        ),
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Billing")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: ListTile(
                leading: Icon(
                  _allowed ? Icons.check_circle : Icons.error,
                  color: _allowed ? Colors.green : Colors.red,
                ),
                title: Text(
                  _allowed
                      ? "Maintenance Fee is Up to Date"
                      : "Maintenance Fee Required",
                ),
                subtitle: Text(
                  _allowed
                      ? "You can boost and support."
                      : _reason ?? "Please pay your monthly maintenance fee.",
                ),
              ),
            ),

            const SizedBox(height: 20),

            if (_nextDue != null)
              Card(
                child: ListTile(
                  leading: const Icon(Icons.calendar_month),
                  title: const Text("Next Maintenance Due"),
                  subtitle: Text(
                    "${_nextDue!.day}/${_nextDue!.month}/${_nextDue!.year}",
                  ),
                ),
              ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _payMaintenance,
                child: const Text("Pay Monthly Maintenance Fee (₦500)"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
