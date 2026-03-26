import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../utils/theme.dart';
import '../models/plan.dart';

class PaymentScreen extends StatefulWidget {
  final String paymentUrl;
  final Plan plan;

  const PaymentScreen({super.key, required this.paymentUrl, required this.plan});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  late WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            setState(() => _isLoading = true);
          },
          onPageFinished: (url) {
            setState(() => _isLoading = false);
            if (url.contains('/auth/payment/callback')) {
              // Payment completed, navigate to home
              Navigator.pushReplacementNamed(context, '/home');
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.paymentUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Complete Payment')),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.card,
              border: Border(bottom: BorderSide(color: AppColors.border)),
            ),
            child: Row(
              children: [
                Icon(Icons.credit_card, color: AppColors.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.plan.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${widget.plan.price} NGN/year',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                WebViewWidget(controller: _controller),
                if (_isLoading)
                  const Center(child: CircularProgressIndicator()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}