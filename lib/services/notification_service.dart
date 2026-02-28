import 'package:notification_listener_service/notification_listener_service.dart';
import 'package:notification_listener_service/notification_event.dart';
import 'regex_parser.dart';
import 'tts_service.dart';
import 'database_service.dart';
import '../models/transaction.dart';

class AppNotificationService {
  static final AppNotificationService _instance =
      AppNotificationService._internal();
  factory AppNotificationService() => _instance;
  AppNotificationService._internal();

  final TTSService _ttsService = TTSService();
  bool _isListening = false;
  Function()? onNewTransaction;

  void startListening(Function() onRefresh) {
    onNewTransaction = onRefresh;
    if (_isListening) return;

    NotificationListenerService.notificationsStream.listen((
      ServiceNotificationEvent event,
    ) async {
      if (event.hasRemoved == true) return; // Skip dismissed notifications

      final String? packageName = event.packageName;

      if (!NotificationParser.isTargetApp(packageName)) return;

      final String? amount = NotificationParser.extractReceivedAmount(
        event.title,
        event.content,
      );

      if (amount != null) {
        await _ttsService.speakPaymentReceived(amount);

        await DatabaseService().insertTransaction(
          TransactionModel(
            appName: packageName ?? 'Unknown',
            amount: amount,
            timestamp: DateTime.now(),
          ),
        );
        onNewTransaction?.call();
      }
    });

    _isListening = true;
  }
}
