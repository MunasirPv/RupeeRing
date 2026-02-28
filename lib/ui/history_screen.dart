import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';
import '../services/database_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _selectedTimeFilter = 'All Time';
  String _selectedAppFilter = 'All';

  final List<String> _timeFilters = [
    'All Time',
    'Today',
    'Yesterday',
    'This Week',
    'This Month',
  ];

  final List<String> _appFilters = [
    'All',
    'PhonePe',
    'Paytm',
    'Google Pay',
    'BHIM UPI',
    'BharatPe',
    'Navi',
  ];

  List<TransactionModel> _transactions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFilteredTransactions();
  }

  Future<void> _loadFilteredTransactions() async {
    setState(() {
      _isLoading = true;
    });

    DateTime? startDate;
    DateTime? endDate;
    final now = DateTime.now();

    if (_selectedTimeFilter == 'Today') {
      startDate = DateTime(now.year, now.month, now.day);
      endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
    } else if (_selectedTimeFilter == 'Yesterday') {
      final yesterday = now.subtract(const Duration(days: 1));
      startDate = DateTime(yesterday.year, yesterday.month, yesterday.day);
      endDate = DateTime(
        yesterday.year,
        yesterday.month,
        yesterday.day,
        23,
        59,
        59,
      );
    } else if (_selectedTimeFilter == 'This Week') {
      final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
      startDate = DateTime(
        startOfWeek.year,
        startOfWeek.month,
        startOfWeek.day,
      );
      endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
    } else if (_selectedTimeFilter == 'This Month') {
      startDate = DateTime(now.year, now.month, 1);
      endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
    }

    String? appSearchString = _selectedAppFilter;
    if (_selectedAppFilter == 'Google Pay')
      appSearchString = 'paisa'; // or google
    if (_selectedAppFilter == 'PhonePe') appSearchString = 'phonepe';
    if (_selectedAppFilter == 'Paytm') appSearchString = 'paytm';
    if (_selectedAppFilter == 'BHIM UPI') appSearchString = 'npci';
    if (_selectedAppFilter == 'BharatPe') appSearchString = 'bharatpe';
    if (_selectedAppFilter == 'Navi') appSearchString = 'naviapp';

    final txs = await DatabaseService().getTransactions(
      limit: 500,
      filterApp: _selectedAppFilter == 'All' ? null : appSearchString,
      startDate: startDate,
      endDate: endDate,
    );

    setState(() {
      _transactions = txs;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction History'),
        backgroundColor: Colors.blue.shade900,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.blue.shade50,
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Time Period',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    value: _selectedTimeFilter,
                    items: _timeFilters.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      if (newValue != null) {
                        setState(() {
                          _selectedTimeFilter = newValue;
                        });
                        _loadFilteredTransactions();
                      }
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'UPI App',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    value: _selectedAppFilter,
                    items: _appFilters.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      if (newValue != null) {
                        setState(() {
                          _selectedAppFilter = newValue;
                        });
                        _loadFilteredTransactions();
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _transactions.isEmpty
                ? const Center(
                    child: Text(
                      'No transactions found for these filters.',
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  )
                : ListView.builder(
                    itemCount: _transactions.length,
                    itemBuilder: (context, index) {
                      final tx = _transactions[index];
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

    String appNameDisplay = 'UPI App';
    IconData appIcon = Icons.account_balance_wallet;
    Color iconColor = Colors.blue;

    if (tx.appName.contains('paytm')) {
      appNameDisplay = 'Paytm';
      appIcon = Icons.payment;
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
    } else if (tx.appName.contains('naviapp')) {
      appNameDisplay = 'Navi';
      appIcon = Icons.currency_rupee;
      iconColor = Colors.green.shade700;
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 1,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: iconColor.withValues(alpha: 0.2),
          child: Icon(appIcon, color: iconColor, size: 20),
        ),
        title: Text(
          'Received via $appNameDisplay',
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
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
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
