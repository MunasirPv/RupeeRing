import 'package:flutter_riverpod/legacy.dart';
import '../models/transaction.dart';
import '../services/database_service.dart';
import '../services/notification_service.dart';

final transactionProvider =
    StateNotifierProvider<TransactionNotifier, List<TransactionModel>>((ref) {
      return TransactionNotifier();
    });

class TransactionNotifier extends StateNotifier<List<TransactionModel>> {
  TransactionNotifier() : super([]) {
    loadTransactions();
    AppNotificationService().startListening(() {
      loadTransactions();
    });
  }

  Future<void> loadTransactions() async {
    final transactions = await DatabaseService().getTransactions();
    state = transactions;
  }
}
