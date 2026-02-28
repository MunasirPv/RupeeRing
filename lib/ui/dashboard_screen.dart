import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/transaction_provider.dart';
import '../models/transaction.dart';
import 'package:intl/intl.dart';
import 'settings_screen.dart';
import 'history_screen.dart';
import '../services/tts_service.dart';

class DashboardScreen extends ConsumerWidget {
  DashboardScreen({Key? key}) : super(key: key);

  final TTSService _ttsService = TTSService();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactions = ref.watch(transactionProvider);

    // Calculate today's total
    double todayTotal = 0;
    final now = DateTime.now();
    for (var tx in transactions) {
      if (tx.timestamp.year == now.year &&
          tx.timestamp.month == now.month &&
          tx.timestamp.day == now.day) {
        todayTotal += double.tryParse(tx.amount) ?? 0;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'AutoAlert Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue.shade900,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.blue.shade800,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
            ),
            child: Column(
              children: [
                const Text(
                  'Today\'s Collections',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  '₹${todayTotal.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recent Transactions',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const HistoryScreen(),
                      ),
                    );
                  },
                  child: const Text('View All'),
                ),
              ],
            ),
          ),
          Expanded(
            child: transactions.isEmpty
                ? const Center(
                    child: Text(
                      'Waiting for payments...',
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  )
                : ListView.builder(
                    itemCount: transactions.length,
                    itemBuilder: (context, index) {
                      final tx = transactions[index];
                      return _buildTransactionItem(tx);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(TransactionModel tx) {
    final timeStr = DateFormat('hh:mm a').format(tx.timestamp);
    final dateStr = DateFormat('MMM dd, yyyy').format(tx.timestamp);

    // Quick app name parser
    String appNameDisplay = 'UPI App';
    IconData appIcon = Icons.account_balance_wallet;
    Color iconColor = Colors.blue;

    if (tx.appName.contains('paytm')) {
      appNameDisplay = 'Paytm';
      appIcon = Icons
          .payment; // Material doesn't have a perfect match, fallback to payment
      iconColor = Colors.lightBlue;
    } else if (tx.appName.contains('phonepe')) {
      appNameDisplay = 'PhonePe';
      appIcon = Icons.phone_android;
      iconColor = Colors.purple;
    } else if (tx.appName.contains('paisa') || tx.appName.contains('google')) {
      appNameDisplay = 'Google Pay';
      appIcon = Icons.g_mobiledata;
      iconColor = Colors.green;
    } else if (tx.appName.contains('bhim') || tx.appName.contains('upiapp')) {
      appNameDisplay = 'BHIM UPI';
      appIcon = Icons.account_balance;
      iconColor = Colors.orange;
    } else if (tx.appName.contains('bharatpe')) {
      appNameDisplay = 'BharatPe';
      appIcon = Icons.storefront;
      iconColor = Colors.teal;
    } else if (tx.appName.contains('navi')) {
      appNameDisplay = 'Navi';
      appIcon = Icons.currency_rupee;
      iconColor = Colors.green.shade700;
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        onTap: () {
          _ttsService.speakPaymentReceived(tx.amount);
        },
        leading: CircleAvatar(
          backgroundColor: iconColor.withOpacity(0.2),
          child: Icon(appIcon, color: iconColor),
        ),
        title: Text(
          'Received via $appNameDisplay',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          '$dateStr • $timeStr',
          style: const TextStyle(color: Colors.grey, fontSize: 12),
        ),
        trailing: Text(
          '+ ₹${tx.amount}',
          style: const TextStyle(
            color: Colors.green,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
    );
  }
}
